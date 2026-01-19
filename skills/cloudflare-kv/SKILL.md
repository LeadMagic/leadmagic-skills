---
name: cloudflare-kv
description: Best practices for using Cloudflare Workers KV key-value storage. Use when caching data, storing configuration, session management, or any key-value patterns. Triggers on "KV", "key-value", "cache", "Workers KV", "namespace".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Cloudflare KV Best Practices

Comprehensive guide for using Cloudflare Workers KV (Key-Value) storage.

## When to Apply

Reference these guidelines when:
- Caching API responses or computed data
- Storing configuration and feature flags
- Managing user sessions or preferences
- Building edge-first applications with global data

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Read/Write Operations | CRITICAL | `ops-` |
| 2 | Consistency | HIGH | `consistency-` |

## Quick Reference

### 1. Read/Write Operations (CRITICAL)

- `ops-get-put` - Basic get/put operations with types

### 2. Consistency (HIGH)

- `consistency-eventual` - Understand eventual consistency

## Essential Patterns

### Basic KV Operations

```typescript
interface Env {
  CACHE: KVNamespace
  CONFIG: KVNamespace
}

// Get a value
app.get('/config/:key', async (c) => {
  const key = c.req.param('key')

  // Get as string (default)
  const value = await c.env.CONFIG.get(key)

  if (!value) {
    return c.json({ error: 'Not found' }, 404)
  }

  return c.json({ key, value })
})

// Get as JSON (parsed automatically)
app.get('/users/:id', async (c) => {
  const id = c.req.param('id')

  const user = await c.env.CACHE.get<User>(`user:${id}`, 'json')

  if (!user) {
    return c.json({ error: 'User not found' }, 404)
  }

  return c.json(user)
})

// Put a value
app.put('/config/:key', async (c) => {
  const key = c.req.param('key')
  const { value } = await c.req.json()

  await c.env.CONFIG.put(key, value)

  return c.json({ success: true })
})

// Put JSON with expiration
app.post('/cache/user/:id', async (c) => {
  const id = c.req.param('id')
  const user = await c.req.json<User>()

  await c.env.CACHE.put(
    `user:${id}`,
    JSON.stringify(user),
    {
      expirationTtl: 3600, // 1 hour in seconds
    }
  )

  return c.json({ cached: true })
})

// Delete a value
app.delete('/config/:key', async (c) => {
  const key = c.req.param('key')

  await c.env.CONFIG.delete(key)

  return c.json({ deleted: true })
})
```

### Store with Metadata

```typescript
// Store value with metadata (useful for caching)
app.post('/cache/:key', async (c) => {
  const key = c.req.param('key')
  const data = await c.req.json()

  await c.env.CACHE.put(key, JSON.stringify(data), {
    expirationTtl: 3600,
    metadata: {
      createdAt: Date.now(),
      contentType: 'application/json',
      version: '1.0',
    },
  })

  return c.json({ cached: true })
})

// Get value with metadata
app.get('/cache/:key', async (c) => {
  const key = c.req.param('key')

  const { value, metadata } = await c.env.CACHE.getWithMetadata<CacheMeta>(
    key,
    'json'
  )

  if (!value) {
    return c.json({ error: 'Not found' }, 404)
  }

  return c.json({
    data: value,
    meta: metadata,
  })
})
```

### List Keys with Pagination

```typescript
app.get('/keys', async (c) => {
  const prefix = c.req.query('prefix') ?? ''
  const cursor = c.req.query('cursor')
  const limit = parseInt(c.req.query('limit') ?? '100')

  const result = await c.env.CACHE.list({
    prefix,
    cursor,
    limit,
  })

  return c.json({
    keys: result.keys.map(k => ({
      name: k.name,
      expiration: k.expiration,
      metadata: k.metadata,
    })),
    complete: result.list_complete,
    cursor: result.list_complete ? undefined : result.cursor,
  })
})

// List all keys (handle pagination)
async function listAllKeys(
  kv: KVNamespace,
  prefix: string = ''
): Promise<string[]> {
  const allKeys: string[] = []
  let cursor: string | undefined

  do {
    const result = await kv.list({ prefix, cursor })
    allKeys.push(...result.keys.map(k => k.name))
    cursor = result.list_complete ? undefined : result.cursor
  } while (cursor)

  return allKeys
}
```

### Cache-Aside Pattern

```typescript
async function getCachedOrFetch<T>(
  kv: KVNamespace,
  key: string,
  fetcher: () => Promise<T>,
  ttlSeconds: number = 3600
): Promise<T> {
  // Try cache first
  const cached = await kv.get<T>(key, 'json')

  if (cached !== null) {
    return cached
  }

  // Fetch fresh data
  const fresh = await fetcher()

  // Cache for next time (don't await - fire and forget)
  kv.put(key, JSON.stringify(fresh), {
    expirationTtl: ttlSeconds,
  })

  return fresh
}

// Usage
app.get('/users/:id', async (c) => {
  const id = c.req.param('id')

  const user = await getCachedOrFetch(
    c.env.CACHE,
    `user:${id}`,
    () => fetchUserFromDatabase(c.env.DB, id),
    3600
  )

  return c.json(user)
})
```

