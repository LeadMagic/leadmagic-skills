# Query Options Pattern

Define query options separately for reuse across components and prefetching.

## Implementation

```typescript
// lib/queries/users.ts
import { queryOptions, infiniteQueryOptions } from '@tanstack/react-query'
import { queryKeys } from './keys'

export const userQueries = {
  list: (filters: UserFilters) =>
    queryOptions({
      queryKey: queryKeys.users.list(filters),
      queryFn: () => fetchUsers(filters),
      staleTime: 5 * 60 * 1000, // 5 minutes
    }),

  detail: (userId: string) =>
    queryOptions({
      queryKey: queryKeys.users.detail(userId),
      queryFn: () => fetchUser(userId),
      staleTime: 10 * 60 * 1000, // 10 minutes
      enabled: !!userId,
    }),

  infinite: (filters: UserFilters) =>
    infiniteQueryOptions({
      queryKey: queryKeys.users.list(filters),
      queryFn: ({ pageParam }) => fetchUsers({ ...filters, cursor: pageParam }),
      initialPageParam: undefined as string | undefined,
      getNextPageParam: (lastPage) => lastPage.nextCursor,
      staleTime: 5 * 60 * 1000,
    }),
}
```

## Usage

```typescript
// In component
function UserList() {
  const { data, isLoading } = useQuery(userQueries.list({ status: 'active' }))
}

// For prefetching
async function prefetchUser(queryClient: QueryClient, userId: string) {
  await queryClient.prefetchQuery(userQueries.detail(userId))
}
```

## Dependent Queries

```typescript
function UserPosts({ userId }: { userId: string }) {
  const { data: user } = useQuery({
    queryKey: ['users', userId],
    queryFn: () => fetchUser(userId),
  })

  // Only runs when user is loaded
  const { data: posts } = useQuery({
    queryKey: ['posts', { authorId: user?.id }],
    queryFn: () => fetchPostsByAuthor(user!.id),
    enabled: !!user?.id,
  })

  return <PostList posts={posts} />
}
```

## Parallel Queries

```typescript
function Dashboard() {
  const usersQuery = useQuery({ queryKey: ['users'], queryFn: fetchUsers })
  const postsQuery = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })
  const statsQuery = useQuery({ queryKey: ['stats'], queryFn: fetchStats })

  const isLoading = usersQuery.isLoading || postsQuery.isLoading || statsQuery.isLoading

  if (isLoading) return <DashboardSkeleton />

  return (
    <Dashboard
      users={usersQuery.data}
      posts={postsQuery.data}
      stats={statsQuery.data}
    />
  )
}

// Or use useQueries for dynamic parallel queries
function UserProfiles({ userIds }: { userIds: string[] }) {
  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
    })),
  })

  const users = userQueries.map((q) => q.data).filter(Boolean)
  return <UserGrid users={users} />
}
```
