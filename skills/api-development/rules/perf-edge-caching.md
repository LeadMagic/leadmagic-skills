---
title: Edge Caching Strategies
impact: MEDIUM
impactDescription: Reduces latency and backend load
tags: caching, performance, edge, cdn
---

## Edge Caching Strategies

Cache responses at the edge to reduce latency and backend load. Use appropriate caching strategies based on data freshness requirements.

**Incorrect (no caching or improper caching):**

```typescript
// No cache headers - browser/CDN behavior undefined
return Response.json(data)

// Caching authenticated responses publicly
return new Response(JSON.stringify(userData), {
  headers: { 'Cache-Control': 'public, max-age=3600' }
})

// Same cache key for different users
const cacheKey = `/api/orders` // All users get same cached data!

// Never invalidating stale data
cache.set(key, data) // No TTL, stale forever
```

**Correct (strategic caching):**

```typescript
// Public data - cache aggressively at edge
function cacheablePublicResponse(data: any, options: {
  maxAge?: number           // Browser cache duration
  sMaxAge?: number          // CDN cache duration
  staleWhileRevalidate?: number
} = {}): Response {
  const { maxAge = 60, sMaxAge = 300, staleWhileRevalidate = 600 } = options

  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': `public, max-age=${maxAge}, s-maxage=${sMaxAge}, stale-while-revalidate=${staleWhileRevalidate}`,
      'CDN-Cache-Control': `max-age=${sMaxAge}`,
      'Vary': 'Accept-Encoding',
    },
  })
}

// Private data - cache only in browser, not CDN
function cacheablePrivateResponse(data: any, maxAge = 60): Response {
  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': `private, max-age=${maxAge}`,
    },
  })
}

// Never cache - mutations, sensitive data
function noCacheResponse(data: any): Response {
  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'private, no-store, no-cache, must-revalidate',
      'Pragma': 'no-cache',
    },
  })
}
```

**Cache Key Design:**

```typescript
// Include all varying factors in cache key
function buildCacheKey(request: Request, ctx: Context): string {
  const url = new URL(request.url)
  const parts = [
    'api',
    ctx.route.version,
    url.pathname,
    // Include query params that affect response
    url.searchParams.get('sort') || 'default',
    url.searchParams.get('filter') || 'none',
  ]

  // For user-specific data, include user ID
  if (ctx.custom.userId) {
    parts.push(`user:${ctx.custom.userId}`)
  }

  return parts.join(':')
}

// Using Cloudflare Cache API
async function cachedHandler(request: Request, ctx: Context): Promise<Response> {
  const cache = caches.default
  const cacheKey = new Request(buildCacheKey(request, ctx), request)

  // Check cache
  let response = await cache.match(cacheKey)

  if (response) {
    // Add cache hit header for debugging
    response = new Response(response.body, response)
    response.headers.set('X-Cache', 'HIT')
    return response
  }

  // Generate response
  response = await generateResponse(request, ctx)

  // Only cache successful GET responses
  if (request.method === 'GET' && response.status === 200) {
    response.headers.set('X-Cache', 'MISS')
    ctx.waitUntil(cache.put(cacheKey, response.clone()))
  }

  return response
}
```

**Conditional Requests (ETag):**

```typescript
// Generate ETag from content
function generateETag(data: any): string {
  const content = JSON.stringify(data)
  const hash = crypto.createHash('md5').update(content).digest('hex')
  return `"${hash}"`
}

// Handle conditional requests
async function handleConditionalRequest(
  request: Request,
  data: any
): Promise<Response> {
  const etag = generateETag(data)
  const ifNoneMatch = request.headers.get('If-None-Match')

  // Client has current version
  if (ifNoneMatch === etag) {
    return new Response(null, {
      status: 304,
      headers: { 'ETag': etag },
    })
  }

  // Return full response with ETag
  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'ETag': etag,
      'Cache-Control': 'private, max-age=0, must-revalidate',
    },
  })
}
```

**Cache Invalidation:**

```typescript
// Purge cache on mutation
async function invalidateCache(patterns: string[]): Promise<void> {
  const cache = caches.default

  for (const pattern of patterns) {
    // Purge specific keys
    await cache.delete(new Request(pattern))
  }
}

// Usage in mutation handler
async function updateUser(request: Request, ctx: Context) {
  const userId = ctx.params.id
  const data = await request.json()

  const user = await db.users.update({
    where: { id: userId },
    data,
  })

  // Invalidate related caches
  ctx.waitUntil(invalidateCache([
    `api:v1:/api/v1/users/${userId}`,
    `api:v1:/api/v1/users:user:${userId}`,
  ]))

  return noCacheResponse(user)
}
```

**Caching by Endpoint Type:**

```typescript
const cacheStrategies = {
  // Static reference data - cache for hours
  'GET /api/v1/countries': { maxAge: 3600, sMaxAge: 86400 },
  'GET /api/v1/currencies': { maxAge: 3600, sMaxAge: 86400 },

  // Semi-static data - cache for minutes
  'GET /api/v1/products': { maxAge: 60, sMaxAge: 300 },
  'GET /api/v1/categories': { maxAge: 60, sMaxAge: 300 },

  // User-specific data - short browser cache only
  'GET /api/v1/me': { maxAge: 30, private: true },
  'GET /api/v1/orders': { maxAge: 30, private: true },

  // Real-time data - never cache
  'GET /api/v1/notifications': { noCache: true },
  'POST *': { noCache: true },
  'PATCH *': { noCache: true },
  'DELETE *': { noCache: true },
}

function getCacheStrategy(method: string, path: string) {
  return cacheStrategies[`${method} ${path}`] ||
         cacheStrategies[`${method} *`] ||
         { maxAge: 0 }
}
```

**Cache Headers Reference:**

| Header | Purpose |
|--------|---------|
| `Cache-Control: public` | CDN and browser can cache |
| `Cache-Control: private` | Only browser can cache |
| `max-age=N` | Cache for N seconds in browser |
| `s-maxage=N` | Cache for N seconds in CDN |
| `stale-while-revalidate=N` | Serve stale while fetching fresh |
| `no-store` | Never cache |
| `must-revalidate` | Always check freshness |
| `Vary: Header` | Cache varies by this header |
| `ETag` | Content fingerprint for conditional requests |
