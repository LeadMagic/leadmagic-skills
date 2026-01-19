---
name: security-best-practices
description: Security patterns for web applications. Use when implementing input validation, CSRF protection, rate limiting, content security policies, or securing APIs. Triggers on "security", "XSS", "CSRF", "validation", "sanitize", "rate limit", "CSP".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Security Best Practices

Security patterns for Next.js, Cloudflare Workers, and web applications.

---

## Input Validation with Zod

### Basic Validation

```typescript
import { z } from 'zod'

// Define schemas
const userSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2).max(100),
  age: z.number().int().positive().optional(),
})

// Validate
function createUser(input: unknown) {
  const result = userSchema.safeParse(input)

  if (!result.success) {
    throw new ValidationError(result.error.flatten())
  }

  return result.data // Fully typed
}
```

### Server Action Validation

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'

const schema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
  tags: z.array(z.string()).max(5).optional(),
})

export async function createPost(formData: FormData) {
  const result = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    tags: formData.getAll('tags'),
  })

  if (!result.success) {
    return { error: result.error.flatten().fieldErrors }
  }

  // Safe to use result.data
  await db.insert(posts).values(result.data)
}
```

### API Route Validation (Hono)

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
})

app.post(
  '/users',
  zValidator('json', createUserSchema),
  async (c) => {
    const data = c.req.valid('json') // Typed and validated
    const user = await createUser(data)
    return c.json(user, 201)
  }
)
```

---

## XSS Prevention

### React (Safe by Default)

```typescript
// Safe - React escapes by default
function UserName({ name }: { name: string }) {
  return <span>{name}</span> // Escaped automatically
}

// DANGEROUS - Only use with trusted content
function RichContent({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />
}
```

### Sanitize HTML (When Needed)

```typescript
import DOMPurify from 'isomorphic-dompurify'

function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href', 'target'],
  })
}

// Usage
function RichContent({ html }: { html: string }) {
  const clean = sanitizeHtml(html)
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

### Content Security Policy

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      "script-src 'self' 'unsafe-eval' 'unsafe-inline'", // Adjust for your needs
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' blob: data: https:",
      "font-src 'self'",
      "connect-src 'self' https://api.example.com",
      "frame-ancestors 'none'",
    ].join('; '),
  },
  {
    key: 'X-Frame-Options',
    value: 'DENY',
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff',
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin',
  },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()',
  },
]

module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
    ]
  },
}
```

---

## CSRF Protection

### Next.js Server Actions

Server Actions include CSRF protection by default via the `Origin` header check.

### Custom CSRF Token

```typescript
// lib/csrf.ts
export function generateCsrfToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32))
  return btoa(String.fromCharCode(...bytes))
}

export function verifyCsrfToken(token: string, expected: string): boolean {
  if (!token || !expected) return false

  // Timing-safe comparison
  if (token.length !== expected.length) return false

  let result = 0
  for (let i = 0; i < token.length; i++) {
    result |= token.charCodeAt(i) ^ expected.charCodeAt(i)
  }
  return result === 0
}
```

### CSRF Middleware (Hono)

```typescript
import { Hono } from 'hono'
import { getCookie, setCookie } from 'hono/cookie'

const app = new Hono()

// Set CSRF token on GET requests
app.use('*', async (c, next) => {
  if (c.req.method === 'GET') {
    const token = generateCsrfToken()
    setCookie(c, 'csrf', token, {
      httpOnly: true,
      secure: true,
      sameSite: 'Strict',
    })
  }
  await next()
})

// Verify on mutations
app.use('/api/*', async (c, next) => {
  if (['POST', 'PUT', 'DELETE', 'PATCH'].includes(c.req.method)) {
    const headerToken = c.req.header('X-CSRF-Token')
    const cookieToken = getCookie(c, 'csrf')

    if (!verifyCsrfToken(headerToken || '', cookieToken || '')) {
      return c.json({ error: 'Invalid CSRF token' }, 403)
    }
  }
  await next()
})
```

---

## Rate Limiting

### With Upstash (Cloudflare/Vercel)

```typescript
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'), // 10 requests per 10 seconds
  analytics: true,
})

// Next.js middleware
export async function middleware(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1'
  const { success, limit, remaining, reset } = await ratelimit.limit(ip)

  if (!success) {
    return new NextResponse('Too Many Requests', {
      status: 429,
      headers: {
        'X-RateLimit-Limit': limit.toString(),
        'X-RateLimit-Remaining': remaining.toString(),
        'X-RateLimit-Reset': reset.toString(),
      },
    })
  }

  return NextResponse.next()
}
```

