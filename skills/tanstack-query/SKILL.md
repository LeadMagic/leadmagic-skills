---
name: tanstack-query
description: TanStack Query (React Query) for server state management and data fetching. Use when fetching data, caching API responses, managing server state, implementing optimistic updates, or handling mutations. Triggers on "React Query", "TanStack Query", "useQuery", "useMutation", "data fetching", "cache", "server state".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.2.0"
  context7: tanstack/query
---

# TanStack Query (React Query)

Comprehensive guide for server state management with TanStack Query v5. Covers queries, mutations, caching, optimistic updates, and integration with Next.js App Router.

## What's New in v5

- **queryOptions()** - Type-safe query configuration factory
- **Streaming SSR** - Better hydration with `dehydrate`/`hydrate` options
- **Standard Schema** - Support for Zod, Valibot, ArkType validation

## When to Apply

Reference these guidelines when:
- Fetching data from APIs
- Caching server responses
- Managing loading/error states
- Implementing optimistic updates
- Handling mutations with cache invalidation
- Prefetching data for navigation
- Integrating with Next.js Server Components

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Patterns | CRITICAL | `query-` |
| 2 | Mutations | CRITICAL | `mutation-` |
| 3 | Caching | HIGH | `cache-` |
| 4 | Optimistic Updates | HIGH | `optimistic-` |
| 5 | SSR/Next.js | MEDIUM | `ssr-` |

## Quick Reference

### 1. Query Patterns (CRITICAL)

- `query-keys` - Use query key factories for type safety
- `query-options` - Configure staleTime, gcTime properly

### 2. Mutations (CRITICAL)

- `mutation-invalidation` - Invalidate related queries after mutation
- `mutation-optimistic` - Implement optimistic updates

### 3. Caching (HIGH)

- `cache-stale-time` - Set appropriate staleTime for data freshness
- `cache-gc-time` - Configure garbage collection timing

---

## Installation

```bash
npm install @tanstack/react-query
npm install -D @tanstack/react-query-devtools
```

---

## Setup

### Provider Setup (Next.js App Router)

```typescript
// app/providers.tsx
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState } from 'react'

function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
        gcTime: 5 * 60 * 1000, // 5 minutes
        retry: 1,
        refetchOnWindowFocus: false,
      },
    },
  })
}

let browserQueryClient: QueryClient | undefined = undefined

function getQueryClient() {
  if (typeof window === 'undefined') {
    return makeQueryClient()
  }
  if (!browserQueryClient) browserQueryClient = makeQueryClient()
  return browserQueryClient
}

export function Providers({ children }: { children: React.ReactNode }) {
  const queryClient = getQueryClient()

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

---

## Query Options Pattern (v5 Recommended)

```typescript
// lib/queries/users.ts
import { queryOptions } from '@tanstack/react-query'

export const userQueries = {
  all: () => queryOptions({
    queryKey: ['users'],
  }),
  
  list: (filters: UserFilters) => queryOptions({
    queryKey: ['users', 'list', filters],
    queryFn: () => fetchUsers(filters),
    staleTime: 5 * 60 * 1000,
  }),
  
  detail: (id: string) => queryOptions({
    queryKey: ['users', 'detail', id],
    queryFn: () => fetchUser(id),
    staleTime: 5 * 60 * 1000,
  }),
}

// Usage - type-safe everywhere
useQuery(userQueries.detail(userId))
useSuspenseQuery(userQueries.list({ role: 'admin' }))
queryClient.prefetchQuery(userQueries.detail(userId))
queryClient.setQueryData(userQueries.detail(userId).queryKey, newUser)
```

---

## Basic Query

```typescript
'use client'

import { useQuery } from '@tanstack/react-query'

function UserProfile({ userId }: { userId: string }) {
  const {
    data: user,
    isLoading,
    isError,
    error,
    refetch,
  } = useQuery({
    queryKey: ['users', userId],
    queryFn: async () => {
      const res = await fetch(`/api/users/${userId}`)
      if (!res.ok) throw new Error('Failed to fetch user')
      return res.json() as Promise<User>
    },
    enabled: !!userId,
    staleTime: 5 * 60 * 1000,
  })

  if (isLoading) return <Skeleton />
  if (isError) return <Error message={error.message} retry={refetch} />

  return <UserCard user={user} />
}
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Missing query keys | Cache collisions | Use unique, descriptive keys |
| Not invalidating after mutation | Stale data | Invalidate related queries |
| staleTime: 0 (default) | Excessive refetching | Set appropriate staleTime |
| Forgetting `enabled` | Unnecessary requests | Disable queries until deps ready |
| Not handling loading/error | Poor UX | Always handle all states |
| Mutating cache directly | Inconsistent state | Use setQueryData properly |

---

## Best Practices

### Do

- Use query key factories for type-safe, consistent keys
- Set appropriate staleTime based on data freshness needs
- Invalidate related queries after mutations
- Use optimistic updates for instant feedback
- Prefetch data on hover/focus for faster navigation
- Use `enabled` to prevent unnecessary requests

### Don't

- Don't use primitive values as query keys (use arrays)
- Don't forget to handle loading and error states
- Don't set gcTime shorter than staleTime
- Don't mutate query data directly
- Don't use client components for initial data fetching in Next.js

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/query-options.md      - Query options factory pattern (v5)
rules/mutations.md          - Mutation patterns
rules/optimistic-updates.md - Optimistic update patterns
rules/infinite-queries.md   - Infinite scroll/pagination
rules/prefetching.md        - Prefetch strategies
rules/ssr-streaming.md      - SSR with streaming hydration
rules/error-handling.md     - Error handling patterns
```

## Resources

- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [Query Options](https://tanstack.com/query/latest/docs/react/guides/query-options)
- [Mutations](https://tanstack.com/query/latest/docs/react/guides/mutations)
- [SSR & Hydration](https://tanstack.com/query/latest/docs/react/guides/ssr)
