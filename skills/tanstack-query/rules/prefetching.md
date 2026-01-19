# Prefetching

Load data before it's needed for faster navigation.

## Prefetch on Hover

```typescript
function PostLink({ postId }: { postId: string }) {
  const queryClient = useQueryClient()

  const prefetchPost = () => {
    queryClient.prefetchQuery({
      queryKey: ['posts', postId],
      queryFn: () => fetchPost(postId),
      staleTime: 5 * 60 * 1000,
    })
  }

  return (
    <Link
      href={`/posts/${postId}`}
      onMouseEnter={prefetchPost}
      onFocus={prefetchPost}
    >
      View Post
    </Link>
  )
}
```

## Prefetch in Server Component (Next.js)

```typescript
// app/posts/page.tsx
import { HydrationBoundary, QueryClient, dehydrate } from '@tanstack/react-query'
import { PostList } from './post-list'

export default async function PostsPage() {
  const queryClient = new QueryClient()

  // Prefetch on server
  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostList />
    </HydrationBoundary>
  )
}
```

## Prefetch with Query Options

Using the query options pattern:

```typescript
// lib/queries/posts.ts
export const postQueries = {
  detail: (postId: string) =>
    queryOptions({
      queryKey: ['posts', postId],
      queryFn: () => fetchPost(postId),
      staleTime: 5 * 60 * 1000,
    }),
}

// In component
function PostLink({ postId }: { postId: string }) {
  const queryClient = useQueryClient()

  return (
    <Link
      href={`/posts/${postId}`}
      onMouseEnter={() => queryClient.prefetchQuery(postQueries.detail(postId))}
    >
      View Post
    </Link>
  )
}
```

## Prefetch on Route Change

```typescript
// Using Next.js router events
import { useRouter } from 'next/router'

function usePrefetchOnNavigate() {
  const router = useRouter()
  const queryClient = useQueryClient()

  useEffect(() => {
    const prefetch = (url: string) => {
      const postMatch = url.match(/\/posts\/(\w+)/)
      if (postMatch) {
        queryClient.prefetchQuery(postQueries.detail(postMatch[1]))
      }
    }

    router.events.on('routeChangeStart', prefetch)
    return () => router.events.off('routeChangeStart', prefetch)
  }, [router, queryClient])
}
```
