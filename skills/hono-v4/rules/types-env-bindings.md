---
title: Define Typed Environment Bindings
impact: CRITICAL
impactDescription: Type-safe access to all Worker bindings
tags: types, bindings, typescript, hono
---

## Define Typed Environment Bindings

Always define a `Bindings` type for all your Cloudflare Worker environment bindings and pass it to Hono's generic parameter.

**Incorrect (no type safety):**

```typescript
import { Hono } from 'hono'

const app = new Hono()

app.get('/data', async (c) => {
  // c.env is 'any' - no type checking
  const result = await c.env.DB.prepare('SELECT * FROM users').all()
  const value = await c.env.CACHE.get('key')
  return c.json({ result, value })
})
```

**Correct (fully typed):**

```typescript
import { Hono } from 'hono'

// Define all bindings
type Bindings = {
  // Databases
  DB: D1Database

  // Key-Value
  CACHE: KVNamespace

  // Object Storage
  BUCKET: R2Bucket

  // Durable Objects
  COUNTER: DurableObjectNamespace

  // Environment Variables
  API_KEY: string
  ENVIRONMENT: 'development' | 'staging' | 'production'

  // Secrets
  JWT_SECRET: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.get('/data', async (c) => {
  // Full type checking and autocomplete
  const result = await c.env.DB.prepare('SELECT * FROM users').all()
  const value = await c.env.CACHE.get('key')
  const env = c.env.ENVIRONMENT // typed as union
  return c.json({ result, value, env })
})
```

This ensures compile-time validation of all binding access and enables IDE autocomplete.
