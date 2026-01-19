---
title: OpenTelemetry Context Propagation
impact: HIGH
impactDescription: Distributed tracing across services
tags: opentelemetry, context, propagation, distributed-tracing
---

## OpenTelemetry Context Propagation

Context propagation enables distributed tracing by passing trace context between services.

### W3C Trace Context

The standard format for trace context headers:

```
traceparent: 00-{trace-id}-{span-id}-{flags}
tracestate: vendor1=value1,vendor2=value2
```

Example:
```
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

---

## Automatic Propagation

Auto-instrumentation handles propagation for HTTP requests:

```typescript
// Outgoing requests automatically get headers injected
const response = await fetch('https://api.example.com/users')

// Incoming requests automatically extract context
// Child spans are automatically linked to parent
```

---

## Manual Injection

### Into HTTP Headers

```typescript
import { context, propagation } from '@opentelemetry/api'

async function makeRequest(url: string, body: unknown) {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  }

  // Inject current context into headers
  propagation.inject(context.active(), headers)

  return fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  })
}
```

### Into Custom Carrier

```typescript
// For message queues, custom protocols, etc.
const carrier: Record<string, string> = {}

propagation.inject(context.active(), carrier, {
  set: (carrier, key, value) => {
    carrier[key] = value
  },
})

// Send carrier with message
await queue.send({
  body: messageBody,
  attributes: carrier,
})
```

---

## Manual Extraction

### From HTTP Headers

```typescript
import { context, propagation, trace } from '@opentelemetry/api'

function handleRequest(request: Request) {
  // Extract context from incoming headers
  const extractedContext = propagation.extract(
    context.active(),
    Object.fromEntries(request.headers)
  )

  // Run code within extracted context
  return context.with(extractedContext, () => {
    const tracer = trace.getTracer('my-service')

    return tracer.startActiveSpan('handleRequest', (span) => {
      try {
        // This span is now a child of the extracted context
        return processRequest(request)
      } finally {
        span.end()
      }
    })
  })
}
```

### From Custom Carrier

```typescript
// For message queues
function handleMessage(message: QueueMessage) {
  const extractedContext = propagation.extract(
    context.active(),
    message.attributes,
    {
      get: (carrier, key) => carrier[key],
      keys: (carrier) => Object.keys(carrier),
    }
  )

  return context.with(extractedContext, () => {
    return tracer.startActiveSpan('processMessage', (span) => {
      span.setAttribute('message.id', message.id)
      // Process message...
      span.end()
    })
  })
}
```

---

## Baggage

Baggage carries key-value pairs across service boundaries.

### Set Baggage

```typescript
import { context, propagation } from '@opentelemetry/api'

// Set baggage in current context
const baggage = propagation.createBaggage({
  'user.id': { value: 'user-123' },
  'tenant.id': { value: 'tenant-456' },
})

const newContext = propagation.setBaggage(context.active(), baggage)

// Run with baggage context
context.with(newContext, () => {
  // Baggage is propagated to downstream services
  await fetch('https://api.example.com/endpoint')
})
```

### Read Baggage

```typescript
import { propagation, context } from '@opentelemetry/api'

const baggage = propagation.getBaggage(context.active())

if (baggage) {
  const userId = baggage.getEntry('user.id')?.value
  const tenantId = baggage.getEntry('tenant.id')?.value

  span.setAttribute('user.id', userId)
  span.setAttribute('tenant.id', tenantId)
}
```

---

## Cross-Service Example

### Service A (API Gateway)

```typescript
app.post('/orders', async (req, res) => {
  return tracer.startActiveSpan('createOrder', async (span) => {
    span.setAttribute('order.items', req.body.items.length)

    // Call payment service - context automatically propagated
    const payment = await fetch('http://payment-service/charge', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount: req.body.total }),
    })

    // Call inventory service
    const inventory = await fetch('http://inventory-service/reserve', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items: req.body.items }),
    })

    span.end()
    return res.json({ orderId: '123' })
  })
})
```

### Service B (Payment Service)

```typescript
// Context is automatically extracted from incoming request
// This span becomes a child of Service A's span
app.post('/charge', async (req, res) => {
  return tracer.startActiveSpan('processPayment', async (span) => {
    span.setAttribute('payment.amount', req.body.amount)

    const result = await stripe.charges.create({
      amount: req.body.amount,
    })

    span.setAttribute('payment.status', result.status)
    span.end()
    return res.json(result)
  })
})
```

---

## Manual Context with Async Operations

```typescript
import { context, trace } from '@opentelemetry/api'

// Capture current context
const currentContext = context.active()

// Use in callback or async operation
setTimeout(() => {
  context.with(currentContext, () => {
    // Spans created here will be children of the original context
    tracer.startActiveSpan('delayedOperation', (span) => {
      // ...
      span.end()
    })
  })
}, 1000)

// Use in Promise.all
const ctx = context.active()
await Promise.all(
  items.map(item =>
    context.with(ctx, () =>
      tracer.startActiveSpan(`process:${item.id}`, async (span) => {
        await processItem(item)
        span.end()
      })
    )
  )
)
```
