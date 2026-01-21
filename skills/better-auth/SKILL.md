---
name: better-auth
description: Better Auth - framework-agnostic authentication library. Use when implementing auth without vendor lock-in, self-hosted auth, or migrating from Auth.js. Triggers on "Better Auth", "authentication", "self-hosted auth", "auth library".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Better Auth

Framework-agnostic, self-hosted authentication library with first-class TypeScript support.

## Why Better Auth

| Feature | Better Auth | Auth.js | Clerk |
|---------|-------------|---------|-------|
| Self-hosted | ✅ | ✅ | ❌ |
| Framework-agnostic | ✅ | ❌ | ❌ |
| Built-in plugins | ✅ | Limited | ✅ |
| TypeScript | First-class | Good | Good |
| Pricing | Free | Free | Paid |

## Installation

```bash
npm install better-auth
```

---

## Server Setup

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { drizzleAdapter } from 'better-auth/adapters/drizzle'
import { db } from '@/db'

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: 'pg', // or 'mysql', 'sqlite'
  }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
})

// Export type for client
export type Auth = typeof auth
```

### API Route Handler

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from '@/lib/auth'
import { toNextJsHandler } from 'better-auth/next-js'

export const { GET, POST } = toNextJsHandler(auth)
```

---

## Client Setup

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/react'
import type { Auth } from './auth'

export const authClient = createAuthClient<Auth>({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
})

export const {
  signIn,
  signUp,
  signOut,
  useSession,
  getSession,
} = authClient
```

---

## Authentication Flows

### Email/Password Sign Up

```tsx
'use client'

import { signUp } from '@/lib/auth-client'
import { useState } from 'react'

export function SignUpForm() {
  const [error, setError] = useState<string>()

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    const { error } = await signUp.email({
      email: formData.get('email') as string,
      password: formData.get('password') as string,
      name: formData.get('name') as string,
    })

    if (error) {
      setError(error.message)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" placeholder="Name" required />
      <input name="email" type="email" placeholder="Email" required />
      <input name="password" type="password" placeholder="Password" required />
      {error && <p className="text-red-500">{error}</p>}
      <button type="submit">Sign Up</button>
    </form>
  )
}
```

### Email/Password Sign In

```tsx
'use client'

import { signIn } from '@/lib/auth-client'

export function SignInForm() {
  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    const { error } = await signIn.email({
      email: formData.get('email') as string,
      password: formData.get('password') as string,
    })

    if (error) {
      console.error(error)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" placeholder="Email" required />
      <input name="password" type="password" placeholder="Password" required />
      <button type="submit">Sign In</button>
    </form>
  )
}
```

### Social Sign In

```tsx
'use client'

import { signIn } from '@/lib/auth-client'

export function SocialButtons() {
  return (
    <div className="space-y-2">
      <button onClick={() => signIn.social({ provider: 'google' })}>
        Sign in with Google
      </button>
      <button onClick={() => signIn.social({ provider: 'github' })}>
        Sign in with GitHub
      </button>
    </div>
  )
}
```

---

## Session Management

### useSession Hook

```tsx
'use client'

import { useSession } from '@/lib/auth-client'

export function UserNav() {
  const { data: session, isPending } = useSession()

  if (isPending) return <Skeleton />

  if (!session) {
    return <a href="/sign-in">Sign In</a>
  }

  return (
    <div>
      <span>{session.user.name}</span>
      <img src={session.user.image} alt="" />
    </div>
  )
}
```

### Server-Side Session

```typescript
// app/dashboard/page.tsx
import { auth } from '@/lib/auth'
import { headers } from 'next/headers'
import { redirect } from 'next/navigation'

export default async function Dashboard() {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    redirect('/sign-in')
  }

  return <div>Welcome, {session.user.name}</div>
}
```

---

## Middleware Protection

```typescript
// middleware.ts
import { auth } from '@/lib/auth'
import { NextRequest, NextResponse } from 'next/server'

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  const isProtectedRoute = request.nextUrl.pathname.startsWith('/dashboard')

  if (isProtectedRoute && !session) {
    return NextResponse.redirect(new URL('/sign-in', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*'],
}
```

---

## Plugins

### Two-Factor Authentication

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { twoFactor } from 'better-auth/plugins'

export const auth = betterAuth({
  // ... base config
  plugins: [
    twoFactor({
      issuer: 'MyApp',
    }),
  ],
})
```

```typescript
// Client usage
import { authClient } from '@/lib/auth-client'

// Enable 2FA
const { totpURI } = await authClient.twoFactor.enable()
// Show QR code with totpURI

// Verify 2FA on sign in
await authClient.twoFactor.verify({ code: '123456' })
```

### Magic Link

```typescript
// lib/auth.ts
import { magicLink } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    magicLink({
      sendMagicLink: async ({ email, url }) => {
        await resend.emails.send({
          to: email,
          subject: 'Sign in to MyApp',
          html: `<a href="${url}">Sign in</a>`,
        })
      },
    }),
  ],
})
```

```tsx
// Client
await signIn.magicLink({ email: 'user@example.com' })
```

### Organization / Multi-Tenant

```typescript
import { organization } from 'better-auth/plugins'

export const auth = betterAuth({
  plugins: [
    organization({
      allowUserToCreateOrganization: true,
    }),
  ],
})
```

---

## Database Schema (Drizzle)

```typescript
// db/schema/auth.ts
import { pgTable, text, timestamp, boolean } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: text('id').primaryKey(),
  name: text('name'),
  email: text('email').notNull().unique(),
  emailVerified: boolean('email_verified').default(false),
  image: text('image'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
})

export const sessions = pgTable('sessions', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id),
  expiresAt: timestamp('expires_at').notNull(),
  ipAddress: text('ip_address'),
  userAgent: text('user_agent'),
})

export const accounts = pgTable('accounts', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id),
  providerId: text('provider_id').notNull(),
  providerAccountId: text('provider_account_id').notNull(),
  accessToken: text('access_token'),
  refreshToken: text('refresh_token'),
  expiresAt: timestamp('expires_at'),
})
```

---

## Environment Variables

```bash
# Required
BETTER_AUTH_SECRET=your-secret-key  # Generate: openssl rand -base64 32
BETTER_AUTH_URL=http://localhost:3000

# Social providers
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Database
DATABASE_URL=postgresql://...
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing BETTER_AUTH_SECRET | Generate secure secret with openssl |
| Not syncing database schema | Run migrations after config changes |
| Wrong adapter provider | Match adapter to your database |
| Missing headers in server calls | Pass `headers: await headers()` |

---

## Quick Reference

| Server | Code |
|--------|------|
| Setup | `betterAuth({ database, emailAndPassword, socialProviders })` |
| Get session | `auth.api.getSession({ headers })` |
| Route handler | `toNextJsHandler(auth)` |

| Client | Code |
|--------|------|
| Sign up | `signUp.email({ email, password, name })` |
| Sign in | `signIn.email({ email, password })` |
| Social | `signIn.social({ provider: 'google' })` |
| Session | `useSession()` |
| Sign out | `signOut()` |

## References

- [Better Auth Docs](https://better-auth.com)
- [GitHub](https://github.com/better-auth/better-auth)
