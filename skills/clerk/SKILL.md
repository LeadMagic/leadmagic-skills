---
name: clerk
description: Clerk authentication for Next.js and React. Use when implementing sign-in, user management, organizations, or webhooks. Triggers on "Clerk", "authentication", "sign-in", "user management", "organizations", "clerkMiddleware".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Clerk Authentication

Complete authentication and user management for Next.js.

## What's New (2025)

| Feature | Description |
|---------|-------------|
| **Core 2** | New architecture with better performance |
| **Elements** | Headless UI components for custom auth flows |
| **Waitlist** | Built-in waitlist mode for launches |
| **B2B Organizations** | Enhanced org management |
| **Reverification** | Step-up authentication for sensitive actions |

## Installation

```bash
npm install @clerk/nextjs
```

## Environment Variables

```bash
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...

# Optional: Custom paths
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
```

---

## Middleware Setup

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)',
])

const isProtectedRoute = createRouteMatcher([
  '/dashboard(.*)',
  '/settings(.*)',
  '/api/protected(.*)',
])

export default clerkMiddleware(async (auth, req) => {
  // Protect specific routes
  if (isProtectedRoute(req)) {
    await auth.protect()
  }
  
  // Or protect all non-public routes
  // if (!isPublicRoute(req)) {
  //   await auth.protect()
  // }
})

export const config = {
  matcher: [
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    '/(api|trpc)(.*)',
  ],
}
```

---

## Provider Setup

```tsx
// app/layout.tsx
import { ClerkProvider } from '@clerk/nextjs'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  )
}
```

---

## Server Components

```tsx
// Get auth state
import { auth, currentUser } from '@clerk/nextjs/server'

export default async function Dashboard() {
  const { userId, orgId, sessionClaims } = await auth()
  
  if (!userId) {
    redirect('/sign-in')
  }
  
  // Get full user object
  const user = await currentUser()
  
  return (
    <div>
      <h1>Welcome, {user?.firstName}</h1>
      <p>User ID: {userId}</p>
      {orgId && <p>Organization: {orgId}</p>}
    </div>
  )
}
```

### Protect Server Actions

```typescript
'use server'

import { auth } from '@clerk/nextjs/server'

export async function createPost(data: FormData) {
  const { userId } = await auth()
  
  if (!userId) {
    throw new Error('Unauthorized')
  }
  
  // Create post with userId
  await db.post.create({
    data: {
      title: data.get('title') as string,
      authorId: userId,
    },
  })
}
```

---

## Client Components

```tsx
'use client'

import { 
  useUser, 
  useAuth, 
  useClerk,
  SignedIn, 
  SignedOut,
  UserButton,
  SignInButton,
} from '@clerk/nextjs'

export function Header() {
  return (
    <header className="flex justify-between p-4">
      <Logo />
      <SignedIn>
        <UserButton afterSignOutUrl="/" />
      </SignedIn>
      <SignedOut>
        <SignInButton mode="modal">
          <button>Sign In</button>
        </SignInButton>
      </SignedOut>
    </header>
  )
}

export function UserProfile() {
  const { user, isLoaded, isSignedIn } = useUser()
  const { signOut, getToken } = useAuth()
  
  if (!isLoaded) return <Skeleton />
  if (!isSignedIn) return null
  
  return (
    <div>
      <img src={user.imageUrl} alt={user.fullName || ''} />
      <h2>{user.fullName}</h2>
      <p>{user.primaryEmailAddress?.emailAddress}</p>
      <button onClick={() => signOut()}>Sign Out</button>
    </div>
  )
}
```

---

## Custom Sign-In Page

```tsx
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from '@clerk/nextjs'

export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <SignIn 
        appearance={{
          elements: {
            rootBox: 'mx-auto',
            card: 'shadow-lg',
          },
        }}
      />
    </div>
  )
}
```

---

## Organizations (B2B)

```tsx
// Server Component
import { auth } from '@clerk/nextjs/server'

export default async function OrgDashboard() {
  const { userId, orgId, orgRole } = await auth()
  
  if (!orgId) {
    return <div>Please select an organization</div>
  }
  
  const isAdmin = orgRole === 'org:admin'
  
  return (
    <div>
      <h1>Organization Dashboard</h1>
      {isAdmin && <AdminPanel />}
    </div>
  )
}

// Client Component - Org Switcher
'use client'
import { OrganizationSwitcher, OrganizationList } from '@clerk/nextjs'

