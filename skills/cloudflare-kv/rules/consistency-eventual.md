---
title: Understand Eventual Consistency
impact: HIGH
impactDescription: Prevents bugs from stale reads in distributed systems
tags: kv, consistency, distributed, caching
---

## Understand Eventual Consistency

KV is eventually consistent - writes propagate globally in ~60 seconds. Don't assume immediate read-after-write consistency.

**Incorrect (assumes immediate consistency):**

```typescript
app.post('/users', async (c) => {
  const user = await c.req.json<CreateUserInput>()

  // Create user in database
  const newUser = await createUserInDB(c.env.DB, user)

  // Cache the user
  await c.env.CACHE.put(`user:${newUser.id}`, JSON.stringify(newUser))

  // ❌ Redirect immediately - user might not see their data
  // KV write hasn't propagated to all edge locations yet
  return c.redirect(`/users/${newUser.id}`)
})

app.post('/settings', async (c) => {
  const settings = await c.req.json()

  // Update settings
  await c.env.CONFIG.put('app:settings', JSON.stringify(settings))

  // ❌ Immediately read back - might get old value!
  const saved = await c.env.CONFIG.get('app:settings', 'json')

  return c.json(saved) // Could return stale data
})
```

**Correct (handle eventual consistency):**

```typescript
app.post('/users', async (c) => {
  const user = await c.req.json<CreateUserInput>()

  // Create user in database (source of truth)
  const newUser = await createUserInDB(c.env.DB, user)

  // Cache the user (background, don't block response)
  c.executionCtx.waitUntil(
    c.env.CACHE.put(`user:${newUser.id}`, JSON.stringify(newUser))
  )

  // ✅ Return the data directly - don't rely on reading back from KV
  return c.json(newUser, 201)
})

// ✅ Cache-aside pattern: DB is source of truth, KV is cache
app.get('/users/:id', async (c) => {
  const id = c.req.param('id')

  // Try cache first
  const cached = await c.env.CACHE.get<User>(`user:${id}`, 'json')

  if (cached) {
    return c.json(cached)
  }

  // Cache miss: fetch from database (source of truth)
  const user = await getUserFromDB(c.env.DB, id)

  if (!user) {
    return c.json({ error: 'Not found' }, 404)
  }

  // Update cache for next request (background)
  c.executionCtx.waitUntil(
    c.env.CACHE.put(`user:${id}`, JSON.stringify(user), {
      expirationTtl: 3600,
    })
  )

  return c.json(user)
})

// ✅ For settings: return what was written, not what was read
app.post('/settings', async (c) => {
  const settings = await c.req.json()

  // Validate settings
  const validated = validateSettings(settings)

  // Write to KV
  await c.env.CONFIG.put('app:settings', JSON.stringify(validated))

  // ✅ Return the input, not a re-read
  return c.json({
    saved: true,
    settings: validated,
    note: 'Changes propagate globally within 60 seconds',
  })
})

// ✅ For critical consistency needs, use Durable Objects instead
app.post('/counter/increment', async (c) => {
  // ❌ KV is wrong for counters - race conditions!
  // const count = await c.env.KV.get('counter', 'json') ?? 0
  // await c.env.KV.put('counter', JSON.stringify(count + 1))

  // ✅ Use Durable Objects for consistent counters
  const id = c.env.COUNTER.idFromName('global')
  const counter = c.env.COUNTER.get(id)
  const newCount = await counter.increment()

  return c.json({ count: newCount })
})
```

**When to use KV vs Durable Objects:**

| Use Case | KV | Durable Objects |
|----------|----|-----------------|
| Read-heavy cache | ✅ | ❌ |
| Config/feature flags | ✅ | ❌ |
| Session storage | ✅ | ⚠️ |
| Counters/analytics | ❌ | ✅ |
| Real-time data | ❌ | ✅ |
| Strong consistency needed | ❌ | ✅ |