### Key Design Patterns

```typescript
// Hierarchical keys with prefixes
const keys = {
  // User data
  user: (id: string) => `user:${id}`,
  userProfile: (id: string) => `user:${id}:profile`,
  userSettings: (id: string) => `user:${id}:settings`,

  // Session data
  session: (token: string) => `session:${token}`,

  // Cache keys
  apiCache: (endpoint: string, params: string) =>
    `cache:api:${endpoint}:${params}`,

  // Feature flags
  featureFlag: (name: string) => `config:feature:${name}`,

  // Rate limiting
  rateLimit: (ip: string, window: string) =>
    `ratelimit:${ip}:${window}`,
}

// List all user-related keys
const userKeys = await c.env.CACHE.list({ prefix: 'user:' })

// List all settings for a user
const settingsKeys = await c.env.CACHE.list({
  prefix: `user:${userId}:settings:`
})
```

### Bulk Delete Pattern

```typescript
// Delete all keys with a prefix
async function deleteByPrefix(
  kv: KVNamespace,
  prefix: string
): Promise<number> {
  let deleted = 0
  let cursor: string | undefined

  do {
    const result = await kv.list({ prefix, cursor })

    // Delete each key (KV doesn't have bulk delete)
    await Promise.all(
      result.keys.map(k => kv.delete(k.name))
    )

    deleted += result.keys.length
    cursor = result.list_complete ? undefined : result.cursor
  } while (cursor)

  return deleted
}

// Usage: Clear user's cache
app.delete('/users/:id/cache', async (c) => {
  const id = c.req.param('id')

  const deleted = await deleteByPrefix(c.env.CACHE, `user:${id}:`)

  return c.json({ deleted })
})
```

### Session Management

```typescript
interface Session {
  userId: string
  createdAt: number
  expiresAt: number
  data: Record<string, unknown>
}

// Create session
async function createSession(
  kv: KVNamespace,
  userId: string,
  ttlSeconds: number = 86400 // 24 hours
): Promise<string> {
  const token = crypto.randomUUID()
  const now = Date.now()

  const session: Session = {
    userId,
    createdAt: now,
    expiresAt: now + ttlSeconds * 1000,
    data: {},
  }

  await kv.put(`session:${token}`, JSON.stringify(session), {
    expirationTtl: ttlSeconds,
  })

  return token
}

// Get session
async function getSession(
  kv: KVNamespace,
  token: string
): Promise<Session | null> {
  return kv.get<Session>(`session:${token}`, 'json')
}

// Delete session (logout)
async function deleteSession(
  kv: KVNamespace,
  token: string
): Promise<void> {
  await kv.delete(`session:${token}`)
}

// Session middleware
const sessionMiddleware = async (c: Context, next: Next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    return c.json({ error: 'Unauthorized' }, 401)
  }

  const session = await getSession(c.env.SESSIONS, token)

  if (!session) {
    return c.json({ error: 'Session expired' }, 401)
  }

  c.set('session', session)
  await next()
}
```

## Wrangler Configuration

```toml
[[kv_namespaces]]
binding = "CACHE"
id = "abc123"
preview_id = "def456"

[[kv_namespaces]]
binding = "CONFIG"
id = "ghi789"
preview_id = "jkl012"

[[kv_namespaces]]
binding = "SESSIONS"
id = "mno345"
preview_id = "pqr678"
```

## KV Limits

| Resource | Limit |
|----------|-------|
| Key size | 512 bytes |
| Value size | 25 MB |
| Metadata size | 1024 bytes |
| List keys per call | 1000 |
| Writes per second | ~1 per key |
| Reads per second | Unlimited |

## Consistency Model

KV is **eventually consistent** with a typical propagation time of ~60 seconds globally.

- **Reads** may return stale data for up to 60 seconds after a write
- **Writes** to the same key from different locations may conflict
- For strong consistency needs, use **Durable Objects** instead

## Wrangler Commands

```bash
# Create namespace
wrangler kv:namespace create CACHE
wrangler kv:namespace create CACHE --preview

# List namespaces
wrangler kv:namespace list

# Put a value
wrangler kv:key put --binding=CACHE "my-key" "my-value"
wrangler kv:key put --binding=CACHE "config" '{"debug":true}' --metadata '{"version":"1"}'

# Get a value
wrangler kv:key get --binding=CACHE "my-key"

# Delete a value
wrangler kv:key delete --binding=CACHE "my-key"

# List keys
wrangler kv:key list --binding=CACHE
wrangler kv:key list --binding=CACHE --prefix="user:"

# Bulk upload from file
wrangler kv:bulk put --binding=CACHE ./data.json
```

