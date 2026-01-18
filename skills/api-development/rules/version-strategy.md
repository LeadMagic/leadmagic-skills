---
title: API Versioning Approaches
impact: HIGH
impactDescription: Enables evolution without breaking clients
tags: versioning, compatibility, evolution
---

## API Versioning Approaches

Version your API to evolve without breaking existing clients. Choose a strategy and apply it consistently.

**Incorrect (no versioning or inconsistent):**

```typescript
// No versioning - any change can break clients
GET /api/users

// Mixed versioning strategies
GET /api/v1/users
GET /api/users?version=2
GET /api/users (with Accept: application/vnd.api.v3+json)

// Breaking changes without version bump
// v1 returned: { "name": "John" }
// Now returns: { "firstName": "John", "lastName": "Doe" }
```

**Correct (URL path versioning - recommended):**

```typescript
// Version in URL path - most explicit and cacheable
GET /api/v1/users
GET /api/v2/users

// Route configuration
const routes = {
  '/api/v1/*': handleV1,
  '/api/v2/*': handleV2,
}

// Version extraction
function extractVersion(url: URL): number | null {
  const match = url.pathname.match(/^\/api\/v(\d+)/)
  return match ? parseInt(match[1], 10) : null
}

// Version routing
export async function router(request: Request): Promise<Response> {
  const url = new URL(request.url)
  const version = extractVersion(url)

  if (!version) {
    return errorResponse(400, 'MISSING_VERSION',
      'API version required. Use /api/v1/ or /api/v2/')
  }

  if (version < 1 || version > CURRENT_VERSION) {
    return errorResponse(400, 'INVALID_VERSION',
      `Supported versions: v1 to v${CURRENT_VERSION}`)
  }

  const handler = routes[`/api/v${version}/*`]
  return handler(request)
}
```

**Version-Specific Handlers:**

```typescript
// Shared types with version differences
interface UserV1 {
  id: string
  name: string
  email: string
}

interface UserV2 {
  id: string
  firstName: string
  lastName: string
  email: string
  createdAt: string
}

// V1 handler
async function getUserV1(id: string): Promise<UserV1> {
  const user = await db.users.findById(id)
  return {
    id: user.id,
    name: `${user.firstName} ${user.lastName}`, // Combine for v1
    email: user.email,
  }
}

// V2 handler
async function getUserV2(id: string): Promise<UserV2> {
  const user = await db.users.findById(id)
  return {
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    createdAt: user.createdAt.toISOString(),
  }
}
```

**Deprecation Headers:**

```typescript
// Mark deprecated versions
function addDeprecationHeaders(
  response: Response,
  deprecatedAt: Date,
  sunsetAt: Date,
  successor: string
): Response {
  const headers = new Headers(response.headers)

  // RFC 8594 Sunset header
  headers.set('Deprecation', deprecatedAt.toUTCString())
  headers.set('Sunset', sunsetAt.toUTCString())

  // Link to successor version
  headers.set('Link', `<${successor}>; rel="successor-version"`)

  return new Response(response.body, {
    status: response.status,
    headers,
  })
}

// Apply to v1 responses
async function handleV1(request: Request): Promise<Response> {
  const response = await processV1Request(request)

  // V1 deprecated Jan 1, sunsets Jul 1
  return addDeprecationHeaders(
    response,
    new Date('2025-01-01'),
    new Date('2025-07-01'),
    '/api/v2'
  )
}
```

**What Requires a New Version:**

```typescript
// Breaking changes (REQUIRE new version)
// ✗ Removing a field
// ✗ Renaming a field
// ✗ Changing a field's type
// ✗ Changing error response format
// ✗ Removing an endpoint
// ✗ Changing authentication method

// Non-breaking changes (can add to current version)
// ✓ Adding a new optional field
// ✓ Adding a new endpoint
// ✓ Adding a new optional query parameter
// ✓ Adding a new error code (if format unchanged)
// ✓ Relaxing validation (accepting more input)
```

**Migration Guide Template:**

```markdown
# API v1 to v2 Migration Guide

## Timeline
- v2 Available: January 1, 2025
- v1 Deprecated: March 1, 2025
- v1 Sunset: July 1, 2025

## Breaking Changes

### User Object
```diff
- { "name": "John Doe" }
+ { "firstName": "John", "lastName": "Doe" }
```

### Removed Endpoints
- `GET /api/v1/users/me` → Use `GET /api/v2/me`

## Migration Steps
1. Update API base URL to `/api/v2`
2. Update User object parsing
3. Test all integrations
4. Monitor for errors
```

**Alternative: Header Versioning:**

```typescript
// Less common but valid for internal APIs
const version = request.headers.get('API-Version') || '1'

// Or Accept header
const accept = request.headers.get('Accept')
const version = accept?.match(/application\/vnd\.api\.v(\d+)\+json/)?.[1]
```

Choose URL path versioning for public APIs (most discoverable, cacheable) and header versioning only for internal APIs where URL stability is critical.
