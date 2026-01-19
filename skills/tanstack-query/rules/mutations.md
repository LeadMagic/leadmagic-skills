# Mutations

Handle data modifications with proper cache invalidation.

## Basic Mutation

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query'

function CreatePostForm() {
  const queryClient = useQueryClient()

  const createPost = useMutation({
    mutationFn: async (newPost: CreatePostInput) => {
      const res = await fetch('/api/posts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newPost),
      })
      if (!res.ok) throw new Error('Failed to create post')
      return res.json() as Promise<Post>
    },
    onSuccess: (data) => {
      // Invalidate posts list to refetch
      queryClient.invalidateQueries({ queryKey: ['posts'] })
      // Or add the new post to cache directly
      queryClient.setQueryData(['posts', data.id], data)
    },
    onError: (error) => {
      toast.error(`Failed to create post: ${error.message}`)
    },
  })

  const handleSubmit = (data: CreatePostInput) => {
    createPost.mutate(data)
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* form fields */}
      <button type="submit" disabled={createPost.isPending}>
        {createPost.isPending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  )
}
```

## Delete Mutation

```typescript
function DeleteButton({ postId }: { postId: string }) {
  const queryClient = useQueryClient()

  const deletePost = useMutation({
    mutationFn: async () => {
      const res = await fetch(`/api/posts/${postId}`, { method: 'DELETE' })
      if (!res.ok) throw new Error('Failed to delete')
    },
    onSuccess: () => {
      // Invalidate and remove from cache
      queryClient.invalidateQueries({ queryKey: ['posts'] })
      queryClient.removeQueries({ queryKey: ['posts', postId] })
    },
    onError: () => {
      toast.error('Failed to delete post')
    },
  })

  return (
    <Button
      variant="destructive"
      onClick={() => deletePost.mutate()}
      disabled={deletePost.isPending}
    >
      {deletePost.isPending ? 'Deleting...' : 'Delete'}
    </Button>
  )
}
```

## Mutation with Return Value

```typescript
const createUser = useMutation({
  mutationFn: createUserApi,
  onSuccess: (newUser) => {
    // Navigate to new user
    router.push(`/users/${newUser.id}`)
  },
})

// Or use mutateAsync for promise-based flow
const handleSubmit = async (data: CreateUserInput) => {
  try {
    const user = await createUser.mutateAsync(data)
    router.push(`/users/${user.id}`)
  } catch (error) {
    // Error already handled by onError
  }
}
```
