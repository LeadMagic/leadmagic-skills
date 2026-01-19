---
title: Cloudflare Workers OTel Export
impact: HIGH
impactDescription: Export traces and logs via OpenTelemetry
tags: cloudflare, opentelemetry, traces, export
---

## Cloudflare Workers OTel Export

Export Workers traces and logs to OpenTelemetry-compatible backends.

### Configuration

```toml
# wrangler.toml

[observability]
enabled = true

[observability.traces]
enabled = true
head_sampling_rate = 0.1  # 10% sampling
persist = true            # Keep in CF dashboard too

[observability.logs]
enabled = true
head_sampling_rate = 1.0  # 100% of logs
persist = true
```

### With Destinations

```toml
[observability.traces]
enabled = true
destinations = ["my-trace-destination"]  # Name from dashboard

[observability.logs]
enabled = true
destinations = ["my-logs-destination"]
```

---

## Dashboard Setup

1. Navigate to **Workers & Pages** → **Settings** → **Observability**
2. Click **Add destination**
3. Select destination type (Axiom, Grafana, Honeycomb, etc.)
4. Configure endpoint and authentication
5. Name the destination (use in wrangler.toml)

---

## Backend-Specific Configs

### Axiom

**Dashboard settings:**
- Type: Custom OTLP
- Traces endpoint: `https://api.axiom.co/v1/traces`
- Logs endpoint: `https://api.axiom.co/v1/logs`
- Headers:
  - `Authorization: Bearer <AXIOM_TOKEN>`
  - `X-Axiom-Dataset: <DATASET_NAME>`

```toml
[observability.traces]
enabled = true
destinations = ["axiom-traces"]

[observability.logs]
enabled = true
destinations = ["axiom-logs"]
```

### Grafana Cloud

**Dashboard settings:**
- Type: Grafana Cloud
- Instance ID: Your Grafana Cloud instance
- API Key: Grafana Cloud API key

```toml
[observability.traces]
enabled = true
destinations = ["grafana-traces"]

[observability.logs]
enabled = true
destinations = ["grafana-logs"]
```

### Honeycomb

**Dashboard settings:**
- Type: Honeycomb
- API Key: Honeycomb API key
- Dataset: Your dataset name

```toml
[observability.traces]
enabled = true
destinations = ["honeycomb-traces"]

[observability.logs]
enabled = true
destinations = ["honeycomb-logs"]
```

### New Relic

**Dashboard settings:**
- Type: Custom OTLP
- Endpoint: `https://otlp.nr-data.net:4318/v1/traces`
- Headers:
  - `Api-Key: <NEW_RELIC_LICENSE_KEY>`

### Datadog

**Dashboard settings:**
- Type: Datadog
- API Key: Datadog API key
- Site: datadoghq.com (or regional endpoint)

---

## Manual Instrumentation

For custom spans beyond automatic instrumentation.

### Installation

```bash
npm install @microlabs/otel-cf-workers @opentelemetry/api
```

### Basic Setup

```typescript
import { trace } from '@opentelemetry/api'
import { instrument, ResolveConfigFn } from '@microlabs/otel-cf-workers'

interface Env {
  OTEL_ENDPOINT: string
  OTEL_TOKEN: string
}

const handler = {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const tracer = trace.getTracer('my-worker')

    return tracer.startActiveSpan('handleRequest', async (span) => {
      span.setAttribute('http.url', request.url)
      span.setAttribute('http.method', request.method)

      try {
        const result = await processRequest(request)
        span.setAttribute('http.status_code', 200)
        return new Response(JSON.stringify(result))
      } catch (error) {
        span.setAttribute('http.status_code', 500)
        span.recordException(error)
        throw error
      } finally {
        span.end()
      }
    })
  },
}

const config: ResolveConfigFn = (env: Env) => ({
  exporter: {
    url: env.OTEL_ENDPOINT,
    headers: {
      Authorization: `Bearer ${env.OTEL_TOKEN}`,
    },
  },
  service: {
    name: 'my-worker',
    version: '1.0.0',
  },
})

export default instrument(handler, config)
```

### Add Custom Attributes

```typescript
const span = trace.getActiveSpan()
if (span) {
  span.setAttribute('user.id', userId)
  span.setAttribute('order.total', orderTotal)
  span.setAttribute('feature.enabled', featureFlag)
}
```

### Create Child Spans

```typescript
async function processOrder(orderId: string) {
  const tracer = trace.getTracer('my-worker')

  return tracer.startActiveSpan('processOrder', async (span) => {
    span.setAttribute('order.id', orderId)

    // Child span for payment
    await tracer.startActiveSpan('chargePayment', async (paymentSpan) => {
      await chargeCard(orderId)
      paymentSpan.end()
    })

    // Child span for fulfillment
    await tracer.startActiveSpan('fulfillOrder', async (fulfillSpan) => {
      await createShipment(orderId)
      fulfillSpan.end()
    })

    span.end()
  })
}
```

---

## Sampling Strategies

### Head Sampling (Default)

Decision made at request start:

```toml
[observability.traces]
head_sampling_rate = 0.1  # 10%
```

### Conditional Sampling

Sample everything for errors, sample for success:

```typescript
const handler = {
  async fetch(request, env, ctx) {
    try {
      return await handleRequest(request)
    } catch (error) {
      // Force this trace to be sampled
      trace.getActiveSpan()?.setAttribute('sampling.priority', 1)
      throw error
    }
  },
}
```

---

## Best Practices

1. **Start with high sampling** - 100% during development
2. **Lower in production** - 1-10% for high traffic
3. **Always sample errors** - Use conditional sampling
4. **Use semantic conventions** - Standard attribute names
5. **Keep persist enabled** - For CF dashboard debugging
6. **Name destinations clearly** - Match wrangler.toml names
