# Optimistic Updates

Update UI immediately before server confirms, with rollback on error.

## Toggle Example

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const queryClient = useQueryClient()

  const toggleTodo = useMutation({
    mutationFn: async (completed: boolean) => {
      const res = await fetch(`/api/todos/${todo.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ completed }),
      })
      if (!res.ok) throw new Error('Failed to update todo')
      return res.json() as Promise<Todo>
    },

    // Optimistic update
    onMutate: async (completed) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['todos'] })

      // Snapshot previous value
      const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

      // Optimistically update
      queryClient.setQueryData<Todo[]>(['todos'], (old) =>
        old?.map((t) => (t.id === todo.id ? { ...t, completed } : t))
      )

      // Return context with snapshot
      return { previousTodos }
    },

    // Rollback on error
    onError: (err, variables, context) => {
      if (context?.previousTodos) {
        queryClient.setQueryData(['todos'], context.previousTodos)
      }
      toast.error('Failed to update todo')
    },

    // Always refetch after error or success
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })

  return (
    <Checkbox
      checked={todo.completed}
      onCheckedChange={(checked) => toggleTodo.mutate(!!checked)}
      disabled={toggleTodo.isPending}
    />
  )
}
```

## Delete with Optimistic Update

```typescript
function DeleteButton({ postId }: { postId: string }) {
  const queryClient = useQueryClient()

  const deletePost = useMutation({
    mutationFn: async () => {
      const res = await fetch(`/api/posts/${postId}`, { method: 'DELETE' })
      if (!res.ok) throw new Error('Failed to delete')
    },

    onMutate: async () => {
      await queryClient.cancelQueries({ queryKey: ['posts'] })

      const previousPosts = queryClient.getQueryData<Post[]>(['posts'])

      // Optimistically remove from list
      queryClient.setQueryData<Post[]>(['posts'], (old) =>
        old?.filter((p) => p.id !== postId)
      )

      return { previousPosts }
    },

    onError: (err, variables, context) => {
      queryClient.setQueryData(['posts'], context?.previousPosts)
      toast.error('Failed to delete post')
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })

  return (
    <Button
      variant="destructive"
      onClick={() => deletePost.mutate()}
      disabled={deletePost.isPending}
    >
      Delete
    </Button>
  )
}
```

## Key Points

1. **Cancel queries** - Prevent race conditions with ongoing fetches
2. **Snapshot data** - Save previous state for rollback
3. **Update optimistically** - Apply change immediately
4. **Return context** - Pass snapshot to error handler
5. **Rollback on error** - Restore previous state
6. **Refetch on settle** - Ensure consistency regardless of outcome
