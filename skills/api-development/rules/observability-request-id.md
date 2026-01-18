---
title: Request Correlation IDs
impact: MEDIUM
impactDescription: Essential for debugging and support
tags: observability, logging, tracing, debugging
---

## Request Correlation IDs

Every request needs a unique identifier for tracing across services, debugging issues, and customer support.

**Incorrect (no request tracking):**

```typescript
// No request ID
export async function handler(request: Request) {
  console.log('Processing request') // Which request?

  try {
    return await processRequest(request)
  } catch (error) {
    console.error('Error:', error) // Can't correlate with user report
    return new Response('Error', { status: 500 })
  }
}

// ID not propagated to response
const requestId = crypto.randomUUID()
console.log({ requestId, message: 'Processing' })
return Response.json(data) // Client can't reference this request
```

**Correct (full request correlation):**

```typescript
// Extract or generate request ID at edge
function getRequestId(request: Request): string {
  // Honor incoming ID for distributed tracing
  return request.headers.get('X-Request-ID') ||
         request.headers.get('X-Correlation-ID') ||
         request.headers.get('CF-Ray') || // Cloudflare's ID
         `req_${crypto.randomUUID().replace(/-/g, '')}`
}

// Request context setup
export async function handler(request: Request, ctx: Context) {
  const requestId = getRequestId(request)
  ctx.custom.requestId = requestId
  ctx.custom.startTime = Date.now()

  // Log request start
  log('info', 'Request started', ctx, {
    method: request.method,
    path: new URL(request.url).pathname,
    userAgent: request.headers.get('User-Agent'),
  })

  try {
    const response = await processRequest(request, ctx)

    // Log request end
    log('info', 'Request completed', ctx, {
      status: response.status,
      duration: Date.now() - ctx.custom.startTime,
    })

    // Include request ID in response
    return addRequestIdHeader(response, requestId)
  } catch (error) {
    log('error', 'Request failed', ctx, {
      error: error.message,
      stack: error.stack,
      duration: Date.now() - ctx.custom.startTime,
    })

    return errorResponse(500, 'INTERNAL_ERROR',
      'An error occurred. Reference ID: ' + requestId,
      { requestId }
    )
  }
}

// Add to all responses
function addRequestIdHeader(response: Response, requestId: string): Response {
  const headers = new Headers(response.headers)
  headers.set('X-Request-ID', requestId)
  return new Response(response.body, { status: response.status, headers })
}
```

**Structured Logging:**

```typescript
interface LogEntry {
  timestamp: string
  level: 'debug' | 'info' | 'warn' | 'error'
  message: string
  requestId: string
  service: string
  route?: string
  method?: string
  userId?: string
  duration?: number
  [key: string]: any
}

function log(
  level: LogEntry['level'],
  message: string,
  ctx: Context,
  extra: Record<string, any> = {}
) {
  const entry: LogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    requestId: ctx.custom.requestId,
    service: 'api',
    route: ctx.route?.path,
    method: ctx.request?.method,
    userId: ctx.custom.userId,
    ...extra,
  }

  // Output as JSON for log aggregation
  console.log(JSON.stringify(entry))
}

// Usage throughout request lifecycle
log('info', 'User authenticated', ctx, { userId: user.id })
log('warn', 'Rate limit approaching', ctx, { remaining: 10 })
log('error', 'Database query failed', ctx, { query: 'SELECT...', error: err.message })
```

**Propagate to Downstream Services:**

```typescript
// Pass request ID to internal service calls
async function callInternalService(endpoint: string, ctx: Context) {
  return fetch(endpoint, {
    headers: {
      'X-Request-ID': ctx.custom.requestId,
      'X-Forwarded-For': ctx.custom.clientIp,
    },
  })
}

// Pass to database for slow query logging
await db.query(sql, {
  comment: `/* requestId: ${ctx.custom.requestId} */`,
})
```

**Include in Error Responses:**

```typescript
// Always include request ID in errors
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An error occurred. Please contact support with reference ID: req_abc123def456",
    "requestId": "req_abc123def456"
  }
}
```

**Customer Support Flow:**

```
1. Customer reports: "I got an error at 3:15 PM"
2. Customer provides: requestId from error response or X-Request-ID header
3. Support searches logs: grep "req_abc123def456"
4. Full request trace available instantly
```

**Metrics with Request ID:**

```typescript
// Track timing with request context
ctx.custom.timings = {
  total: 0,
  auth: 0,
  database: 0,
  external: 0,
}

const authStart = Date.now()
await authenticate(request, ctx)
ctx.custom.timings.auth = Date.now() - authStart

// Log timings at end of request
log('info', 'Request timings', ctx, { timings: ctx.custom.timings })
```
