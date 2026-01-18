---
title: Avoid Single Global Instance Bottleneck
impact: CRITICAL
impactDescription: Single global DO becomes performance bottleneck and single point of failure
tags: durable-objects, scaling, anti-pattern, bottleneck
---

## Avoid Single Global Instance Bottleneck

Don't route all requests through a single global Durable Object instance. This creates a bottleneck and defeats the purpose of edge computing.

**Incorrect (single global instance):**

```typescript
// ❌ All traffic goes through one instance
app.post('/increment', async (c) => {
  // Everyone shares the same "global" counter
  const id = c.env.COUNTER.idFromName('global')
  const counter = c.env.COUNTER.get(id)
  
  const count = await counter.increment()
  return c.json({ count })
})

// ❌ Single rate limiter for entire app
app.use('*', async (c, next) => {
  const id = c.env.RATE_LIMITER.idFromName('global')
  const limiter = c.env.RATE_LIMITER.get(id)
  
  // All requests queue through one instance!
  const allowed = await limiter.check()
  if (!allowed) return c.json({ error: 'Rate limited' }, 429)
  
  await next()
})

// ❌ Global session store
async function getSession(env: Env, token: string) {
  const id = env.SESSIONS.idFromName('global-sessions')
  const sessions = env.SESSIONS.get(id)
  return sessions.get(token)
}
```

**Correct (distributed instances):**

```typescript
// ✅ Per-user counters - distributed across instances
app.post('/users/:userId/increment', async (c) => {
  const userId = c.req.param('userId')
  
  // Each user has their own DO instance
  const id = c.env.COUNTER.idFromName(`user:${userId}`)
  const counter = c.env.COUNTER.get(id)
  
  const count = await counter.increment()
  return c.json({ count })
})

// ✅ Per-IP rate limiting - distributed
app.use('*', async (c, next) => {
  const ip = c.req.header('CF-Connecting-IP') ?? 'unknown'
  
  // Each IP has its own rate limiter instance
  const id = c.env.RATE_LIMITER.idFromName(`ip:${ip}`)
  const limiter = c.env.RATE_LIMITER.get(id)
  
  const { allowed } = await limiter.checkLimit()
  if (!allowed) return c.json({ error: 'Rate limited' }, 429)
  
  await next()
})

// ✅ Per-session instances
async function getSession(env: Env, token: string) {
  // Each session token maps to its own DO
  const id = env.SESSIONS.idFromName(`session:${token}`)
  const session = env.SESSIONS.get(id)
  return session.getData()
}

// ✅ Sharded global counter (for truly global counts)
app.post('/global/increment', async (c) => {
  // Shard by time window or random bucket
  const shard = Math.floor(Math.random() * 10) // 10 shards
  const id = c.env.COUNTER.idFromName(`global:shard:${shard}`)
  const counter = c.env.COUNTER.get(id)
  
  await counter.increment()
  return c.json({ success: true })
})

// Get total by summing shards (read-time aggregation)
app.get('/global/count', async (c) => {
  const shardCounts = await Promise.all(
    Array.from({ length: 10 }, (_, i) => {
      const id = c.env.COUNTER.idFromName(`global:shard:${i}`)
      return c.env.COUNTER.get(id).getCount()
    })
  )
  
  const total = shardCounts.reduce((a, b) => a + b, 0)
  return c.json({ count: total })
})
```

**When you truly need global coordination:**

```typescript
// For leader election or global locks, use DO but:
// 1. Keep operations fast
// 2. Use alarms for background work
// 3. Consider if you really need global state

export class GlobalCoordinator extends DurableObject {
  private leader: string | null = null
  
  async electLeader(candidateId: string): Promise<boolean> {
    // Fast check-and-set operation
    if (this.leader === null) {
      this.leader = candidateId
      await this.ctx.storage.put('leader', candidateId)
      
      // Set alarm to expire leadership
      await this.ctx.storage.setAlarm(Date.now() + 30000)
      return true
    }
    return this.leader === candidateId
  }
  
  async alarm() {
    // Leadership expires - allow re-election
    this.leader = null
    await this.ctx.storage.delete('leader')
  }
}
```

**Scaling guidelines:**
- 1 DO instance can handle ~1000 requests/second
- Use natural sharding keys (user ID, session ID, IP)
- For global aggregates, shard and aggregate at read time
- For global coordination, keep critical sections short
