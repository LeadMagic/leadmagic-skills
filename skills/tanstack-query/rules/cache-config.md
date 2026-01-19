# Cache Configuration

Configure caching behavior for optimal performance.

## staleTime vs gcTime

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // How long data is considered fresh (won't refetch)
      staleTime: 5 * 60 * 1000, // 5 minutes

      // How long inactive data stays in cache before garbage collection
      gcTime: 30 * 60 * 1000, // 30 minutes (must be > staleTime)

      // Other useful defaults
      retry: 2,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
    },
  },
})
```

## Per-Query Cache Configuration

```typescript
// Static data - long staleTime
const { data: countries } = useQuery({
  queryKey: ['countries'],
  queryFn: fetchCountries,
  staleTime: Infinity, // Never refetch
  gcTime: Infinity, // Never garbage collect
})

// Frequently changing data - short staleTime
const { data: notifications } = useQuery({
  queryKey: ['notifications'],
  queryFn: fetchNotifications,
  staleTime: 30 * 1000, // 30 seconds
  refetchInterval: 60 * 1000, // Poll every minute
})

// User-specific data
const { data: profile } = useQuery({
  queryKey: ['profile', userId],
  queryFn: () => fetchProfile(userId),
  staleTime: 5 * 60 * 1000,
  enabled: !!userId,
})
```

## Cache Configuration Guide

| Data Type | staleTime | gcTime | Notes |
|-----------|-----------|--------|-------|
| Static (countries, categories) | Infinity | Infinity | Never changes |
| User profile | 5-10 min | 30 min | Changes infrequently |
| Lists (posts, users) | 1-5 min | 10-30 min | May change often |
| Real-time (notifications) | 30s | 5 min | Use with refetchInterval |
| Sensitive (payments) | 0 | 5 min | Always fresh |

## Select/Transform Data

```typescript
const { data: userNames } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  select: (data) => data.map((user) => user.name),
})
```

## Placeholder Data

```typescript
const { data } = useQuery({
  queryKey: ['posts', postId],
  queryFn: () => fetchPost(postId),
  placeholderData: (previousData) => previousData, // Keep previous data while loading
})
```
