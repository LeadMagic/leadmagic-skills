---
name: nextjs-app-router
description: Next.js 16 App Router patterns with React 19. Use when building pages, layouts, Server Components, Server Actions, or data fetching. Triggers on "App Router", "Server Components", "Server Actions", "Next.js", "RSC", "page.tsx".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Next.js App Router

Patterns for Next.js 16 App Router with React 19.

## What's New in Next.js 16

- **Turbopack default** - No `--turbopack` flag needed
- **Proxy replaces Middleware** - `middleware.ts` → `proxy.ts`
- **React Compiler** - Automatic memoization via `reactCompiler: true`
- **updateTag()** - Read-your-writes cache semantics
- **Async params** - `params` in page components are Promises

## File Conventions

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Home page (/)
├── loading.tsx         # Loading UI
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 page
├── dashboard/
│   ├── layout.tsx      # Nested layout
│   ├── page.tsx        # /dashboard
│   └── [id]/page.tsx   # /dashboard/:id
├── api/route.ts        # API route
└── (auth)/             # Route group (no URL segment)
    └── login/page.tsx
```

---

## Server Components (Default)

```typescript
// app/posts/page.tsx - Server Component (no 'use client')
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60 }, // ISR: revalidate every 60s
  })
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export default async function PostsPage() {
  const posts = await getPosts()
  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### Parallel Data Fetching

```typescript
export default async function DashboardPage() {
  // Parallel - much faster than sequential
  const [user, stats] = await Promise.all([getUser(), getStats()])
  return <Dashboard user={user} stats={stats} />
}
```

### Streaming with Suspense

```typescript
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      <QuickStats /> {/* Fast - renders immediately */}
      <Suspense fallback={<ChartSkeleton />}>
        <SlowChart /> {/* Streams in when ready */}
      </Suspense>
    </div>
  )
}
```

---

## Client Components

```typescript
// components/counter.tsx
'use client' // Required for interactivity

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>
}
```

| Client Component | Server Component |
|-----------------|------------------|
| useState, useEffect | Data fetching |
| Event handlers | Backend resources |
| Browser APIs | Sensitive data |

---

## Server Actions

See `rules/server-actions.md` for detailed patterns.

```typescript
// app/posts/actions.ts
'use server'

export async function createPost(prevState: any, formData: FormData) {
  const title = formData.get('title') as string
  await db.insert(posts).values({ title })
  revalidatePath('/posts')
  redirect('/posts')
}
```

```typescript
// app/posts/new/page.tsx
'use client'
import { useActionState } from 'react'
import { createPost } from './actions'

export default function NewPostForm() {
  const [state, formAction, pending] = useActionState(createPost, null)

  return (
    <form action={formAction}>
      <input name="title" required />
      {state?.error && <p className="text-red-500">{state.error}</p>}
      <button disabled={pending}>{pending ? 'Creating...' : 'Create'}</button>
    </form>
  )
}
```

---

## Metadata & SEO

```typescript
// Static metadata
export const metadata: Metadata = {
  title: 'My App',
  description: 'My description',
}

// Dynamic metadata
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { id } = await params
  const post = await getPost(id)
  return { title: post.title, description: post.excerpt }
}
```

---

## Route Handlers

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const posts = await db.query.posts.findMany()
  return NextResponse.json(posts)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const post = await db.insert(posts).values(body).returning()
  return NextResponse.json(post, { status: 201 })
}
```

```typescript
// app/api/posts/[id]/route.ts
type Props = { params: Promise<{ id: string }> }

export async function GET(request: NextRequest, { params }: Props) {
  const { id } = await params // Must await params in Next.js 15+
  const post = await getPost(id)
  if (!post) return NextResponse.json({ error: 'Not found' }, { status: 404 })
  return NextResponse.json(post)
}
```

---

## Caching & Revalidation

```typescript
// Fetch options
fetch(url, { cache: 'no-store' })           // No caching
fetch(url, { cache: 'force-cache' })        // Cache forever
fetch(url, { next: { revalidate: 60 } })    // ISR: 60 seconds
fetch(url, { next: { tags: ['posts'] } })   // Tag-based

// Revalidation
import { revalidatePath, revalidateTag } from 'next/cache'
revalidatePath('/posts')
revalidateTag('posts')

// Route segment config
export const dynamic = 'force-dynamic'
export const revalidate = 60
export const runtime = 'edge'
```

### updateTag() (Next.js 16)

Read-your-writes: expire AND refresh in same request.

```typescript
'use server'
import { updateTag } from 'next/cache'

export async function updateProfile(userId: string, data: Profile) {
  await db.users.update(userId, data)
  updateTag(`user-${userId}`) // User sees changes immediately
}
```

---

## Error Handling

```typescript
// app/dashboard/error.tsx
'use client'

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}

// app/posts/[id]/page.tsx
import { notFound } from 'next/navigation'

export default async function PostPage({ params }: Props) {
  const { id } = await params
  const post = await getPost(id)
  if (!post) notFound()
  return <Article post={post} />
}
```

---

## Proxy (Next.js 16)

Replaces `middleware.ts` with Node.js runtime.

```typescript
// proxy.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function proxy(request: NextRequest) {
  if (request.nextUrl.pathname === '/old') {
    return NextResponse.redirect(new URL('/new', request.url))
  }
  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

---

## Configuration

```typescript
// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactCompiler: true, // Enable React Compiler
}

export default nextConfig
```

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build"
  }
}
```

> Turbopack is default in Next.js 16 - remove `--turbopack` flag.

---

## Quick Reference

| Pattern | Usage |
|---------|-------|
| Server Component | Default, no directive needed |
| Client Component | Add `'use client'` at top |
| Server Action | Add `'use server'` in function/file |
| useActionState | `const [state, action, pending] = useActionState(fn, init)` |
| useOptimistic | `const [optimistic, addOptimistic] = useOptimistic(state, reducer)` |
| useFormStatus | `const { pending } = useFormStatus()` (in form child) |
| Revalidate path | `revalidatePath('/posts')` |
| Revalidate tag | `revalidateTag('posts')` |
| updateTag | `updateTag('posts')` (Next.js 16, read-your-writes) |

---

## Common Mistakes

See `rules/common-mistakes.md` for detailed examples.

1. **Missing prevState** - useActionState actions need `(prevState, formData)`
2. **Missing 'use server'** - Server Actions require the directive
3. **Cache defaults changed** - fetch is NOT cached by default in Next.js 15+
4. **cookies()/headers()** - Makes route dynamic, not static
5. **refresh() scope** - Only works in Server Actions
6. **Sequential fetching** - Use `Promise.all()` for parallel
7. **params not awaited** - `params` is a Promise in Next.js 15+
8. **useFormStatus placement** - Must be in child of `<form>`

---

## Best Practices

**Do:**
- Use Server Components by default
- Fetch data in Server Components
- Use Suspense for streaming
- Use Server Actions for mutations
- Await `params` and `searchParams`
- Use parallel fetching with `Promise.all()`

**Don't:**
- Add `'use client'` unless needed
- Fetch in useEffect when Server Components work
- Pass sensitive data to Client Components
- Use sequential fetches (waterfall)
- Forget prevState with useActionState