### With Cloudflare KV

```typescript
// Simple rate limiter with KV
async function rateLimit(
  kv: KVNamespace,
  key: string,
  limit: number,
  windowSec: number
): Promise<{ allowed: boolean; remaining: number }> {
  const now = Math.floor(Date.now() / 1000)
  const windowKey = `ratelimit:${key}:${Math.floor(now / windowSec)}`

  const current = parseInt(await kv.get(windowKey) || '0')

  if (current >= limit) {
    return { allowed: false, remaining: 0 }
  }

  await kv.put(windowKey, (current + 1).toString(), {
    expirationTtl: windowSec,
  })

  return { allowed: true, remaining: limit - current - 1 }
}

// Usage
app.use('/api/*', async (c, next) => {
  const ip = c.req.header('CF-Connecting-IP') || 'unknown'
  const { allowed, remaining } = await rateLimit(c.env.KV, ip, 100, 60)

  if (!allowed) {
    return c.json({ error: 'Rate limit exceeded' }, 429)
  }

  c.header('X-RateLimit-Remaining', remaining.toString())
  await next()
})
```

### Per-Route Rate Limiting

```typescript
const rateLimits = {
  login: Ratelimit.slidingWindow(5, '15 m'),   // 5 attempts per 15 min
  api: Ratelimit.slidingWindow(100, '1 m'),    // 100 requests per min
  upload: Ratelimit.slidingWindow(10, '1 h'),  // 10 uploads per hour
}

function createRateLimiter(type: keyof typeof rateLimits) {
  return new Ratelimit({
    redis: Redis.fromEnv(),
    limiter: rateLimits[type],
    prefix: type,
  })
}
```

---

## SQL Injection Prevention

### Always Use Parameterized Queries

```typescript
// NEVER do this
const query = `SELECT * FROM users WHERE email = '${email}'` // SQL injection!

// DO this with Drizzle
const user = await db.query.users.findFirst({
  where: eq(users.email, email), // Parameterized
})

// Or with raw SQL (parameterized)
const result = await db.run(
  sql`SELECT * FROM users WHERE email = ${email}`
)
```

---

## Authentication Security

### Password Requirements

```typescript
const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain an uppercase letter')
  .regex(/[a-z]/, 'Password must contain a lowercase letter')
  .regex(/[0-9]/, 'Password must contain a number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain a special character')
```

### Secure Cookie Settings

```typescript
setCookie(c, 'session', sessionId, {
  httpOnly: true,      // Not accessible via JavaScript
  secure: true,        // HTTPS only
  sameSite: 'Lax',     // CSRF protection
  maxAge: 60 * 60 * 24 * 7, // 7 days
  path: '/',
})
```

### Timing-Safe Comparison

```typescript
import { timingSafeEqual } from 'crypto'

function secureCompare(a: string, b: string): boolean {
  if (a.length !== b.length) return false

  const bufA = Buffer.from(a)
  const bufB = Buffer.from(b)

  return timingSafeEqual(bufA, bufB)
}
```

---

## Environment Variables

### Never Expose Secrets

```typescript
// WRONG - exposes to client
const apiKey = process.env.NEXT_PUBLIC_API_KEY // Client-accessible!

// RIGHT - server-only
const apiKey = process.env.API_KEY // Server-only
```

### Validate Environment

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  CLERK_SECRET_KEY: z.string().startsWith('sk_'),
})

export const env = envSchema.parse(process.env)
```

---

## Security Checklist

### Headers
- [ ] Content-Security-Policy configured
- [ ] X-Frame-Options: DENY
- [ ] X-Content-Type-Options: nosniff
- [ ] Referrer-Policy configured
- [ ] HSTS enabled (via Vercel/Cloudflare)

### Authentication
- [ ] Passwords hashed with PBKDF2/bcrypt/argon2
- [ ] Session tokens are random and long enough
- [ ] Cookies are httpOnly, secure, sameSite
- [ ] Rate limiting on login attempts
- [ ] Account lockout after failed attempts

### Input
- [ ] All user input validated with Zod
- [ ] SQL queries parameterized (use Drizzle)
- [ ] HTML sanitized before rendering
- [ ] File uploads validated (type, size)

### API
- [ ] Rate limiting enabled
- [ ] CORS configured properly
- [ ] API keys not exposed to client
- [ ] Sensitive endpoints authenticated

### Data
- [ ] Sensitive data encrypted at rest
- [ ] PII handling follows regulations
- [ ] Audit logging for sensitive operations
