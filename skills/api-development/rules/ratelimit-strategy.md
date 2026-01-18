---
title: Rate Limiting Strategies
impact: CRITICAL
impactDescription: Protects API from abuse and ensures fair usage
tags: rate-limiting, security, throttling
---

## Rate Limiting Strategies

Implement rate limiting to protect your API from abuse, ensure fair usage across clients, and maintain system stability.

**Incorrect (no rate limiting or poor implementation):**

```typescript
// No rate limiting at all
export async function handler(request: Request) {
  return processRequest(request) // Unlimited requests!
}

// Rate limit only by IP (easily bypassed)
const count = await redis.incr(`ratelimit:${clientIp}`)

// No rate limit headers (clients can't adapt)
if (isRateLimited) {
  return new Response('Too many requests', { status: 429 })
}
```

**Correct (comprehensive rate limiting):**

```typescript
interface RateLimitConfig {
  requests: number  // Max requests
  window: number    // Time window in seconds
}

// Tiered rate limits
const rateLimits: Record<string, RateLimitConfig> = {
  free: { requests: 100, window: 60 },       // 100/min
  pro: { requests: 1000, window: 60 },       // 1000/min
  enterprise: { requests: 10000, window: 60 }, // 10000/min
  anonymous: { requests: 20, window: 60 },   // 20/min for unauthenticated
}

// Rate limit by API key (primary) with IP fallback
async function checkRateLimit(
  request: Request,
  ctx: Context
): Promise<{ allowed: boolean; limit: number; remaining: number; reset: number }> {
  const apiKey = ctx.custom.apiKey
  const tier = apiKey?.tier || 'anonymous'
  const config = rateLimits[tier]

  // Use API key ID if authenticated, otherwise IP
  const identifier = apiKey?.id || getClientIp(request)
  const key = `ratelimit:${identifier}:${Math.floor(Date.now() / 1000 / config.window)}`

  // Atomic increment with expiration
  const current = await redis.incr(key)
  if (current === 1) {
    await redis.expire(key, config.window)
  }

  const reset = Math.ceil(Date.now() / 1000 / config.window) * config.window

  return {
    allowed: current <= config.requests,
    limit: config.requests,
    remaining: Math.max(0, config.requests - current),
    reset,
  }
}

// Apply rate limiting middleware
export async function rateLimitMiddleware(
  request: Request,
  ctx: Context
): Promise<Response | null> {
  const { allowed, limit, remaining, reset } = await checkRateLimit(request, ctx)

  // Store for response headers
  ctx.custom.rateLimit = { limit, remaining, reset }

  if (!allowed) {
    return new Response(JSON.stringify({
      error: {
        code: 'RATE_LIMIT_EXCEEDED',
        message: 'Too many requests. Please slow down.',
        retryAfter: reset - Math.floor(Date.now() / 1000),
        requestId: ctx.custom.requestId,
      },
    }), {
      status: 429,
      headers: {
        'Content-Type': 'application/json',
        'Retry-After': (reset - Math.floor(Date.now() / 1000)).toString(),
        'X-RateLimit-Limit': limit.toString(),
        'X-RateLimit-Remaining': '0',
        'X-RateLimit-Reset': reset.toString(),
      },
    })
  }

  return null // Continue to handler
}

// Add rate limit headers to all responses
export function addRateLimitHeaders(response: Response, ctx: Context): Response {
  const { limit, remaining, reset } = ctx.custom.rateLimit || {}

  if (limit !== undefined) {
    const headers = new Headers(response.headers)
    headers.set('X-RateLimit-Limit', limit.toString())
    headers.set('X-RateLimit-Remaining', remaining.toString())
    headers.set('X-RateLimit-Reset', reset.toString())
    return new Response(response.body, { status: response.status, headers })
  }

  return response
}
```

**Per-Endpoint Rate Limits:**

```typescript
// Different limits for different operations
const endpointLimits: Record<string, RateLimitConfig> = {
  'POST /api/v1/auth/login': { requests: 5, window: 60 },      // 5/min
  'POST /api/v1/auth/signup': { requests: 3, window: 3600 },   // 3/hour
  'POST /api/v1/emails/send': { requests: 100, window: 3600 }, // 100/hour
  'GET /api/v1/search': { requests: 30, window: 60 },          // 30/min
  'default': { requests: 1000, window: 60 },                   // Default
}

function getEndpointLimit(method: string, path: string): RateLimitConfig {
  const key = `${method} ${path}`
  return endpointLimits[key] || endpointLimits.default
}
```

**Sliding Window Algorithm:**

```typescript
// More accurate than fixed windows
async function slidingWindowRateLimit(
  identifier: string,
  limit: number,
  windowSeconds: number
): Promise<{ allowed: boolean; remaining: number }> {
  const now = Date.now()
  const windowStart = now - windowSeconds * 1000
  const key = `ratelimit:sliding:${identifier}`

  // Remove old entries and count recent ones
  await redis.zremrangebyscore(key, 0, windowStart)
  const count = await redis.zcard(key)

  if (count >= limit) {
    return { allowed: false, remaining: 0 }
  }

  // Add current request
  await redis.zadd(key, now, `${now}:${crypto.randomUUID()}`)
  await redis.expire(key, windowSeconds)

  return { allowed: true, remaining: limit - count - 1 }
}
```

**Standard Rate Limit Headers:**

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Max requests in window |
| `X-RateLimit-Remaining` | Remaining requests |
| `X-RateLimit-Reset` | Unix timestamp when limit resets |
| `Retry-After` | Seconds to wait (on 429) |
