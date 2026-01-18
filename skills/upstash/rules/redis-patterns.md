---
title: Upstash Redis Patterns
impact: HIGH
impactDescription: Caching, sessions, and data structures
tags: redis, caching, upstash
---

## Upstash Redis Patterns

### Client Setup

```typescript
import { Redis } from "@upstash/redis"

// From environment (recommended)
export const redis = Redis.fromEnv()

// With options
export const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
  enableAutoPipelining: true, // Auto-batch commands
  readYourWrites: true,       // Consistency guarantee
})
```

### Cloudflare Workers

```typescript
import { Redis } from "@upstash/redis/cloudflare"

export interface Env {
  UPSTASH_REDIS_REST_URL: string
  UPSTASH_REDIS_REST_TOKEN: string
}

export default {
  async fetch(request: Request, env: Env) {
    const redis = Redis.fromEnv(env)
    const count = await redis.incr("page-views")
    return new Response(JSON.stringify({ views: count }))
  },
}
```

### Common Operations

```typescript
// Basic
await redis.set("key", "value")
await redis.set("key", "value", { ex: 3600 }) // TTL
const value = await redis.get<string>("key")

// JSON
await redis.set("user:123", { name: "Alice", email: "alice@example.com" })
const user = await redis.get<{ name: string }>("user:123")

// Hash
await redis.hset("user:123", { name: "Alice", role: "admin" })
const data = await redis.hgetall<Record<string, string>>("user:123")

// Lists
await redis.lpush("queue", "task1", "task2")
const task = await redis.rpop<string>("queue")

// Sets
await redis.sadd("tags", "typescript", "react")
const tags = await redis.smembers<string[]>("tags")

// Sorted sets (leaderboards)
await redis.zadd("leaderboard", { score: 100, member: "player1" })
const top10 = await redis.zrange<string[]>("leaderboard", 0, 9, { rev: true })

// Increment
const views = await redis.incr("page:views")
```

### Auto-Pipelining

```typescript
const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
  enableAutoPipelining: true,
})

// These 3 commands sent in single HTTP request
const [user, cart, prefs] = await Promise.all([
  redis.hgetall("user:123"),
  redis.lrange("cart:123", 0, -1),
  redis.smembers("prefs:123"),
])
```

### Pub/Sub with SSE

```typescript
// Subscribe endpoint
export async function GET(req: Request, { params }: { params: { channel: string } }) {
  const response = await fetch(
    `${process.env.UPSTASH_REDIS_REST_URL}/subscribe/${params.channel}`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.UPSTASH_REDIS_REST_TOKEN}`,
        Accept: "text/event-stream",
      },
    }
  )

  return new Response(response.body, {
    headers: { "Content-Type": "text/event-stream" },
  })
}

// Publish
await redis.publish("chat", JSON.stringify({ user: "Alice", message: "Hello!" }))
```
