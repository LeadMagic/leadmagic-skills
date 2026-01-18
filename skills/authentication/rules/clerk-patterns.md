---
title: Clerk Authentication Patterns
impact: CRITICAL
impactDescription: Next.js authentication with Clerk
tags: clerk, auth, next.js
---

## Clerk Authentication Patterns

### Setup

```bash
npm install @clerk/nextjs
```

```typescript
// middleware.ts (or proxy.ts in Next.js 16)
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isProtectedRoute = createRouteMatcher([
  '/dashboard(.*)',
  '/api/protected(.*)',
])

export default clerkMiddleware(async (auth, req) => {
  if (isProtectedRoute(req)) {
    await auth.protect()
  }
})

export const config = {
  matcher: [
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    '/(api|trpc)(.*)',
  ],
}
```

```typescript
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

### Environment Variables

```env
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
```

### Components

```typescript
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from '@clerk/nextjs'

export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <SignIn />
    </div>
  )
}
```

### Server-Side Auth

```typescript
import { auth, currentUser } from '@clerk/nextjs/server'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const { userId } = await auth()

  if (!userId) {
    redirect('/sign-in')
  }

  const user = await currentUser()
  return <h1>Welcome, {user?.firstName}</h1>
}
```

### Client-Side Auth

```typescript
'use client'

import { useUser, useAuth, SignedIn, SignedOut } from '@clerk/nextjs'

export function UserButton() {
  const { user } = useUser()
  const { signOut } = useAuth()

  return (
    <>
      <SignedIn>
        <span>Hello, {user?.firstName}</span>
        <button onClick={() => signOut()}>Sign out</button>
      </SignedIn>
      <SignedOut>
        <a href="/sign-in">Sign in</a>
      </SignedOut>
    </>
  )
}
```

### API Routes

```typescript
import { auth } from '@clerk/nextjs/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const { userId } = await auth()

  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  return NextResponse.json({ userId })
}
```
