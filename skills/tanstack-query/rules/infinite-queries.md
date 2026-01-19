# Infinite Queries

Load more / infinite scroll patterns.

## Basic Infinite Query

```typescript
import { useInfiniteQuery } from '@tanstack/react-query'

function InfinitePostList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useInfiniteQuery({
    queryKey: ['posts', 'infinite'],
    queryFn: async ({ pageParam }) => {
      const res = await fetch(`/api/posts?cursor=${pageParam ?? ''}`)
      return res.json() as Promise<{
        posts: Post[]
        nextCursor: string | null
      }>
    },
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  })

  // Flatten pages into single array
  const posts = data?.pages.flatMap((page) => page.posts) ?? []

  return (
    <div>
      {posts.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}

      <Button
        onClick={() => fetchNextPage()}
        disabled={!hasNextPage || isFetchingNextPage}
      >
        {isFetchingNextPage
          ? 'Loading more...'
          : hasNextPage
          ? 'Load More'
          : 'No more posts'}
      </Button>
    </div>
  )
}
```

## Infinite Scroll with Intersection Observer

```typescript
import { useInView } from 'react-intersection-observer'
import { useEffect } from 'react'

function InfiniteScrollList() {
  const { ref, inView } = useInView()

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: fetchItems,
    initialPageParam: 0,
    getNextPageParam: (lastPage, pages) =>
      lastPage.hasMore ? pages.length : undefined,
  })

  // Auto-fetch when bottom is in view
  useEffect(() => {
    if (inView && hasNextPage && !isFetchingNextPage) {
      fetchNextPage()
    }
  }, [inView, hasNextPage, isFetchingNextPage, fetchNextPage])

  return (
    <div>
      {data?.pages.map((page) =>
        page.items.map((item) => <Item key={item.id} item={item} />)
      )}

      {/* Sentinel element */}
      <div ref={ref}>
        {isFetchingNextPage && <Spinner />}
      </div>
    </div>
  )
}
```

## Bidirectional Infinite Query

For loading in both directions:

```typescript
const {
  data,
  fetchNextPage,
  fetchPreviousPage,
  hasNextPage,
  hasPreviousPage,
} = useInfiniteQuery({
  queryKey: ['messages'],
  queryFn: ({ pageParam }) => fetchMessages(pageParam),
  initialPageParam: { cursor: undefined, direction: 'forward' },
  getNextPageParam: (lastPage) => 
    lastPage.nextCursor ? { cursor: lastPage.nextCursor, direction: 'forward' } : undefined,
  getPreviousPageParam: (firstPage) =>
    firstPage.prevCursor ? { cursor: firstPage.prevCursor, direction: 'backward' } : undefined,
})
```
