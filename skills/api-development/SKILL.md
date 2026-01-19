---
name: api-development
description: Best practices for building production APIs at the edge. Use when designing API endpoints, implementing authentication, rate limiting, error handling, versioning, or building developer-facing APIs. Triggers on "API design", "REST API", "rate limiting", "API authentication", "error handling", "API versioning", "developer portal".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# API Development Best Practices

Comprehensive guide for building production-grade APIs at the edge.

## When to Apply

Reference these guidelines when:
- Designing new API endpoints
- Implementing authentication and authorization
- Adding rate limiting and throttling
- Defining error responses and status codes
- Versioning APIs for backward compatibility
- Building developer portals and documentation
- Optimizing API performance at the edge

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | API Design | CRITICAL | `design-` |
| 2 | Authentication | CRITICAL | `auth-` |
| 3 | Rate Limiting | CRITICAL | `ratelimit-` |
| 4 | Error Handling | HIGH | `errors-` |
| 5 | Versioning | HIGH | `version-` |
| 6 | Security | HIGH | `security-` |
| 7 | Observability | MEDIUM | `observability-` |
| 8 | Performance | MEDIUM | `perf-` |

## Quick Reference

### 1. API Design (CRITICAL)

- `design-rest-conventions` - RESTful naming and HTTP methods

### 2. Authentication (CRITICAL)

- `auth-api-keys` - Secure API key management

### 3. Rate Limiting (CRITICAL)

- `ratelimit-strategy` - Rate limiting strategies

### 4. Error Handling (HIGH)

- `errors-response-format` - Structured error responses

### 5. Versioning (HIGH)

- `version-strategy` - API versioning approaches

### 6. Security (HIGH)

- `security-input-validation` - Input sanitization

### 7. Observability (MEDIUM)

- `observability-request-id` - Request correlation IDs

### 8. Performance (MEDIUM)

- `perf-edge-caching` - Edge caching strategies

## Essential Patterns

### RESTful API Design

```typescript
// Resource-based URLs with consistent naming
// ✓ Good: Nouns, plural, lowercase, kebab-case
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

// Nested resources for relationships
GET    /api/v1/users/:id/orders
GET    /api/v1/users/:id/orders/:orderId

// Query parameters for filtering, sorting, pagination
GET    /api/v1/users?status=active&sort=-created_at&limit=20&offset=0

// ✗ Bad: Verbs in URLs, inconsistent naming
GET    /api/v1/getUser/:id
POST   /api/v1/createNewUser
GET    /api/v1/user_orders/:userId
```

### Request Validation

```typescript
import { z } from 'zod'

// Define strict schemas for all inputs
const createUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin', 'viewer']).default('user'),
  metadata: z.record(z.string()).optional(),
})

// Validate at the edge before processing
export async function handleCreateUser(request: Request, ctx: Context) {
  const body = await request.json()

  const result = createUserSchema.safeParse(body)
  if (!result.success) {
    return new Response(JSON.stringify({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid request body',
        details: result.error.issues.map(issue => ({
          field: issue.path.join('.'),
          message: issue.message,
        })),
      },
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Process validated data
  const user = await createUser(result.data)
  return Response.json(user, { status: 201 })
}
```

### Standardized Response Format

```typescript
// Success response structure
interface SuccessResponse<T> {
  data: T
  meta?: {
    pagination?: {
      total: number
      limit: number
      offset: number
      hasMore: boolean
    }
    requestId: string
  }
}

// Error response structure
interface ErrorResponse {
  error: {
    code: string           // Machine-readable: 'RATE_LIMIT_EXCEEDED'
    message: string        // Human-readable: 'Too many requests'
    details?: Array<{      // Optional field-level details
      field?: string
      message: string
    }>
    requestId: string      // For support/debugging
  }
}

// Implementation
function successResponse<T>(data: T, meta?: object): Response {
  return Response.json({ data, meta }, { status: 200 })
}

function errorResponse(
  status: number,
  code: string,
  message: string,
  details?: any[],
  requestId?: string
): Response {
  return Response.json({
    error: { code, message, details, requestId }
  }, { status })
}
```

