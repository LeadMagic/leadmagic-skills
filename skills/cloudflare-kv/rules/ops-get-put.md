---
title: Basic Get/Put Operations with Types
impact: CRITICAL
impactDescription: Type-safe KV access prevents runtime errors
tags: kv, operations, types, get, put
---

## Basic Get/Put Operations with Types

Always use typed get operations and handle null returns properly. KV can return different formats (string, JSON, ArrayBuffer, stream).

**Incorrect (untyped, no null handling):**

```typescript
app.get('/user/:id', async (c) => {
  const id = c.req.param('id')

  // ❌ Returns string | null, not typed
  const user = await c.env.CACHE.get(`user:${id}`)

  // ❌ Will crash if user is null
  return c.json({ name: JSON.parse(user).name })
})

app.post('/user/:id', async (c) => {
  const id = c.req.param('id')
  const user = await c.req.json()

  // ❌ Storing object directly - will be [object Object]
  await c.env.CACHE.put(`user:${id}`, user)

  return c.json({ saved: true })
})
```

**Correct (typed operations with proper handling):**

```typescript
interface User {
  id: string
  name: string
  email: string
}

app.get('/user/:id', async (c) => {
  const id = c.req.param('id')

  // ✅ Get as JSON with type parameter - automatically parsed
  const user = await c.env.CACHE.get<User>(`user:${id}`, 'json')

  // ✅ Handle null case
  if (!user) {
    return c.json({ error: 'User not found' }, 404)
  }

  // ✅ user is typed as User
  return c.json({ name: user.name })
})

app.post('/user/:id', async (c) => {
  const id = c.req.param('id')
  const user = await c.req.json<User>()

  // ✅ Stringify JSON before storing
  await c.env.CACHE.put(`user:${id}`, JSON.stringify(user))

  return c.json({ saved: true })
})

// ✅ Get with different return types
const asString = await kv.get('key')              // string | null
const asJson = await kv.get<MyType>('key', 'json') // MyType | null
const asBuffer = await kv.get('key', 'arrayBuffer') // ArrayBuffer | null
const asStream = await kv.get('key', 'stream')     // ReadableStream | null
```

**Type definitions:**

```typescript
// KVNamespace type signatures
interface KVNamespace {
  get(key: string): Promise<string | null>
  get(key: string, type: 'text'): Promise<string | null>
  get<T>(key: string, type: 'json'): Promise<T | null>
  get(key: string, type: 'arrayBuffer'): Promise<ArrayBuffer | null>
  get(key: string, type: 'stream'): Promise<ReadableStream | null>

  put(
    key: string,
    value: string | ArrayBuffer | ReadableStream,
    options?: KVNamespacePutOptions
  ): Promise<void>
}

interface KVNamespacePutOptions {
  expiration?: number      // Unix timestamp (seconds)
  expirationTtl?: number   // Seconds from now
  metadata?: Record<string, unknown>
}
```
