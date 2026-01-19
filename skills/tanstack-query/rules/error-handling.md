# Error Handling

Handle query and mutation errors gracefully.

## Global Error Handler

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Don't retry on 4xx errors
        if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
          return false
        }
        return failureCount < 3
      },
    },
    mutations: {
      onError: (error) => {
        // Global error handling for mutations
        if (error instanceof ApiError) {
          toast.error(error.message)
        }
      },
    },
  },
})
```

## Per-Query Error Handling

```typescript
const { data, isError, error, refetch } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
})

if (isError) {
  return (
    <div className="text-center p-4">
      <p className="text-destructive">{error.message}</p>
      <Button onClick={() => refetch()}>Try Again</Button>
    </div>
  )
}
```

## Error Boundary Integration

```typescript
// Use throwOnError with React Error Boundary
function PostDetail({ postId }: { postId: string }) {
  const { data } = useQuery({
    queryKey: ['posts', postId],
    queryFn: () => fetchPost(postId),
    throwOnError: true, // Throws to nearest error boundary
  })

  return <PostCard post={data} />
}

// Wrap with error boundary
<ErrorBoundary fallback={<ErrorFallback />}>
  <Suspense fallback={<Skeleton />}>
    <PostDetail postId={id} />
  </Suspense>
</ErrorBoundary>
```

## Mutation Error Handling

```typescript
const createPost = useMutation({
  mutationFn: createPostApi,
  onError: (error, variables, context) => {
    // Specific error handling
    if (error instanceof ValidationError) {
      setFormErrors(error.fields)
    } else {
      toast.error('Failed to create post')
    }
  },
})

// Or handle inline
const handleSubmit = async (data: CreatePostInput) => {
  try {
    await createPost.mutateAsync(data)
    toast.success('Post created!')
  } catch (error) {
    if (error instanceof DuplicateError) {
      toast.error('A post with this title already exists')
    }
    // Other errors handled by onError
  }
}
```

## Custom Error Types

```typescript
class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public code?: string
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

async function fetchWithError<T>(url: string): Promise<T> {
  const res = await fetch(url)
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new ApiError(
      body.message || 'Request failed',
      res.status,
      body.code
    )
  }
  return res.json()
}
```