export function OrgSelector() {
  return (
    <OrganizationSwitcher 
      hidePersonal
      afterSelectOrganizationUrl="/dashboard"
      afterCreateOrganizationUrl="/dashboard"
    />
  )
}
```

### Create Organization

```tsx
import { CreateOrganization } from '@clerk/nextjs'

export default function CreateOrgPage() {
  return <CreateOrganization afterCreateOrganizationUrl="/dashboard" />
}
```

---

## Webhooks

```typescript
// app/api/webhooks/clerk/route.ts
import { Webhook } from 'svix'
import { headers } from 'next/headers'
import { WebhookEvent } from '@clerk/nextjs/server'

export async function POST(req: Request) {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET
  if (!WEBHOOK_SECRET) throw new Error('Missing CLERK_WEBHOOK_SECRET')

  const headerPayload = await headers()
  const svix_id = headerPayload.get('svix-id')
  const svix_timestamp = headerPayload.get('svix-timestamp')
  const svix_signature = headerPayload.get('svix-signature')

  if (!svix_id || !svix_timestamp || !svix_signature) {
    return new Response('Missing svix headers', { status: 400 })
  }

  const payload = await req.json()
  const body = JSON.stringify(payload)

  const wh = new Webhook(WEBHOOK_SECRET)
  let evt: WebhookEvent

  try {
    evt = wh.verify(body, {
      'svix-id': svix_id,
      'svix-timestamp': svix_timestamp,
      'svix-signature': svix_signature,
    }) as WebhookEvent
  } catch (err) {
    return new Response('Invalid signature', { status: 400 })
  }

  switch (evt.type) {
    case 'user.created':
      await db.user.create({
        data: {
          clerkId: evt.data.id,
          email: evt.data.email_addresses[0]?.email_address,
          name: `${evt.data.first_name} ${evt.data.last_name}`,
        },
      })
      break
    case 'user.updated':
      await db.user.update({
        where: { clerkId: evt.data.id },
        data: { name: `${evt.data.first_name} ${evt.data.last_name}` },
      })
      break
    case 'user.deleted':
      await db.user.delete({ where: { clerkId: evt.data.id } })
      break
  }

  return new Response('OK', { status: 200 })
}
```

---

## Session Tokens for APIs

```typescript
// Client: Get token for API calls
'use client'
import { useAuth } from '@clerk/nextjs'

export function ApiClient() {
  const { getToken } = useAuth()
  
  async function fetchData() {
    const token = await getToken()
    const res = await fetch('/api/data', {
      headers: { Authorization: `Bearer ${token}` },
    })
    return res.json()
  }
}

// Server: Verify token in API route
import { auth } from '@clerk/nextjs/server'

export async function GET() {
  const { userId, getToken } = await auth()
  
  if (!userId) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }
  
  // Get token for external API
  const token = await getToken({ template: 'supabase' })
  
  return Response.json({ data: '...' })
}
```

---

## Reverification (Step-Up Auth)

```typescript
'use server'

import { auth } from '@clerk/nextjs/server'

export async function deleteAccount() {
  const { userId, has } = await auth()
  
  // Require recent authentication
  const isRecentlyAuthed = has({
    reverification: { level: 'strict', afterMinutes: 10 }
  })
  
  if (!isRecentlyAuthed) {
    throw new Error('Please re-authenticate')
  }
  
  await db.user.delete({ where: { clerkId: userId } })
}
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `auth()` in client | Use `useAuth()` hook in client components |
| Missing middleware matcher | Include `/(api|trpc)(.*)` pattern |
| Not awaiting `auth()` | Always `await auth()` in server code |
| Webhook without verification | Always verify with svix |
| Exposing full user object | Return only needed fields |

---

## Quick Reference

| Server | Code |
|--------|------|
| Get auth | `const { userId } = await auth()` |
| Get user | `const user = await currentUser()` |
| Protect route | `await auth.protect()` |
| Get token | `await getToken()` |

| Client | Code |
|--------|------|
| Get user | `const { user } = useUser()` |
| Get auth | `const { userId, getToken } = useAuth()` |
| Sign out | `const { signOut } = useClerk()` |
| Conditionals | `<SignedIn>`, `<SignedOut>` |

## References

- [Clerk Docs](https://clerk.com/docs)
- [Next.js Quickstart](https://clerk.com/docs/quickstarts/nextjs)
- [Organizations](https://clerk.com/docs/organizations/overview)
- [Webhooks](https://clerk.com/docs/integrations/webhooks)
