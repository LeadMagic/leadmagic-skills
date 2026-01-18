---
name: authentication
description: Authentication patterns for Next.js 16 and Cloudflare Workers. Use when implementing sign-in, sessions, JWT, OAuth, or auth providers. Triggers on "authentication", "login", "sessions", "JWT", "Clerk", "Auth.js".
license: MIT
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Authentication

Authentication patterns for Next.js and Cloudflare Workers.

## Options

| Provider | Best For | Package |
|----------|----------|---------|
| **Clerk** | Next.js apps | `@clerk/nextjs` |
| **Auth.js** | Multi-provider OAuth | `next-auth` |
| **Custom JWT** | Workers/APIs | `hono/jwt` |

---

## Clerk (Next.js)

See `rules/clerk-patterns.md` for detailed patterns.

```bash
npm install @clerk/nextjs
```

```typescript
// middleware.ts (or proxy.ts in Next.js 16)
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isProtectedRoute = createRouteMatcher(['/dashboard(.*)'])

export default clerkMiddleware(async (auth, req) => {
  if (isProtectedRoute(req)) await auth.protect()
})
```

```typescript
// Server Component
import { auth, currentUser } from '@clerk/nextjs/server'

export default async function Dashboard() {
  const { userId } = await auth()
  if (!userId) redirect('/sign-in')
  
  const user = await currentUser()
  return <h1>Welcome, {user?.firstName}</h1>
}
```

```typescript
// Client Component
'use client'
import { useUser, SignedIn, SignedOut } from '@clerk/nextjs'

export function UserNav() {
  const { user } = useUser()
  return (
    <>
      <SignedIn><span>Hi, {user?.firstName}</span></SignedIn>
      <SignedOut><a href="/sign-in">Sign in</a></SignedOut>
    </>
  )
}
```

---

## Auth.js (NextAuth v5)

```bash
npm install next-auth@beta
```

```typescript
// auth.ts
import NextAuth from 'next-auth'
import GitHub from 'next-auth/providers/github'

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [GitHub],
})

// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/auth'
export const { GET, POST } = handlers
```

```typescript
// Server Component
import { auth } from '@/auth'

export default async function Page() {
  const session = await auth()
  if (!session) redirect('/api/auth/signin')
  return <div>Welcome {session.user?.name}</div>
}
```

---

## Cloudflare Workers

See `rules/workers-auth.md` for detailed patterns.

### JWT Auth

```typescript
import { Hono } from 'hono'
import { jwt } from 'hono/jwt'

const app = new Hono<{ Bindings: Env }>()

app.use('/api/*', jwt({ secret: 'your-secret' }))

app.get('/api/me', (c) => {
  const payload = c.get('jwtPayload')
  return c.json({ userId: payload.sub })
})
```

### Session Auth (KV)

```typescript
import { getCookie, setCookie } from 'hono/cookie'

app.post('/login', async (c) => {
  const user = await verifyCredentials(/* ... */)
  const sessionId = crypto.randomUUID()
  
  await c.env.SESSIONS.put(`session:${sessionId}`, user.id, { expirationTtl: 86400 })
  
  setCookie(c, 'session', sessionId, {
    httpOnly: true,
    secure: true,
    sameSite: 'Lax',
    maxAge: 86400,
  })
  
  return c.json({ success: true })
})
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `auth()` instead of `auth.protect()` | Use `auth.protect()` for automatic redirects |
| Wrong middleware matcher | Include `/(api|trpc)(.*)` pattern |
| Exposing full user object | Return only needed fields |
| No rate limiting on login | Add rate limiting |
| Insecure cookies | Set `httpOnly`, `secure`, `sameSite` |

---

## Environment Variables

```env
# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...

# Auth.js
AUTH_SECRET=your-secret
AUTH_GITHUB_ID=...
AUTH_GITHUB_SECRET=...

# Workers
JWT_SECRET=your-jwt-secret
```

---

## Quick Reference

| Pattern | Code |
|---------|------|
| Clerk protect route | `await auth.protect()` |
| Clerk get user | `await currentUser()` |
| Auth.js session | `const session = await auth()` |
| JWT middleware | `app.use('/api/*', jwt({ secret }))` |
| Session cookie | `setCookie(c, 'session', id, { httpOnly: true })` |
