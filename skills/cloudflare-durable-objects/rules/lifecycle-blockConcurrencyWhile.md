---
title: Use blockConcurrencyWhile for Initialization
impact: CRITICAL
impactDescription: Prevents race conditions during async state loading
tags: lifecycle, concurrency, initialization
---

## Use blockConcurrencyWhile for Initialization

Use `ctx.blockConcurrencyWhile()` in the constructor to load state from storage before handling any requests.

**Incorrect (race condition during initialization):**

```typescript
export class Counter extends DurableObject {
  private count: number = 0
  private initialized = false

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)

    // ❌ This runs async but constructor returns immediately
    this.loadState()
  }

  private async loadState() {
    // ❌ Requests might arrive before this completes!
    this.count = (await this.ctx.storage.get<number>('count')) ?? 0
    this.initialized = true
  }

  async increment(): Promise<number> {
    // ❌ Might run before loadState completes - wrong count!
    this.count++
    await this.ctx.storage.put('count', this.count)
    return this.count
  }
}
```

**Correct (blockConcurrencyWhile ensures initialization completes first):**

```typescript
export class Counter extends DurableObject {
  private count: number = 0

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)

    // ✅ Blocks ALL incoming requests until this completes
    this.ctx.blockConcurrencyWhile(async () => {
      const stored = await this.ctx.storage.get<number>('count')
      this.count = stored ?? 0

      // Can do multiple async operations
      // All will complete before any request is processed
    })
  }

  async increment(): Promise<number> {
    // ✅ Guaranteed to run AFTER initialization completes
    this.count++
    await this.ctx.storage.put('count', this.count)
    return this.count
  }

  async getCount(): Promise<number> {
    return this.count
  }
}

// ✅ More complex initialization example
export class UserSession extends DurableObject {
  private user: User | null = null
  private permissions: Set<string> = new Set()
  private lastAccess: number = 0

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)

    this.ctx.blockConcurrencyWhile(async () => {
      // Load multiple pieces of state
      const [user, permissions, lastAccess] = await Promise.all([
        this.ctx.storage.get<User>('user'),
        this.ctx.storage.get<string[]>('permissions'),
        this.ctx.storage.get<number>('lastAccess'),
      ])

      this.user = user ?? null
      this.permissions = new Set(permissions ?? [])
      this.lastAccess = lastAccess ?? Date.now()

      // Update last access timestamp
      await this.ctx.storage.put('lastAccess', Date.now())
    })
  }

  async getUser(): Promise<User | null> {
    return this.user
  }

  async hasPermission(permission: string): Promise<boolean> {
    return this.permissions.has(permission)
  }
}
```

**Key points:**
- `blockConcurrencyWhile` queues ALL incoming requests until the promise resolves
- Only call it in the constructor - calling it elsewhere blocks new requests
- The DO is single-threaded, so state loaded here is safe to use in handlers
