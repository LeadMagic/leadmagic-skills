---
name: cloudflare-observability
description: Cloudflare Workers observability with logs, traces, Logpush, and OTel export. Use when setting up logging, tracing, or exporting telemetry from Workers. Triggers on "Workers logs", "Logpush", "wrangler tail", "Workers tracing", "OTel export".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Cloudflare Observability

Logging, tracing, and telemetry export for Cloudflare Workers.

## Workers Logs

### Enable in wrangler.toml

```toml
[observability]
enabled = true
head_sampling_rate = 1  # 0-1, default 1 (100%)
```

### Using console

```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    console.log('Request received', { url: request.url })
    console.info('Processing', { method: request.method })
    console.warn('Slow operation detected')
    console.error('Something failed', { error: 'details' })

    return new Response('OK')
  },
}
```

Logs appear in:
- `wrangler tail` (real-time)
- Workers Logs in dashboard
- Logpush destinations

---

## Real-Time Logs (wrangler tail)

```bash
# Stream logs from deployed Worker
npx wrangler tail

# With filters
npx wrangler tail --status error
npx wrangler tail --method POST
npx wrangler tail --search "payment"

# JSON output for piping
npx wrangler tail --format json | jq '.logs[]'

# Specific Worker
npx wrangler tail my-worker-name
```

### Output Format

```json
{
  "outcome": "ok",
  "scriptName": "my-worker",
  "exceptions": [],
  "logs": [
    {
      "message": ["Request received", { "url": "https://..." }],
      "level": "log",
      "timestamp": 1705312345678
    }
  ],
  "eventTimestamp": 1705312345678,
  "event": {
    "request": {
      "url": "https://example.com/api",
      "method": "GET"
    }
  }
}
```

---

## Logpush

Push Worker logs to external destinations (R2, S3, Datadog, Splunk, etc.).

### Create Logpush Job (API)

```bash
curl "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/logpush/jobs" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "workers-logpush",
    "output_options": {
      "field_names": [
        "Event",
        "EventTimestampMs",
        "Outcome",
        "Exceptions",
        "Logs",
        "ScriptName",
        "ScriptVersion"
      ]
    },
    "destination_conf": "r2://my-bucket/logs/{DATE}?account-id='$ACCOUNT_ID'",
    "dataset": "workers_trace_events",
    "enabled": true
  }'
```

### To R2

```bash
# Destination format
"r2://bucket-name/path/{DATE}?account-id=ACCOUNT_ID&access-key-id=R2_KEY&secret-access-key=R2_SECRET"
```

### With Filters

```bash
# Only push errors
"filter": "{\"where\": {\"key\":\"Outcome\",\"operator\":\"eq\",\"value\":\"exception\"}}"

# Exclude certain scripts
"filter": "{\"where\": {\"key\":\"ScriptName\",\"operator\":\"!eq\",\"value\":\"health-check\"}}"
```

### Available Fields

| Field | Description |
|-------|-------------|
| `Event` | Event type (fetch, scheduled, etc.) |
| `EventTimestampMs` | Unix timestamp in ms |
| `Outcome` | ok, exception, canceled |
| `Exceptions` | Array of exception details |
| `Logs` | Console.log output |
| `ScriptName` | Worker name |
| `ScriptVersion` | Deployment version |

---

## OpenTelemetry Export

Export traces and logs to OTel-compatible backends.

### Configure in wrangler.toml

```toml
[observability]
enabled = true

[observability.traces]
enabled = true
head_sampling_rate = 0.1  # 10% of traces
persist = true             # Also keep in CF dashboard

[observability.logs]
enabled = true
head_sampling_rate = 1.0   # 100% of logs
persist = true
```

### Configure Destinations (Dashboard)

1. Go to **Workers & Pages** → **Settings** → **Observability**
2. Add **Trace destination** or **Log destination**
3. Configure OTLP endpoint and authentication

### wrangler.toml with Destinations

```toml
[observability.traces]
enabled = true
destinations = ["axiom-traces"]  # Match dashboard name

[observability.logs]
enabled = true
destinations = ["axiom-logs"]
```

