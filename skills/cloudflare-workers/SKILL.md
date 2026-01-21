---
name: cloudflare-workers
description: Best practices for building and deploying Cloudflare Workers. Use when creating Workers, configuring bindings, handling requests at the edge, or optimizing Worker performance. Triggers on "create worker", "edge function", "serverless", "Cloudflare deployment".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.1.0"
---

# Cloudflare Workers Best Practices

Comprehensive guide for building production-ready Cloudflare Workers.

## What's New (2025-2026)

| Feature | Date | Description |
|---------|------|-------------|
| V8 v14.4 | Jan 2026 | Latest JS engine |
| WebSocket 32 MiB | Oct 2025 | Increased from 1 MiB |
| node:fs & Web File System | Sep 2025 | File APIs available |
| MessageChannel/MessagePort | Aug 2025 | Web APIs |
| Float16Array | May 2025 | New typed array |
| Smart Placement improvements | Mar 2025 | Better heuristics |
| `nodejs_compat_v2` | 2025 | Includes `process.env` from text bindings |

## Configuration

```jsonc
// wrangler.jsonc
{
  "$schema": "./node_modules/wrangler/config-schema.json",
  "compatibility_date": "2026-01-01",
  "compatibility_flags": ["nodejs_compat"],
  "observability": { "enabled": true },
  "placement": { "mode": "smart" }
}
```

## When to Apply

Reference these guidelines when:
- Creating new Cloudflare Workers
- Configuring environment bindings (KV, D1, R2, Durable Objects)
- Handling HTTP requests at the edge
- Optimizing for cold start and execution time
- Implementing caching strategies

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Request Handling | CRITICAL | `request-` |
| 2 | Bindings & Environment | CRITICAL | `bindings-` |
| 3 | Caching | HIGH | `cache-` |
| 4 | Performance | HIGH | `perf-` |
| 5 | Security | MEDIUM-HIGH | `security-` |

## Quick Reference

### 1. Request Handling (CRITICAL)

- `request-response-clone` - Clone requests/responses when reading body multiple times
- `request-streaming` - Stream large request/response bodies
- `request-headers-immutable` - Headers are immutable, create new Response to modify
- `request-body-once` - Request body can only be read once
- `request-cf-properties` - Use request.cf for geolocation and client info

### 2. Bindings & Environment (CRITICAL)

- `bindings-type-safety` - Type all environment bindings
- `bindings-lazy-access` - Access bindings lazily, not at module level
- `bindings-secrets` - Use secrets for sensitive values
- `bindings-service-bindings` - Use service bindings for Worker-to-Worker calls
- `bindings-analytics-engine` - Use Analytics Engine for metrics

### 3. Caching (HIGH)

- `cache-api` - Use Cache API for custom caching logic
- `cache-headers` - Set appropriate Cache-Control headers
- `cache-vary` - Use Vary header for content negotiation
- `cache-purge` - Implement cache invalidation strategies
- `cache-bypass` - Know when to bypass cache

### 4. Performance (HIGH)

- `perf-avoid-blocking` - Never block the event loop
- `perf-streams` - Use streams for large payloads
- `perf-cpu-limits` - Stay within CPU time limits
- `perf-memory` - Monitor memory usage
- `perf-subrequests` - Minimize subrequest count (max 50 per request)

### 5. Security (MEDIUM-HIGH)

- `security-validate-input` - Validate all input
- `security-cors` - Configure CORS properly
- `security-rate-limiting` - Implement rate limiting
- `security-headers` - Set security headers
- `security-origin-check` - Verify request origins

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/request-streaming.md
rules/bindings-type-safety.md
rules/cache-api.md
```

## Essential Patterns

### Basic Worker Setup

```typescript
export interface Env {
  DB: D1Database
  CACHE: KVNamespace
  BUCKET: R2Bucket
  API_KEY: string
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url)

    // Route handling
    if (url.pathname === '/api/data') {
      return handleData(request, env, ctx)
    }

    return new Response('Not Found', { status: 404 })
  }
}
```

### Using waitUntil for Background Tasks

```typescript
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    // Handle request immediately
    const response = await handleRequest(request, env)

    // Background task that doesn't block response
    ctx.waitUntil(
      logAnalytics(env.ANALYTICS, request, response)
    )

    return response
  }
}
```

### Caching Pattern

```typescript
async function handleWithCache(request: Request, env: Env, ctx: ExecutionContext) {
  const cache = caches.default
  const cacheKey = new Request(request.url, request)

  // Check cache first
  let response = await cache.match(cacheKey)

  if (!response) {
    // Generate fresh response
    response = await generateResponse(request, env)

    // Clone before caching (response body can only be read once)
    const responseToCache = response.clone()

    // Cache in background
    ctx.waitUntil(cache.put(cacheKey, responseToCache))
  }

  return response
}
```

### Request Geolocation

```typescript
async function handleRequest(request: Request) {
  const cf = request.cf

  if (cf) {
    const country = cf.country      // "US"
    const city = cf.city            // "San Francisco"
    const timezone = cf.timezone    // "America/Los_Angeles"
    const colo = cf.colo            // "SFO"

    // Route to nearest datacenter or customize response
  }

  return new Response('Hello from the edge!')
}
```

## Worker Limits

| Resource | Free | Paid |
|----------|------|------|
| CPU time | 10ms | 30s (50ms default) |
| Memory | 128MB | 128MB |
| Subrequests | 50 | 50 (1000 with unbound) |
| Script size | 1MB | 10MB |

