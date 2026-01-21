---
name: cloudflare-durable-objects
description: Best practices for building stateful applications with Cloudflare Durable Objects. Use when implementing real-time features, coordination, sessions, rate limiting, or any stateful edge logic. Triggers on "Durable Objects", "stateful worker", "real-time", "coordination", "WebSocket".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.1.0"
---

# Cloudflare Durable Objects Best Practices

Comprehensive guide for building stateful edge applications with Durable Objects.

## What's New (2025)

| Feature | Description |
|---------|-------------|
| Alarm handlers | 15-minute max wall time |
| JSRPC 32 MiB | Increased message limit |
| WebSocket 32 MiB | Message size limit increased |
| `.retryable` | Exception property for transient failures |
| `.overloaded` | Exception property for overload detection |

## When to Apply

Reference these guidelines when:
- Building real-time collaborative features
- Implementing coordination and locking
- Managing user sessions or presence
- Building rate limiters or counters
- Handling WebSocket connections

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Lifecycle | CRITICAL | `lifecycle-` |
| 2 | Concurrency | CRITICAL | `concurrency-` |
| 3 | WebSockets | HIGH | `websocket-` |

## Quick Reference

### 1. Lifecycle (CRITICAL)

- `lifecycle-blockConcurrencyWhile` - Use for async initialization

### 2. Concurrency (CRITICAL)

- `concurrency-single-instance` - Understand single-instance execution model

### 3. WebSockets (HIGH)

- `websocket-hibernation` - Use Hibernatable WebSockets API
- `pattern-session` - Session management
- `pattern-leader-election` - Leader election pattern
- `pattern-sharding` - Sharding for scale

## Essential Patterns

### Basic Durable Object

```typescript
import { DurableObject } from 'cloudflare:workers'

export class Counter extends DurableObject {
  private count: number = 0

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)

    // Load initial state
    this.ctx.blockConcurrencyWhile(async () => {
      this.count = (await this.ctx.storage.get<number>('count')) ?? 0
    })
  }

  async increment(): Promise<number> {
    this.count++
    await this.ctx.storage.put('count', this.count)
    return this.count
  }

  async decrement(): Promise<number> {
    this.count--
    await this.ctx.storage.put('count', this.count)
    return this.count
  }

  async getCount(): Promise<number> {
    return this.count
  }
}
```

### Using Durable Object from Worker

```typescript
interface Env {
  COUNTER: DurableObjectNamespace<Counter>
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url)

    // Get or create DO instance by name
    const id = env.COUNTER.idFromName('global-counter')
    const stub = env.COUNTER.get(id)

    // Call methods directly (RPC)
    if (url.pathname === '/increment') {
      const count = await stub.increment()
      return Response.json({ count })
    }

    if (url.pathname === '/count') {
      const count = await stub.getCount()
      return Response.json({ count })
    }

    return new Response('Not found', { status: 404 })
  }
}
```

### Hibernatable WebSockets

```typescript
export class ChatRoom extends DurableObject {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)

    if (url.pathname === '/websocket') {
      if (request.headers.get('Upgrade') !== 'websocket') {
        return new Response('Expected WebSocket', { status: 426 })
      }

      const pair = new WebSocketPair()
      const [client, server] = Object.values(pair)

      // Accept with hibernation support
      this.ctx.acceptWebSocket(server, ['user-tag'])

      return new Response(null, { status: 101, webSocket: client })
    }

    return new Response('Not found', { status: 404 })
  }

  // Called when WebSocket receives a message
  async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
    const data = JSON.parse(message as string)

    // Broadcast to all connected clients
    const sockets = this.ctx.getWebSockets()
    for (const socket of sockets) {
      socket.send(JSON.stringify({
        type: 'message',
        data: data.content,
        timestamp: Date.now(),
      }))
    }
  }

  // Called when WebSocket closes
  async webSocketClose(ws: WebSocket, code: number, reason: string) {
    // Notify others of disconnection
    const sockets = this.ctx.getWebSockets()
    for (const socket of sockets) {
      if (socket !== ws) {
        socket.send(JSON.stringify({ type: 'user_left' }))
      }
    }
  }

  // Called on WebSocket error
  async webSocketError(ws: WebSocket, error: unknown) {
    console.error('WebSocket error:', error)
    ws.close(1011, 'Internal error')
  }
}
```

### Rate Limiter Pattern

```typescript
export class RateLimiter extends DurableObject {
  private requests: number[] = []

  async checkLimit(
    maxRequests: number = 100,
    windowMs: number = 60000
  ): Promise<{ allowed: boolean; remaining: number }> {
    const now = Date.now()
    const windowStart = now - windowMs

    // Remove old requests
    this.requests = this.requests.filter(t => t > windowStart)

    if (this.requests.length >= maxRequests) {
      return {
        allowed: false,
        remaining: 0,
      }
    }

    this.requests.push(now)

    return {
      allowed: true,
      remaining: maxRequests - this.requests.length,
    }
  }
}

// Usage in Worker
async function handleWithRateLimit(request: Request, env: Env) {
  const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown'
  const id = env.RATE_LIMITER.idFromName(ip)
  const limiter = env.RATE_LIMITER.get(id)

  const { allowed, remaining } = await limiter.checkLimit(100, 60000)

  if (!allowed) {
    return new Response('Rate limit exceeded', {
      status: 429,
      headers: { 'X-RateLimit-Remaining': '0' },
    })
  }

  const response = await handleRequest(request, env)
  return new Response(response.body, {
    ...response,
    headers: {
      ...Object.fromEntries(response.headers),
      'X-RateLimit-Remaining': remaining.toString(),
    },
  })
}
```

### Using Alarms

