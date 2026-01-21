---
name: caching-strategies
description: Caching patterns for Next.js 16 and Cloudflare. Use when implementing data caching, ISR, SWR, cache headers, or optimizing performance. Triggers on "caching", "cache", "ISR", "revalidate", "stale-while-revalidate", "CDN", "cache headers".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.0.0"
  context7: vercel/next.js
---

# Caching Strategies

Caching patterns for Next.js 16, React 19, and Cloudflare.

---

## Next.js Caching

### Fetch Cache Options

```typescript
// No caching - always fresh
fetch(url, { cache: 'no-store' })

// Cache forever (default for static)
fetch(url, { cache: 'force-cache' })

// Time-based revalidation (ISR)
fetch(url, { next: { revalidate: 60 } }) // Revalidate every 60 seconds

// Tag-based revalidation
fetch(url, { next: { tags: ['posts', 'user-123'] } })
```

### Route Segment Config

```typescript
// app/posts/page.tsx

// Force dynamic rendering (no cache)
export const dynamic = 'force-dynamic'

// Force static (cache at build)
export const dynamic = 'force-static'

// Default revalidation for all fetches in segment
export const revalidate = 60 // seconds

// Runtime
export const runtime = 'edge' // or 'nodejs'
```

### Revalidation

```typescript
// app/actions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

export async function createPost(data: FormData) {
  await db.insert(posts).values(/* ... */)

  // Revalidate by path
  revalidatePath('/posts')
  revalidatePath('/posts/[slug]', 'page')

  // Revalidate by tag
  revalidateTag('posts')
}

// NEW in Next.js 16: updateTag for read-your-writes
import { updateTag } from 'next/cache'

export async function updatePost(id: string, data: FormData) {
  await db.update(posts).set(data).where(eq(posts.id, id))

  // updateTag expires AND refreshes in same request
  // User immediately sees their changes
  updateTag(`post-${id}`)
}

// On-demand revalidation via API
// app/api/revalidate/route.ts
export async function POST(request: Request) {
  const { tag, secret } = await request.json()

  if (secret !== process.env.REVALIDATION_SECRET) {
    return Response.json({ error: 'Invalid secret' }, { status: 401 })
  }

  revalidateTag(tag)
  return Response.json({ revalidated: true })
}
```

---

## React Cache

### Memoizing Data Fetches

```typescript
import { cache } from 'react'

// Deduplicated across the request
export const getUser = cache(async (id: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.id, id),
  })
  return user
})

// Multiple components can call this - only one DB query
async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId)
  return <div>{user?.name}</div>
}

async function UserAvatar({ userId }: { userId: string }) {
  const user = await getUser(userId) // Same query, cached result
  return <img src={user?.avatarUrl} />
}
```

### unstable_cache for Data

```typescript
import { unstable_cache } from 'next/cache'

const getCachedPosts = unstable_cache(
  async () => {
    return db.query.posts.findMany({
      where: eq(posts.published, true),
      orderBy: [desc(posts.createdAt)],
    })
  },
  ['posts'], // Cache key
  {
    tags: ['posts'],
    revalidate: 60,
  }
)

export default async function PostsPage() {
  const posts = await getCachedPosts()
  return <PostList posts={posts} />
}
```

---

## Client-Side Caching with SWR

### Basic Usage

```typescript
'use client'

import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(res => res.json())

export function UserProfile({ userId }: { userId: string }) {
  const { data, error, isLoading, mutate } = useSWR(
    `/api/users/${userId}`,
    fetcher
  )

  if (isLoading) return <Skeleton />
  if (error) return <Error message={error.message} />

  return (
    <div>
      <h1>{data.name}</h1>
      <button onClick={() => mutate()}>Refresh</button>
    </div>
  )
}
```

### SWR Configuration

```typescript
// app/providers.tsx
'use client'

import { SWRConfig } from 'swr'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher: (url) => fetch(url).then(res => res.json()),
        revalidateOnFocus: true,
        revalidateOnReconnect: true,
        dedupingInterval: 2000,
        errorRetryCount: 3,
      }}
    >
      {children}
    </SWRConfig>
  )
}
```

### Optimistic Updates

```typescript
'use client'

import useSWR, { mutate } from 'swr'

export function TodoList() {
  const { data: todos } = useSWR('/api/todos')

  async function addTodo(title: string) {
    const newTodo = { id: Date.now(), title, completed: false }

    // Optimistic update
    mutate('/api/todos', [...todos, newTodo], false)

    // API call
    await fetch('/api/todos', {
      method: 'POST',
      body: JSON.stringify({ title }),
    })

    // Revalidate
    mutate('/api/todos')
  }

  return (/* ... */)
}
```

