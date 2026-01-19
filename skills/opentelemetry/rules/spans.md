---
title: OpenTelemetry Span Patterns
impact: CRITICAL
impactDescription: Manual instrumentation for custom spans
tags: opentelemetry, spans, tracing, instrumentation
---

## OpenTelemetry Span Patterns

### Basic Span Creation

```typescript
import { trace, SpanStatusCode, SpanKind } from '@opentelemetry/api'

const tracer = trace.getTracer('my-service', '1.0.0')

// Synchronous span
function processItem(item: Item) {
  return tracer.startActiveSpan('processItem', (span) => {
    try {
      span.setAttribute('item.id', item.id)
      const result = doProcessing(item)
      span.setStatus({ code: SpanStatusCode.OK })
      return result
    } catch (error) {
      span.recordException(error)
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message })
      throw error
    } finally {
      span.end()
    }
  })
}

// Async span
async function fetchUser(userId: string) {
  return tracer.startActiveSpan('fetchUser', async (span) => {
    try {
      span.setAttribute('user.id', userId)

      const user = await db.users.findById(userId)

      if (!user) {
        span.setStatus({ code: SpanStatusCode.ERROR, message: 'User not found' })
        return null
      }

      span.setStatus({ code: SpanStatusCode.OK })
      return user
    } catch (error) {
      span.recordException(error)
      span.setStatus({ code: SpanStatusCode.ERROR })
      throw error
    } finally {
      span.end()
    }
  })
}
```

### Span with Options

```typescript
tracer.startActiveSpan(
  'httpRequest',
  {
    kind: SpanKind.CLIENT,  // CLIENT, SERVER, PRODUCER, CONSUMER, INTERNAL
    attributes: {
      'http.method': 'POST',
      'http.url': url,
    },
  },
  (span) => {
    // ...
    span.end()
  }
)
```

### Nested Spans

```typescript
async function processOrder(orderId: string) {
  return tracer.startActiveSpan('processOrder', async (orderSpan) => {
    try {
      orderSpan.setAttribute('order.id', orderId)

      // Child span 1
      const items = await tracer.startActiveSpan('validateItems', async (span) => {
        const result = await validateOrderItems(orderId)
        span.setAttribute('items.count', result.length)
        span.end()
        return result
      })

      // Child span 2
      const payment = await tracer.startActiveSpan('processPayment', async (span) => {
        span.setAttribute('payment.method', 'card')
        const result = await chargeCustomer(orderId)
        span.setAttribute('payment.status', result.status)
        span.end()
        return result
      })

      // Child span 3
      await tracer.startActiveSpan('sendConfirmation', async (span) => {
        await sendEmail(orderId)
        span.end()
      })

      orderSpan.setStatus({ code: SpanStatusCode.OK })
      return { items, payment }
    } catch (error) {
      orderSpan.recordException(error)
      orderSpan.setStatus({ code: SpanStatusCode.ERROR })
      throw error
    } finally {
      orderSpan.end()
    }
  })
}
```

---

## Span Attributes

### Semantic Conventions

```typescript
import {
  ATTR_HTTP_REQUEST_METHOD,
  ATTR_HTTP_RESPONSE_STATUS_CODE,
  ATTR_URL_FULL,
  ATTR_USER_AGENT_ORIGINAL,
  ATTR_DB_SYSTEM,
  ATTR_DB_STATEMENT,
  ATTR_MESSAGING_SYSTEM,
} from '@opentelemetry/semantic-conventions'

span.setAttribute(ATTR_HTTP_REQUEST_METHOD, 'POST')
span.setAttribute(ATTR_HTTP_RESPONSE_STATUS_CODE, 200)
span.setAttribute(ATTR_URL_FULL, 'https://api.example.com/users')
```

### Custom Attributes

```typescript
// String
span.setAttribute('user.id', 'user-123')
span.setAttribute('order.status', 'pending')

// Number
span.setAttribute('order.total', 99.99)
span.setAttribute('items.count', 3)
span.setAttribute('retry.attempt', 2)

// Boolean
span.setAttribute('cache.hit', true)
span.setAttribute('user.premium', false)

// Array of strings
span.setAttribute('tags', ['urgent', 'vip'])

// Batch attributes
span.setAttributes({
  'user.id': userId,
  'user.email_domain': emailDomain,
  'user.subscription': 'premium',
})
```

---

## Span Events

```typescript
// Simple event
span.addEvent('cache.miss')

// Event with attributes
span.addEvent('item.processed', {
  'item.id': item.id,
  'processing.duration_ms': duration,
})

// Event with timestamp
span.addEvent('retry.scheduled', { 'retry.delay_ms': 1000 }, Date.now())

// Multiple events in a span
span.addEvent('validation.started')
// ... validation logic ...
span.addEvent('validation.completed', { 'validation.errors': 0 })
```

---

## Error Handling

```typescript
import { SpanStatusCode } from '@opentelemetry/api'

// Record exception with status
try {
  await riskyOperation()
  span.setStatus({ code: SpanStatusCode.OK })
} catch (error) {
  // Record the exception (adds event with stack trace)
  span.recordException(error)

  // Set error status
  span.setStatus({
    code: SpanStatusCode.ERROR,
    message: error.message,
  })

  // Add custom error attributes
  span.setAttribute('error.type', error.name)
  span.setAttribute('error.retriable', error.retriable ?? false)

  throw error
}

// Partial success
span.setStatus({
  code: SpanStatusCode.OK,  // or UNSET for partial success
  message: '3 of 5 items processed',
})
```

---

## Span Kinds

```typescript
import { SpanKind } from '@opentelemetry/api'

// SERVER - Handling incoming request
tracer.startActiveSpan('handleRequest', { kind: SpanKind.SERVER }, (span) => {
  // Handle HTTP request, gRPC call, etc.
})

// CLIENT - Making outgoing request
tracer.startActiveSpan('fetchData', { kind: SpanKind.CLIENT }, (span) => {
  // HTTP client, database client, etc.
})

// PRODUCER - Producing message
tracer.startActiveSpan('publishEvent', { kind: SpanKind.PRODUCER }, (span) => {
  // Kafka producer, SQS, etc.
})

// CONSUMER - Consuming message
tracer.startActiveSpan('processMessage', { kind: SpanKind.CONSUMER }, (span) => {
  // Kafka consumer, SQS handler, etc.
})

// INTERNAL - Internal operation (default)
tracer.startActiveSpan('computeTotal', { kind: SpanKind.INTERNAL }, (span) => {
  // Internal business logic
})
```

---

## Getting Current Span

```typescript
import { trace } from '@opentelemetry/api'

// Get active span from context
const currentSpan = trace.getActiveSpan()

if (currentSpan) {
  currentSpan.setAttribute('late.attribute', 'value')
  currentSpan.addEvent('late.event')
}

// In middleware or utility functions
function logWithTrace(message: string) {
  const span = trace.getActiveSpan()
  console.log({
    message,
    traceId: span?.spanContext().traceId,
    spanId: span?.spanContext().spanId,
  })
}
```

---

## Span Links

```typescript
// Link to related spans (e.g., batch processing)
const links = items.map(item => ({
  context: item.spanContext,
  attributes: { 'item.id': item.id },
}))

tracer.startActiveSpan('processBatch', { links }, (span) => {
  // Process items, linked to their individual spans
  span.end()
})
```
