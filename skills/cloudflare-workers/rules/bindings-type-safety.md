---
title: Type All Environment Bindings
impact: CRITICAL
impactDescription: Compile-time verification of all binding access
tags: types, bindings, typescript
---

## Type All Environment Bindings

Define an `Env` interface with all Worker bindings typed. This catches binding name typos at compile time.

**Incorrect (untyped environment):**

```typescript
export default {
  async fetch(request: Request, env: any): Promise<Response> {
    // No type checking - typos compile fine
    const value = await env.CHACHE.get('key')  // Typo: CHACHE vs CACHE
    const result = await env.db.prepare('...').all()  // Typo: db vs DB

    return new Response('ok')
  }
}
```

**Correct (fully typed environment):**

```typescript
// Define interface matching wrangler.toml bindings
export interface Env {
  // KV Namespaces
  CACHE: KVNamespace
  SESSIONS: KVNamespace

  // D1 Databases
  DB: D1Database

  // R2 Buckets
  ASSETS: R2Bucket
  UPLOADS: R2Bucket

  // Durable Objects
  RATE_LIMITER: DurableObjectNamespace
  COUNTER: DurableObjectNamespace

  // Service Bindings
  AUTH_SERVICE: Fetcher

  // Environment Variables (from [vars])
  ENVIRONMENT: 'development' | 'staging' | 'production'
  API_VERSION: string

  // Secrets (from wrangler secret)
  API_KEY: string
  JWT_SECRET: string
  DATABASE_URL: string

  // Analytics Engine
  ANALYTICS: AnalyticsEngineDataset

  // Queues
  MY_QUEUE: Queue<QueueMessage>

  // Vectorize
  VECTOR_INDEX: VectorizeIndex
}

// Type your queue messages too
interface QueueMessage {
  type: 'email' | 'notification'
  payload: unknown
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // ✅ TypeScript catches typos
    // env.CHACHE.get('key')  // Error: Property 'CHACHE' does not exist

    // ✅ Correct binding names with autocomplete
    const value = await env.CACHE.get('key')
    const { results } = await env.DB.prepare('SELECT * FROM users').all()

    // ✅ Environment variables are typed
    if (env.ENVIRONMENT === 'production') {
      // Production-specific logic
    }

    return Response.json({ value, results })
  },

  // Typed queue handler
  async queue(batch: MessageBatch<QueueMessage>, env: Env): Promise<void> {
    for (const message of batch.messages) {
      // message.body is typed as QueueMessage
      if (message.body.type === 'email') {
        await sendEmail(message.body.payload)
      }
      message.ack()
    }
  }
}
```

Run `wrangler types` to auto-generate types from your `wrangler.toml`.