---

## TanStack Query

### Setup

```typescript
// app/providers.tsx
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState } from 'react'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000, // 1 minute
            gcTime: 5 * 60 * 1000, // 5 minutes
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}
```

### Queries

```typescript
'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

export function Posts() {
  const queryClient = useQueryClient()

  const { data, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: () => fetch('/api/posts').then(res => res.json()),
  })

  const mutation = useMutation({
    mutationFn: (newPost) =>
      fetch('/api/posts', {
        method: 'POST',
        body: JSON.stringify(newPost),
      }).then(res => res.json()),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })

  return (/* ... */)
}
```

---

## HTTP Cache Headers

### Next.js Route Handlers

```typescript
// app/api/posts/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const posts = await getPosts()

  return NextResponse.json(posts, {
    headers: {
      // Cache for 60 seconds, stale-while-revalidate for 1 hour
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=3600',
    },
  })
}
```

### Cloudflare Workers

```typescript
// Hono response with cache headers
app.get('/api/posts', async (c) => {
  const posts = await getPosts()

  return c.json(posts, {
    headers: {
      'Cache-Control': 'public, max-age=60, s-maxage=300',
      'CDN-Cache-Control': 'max-age=300', // Cloudflare-specific
    },
  })
})
```

### Cache-Control Directives

```
public          - Can be cached by CDN
private         - Only browser can cache
no-cache        - Must revalidate before using
no-store        - Never cache
max-age=60      - Browser cache for 60s
s-maxage=300    - CDN cache for 300s
stale-while-revalidate=3600 - Serve stale while fetching fresh
```

---

## Cloudflare Cache

### Cache API

```typescript
// Workers Cache API
app.get('/api/expensive', async (c) => {
  const cache = caches.default
  const cacheKey = new Request(c.req.url)

  // Check cache
  let response = await cache.match(cacheKey)
  if (response) {
    return response
  }

  // Compute expensive result
  const data = await expensiveOperation()

  // Create response
  response = new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=300',
    },
  })

  // Store in cache
  c.executionCtx.waitUntil(cache.put(cacheKey, response.clone()))

  return response
})
```

### KV Caching

```typescript
// Cache in KV with TTL
async function getCachedData(kv: KVNamespace, key: string) {
  // Try cache
  const cached = await kv.get(key, 'json')
  if (cached) return cached

  // Fetch fresh
  const data = await fetchData()

  // Cache for 5 minutes
  await kv.put(key, JSON.stringify(data), {
    expirationTtl: 300,
  })

  return data
}
```

---

## Caching Patterns

### Cache-Aside

```typescript
async function getUser(id: string) {
  // 1. Check cache
  const cached = await cache.get(`user:${id}`)
  if (cached) return cached

  // 2. Fetch from DB
  const user = await db.query.users.findFirst({ where: eq(users.id, id) })

  // 3. Store in cache
  if (user) {
    await cache.set(`user:${id}`, user, { ttl: 300 })
  }

  return user
}
```

### Write-Through

```typescript
async function updateUser(id: string, data: Partial<User>) {
  // 1. Update DB
  const user = await db.update(users).set(data).where(eq(users.id, id)).returning()

  // 2. Update cache
  await cache.set(`user:${id}`, user[0], { ttl: 300 })

  return user[0]
}
```

### Cache Invalidation

```typescript
async function deleteUser(id: string) {
  // 1. Delete from DB
  await db.delete(users).where(eq(users.id, id))

  // 2. Invalidate cache
  await cache.delete(`user:${id}`)

  // 3. Invalidate related caches
  await cache.delete(`user:${id}:posts`)
  await cache.delete(`user:${id}:followers`)
}
```

---

## Best Practices

### Cache Duration Guidelines

| Data Type | TTL | Strategy |
|-----------|-----|----------|
| Static assets | 1 year | Immutable |
| User profile | 5 min | Cache-aside |
| Feed/timeline | 30 sec | SWR |
| Search results | 1 min | Time-based |
| Auth tokens | Don't cache | No-store |
| Prices/inventory | 0-30 sec | Short TTL |

### Do

- Cache at the edge (CDN) when possible
- Use stale-while-revalidate for better UX
- Tag caches for targeted invalidation
- Monitor cache hit rates
- Set appropriate TTLs per data type

### Don't

- Cache personalized/sensitive data on CDN
- Use long TTLs for frequently changing data
- Forget to invalidate on mutations
- Cache errors (use short TTL if needed)
- Over-cache (causes stale data issues)