```typescript
export class ScheduledTask extends DurableObject {
  async scheduleTask(delayMs: number, data: unknown) {
    // Store task data
    await this.ctx.storage.put('taskData', data)

    // Schedule alarm
    await this.ctx.storage.setAlarm(Date.now() + delayMs)
  }

  // Called when alarm fires
  async alarm() {
    const taskData = await this.ctx.storage.get('taskData')

    if (taskData) {
      await this.processTask(taskData)
      await this.ctx.storage.delete('taskData')
    }
  }

  private async processTask(data: unknown) {
    // Process the scheduled task
    console.log('Processing task:', data)
  }
}
```

### Hono Integration

```typescript
import { Hono } from 'hono'

type Bindings = {
  COUNTER: DurableObjectNamespace<Counter>
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/counters/:name/increment', async (c) => {
  const name = c.req.param('name')
  const id = c.env.COUNTER.idFromName(name)
  const counter = c.env.COUNTER.get(id)

  const count = await counter.increment()
  return c.json({ name, count })
})

app.get('/counters/:name', async (c) => {
  const name = c.req.param('name')
  const id = c.env.COUNTER.idFromName(name)
  const counter = c.env.COUNTER.get(id)

  const count = await counter.getCount()
  return c.json({ name, count })
})
```

## Wrangler Configuration

```toml
[[durable_objects.bindings]]
name = "COUNTER"
class_name = "Counter"

[[durable_objects.bindings]]
name = "CHAT_ROOM"
class_name = "ChatRoom"

[[migrations]]
tag = "v1"
new_classes = ["Counter", "ChatRoom"]

# For deleting classes
# [[migrations]]
# tag = "v2"
# deleted_classes = ["OldClass"]
```

## Durable Object Limits

| Resource | Limit |
|----------|-------|
| Storage per object | 10GB |
| Storage key size | 2KB |
| Storage value size | 128KB |
| WebSocket connections per object | 32,768 |
| Subrequests per invocation | 50 (1000 unbound) |

---

## Common Mistakes

### 1. Using Legacy WebSocket accept() Instead of Hibernation

```typescript
// ❌ WRONG - Legacy approach, no hibernation
async fetch(request: Request) {
  const pair = new WebSocketPair()
  const [client, server] = Object.values(pair)
  server.accept() // Legacy - don't use!
  server.addEventListener('message', (event) => {
    // Handler
  })
  return new Response(null, { status: 101, webSocket: client })
}

// ✅ CORRECT - Hibernatable WebSockets API
async fetch(request: Request) {
  const pair = new WebSocketPair()
  const [client, server] = Object.values(pair)
  this.ctx.acceptWebSocket(server) // Use ctx.acceptWebSocket
  return new Response(null, { status: 101, webSocket: client })
}

// Implement handler methods instead of addEventListener
async webSocketMessage(ws: WebSocket, message: string | ArrayBuffer) {
  // Handle message
}
```

### 2. Not Using blockConcurrencyWhile for Initialization

```typescript
// ❌ WRONG - Race condition during initialization
export class MyDO extends DurableObject {
  private data: Map<string, string>

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)
    // Async init without blocking - other requests may arrive!
    this.loadData()
  }

  async loadData() {
    this.data = await this.ctx.storage.get('data') ?? new Map()
  }
}

// ✅ CORRECT - Block until initialization complete
export class MyDO extends DurableObject {
  private data: Map<string, string>

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)
    ctx.blockConcurrencyWhile(async () => {
      this.data = await ctx.storage.get('data') ?? new Map()
    })
  }
}
```

### 3. Multiple Storage Operations Without Batching

```typescript
// ❌ WRONG - Multiple round trips
async updateUser(id: string, data: UserData) {
  await this.ctx.storage.put(`user:${id}:name`, data.name)
  await this.ctx.storage.put(`user:${id}:email`, data.email)
  await this.ctx.storage.put(`user:${id}:role`, data.role)
}

// ✅ CORRECT - Single batch operation
async updateUser(id: string, data: UserData) {
  await this.ctx.storage.put({
    [`user:${id}:name`]: data.name,
    [`user:${id}:email`]: data.email,
    [`user:${id}:role`]: data.role,
  })
}
```

### 4. Accessing Storage Outside Input Gate

```typescript
// ❌ WRONG - Storage access can be slow outside input gate
async fetch(request: Request) {
  const data = await this.ctx.storage.get('data')
  // Long-running operation
  await processData(data)
  // Another storage access - may have stale view
  const updated = await this.ctx.storage.get('data')
}

// ✅ CORRECT - Use atomic operations for consistency
async fetch(request: Request) {
  await this.ctx.storage.transaction(async (txn) => {
    const data = await txn.get('data')
    const result = await processData(data)
    await txn.put('data', result)
  })
}
```

### 5. Confusing D1 vs Durable Objects SQL

| Use D1 When | Use DO SQL When |
|-------------|-----------------|
| Traditional database needs | Real-time, low-latency |
| External access needed | Worker-only access |
| Built-in tooling required | Custom requirements |
| Shared data across requests | Per-entity isolation |
| Network latency acceptable | Colocated compute + storage |

### 6. Not Handling WebSocket Errors

```typescript
// ❌ WRONG - Missing error handler
export class ChatRoom extends DurableObject {
  webSocketMessage(ws: WebSocket, message: string) { /* ... */ }
  webSocketClose(ws: WebSocket, code: number) { /* ... */ }
  // Missing webSocketError!
}

// ✅ CORRECT - Handle all WebSocket events
export class ChatRoom extends DurableObject {
  webSocketMessage(ws: WebSocket, message: string) { /* ... */ }
  webSocketClose(ws: WebSocket, code: number, reason: string) { /* ... */ }
  webSocketError(ws: WebSocket, error: unknown) {
    console.error('WebSocket error:', error)
    // Clean up connection state
  }
}
```