---

## Export to Specific Backends

### Axiom

```toml
[observability.traces]
enabled = true
destinations = ["axiom-traces"]

[observability.logs]
enabled = true
destinations = ["axiom-logs"]
```

Dashboard config:
- Endpoint: `https://api.axiom.co/v1/traces`
- Headers: `Authorization: Bearer $AXIOM_TOKEN`, `X-Axiom-Dataset: $DATASET`

### Grafana Cloud

```toml
[observability.traces]
enabled = true
destinations = ["grafana-traces"]

[observability.logs]
enabled = true
destinations = ["grafana-logs"]
```

### Honeycomb

```toml
[observability.traces]
enabled = true
destinations = ["honeycomb-traces"]

[observability.logs]
enabled = true
destinations = ["honeycomb-logs"]
```

### Sentry

```toml
[observability.traces]
enabled = true
destinations = ["sentry-traces"]

[observability.logs]
enabled = true
destinations = ["sentry-logs"]
```

---

## Manual OTel Instrumentation

Use `@microlabs/otel-cf-workers` for custom spans.

### Installation

```bash
npm install @microlabs/otel-cf-workers @opentelemetry/api
```

### Setup

```typescript
// src/index.ts
import { trace } from '@opentelemetry/api'
import { instrument, ResolveConfigFn } from '@microlabs/otel-cf-workers'

export interface Env {
  AXIOM_API_TOKEN: string
  AXIOM_DATASET: string
}

const handler = {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // Add custom span attribute
    trace.getActiveSpan()?.setAttribute('custom.field', 'value')

    // Create child span
    const tracer = trace.getTracer('my-worker')
    return tracer.startActiveSpan('processRequest', async (span) => {
      try {
        const result = await doWork()
        span.setAttribute('result.status', 'success')
        return new Response(JSON.stringify(result))
      } finally {
        span.end()
      }
    })
  },
}

const config: ResolveConfigFn = (env: Env) => ({
  exporter: {
    url: 'https://api.axiom.co/v1/traces',
    headers: {
      Authorization: `Bearer ${env.AXIOM_API_TOKEN}`,
      'X-Axiom-Dataset': env.AXIOM_DATASET,
    },
  },
  service: { name: 'my-worker' },
})

export default instrument(handler, config)
```

---

## Structured Logging Pattern

```typescript
interface LogEntry {
  timestamp: string
  level: 'info' | 'warn' | 'error'
  message: string
  request_id: string
  [key: string]: unknown
}

function log(entry: Omit<LogEntry, 'timestamp'>) {
  console.log(JSON.stringify({
    ...entry,
    timestamp: new Date().toISOString(),
  }))
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const requestId = crypto.randomUUID()
    const start = Date.now()

    log({
      level: 'info',
      message: 'Request received',
      request_id: requestId,
      method: request.method,
      url: request.url,
    })

    try {
      const response = await handleRequest(request, env)

      log({
        level: 'info',
        message: 'Request completed',
        request_id: requestId,
        status: response.status,
        duration_ms: Date.now() - start,
      })

      return response
    } catch (error) {
      log({
        level: 'error',
        message: 'Request failed',
        request_id: requestId,
        error: error.message,
        duration_ms: Date.now() - start,
      })
      throw error
    }
  },
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Logs not appearing | Enable `[observability]` in wrangler.toml |
| Missing in Logpush | Check dataset is `workers_trace_events` |
| OTel not exporting | Configure destinations in dashboard first |
| Sampling too low | Increase `head_sampling_rate` for debugging |
| No request context | Use `ctx.waitUntil()` for async logging |

---

## Quick Reference

| Task | Config/Command |
|------|----------------|
| Enable logs | `[observability] enabled = true` |
| Real-time tail | `npx wrangler tail` |
| Logpush to R2 | Create job via API |
| OTel traces | `[observability.traces] enabled = true` |
| Custom spans | `@microlabs/otel-cf-workers` |
| Sampling | `head_sampling_rate = 0.1` |