### API Key Authentication

```typescript
// API key should be in header, not URL
// ✓ Good: Authorization header
const apiKey = request.headers.get('Authorization')?.replace('Bearer ', '')

// ✗ Bad: Query parameter (logged in URLs)
const apiKey = url.searchParams.get('api_key')

// Validate API key
export async function authenticateApiKey(
  request: Request,
  ctx: Context
): Promise<Response | null> {
  const authHeader = request.headers.get('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    return errorResponse(401, 'UNAUTHORIZED', 'Missing or invalid Authorization header')
  }

  const apiKey = authHeader.slice(7)
  const keyData = await validateApiKey(apiKey)

  if (!keyData) {
    return errorResponse(401, 'INVALID_API_KEY', 'API key is invalid or expired')
  }

  // Check scopes for this endpoint
  if (!keyData.scopes.includes(ctx.route.requiredScope)) {
    return errorResponse(403, 'INSUFFICIENT_SCOPE',
      `This endpoint requires the '${ctx.route.requiredScope}' scope`)
  }

  // Attach to context for downstream use
  ctx.custom.apiKey = keyData
  ctx.custom.userId = keyData.userId

  return null // Continue to handler
}
```

### Rate Limiting

```typescript
// Rate limit configuration by tier
const rateLimits = {
  free: { requests: 100, window: 60 },     // 100/min
  pro: { requests: 1000, window: 60 },     // 1000/min
  enterprise: { requests: 10000, window: 60 }, // 10000/min
}

// Rate limit response headers
function addRateLimitHeaders(
  response: Response,
  limit: number,
  remaining: number,
  reset: number
): Response {
  const headers = new Headers(response.headers)
  headers.set('X-RateLimit-Limit', limit.toString())
  headers.set('X-RateLimit-Remaining', Math.max(0, remaining).toString())
  headers.set('X-RateLimit-Reset', reset.toString())

  return new Response(response.body, {
    status: response.status,
    headers,
  })
}

// Rate limit exceeded response
function rateLimitExceeded(reset: number, requestId: string): Response {
  return new Response(JSON.stringify({
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests. Please retry after the reset time.',
      requestId,
    },
  }), {
    status: 429,
    headers: {
      'Content-Type': 'application/json',
      'Retry-After': Math.ceil(reset - Date.now() / 1000).toString(),
      'X-RateLimit-Remaining': '0',
      'X-RateLimit-Reset': reset.toString(),
    },
  })
}
```

### HTTP Status Codes

```typescript
// Use correct status codes
const STATUS_CODES = {
  // Success
  200: 'OK',              // GET, PATCH success
  201: 'Created',         // POST success (resource created)
  204: 'No Content',      // DELETE success

  // Client errors
  400: 'Bad Request',     // Validation error, malformed request
  401: 'Unauthorized',    // Missing or invalid authentication
  403: 'Forbidden',       // Valid auth but insufficient permissions
  404: 'Not Found',       // Resource doesn't exist
  409: 'Conflict',        // Resource conflict (e.g., duplicate)
  422: 'Unprocessable',   // Semantic validation error
  429: 'Too Many Requests', // Rate limit exceeded

  // Server errors
  500: 'Internal Error',  // Unexpected server error
  502: 'Bad Gateway',     // Upstream service error
  503: 'Service Unavailable', // Temporarily unavailable
  504: 'Gateway Timeout', // Upstream timeout
}

// Map errors to status codes
function getStatusCode(error: AppError): number {
  switch (error.code) {
    case 'VALIDATION_ERROR': return 400
    case 'UNAUTHORIZED': return 401
    case 'FORBIDDEN': return 403
    case 'NOT_FOUND': return 404
    case 'CONFLICT': return 409
    case 'RATE_LIMIT_EXCEEDED': return 429
    default: return 500
  }
}
```

### API Versioning

