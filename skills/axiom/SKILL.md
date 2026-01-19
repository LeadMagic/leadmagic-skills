---
name: axiom
description: Axiom observability platform for logs, traces, and metrics. Use when sending logs to Axiom, querying with APL, or integrating with Next.js/Cloudflare Workers. Triggers on "Axiom", "APL", "observability platform", "log analytics".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Axiom

Cloud-native observability platform for logs, traces, and metrics.

## Installation

```bash
# Core SDK
npm install @axiomhq/js

# Logger transports
npm install @axiomhq/pino    # For Pino
npm install @axiomhq/winston # For Winston

# Framework integrations
npm install @axiomhq/nextjs  # For Next.js
```

## Environment Variables

```bash
AXIOM_TOKEN=xaat-xxx          # API token
AXIOM_DATASET=my-logs         # Dataset name
AXIOM_ORG_ID=my-org           # Organization ID (optional)
```

---

## Quick Start

### Direct Ingestion

```typescript
import { Axiom } from '@axiomhq/js'

const axiom = new Axiom({ token: process.env.AXIOM_TOKEN! })

// Ingest events
await axiom.ingest('my-dataset', [
  { timestamp: new Date().toISOString(), level: 'info', message: 'Hello' },
  { timestamp: new Date().toISOString(), level: 'error', message: 'Failed' },
])

// Flush before exit
await axiom.flush()
```

### Pino Transport

```typescript
import pino from 'pino'

const logger = pino(
  { level: 'info' },
  pino.transport({
    target: '@axiomhq/pino',
    options: {
      dataset: process.env.AXIOM_DATASET,
      token: process.env.AXIOM_TOKEN,
    },
  })
)

logger.info({ userId: '123', action: 'login' }, 'User logged in')
logger.error({ err: new Error('Timeout') }, 'Database error')
```

### Winston Transport

```typescript
import winston from 'winston'
import { WinstonTransport as AxiomTransport } from '@axiomhq/winston'

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'api', environment: 'production' },
  transports: [
    new AxiomTransport({
      dataset: process.env.AXIOM_DATASET!,
      token: process.env.AXIOM_TOKEN!,
    }),
    new winston.transports.Console(),
  ],
})

logger.info('Payment processed', { orderId: 'order-456', amount: 99.99 })
```

---

## APL (Axiom Processing Language)

See `rules/apl-queries.md` for detailed patterns.

### Basic Queries

```apl
// Filter by field
['my-logs']
| where level == 'error'
| where _time > ago(1h)

// Project specific fields
['my-logs']
| project _time, level, message, user_id

// Aggregation
['my-logs']
| summarize count() by level

// Time buckets
['my-logs']
| summarize count() by bin(_time, 5m)
```

### Common Patterns

```apl
// Error rate by service
['my-logs']
| where _time > ago(24h)
| summarize
    total = count(),
    errors = countif(level == 'error')
  by service
| extend error_rate = errors * 100.0 / total

// P99 latency
['my-logs']
| where _time > ago(1h)
| summarize p99 = percentile(duration_ms, 99) by endpoint

// Top errors
['my-logs']
| where level == 'error'
| summarize count() by error_type
| top 10 by count_
```

---

## Framework Integrations

### Next.js

See `rules/nextjs-integration.md` for detailed patterns.

```typescript
// lib/axiom.ts
import { Axiom } from '@axiomhq/js'

export const axiom = new Axiom({
  token: process.env.AXIOM_TOKEN!,
})

// app/api/route.ts
import { axiom } from '@/lib/axiom'

export async function POST(request: Request) {
  const start = Date.now()

  try {
    const result = await processRequest(request)

    axiom.ingest(process.env.AXIOM_DATASET!, [{
      timestamp: new Date().toISOString(),
      level: 'info',
      path: '/api/endpoint',
      duration_ms: Date.now() - start,
      status: 200,
    }])

    return Response.json(result)
  } catch (error) {
    axiom.ingest(process.env.AXIOM_DATASET!, [{
      timestamp: new Date().toISOString(),
      level: 'error',
      path: '/api/endpoint',
      error: error.message,
      duration_ms: Date.now() - start,
    }])
    throw error
  }
}
```

### Cloudflare Workers

```typescript
// src/index.ts
export default {
  async fetch(request: Request, env: Env) {
    const start = Date.now()
    const log = {
      timestamp: new Date().toISOString(),
      url: request.url,
      method: request.method,
      cf: request.cf,
    }

    try {
      const response = await handleRequest(request, env)

      // Send to Axiom
      await fetch(`https://api.axiom.co/v1/datasets/${env.AXIOM_DATASET}/ingest`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.AXIOM_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify([{
          ...log,
          status: response.status,
          duration_ms: Date.now() - start,
        }]),
      })

      return response
    } catch (error) {
      // Log error
      ctx.waitUntil(fetch(`https://api.axiom.co/v1/datasets/${env.AXIOM_DATASET}/ingest`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.AXIOM_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify([{
          ...log,
          level: 'error',
          error: error.message,
          duration_ms: Date.now() - start,
        }]),
      }))
      throw error
    }
  },
}
```

---

## API Reference

### Ingest Endpoint

```bash
POST https://api.axiom.co/v1/datasets/{dataset}/ingest
Authorization: Bearer {token}
Content-Type: application/json

[
  {"timestamp": "2025-01-15T10:00:00Z", "level": "info", "message": "Hello"},
  {"timestamp": "2025-01-15T10:00:01Z", "level": "error", "message": "Failed"}
]
```

### Query Endpoint

```bash
POST https://api.axiom.co/v1/datasets/_apl
Authorization: Bearer {token}
Content-Type: application/json

{
  "apl": "['my-logs'] | where level == 'error' | limit 10",
  "startTime": "2025-01-14T00:00:00Z",
  "endTime": "2025-01-15T00:00:00Z"
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Not flushing before exit | Call `await axiom.flush()` |
| Missing timestamps | Always include `timestamp` field |
| Blocking on ingest | Use `ctx.waitUntil()` in Workers |
| Hardcoded tokens | Use environment variables |
| No batching | SDK batches automatically, or batch manually |

---

## Quick Reference

| Task | Code |
|------|------|
| Install | `npm install @axiomhq/js` |
| Ingest | `axiom.ingest(dataset, [events])` |
| Flush | `await axiom.flush()` |
| Query | APL in dashboard or API |
| Pino | `@axiomhq/pino` transport |
| Winston | `@axiomhq/winston` transport |
