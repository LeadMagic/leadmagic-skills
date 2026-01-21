---
name: zod
description: Zod schema validation for TypeScript. Use when validating forms, API requests, environment variables, or generating types. Triggers on "validation", "schema", "zod", "parse", "safeParse", "z.object", "form validation".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
  context7: colinhacks/zod
---

# Zod - TypeScript Schema Validation

Type-safe schema validation with automatic TypeScript inference.

## What's New in Zod 4 (Mini)

| Feature | Description |
|---------|-------------|
| **zod/v4-mini** | 50% smaller bundle for simple schemas |
| **Standard Schema** | Universal schema spec (works with AI SDK, tRPC, etc.) |
| **`z.interface()`** | Better type inference for object schemas |
| **Improved errors** | Cleaner error messages with paths |

## Installation

```bash
npm install zod
```

---

## Basic Schemas

```typescript
import { z } from 'zod'

// Primitives
const stringSchema = z.string()
const numberSchema = z.number()
const booleanSchema = z.boolean()
const dateSchema = z.date()

// With constraints
const email = z.string().email()
const age = z.number().int().min(0).max(120)
const url = z.string().url()
const uuid = z.string().uuid()

// Parse (throws on error)
const result = email.parse('user@example.com') // string

// SafeParse (returns result object)
const result = email.safeParse('invalid')
if (!result.success) {
  console.error(result.error.format())
}
```

---

## Object Schemas

```typescript
// Define schema
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2).max(100),
  age: z.number().int().positive().optional(),
  role: z.enum(['user', 'admin', 'moderator']),
  createdAt: z.coerce.date(), // Coerce strings to Date
})

// Infer TypeScript type
type User = z.infer<typeof UserSchema>
// { id: string; email: string; name: string; age?: number; role: 'user' | 'admin' | 'moderator'; createdAt: Date }

// Parse
const user = UserSchema.parse(data)
```

### Partial & Required

```typescript
// All fields optional
const PartialUser = UserSchema.partial()

// All fields required
const RequiredUser = UserSchema.required()

// Pick specific fields
const UserPreview = UserSchema.pick({ id: true, name: true })

// Omit specific fields
const CreateUser = UserSchema.omit({ id: true, createdAt: true })

// Extend schema
const AdminUser = UserSchema.extend({
  permissions: z.array(z.string()),
})
```

---

## API Request Validation

```typescript
// schemas/api.ts
export const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
  tags: z.array(z.string()).max(5).default([]),
  published: z.boolean().default(false),
})

export type CreatePostInput = z.infer<typeof CreatePostSchema>

// app/api/posts/route.ts
import { CreatePostSchema } from '@/schemas/api'

export async function POST(request: Request) {
  const body = await request.json()

  const result = CreatePostSchema.safeParse(body)
  if (!result.success) {
    return Response.json(
      { error: 'Validation failed', issues: result.error.issues },
      { status: 400 }
    )
  }

  const post = await createPost(result.data)
  return Response.json(post, { status: 201 })
}
```

---

## Environment Variables

```typescript
// env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  PORT: z.coerce.number().default(3000),
  DEBUG: z.coerce.boolean().default(false),
})

// Parse and export typed env
export const env = envSchema.parse(process.env)

// Usage: env.DATABASE_URL (fully typed)
```

---

## Form Validation (with react-hook-form)

```typescript
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

const SignUpSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[0-9]/, 'Must contain number'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
})

type SignUpForm = z.infer<typeof SignUpSchema>

export function SignUpForm() {
  const form = useForm<SignUpForm>({
    resolver: zodResolver(SignUpSchema),
  })

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {/* ... */}
    </form>
  )
}
```

---

## AI SDK Tools

```typescript
import { tool } from 'ai'
import { z } from 'zod'

const weatherTool = tool({
  description: 'Get weather for a location',
  parameters: z.object({
    location: z.string().describe('City name'),
    unit: z.enum(['celsius', 'fahrenheit']).default('celsius'),
  }),
  execute: async ({ location, unit }) => {
    return await fetchWeather(location, unit)
  },
})
```

---

## Server Actions

```typescript
'use server'

import { z } from 'zod'

const UpdateProfileSchema = z.object({
  name: z.string().min(2),
  bio: z.string().max(500).optional(),
})

export async function updateProfile(formData: FormData) {
  const result = UpdateProfileSchema.safeParse({
    name: formData.get('name'),
    bio: formData.get('bio'),
  })

  if (!result.success) {
    return { error: result.error.flatten().fieldErrors }
  }

  await db.user.update({ data: result.data })
  return { success: true }
}
```

---

## Advanced Patterns

### Discriminated Unions

```typescript
const EventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('click'), x: z.number(), y: z.number() }),
  z.object({ type: z.literal('scroll'), delta: z.number() }),
  z.object({ type: z.literal('keypress'), key: z.string() }),
])

type Event = z.infer<typeof EventSchema>
// Narrowed by 'type' field
```

### Transform

```typescript
const DateStringSchema = z.string().transform((str) => new Date(str))

const SlugSchema = z.string().transform((str) =>
  str.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
)
```

### Preprocess

```typescript
// Handle FormData strings
const NumberFromString = z.preprocess(
  (val) => (typeof val === 'string' ? parseInt(val, 10) : val),
  z.number()
)
```

### Recursive Schemas

```typescript
interface Category {
  name: string
  children: Category[]
}

const CategorySchema: z.ZodType<Category> = z.lazy(() =>
  z.object({
    name: z.string(),
    children: z.array(CategorySchema),
  })
)
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `parse()` without try/catch | Use `safeParse()` for API handlers |
| Not using `.coerce` for form data | Use `z.coerce.number()` for string→number |
| Missing error messages | Add custom messages: `z.string().min(1, 'Required')` |
| Over-validating on client | Validate on server, display errors on client |

---

## Quick Reference

| Pattern | Code |
|---------|------|
| Parse (throws) | `schema.parse(data)` |
| Safe parse | `schema.safeParse(data)` |
| Infer type | `type T = z.infer<typeof Schema>` |
| Optional | `z.string().optional()` |
| Default | `z.string().default('value')` |
| Nullable | `z.string().nullable()` |
| Array | `z.array(z.string())` |
| Enum | `z.enum(['a', 'b', 'c'])` |
| Union | `z.union([z.string(), z.number()])` |
| Coerce | `z.coerce.number()` |
| Transform | `z.string().transform(fn)` |
| Refine | `schema.refine(fn, { message })` |

## References

- [Zod Documentation](https://zod.dev)
- [Zod 4 Announcement](https://zod.dev/v4)
