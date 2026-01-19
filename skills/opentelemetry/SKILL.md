---
name: opentelemetry
description: OpenTelemetry instrumentation for traces, metrics, and logs. Use when adding observability, distributed tracing, or exporting telemetry to backends. Triggers on "OpenTelemetry", "OTel", "tracing", "spans", "OTLP", "distributed tracing".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# OpenTelemetry

Vendor-neutral observability framework for traces, metrics, and logs.

## Installation

```bash
# Core SDK
npm install @opentelemetry/sdk-node
npm install @opentelemetry/api

# Auto-instrumentation
npm install @opentelemetry/auto-instrumentations-node

# Exporters (choose based on backend)
npm install @opentelemetry/exporter-trace-otlp-proto
npm install @opentelemetry/exporter-metrics-otlp-proto
npm install @opentelemetry/exporter-logs-otlp-proto

# For gRPC transport
npm install @opentelemetry/exporter-trace-otlp-grpc
```

---

## Quick Setup

### Node.js SDK

```typescript
// instrumentation.ts - Run BEFORE other imports
import { NodeSDK } from '@opentelemetry/sdk-node'
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node'
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto'
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-proto'
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics'
import { resourceFromAttributes } from '@opentelemetry/resources'
import { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } from '@opentelemetry/semantic-conventions'

const sdk = new NodeSDK({
  resource: resourceFromAttributes({
    [ATTR_SERVICE_NAME]: 'my-service',
    [ATTR_SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
    headers: {
      Authorization: `Bearer ${process.env.OTEL_AUTH_TOKEN}`,
    },
  }),
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({
      url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/metrics',
    }),
  }),
  instrumentations: [getNodeAutoInstrumentations()],
})

sdk.start()

// Graceful shutdown
process.on('SIGTERM', () => sdk.shutdown())
```

### Load Before App

```bash
# Option 1: --require flag
node --require ./instrumentation.js app.js

# Option 2: --import flag (ESM)
node --import ./instrumentation.js app.js
```

---

## Manual Spans

See `rules/spans.md` for detailed patterns.

### Create Spans

```typescript
import { trace, SpanStatusCode } from '@opentelemetry/api'

const tracer = trace.getTracer('my-service', '1.0.0')

// Active span (recommended)
function processOrder(orderId: string) {
  return tracer.startActiveSpan('processOrder', (span) => {
    try {
      span.setAttribute('order.id', orderId)

      const result = doWork()

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
async function fetchData(url: string) {
  return tracer.startActiveSpan('fetchData', async (span) => {
    try {
      span.setAttribute('http.url', url)
      const response = await fetch(url)
      span.setAttribute('http.status_code', response.status)
      return response.json()
    } finally {
      span.end()
    }
  })
}
```

### Span Attributes

```typescript
span.setAttribute('user.id', userId)
span.setAttribute('order.total', 99.99)
span.setAttribute('order.items', 3)
span.setAttribute('feature.enabled', true)

// Multiple at once
span.setAttributes({
  'user.id': userId,
  'order.id': orderId,
  'order.total': total,
})
```

### Span Events

```typescript
// Add event (point in time within span)
span.addEvent('order.validated')

span.addEvent('payment.processed', {
  'payment.method': 'card',
  'payment.amount': 99.99,
})
```

---

## Context Propagation

See `rules/context.md` for detailed patterns.

### Automatic (HTTP)

Auto-instrumentation handles propagation for HTTP requests automatically.

### Manual Injection

```typescript
import { context, propagation } from '@opentelemetry/api'

// Inject into outgoing request
const headers: Record<string, string> = {}
propagation.inject(context.active(), headers)

await fetch('https://api.example.com', {
  headers: {
    ...headers,
    'Content-Type': 'application/json',
  },
})
```

### Manual Extraction

```typescript
import { context, propagation, trace } from '@opentelemetry/api'

// Extract from incoming request
const ctx = propagation.extract(context.active(), request.headers)

// Use extracted context
context.with(ctx, () => {
  const span = tracer.startSpan('handleRequest')
  // ... span is now a child of the extracted context
  span.end()
})
```

---

## Exporters

### OTLP (Protocol Buffer)

```typescript
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-proto'

new OTLPTraceExporter({
  url: 'https://otlp.example.com/v1/traces',
  headers: {
    Authorization: 'Bearer token',
    'X-Custom-Header': 'value',
  },
})
```

### To Axiom

```typescript
new OTLPTraceExporter({
  url: 'https://api.axiom.co/v1/traces',
  headers: {
    Authorization: `Bearer ${process.env.AXIOM_TOKEN}`,
    'X-Axiom-Dataset': process.env.AXIOM_DATASET,
  },
})
```

### To Grafana Cloud

```typescript
new OTLPTraceExporter({
  url: 'https://otlp-gateway-prod-us-central-0.grafana.net/otlp/v1/traces',
  headers: {
    Authorization: `Basic ${Buffer.from(`${instanceId}:${token}`).toString('base64')}`,
  },
})
```

---

## Environment Variables

```bash
# Endpoint
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318

# Service info
OTEL_SERVICE_NAME=my-service
OTEL_SERVICE_VERSION=1.0.0

# Sampling
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1  # 10% sampling

# Headers
OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer token,X-Custom=value"
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| SDK not loaded first | Use `--require` or `--import` flag |
| Missing `span.end()` | Always call `span.end()` in finally block |
| Not handling errors | Use `span.recordException()` and `setStatus(ERROR)` |
| Forgetting shutdown | Call `sdk.shutdown()` on SIGTERM |
| Wrong exporter URL | Check `/v1/traces` vs `/v1/metrics` paths |

---

## Quick Reference

| Concept | Code |
|---------|------|
| Get tracer | `trace.getTracer('name')` |
| Start span | `tracer.startActiveSpan('name', (span) => {})` |
| Set attribute | `span.setAttribute('key', 'value')` |
| Add event | `span.addEvent('name', { attrs })` |
| Record error | `span.recordException(error)` |
| Set status | `span.setStatus({ code: SpanStatusCode.ERROR })` |
| End span | `span.end()` |
| Inject context | `propagation.inject(context.active(), headers)` |
| Extract context | `propagation.extract(context.active(), headers)` |