```typescript
// Version in URL path (recommended)
// /api/v1/users
// /api/v2/users

// Version routing
export function routeByVersion(request: Request): Response {
  const url = new URL(request.url)
  const version = url.pathname.match(/^\/api\/v(\d+)/)?.[1]

  switch (version) {
    case '1':
      return handleV1(request)
    case '2':
      return handleV2(request)
    default:
      return errorResponse(400, 'INVALID_VERSION',
        'API version not specified. Use /api/v1/ or /api/v2/')
  }
}

// Deprecation headers
function addDeprecationHeaders(response: Response, sunset: Date): Response {
  const headers = new Headers(response.headers)
  headers.set('Deprecation', 'true')
  headers.set('Sunset', sunset.toUTCString())
  headers.set('Link', '</api/v2/users>; rel="successor-version"')
  return new Response(response.body, { status: response.status, headers })
}
```

### Request Correlation

```typescript
// Generate or use existing request ID
function getRequestId(request: Request): string {
  return request.headers.get('X-Request-ID') ||
         request.headers.get('X-Correlation-ID') ||
         crypto.randomUUID()
}

// Include in all responses
function withRequestId(response: Response, requestId: string): Response {
  const headers = new Headers(response.headers)
  headers.set('X-Request-ID', requestId)
  return new Response(response.body, { status: response.status, headers })
}

// Include in all logs
function log(level: string, message: string, ctx: Context) {
  console.log(JSON.stringify({
    level,
    message,
    requestId: ctx.custom.requestId,
    route: ctx.route.path,
    method: ctx.request.method,
    timestamp: new Date().toISOString(),
  }))
}
```

### Edge Caching

```typescript
// Cache GET requests at the edge
function cacheableResponse(
  data: any,
  options: { maxAge?: number; staleWhileRevalidate?: number } = {}
): Response {
  const { maxAge = 60, staleWhileRevalidate = 300 } = options

  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': `public, max-age=${maxAge}, stale-while-revalidate=${staleWhileRevalidate}`,
      'CDN-Cache-Control': `max-age=${maxAge * 2}`,
      'Vary': 'Authorization, Accept-Encoding',
    },
  })
}

// Never cache authenticated or mutating requests
function noCacheResponse(data: any): Response {
  return new Response(JSON.stringify({ data }), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'private, no-store, must-revalidate',
    },
  })
}
```

### Pagination

```typescript
// Cursor-based pagination (recommended for large datasets)
interface PaginatedResponse<T> {
  data: T[]
  meta: {
    nextCursor: string | null
    hasMore: boolean
  }
}

// Offset-based pagination (simpler but less efficient)
interface OffsetPaginatedResponse<T> {
  data: T[]
  meta: {
    total: number
    limit: number
    offset: number
    hasMore: boolean
  }
}

// Implementation
async function paginatedList(
  request: Request,
  query: QueryBuilder
): Promise<Response> {
  const url = new URL(request.url)
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 100)
  const cursor = url.searchParams.get('cursor')

  const items = await query
    .where(cursor ? { id: { gt: cursor } } : {})
    .limit(limit + 1) // Fetch one extra to check hasMore
    .execute()

  const hasMore = items.length > limit
  const data = hasMore ? items.slice(0, -1) : items

  return Response.json({
    data,
    meta: {
      nextCursor: hasMore ? data[data.length - 1].id : null,
      hasMore,
    },
  })
}
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Verbs in URLs | `/getUser`, `/createOrder` | Use HTTP methods: `GET /users`, `POST /orders` |
| API key in URL | Logged, cached, leaked | Use `Authorization` header |
| No rate limiting | Abuse, DDoS vulnerability | Implement tiered rate limits |
| Generic error messages | Poor DX, hard to debug | Include error code, details, requestId |
| No versioning | Breaking changes affect all clients | Version in URL path |
| Missing request ID | Can't trace issues | Generate/propagate correlation ID |
| Inconsistent naming | Confusing API surface | Use consistent conventions |

## Developer Experience Checklist

- [ ] OpenAPI/Swagger spec generated from code
- [ ] Interactive API documentation
- [ ] Code examples in multiple languages
- [ ] Sandbox/test environment available
- [ ] API key self-service management
- [ ] Clear error messages with solutions
- [ ] Deprecation notices with migration guides
- [ ] Webhook debugging tools
- [ ] Rate limit dashboard
- [ ] Status page for API health
