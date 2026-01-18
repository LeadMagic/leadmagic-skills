---
name: upstash
description: Upstash serverless services - QStash (message queue), Redis (caching), Workflows (durable execution), Ratelimit. Use when building background jobs, scheduling, caching, rate limiting. Triggers on "QStash", "Upstash", "message queue", "rate limit", "background job".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Upstash Best Practices

Serverless services for Next.js and Cloudflare Workers.

## Services

| Service | Use Case | Package |
|---------|----------|---------|
| **QStash** | Message queue, scheduling | `@upstash/qstash` |
| **Redis** | Caching, sessions, pub/sub | `@upstash/redis` |
| **Workflow** | Durable execution | `@upstash/workflow` |
| **Ratelimit** | API rate limiting | `@upstash/ratelimit` |

## Installation

```bash
npm install @upstash/qstash @upstash/redis @upstash/workflow @upstash/ratelimit
```

## Environment

```bash
QSTASH_TOKEN=your-token
QSTASH_CURRENT_SIGNING_KEY=your-key
UPSTASH_REDIS_REST_URL=https://your-region.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-redis-token
```

---

## QStash Quick Start

See `rules/qstash-patterns.md` for detailed patterns.

```typescript
import { Client } from "@upstash/qstash"

const qstash = new Client({ token: process.env.QSTASH_TOKEN! })

// Publish message
await qstash.publishJSON({
  url: `${process.env.NEXT_PUBLIC_APP_URL}/api/process`,
  body: { userId: "123" },
})

// Schedule cron
await qstash.schedules.create({
  destination: `${process.env.NEXT_PUBLIC_APP_URL}/api/daily`,
  cron: "0 9 * * *",
})
```

```typescript
// Receive & verify
import { verifySignatureAppRouter } from "@upstash/qstash/nextjs"

async function handler(req: Request) {
  const body = await req.json()
  return new Response("OK")
}

export const POST = verifySignatureAppRouter(handler)
```

---

## Redis Quick Start

See `rules/redis-patterns.md` for detailed patterns.

```typescript
import { Redis } from "@upstash/redis"

const redis = Redis.fromEnv()

// Basic ops
await redis.set("key", "value", { ex: 3600 })
const val = await redis.get<string>("key")

// Auto-pipeline (single HTTP request)
const [user, cart] = await Promise.all([
  redis.hgetall("user:123"),
  redis.lrange("cart:123", 0, -1),
])
```

### Cloudflare Workers

```typescript
import { Redis } from "@upstash/redis/cloudflare"

export default {
  async fetch(request: Request, env: Env) {
    const redis = Redis.fromEnv(env)
    return Response.json({ views: await redis.incr("views") })
  },
}
```

---

## Workflow Quick Start

See `rules/workflow-patterns.md` for detailed patterns.

```typescript
import { serve } from "@upstash/workflow/nextjs"

export const { POST } = serve<{ orderId: string }>(async (context) => {
  const { orderId } = context.requestPayload

  // Auto-retries on failure
  const result = await context.run("process", async () => {
    return await processOrder(orderId)
  })

  // Wait for external event
  const { eventData, timeout } = await context.waitForEvent(
    "wait-payment",
    `payment-${orderId}`,
    { timeout: "24h" }
  )

  if (timeout) return { success: false }
  return { success: true, data: eventData }
})
```

---

## Rate Limiting

```typescript
import { Ratelimit } from "@upstash/ratelimit"
import { Redis } from "@upstash/redis"

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "10 s"),
})

// In API route
const ip = headers().get("x-forwarded-for") ?? "anonymous"
const { success, remaining } = await ratelimit.limit(ip)

if (!success) {
  return new Response("Rate limit exceeded", { status: 429 })
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| No signature verification | Wrap with `verifySignatureAppRouter` |
| Wrong Redis import for CF | Use `@upstash/redis/cloudflare` |
| Sequential Redis calls | Use `Promise.all()` + auto-pipelining |
| Hardcoded URLs | Use `process.env.NEXT_PUBLIC_APP_URL` |
| No TTL on Redis keys | Always set `{ ex: seconds }` |

---

## Quick Reference

| Task | Code |
|------|------|
| Queue job | `qstash.publishJSON({ url, body })` |
| Schedule cron | `qstash.schedules.create({ destination, cron })` |
| Verify webhook | `verifySignatureAppRouter(handler)` |
| Redis get/set | `redis.set(key, val)` / `redis.get(key)` |
| Redis with TTL | `redis.set(key, val, { ex: 3600 })` |
| Workflow step | `context.run("name", async () => {})` |
| Wait for event | `context.waitForEvent("name", eventId, { timeout })` |
| Rate limit | `ratelimit.limit(identifier)` |
