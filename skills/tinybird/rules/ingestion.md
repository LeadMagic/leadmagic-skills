---
title: Tinybird Ingestion Patterns
impact: HIGH
impactDescription: Data ingestion and real-time streaming
tags: tinybird, ingestion, events, streaming
---

## Tinybird Ingestion Patterns

### Events API (Real-Time)

Best for real-time event streaming from applications.

```bash
# Single event
curl -X POST "https://api.tinybird.co/v0/events?name=events" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"timestamp":"2024-01-15T10:00:00Z","user_id":"u123","event_type":"click"}'
```

```typescript
// TypeScript
async function trackEvent(event: {
  timestamp: string
  user_id: string
  event_type: string
  properties?: Record<string, unknown>
}) {
  await fetch(`https://api.tinybird.co/v0/events?name=events`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${process.env.TINYBIRD_TOKEN}` },
    body: JSON.stringify(event),
  })
}
```

### Batch Events (NDJSON)

```typescript
async function trackEvents(events: Event[]) {
  const ndjson = events.map(e => JSON.stringify(e)).join('\n')

  await fetch(`https://api.tinybird.co/v0/events?name=events`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.TINYBIRD_TOKEN}`,
      'Content-Type': 'application/x-ndjson',
    },
    body: ndjson,
  })
}
```

### Data Sources API (Bulk)

Best for batch imports from files or URLs.

```bash
# From URL (CSV, Parquet, NDJSON)
curl -X POST "https://api.tinybird.co/v0/datasources?name=events&mode=append" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"url":"https://s3.amazonaws.com/bucket/data.parquet"}'

# From local file
curl -X POST "https://api.tinybird.co/v0/datasources?name=events&mode=append" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -F "csv=@data.csv"

# Replace mode (truncate + insert)
curl -X POST "https://api.tinybird.co/v0/datasources?name=events&mode=replace" \
  -H "Authorization: Bearer $TB_TOKEN" \
  -d '{"url":"https://example.com/full_export.csv"}'
```

### CLI Ingestion

```bash
# Append from URL
tb datasource append events --url "https://example.com/data.parquet"

# Append from file
tb datasource append events --file data.csv

# With format specification
tb datasource append events --url "https://example.com/data.json" --format ndjson
```

---

## Next.js Integration

### API Route for Event Tracking

```typescript
// app/api/track/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const event = await request.json()

  // Add server-side context
  const enrichedEvent = {
    ...event,
    timestamp: new Date().toISOString(),
    ip: request.headers.get('x-forwarded-for') || 'unknown',
    user_agent: request.headers.get('user-agent') || 'unknown',
  }

  const res = await fetch(
    `https://api.tinybird.co/v0/events?name=events`,
    {
      method: 'POST',
      headers: { Authorization: `Bearer ${process.env.TINYBIRD_TOKEN}` },
      body: JSON.stringify(enrichedEvent),
    }
  )

  if (!res.ok) {
    return NextResponse.json({ error: 'Failed to track' }, { status: 500 })
  }

  return NextResponse.json({ success: true })
}
```

### Client-Side Tracking

```typescript
// lib/analytics.ts
export async function track(eventType: string, properties?: Record<string, unknown>) {
  await fetch('/api/track', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event_type: eventType,
      page_url: window.location.href,
      referrer: document.referrer,
      properties: JSON.stringify(properties || {}),
    }),
  })
}

// Usage
track('page_view', { title: document.title })
track('button_click', { button_id: 'signup', variant: 'primary' })
```

---

## Cloudflare Worker Integration

```typescript
// src/index.ts
import { Hono } from 'hono'

const app = new Hono<{ Bindings: { TINYBIRD_TOKEN: string } }>()

app.post('/track', async (c) => {
  const event = await c.req.json()

  const res = await fetch('https://api.tinybird.co/v0/events?name=events', {
    method: 'POST',
    headers: { Authorization: `Bearer ${c.env.TINYBIRD_TOKEN}` },
    body: JSON.stringify({
      ...event,
      timestamp: new Date().toISOString(),
      cf_country: c.req.raw.cf?.country,
      cf_city: c.req.raw.cf?.city,
    }),
  })

  if (!res.ok) {
    return c.json({ error: 'Failed' }, 500)
  }

  return c.json({ success: true })
})

export default app
```

---

## Kafka/Event Streaming

```bash
# Create Kafka connector
tb connection create kafka my_kafka \
  --bootstrap-servers "broker1:9092,broker2:9092" \
  --topic "events" \
  --group-id "tinybird-consumer"

# Connect to data source
tb datasource connect events --connection my_kafka
```

---

## Best Practices

1. **Use Events API for real-time** - Low latency, auto-creates schema
2. **Batch when possible** - Group events, send every 1-5 seconds
3. **Use NDJSON format** - Most efficient for streaming
4. **Add timestamps server-side** - More reliable than client
5. **Include request context** - IP, user agent, geo data
6. **Use `wait=true` for critical** - Ensure acknowledgment
7. **Set up error handling** - Queue failed events for retry
