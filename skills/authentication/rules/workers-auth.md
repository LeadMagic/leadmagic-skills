---
title: Cloudflare Workers Authentication
impact: HIGH
impactDescription: JWT and session auth for Workers
tags: workers, jwt, sessions, hono
---

## Cloudflare Workers Authentication

### JWT Authentication

```typescript
import { Hono } from 'hono'
import { jwt } from 'hono/jwt'

const app = new Hono<{ Bindings: Env }>()

// JWT middleware
app.use('/api/*', jwt({ secret: 'your-secret-key' }))

app.get('/api/protected', (c) => {
  const payload = c.get('jwtPayload')
  return c.json({ userId: payload.sub })
})

// Generate token
app.post('/login', async (c) => {
  const { email, password } = await c.req.json()
  const user = await verifyCredentials(email, password)

  if (!user) {
    return c.json({ error: 'Invalid credentials' }, 401)
  }

  const token = await sign(
    { sub: user.id, email: user.email, exp: Math.floor(Date.now() / 1000) + 3600 },
    'your-secret-key'
  )

  return c.json({ token })
})
```

### Custom Auth Middleware

```typescript
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'

type AuthEnv = {
  Variables: { userId: string; user: User }
  Bindings: Env
}

export const authMiddleware = createMiddleware<AuthEnv>(async (c, next) => {
  const authHeader = c.req.header('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    throw new HTTPException(401, { message: 'Missing authorization header' })
  }

  const token = authHeader.slice(7)

  try {
    const payload = await verify(token, c.env.JWT_SECRET)
    c.set('userId', payload.sub as string)
    await next()
  } catch {
    throw new HTTPException(401, { message: 'Invalid token' })
  }
})
```

### Session-Based Auth (KV)

```typescript
import { getCookie, setCookie, deleteCookie } from 'hono/cookie'

async function createSession(kv: KVNamespace, userId: string): Promise<string> {
  const sessionId = crypto.randomUUID()
  await kv.put(`session:${sessionId}`, userId, { expirationTtl: 86400 })
  return sessionId
}

async function getSession(kv: KVNamespace, sessionId: string): Promise<string | null> {
  return await kv.get(`session:${sessionId}`)
}

app.post('/login', async (c) => {
  const { email, password } = await c.req.json()
  const user = await verifyCredentials(email, password)

  if (!user) return c.json({ error: 'Invalid credentials' }, 401)

  const sessionId = await createSession(c.env.SESSIONS, user.id)

  setCookie(c, 'session', sessionId, {
    httpOnly: true,
    secure: true,
    sameSite: 'Lax',
    maxAge: 86400,
  })

  return c.json({ success: true })
})

app.post('/logout', async (c) => {
  const sessionId = getCookie(c, 'session')

  if (sessionId) {
    await c.env.SESSIONS.delete(`session:${sessionId}`)
    deleteCookie(c, 'session')
  }

  return c.json({ success: true })
})
```

### Password Hashing (Web Crypto)

```typescript
async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(password)
  const salt = crypto.getRandomValues(new Uint8Array(16))

  const key = await crypto.subtle.importKey(
    'raw', data, { name: 'PBKDF2' }, false, ['deriveBits']
  )

  const derivedBits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
    key, 256
  )

  const hashArray = new Uint8Array(derivedBits)
  const combined = new Uint8Array(salt.length + hashArray.length)
  combined.set(salt)
  combined.set(hashArray, salt.length)

  return btoa(String.fromCharCode(...combined))
}

async function verifyPassword(password: string, storedHash: string): Promise<boolean> {
  const combined = Uint8Array.from(atob(storedHash), c => c.charCodeAt(0))
  const salt = combined.slice(0, 16)
  const storedKey = combined.slice(16)

  const encoder = new TextEncoder()
  const key = await crypto.subtle.importKey(
    'raw', encoder.encode(password), { name: 'PBKDF2' }, false, ['deriveBits']
  )

  const derivedBits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' },
    key, 256
  )

  const derivedKey = new Uint8Array(derivedBits)
  return derivedKey.every((byte, i) => byte === storedKey[i])
}
```
