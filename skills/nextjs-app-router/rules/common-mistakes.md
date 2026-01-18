---
title: Common Next.js App Router Mistakes
impact: CRITICAL
impactDescription: Avoid these 8 common pitfalls
tags: next.js, mistakes, debugging, errors
---

## Common Next.js App Router Mistakes

### 1. useActionState Signature Error

Server Actions used with `useActionState` must accept `prevState` as first parameter.

```typescript
// ❌ WRONG - missing prevState parameter
export async function createPost(formData: FormData) {
  'use server'
  // ...
}

// ✅ CORRECT - prevState is required
export async function createPost(prevState: any, formData: FormData) {
  'use server'
  // ...
}
```

---

### 2. Missing 'use server' Directive

Server Actions must include the `'use server'` directive.

```typescript
// ❌ WRONG - no directive
async function submitForm(formData: FormData) {
  await db.insert(...)
}

// ✅ CORRECT - directive at top of function or file
async function submitForm(formData: FormData) {
  'use server'
  await db.insert(...)
}
```

---

### 3. Cache Behavior Misunderstanding

Next.js 15+ changed default fetch caching behavior.

```typescript
// In Next.js 14: cached by default (force-cache)
// In Next.js 15+: NOT cached by default (no-store)
fetch(url) // Now dynamic by default

// Explicitly opt-in to caching
fetch(url, { cache: 'force-cache' })
fetch(url, { next: { revalidate: 60 } })
```

---

### 4. Cookies/Headers Make Route Dynamic

Using `cookies()` or `headers()` opts route out of static generation.

```typescript
// ❌ This route will be dynamic, NOT static
export default async function Page() {
  const cookieStore = await cookies()
  const theme = cookieStore.get('theme')
  return <div>...</div>
}

// ✅ If you need static + cookies, use middleware
// or read cookies client-side
```

---

### 5. refresh() Only Works in Server Actions

```typescript
import { refresh } from 'next/cache'

// ❌ WRONG - will throw error
export async function GET() {
  refresh() // Cannot use in Route Handler!
}

// ✅ CORRECT - only in Server Actions
async function updateData() {
  'use server'
  await db.update(...)
  refresh()
}
```

---

### 6. Sequential Fetching (Waterfall)

```typescript
// ❌ WRONG - sequential, slow
export default async function Page() {
  const user = await getUser()
  const posts = await getPosts() // Waits for user to finish
  const comments = await getComments() // Waits for posts
}

// ✅ CORRECT - parallel
export default async function Page() {
  const [user, posts, comments] = await Promise.all([
    getUser(),
    getPosts(),
    getComments(),
  ])
}
```

---

### 7. params Must Be Awaited (Next.js 15+)

```typescript
// ❌ WRONG in Next.js 15+
export default function Page({ params }: { params: { id: string } }) {
  return <div>{params.id}</div>
}

// ✅ CORRECT - params is now a Promise
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  return <div>{id}</div>
}
```

---

### 8. Not Using useFormStatus Correctly

`useFormStatus` must be used inside a form child component.

```typescript
// ❌ WRONG - in same component as form
export function Form() {
  const { pending } = useFormStatus() // Won't work!
  return <form><button disabled={pending}>Submit</button></form>
}

// ✅ CORRECT - in child component
function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>Submit</button>
}

export function Form() {
  return (
    <form action={action}>
      <SubmitButton />
    </form>
  )
}
```
