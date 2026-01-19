---
title: Next.js Error Boundaries
impact: CRITICAL
impactDescription: Catch and display errors gracefully in Next.js
tags: nextjs, error-boundary, error.tsx, global-error
---

## Next.js Error Boundaries

### Page-Level Error Boundary

```typescript
// app/dashboard/error.tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error('Dashboard error:', error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
      <div className="text-center">
        <h2 className="text-xl font-semibold">Something went wrong</h2>
        <p className="text-muted-foreground mt-2">
          {error.message || 'An unexpected error occurred'}
        </p>
        {error.digest && (
          <p className="text-xs text-muted-foreground mt-1">
            Error ID: {error.digest}
          </p>
        )}
      </div>
      <div className="flex gap-2">
        <Button onClick={() => reset()}>Try again</Button>
        <Button variant="outline" onClick={() => window.location.href = '/'}>
          Go home
        </Button>
      </div>
    </div>
  )
}
```

### Global Error Boundary

Catches errors in root layout:

```typescript
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <div className="flex flex-col items-center justify-center min-h-screen">
          <h1 className="text-2xl font-bold">Something went wrong!</h1>
          <button onClick={() => reset()}>Try again</button>
        </div>
      </body>
    </html>
  )
}
```

### Not Found Page

```typescript
// app/not-found.tsx
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
      <h1 className="text-6xl font-bold">404</h1>
      <h2 className="text-xl text-muted-foreground">Page not found</h2>
      <p className="text-center max-w-md text-muted-foreground">
        The page you're looking for doesn't exist or has been moved.
      </p>
      <Button asChild>
        <Link href="/">Go home</Link>
      </Button>
    </div>
  )
}
```

### Triggering Not Found

```typescript
// app/posts/[id]/page.tsx
import { notFound } from 'next/navigation'

export default async function PostPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const post = await getPost(id)

  if (!post) {
    notFound()  // Renders not-found.tsx
  }

  return <Post post={post} />
}
```

### Error Boundary Hierarchy

```
app/
├── global-error.tsx   # Catches root layout errors
├── error.tsx          # Catches app-level errors
├── not-found.tsx      # 404 page
├── dashboard/
│   ├── error.tsx      # Catches dashboard errors
│   └── settings/
│       └── error.tsx  # Catches settings errors
```

Errors bubble up to the nearest `error.tsx` boundary.
