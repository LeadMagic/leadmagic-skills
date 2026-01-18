---
name: typescript-best-practices
description: TypeScript best practices for building type-safe applications. Use when writing TypeScript code, configuring tsconfig, defining types/interfaces, or reviewing code for type safety. Triggers on "TypeScript", "type safety", "tsconfig", "interfaces", "generics".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# TypeScript Best Practices

Comprehensive guide for writing production-ready TypeScript code. Contains 40+ rules across 7 categories.

## When to Apply

Reference these guidelines when:
- Setting up new TypeScript projects
- Writing type definitions and interfaces
- Configuring tsconfig.json
- Reviewing code for type safety
- Refactoring JavaScript to TypeScript

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Configuration | CRITICAL | `config-` |
| 2 | Type Definitions | CRITICAL | `types-` |
| 3 | Type Safety | HIGH | `safety-` |
| 4 | Generics | HIGH | `generics-` |
| 5 | Utility Types | MEDIUM | `utility-` |
| 6 | Error Handling | MEDIUM | `errors-` |
| 7 | Performance | LOW-MEDIUM | `perf-` |

## Quick Reference

### 1. Configuration (CRITICAL)

- `config-strict-mode` - Enable strict mode and all strict checks
- `config-no-implicit-any` - Disallow implicit any
- `config-strict-null-checks` - Enable strict null checks
- `config-no-unchecked-indexed-access` - Check indexed access
- `config-exact-optional-property-types` - Exact optional properties

### 2. Type Definitions (CRITICAL)

- `types-interface-vs-type` - When to use interface vs type
- `types-explicit-return` - Explicit function return types
- `types-const-assertions` - Use const assertions for literals
- `types-discriminated-unions` - Use discriminated unions for variants
- `types-branded-types` - Use branded types for type-safe IDs

### 3. Type Safety (HIGH)

- `safety-no-any` - Avoid `any`, use `unknown` for unknown types
- `safety-type-guards` - Implement proper type guards
- `safety-exhaustive-checks` - Use exhaustive checks in switches
- `safety-readonly` - Use readonly for immutable data
- `safety-null-handling` - Handle null/undefined explicitly

### 4. Generics (HIGH)

- `generics-constraints` - Use constraints to limit generic types
- `generics-defaults` - Provide sensible defaults
- `generics-inference` - Let TypeScript infer when possible
- `generics-variance` - Understand covariance and contravariance

### 5. Utility Types (MEDIUM)

- `utility-partial-required` - Use Partial<T> and Required<T>
- `utility-pick-omit` - Use Pick<T, K> and Omit<T, K>
- `utility-record` - Use Record<K, V> for dictionaries
- `utility-extract-exclude` - Extract and Exclude for unions
- `utility-parameters-return` - Parameters<T> and ReturnType<T>

### 6. Error Handling (MEDIUM)

- `errors-result-type` - Use Result<T, E> pattern
- `errors-custom-errors` - Create typed custom errors
- `errors-never-throw-strings` - Never throw string literals
- `errors-async-errors` - Handle async errors properly

### 7. Performance (LOW-MEDIUM)

- `perf-type-only-imports` - Use type-only imports
- `perf-isolatedModules` - Enable isolatedModules
- `perf-incremental` - Enable incremental compilation
- `perf-skipLibCheck` - Consider skipLibCheck for faster builds

## Essential Configuration

### Recommended tsconfig.json

```json
{
  "compilerOptions": {
    // Strict Type Checking
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true,
    "alwaysStrict": true,

    // Additional Checks
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,

    // Module Resolution
    "moduleResolution": "bundler",
    "module": "ESNext",
    "target": "ES2022",
    "lib": ["ES2022"],

    // Emit
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    // Performance
    "incremental": true,
    "skipLibCheck": true,
    "isolatedModules": true,

    // Paths
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Cloudflare Workers tsconfig.json

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "types": ["@cloudflare/workers-types"],
    "noEmit": true,
    "isolatedModules": true,
    "skipLibCheck": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

## Essential Patterns

### Discriminated Unions

```typescript
// ❌ Bad: Unclear which properties exist
interface ApiResponse {
  success: boolean
  data?: unknown
  error?: string
}

// ✅ Good: Discriminated union with type narrowing
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string }

function handleResponse<T>(response: ApiResponse<T>) {
  if (response.success) {
    // TypeScript knows: response.data exists
    console.log(response.data)
  } else {
    // TypeScript knows: response.error exists
    console.error(response.error)
  }
}
```

### Branded Types (Type-Safe IDs)

```typescript
// Create branded type
type Brand<T, B> = T & { __brand: B }

type UserId = Brand<string, 'UserId'>
type PostId = Brand<string, 'PostId'>

// Constructor functions
function UserId(id: string): UserId {
  return id as UserId
}

function PostId(id: string): PostId {
  return id as PostId
}

// Now these are type-safe
function getUser(id: UserId) { /* ... */ }
function getPost(id: PostId) { /* ... */ }

const userId = UserId('user-123')
const postId = PostId('post-456')

getUser(userId) // ✅ OK
getUser(postId) // ❌ Type error! Can't pass PostId to UserId
```

### Type Guards

```typescript
// Custom type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value &&
    typeof (value as User).id === 'string' &&
    typeof (value as User).email === 'string'
  )
}

// Usage
function processData(data: unknown) {
  if (isUser(data)) {
    // TypeScript knows: data is User
    console.log(data.email)
  }
}

// Assertion function
function assertIsUser(value: unknown): asserts value is User {
  if (!isUser(value)) {
    throw new Error('Value is not a User')
  }
}
```

### Exhaustive Checks

```typescript
type Status = 'pending' | 'active' | 'completed' | 'cancelled'

function getStatusMessage(status: Status): string {
  switch (status) {
    case 'pending':
      return 'Waiting to start'
    case 'active':
      return 'In progress'
    case 'completed':
      return 'Finished'
    case 'cancelled':
      return 'Cancelled'
    default:
      // This ensures all cases are handled
      const _exhaustive: never = status
      throw new Error(`Unhandled status: ${_exhaustive}`)
  }
}
```

### Result Type Pattern

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E }

function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value }
}

function Err<E>(error: E): Result<never, E> {
  return { ok: false, error }
}

// Usage
async function fetchUser(id: string): Promise<Result<User, 'NOT_FOUND' | 'NETWORK_ERROR'>> {
  try {
    const response = await fetch(`/api/users/${id}`)

    if (response.status === 404) {
      return Err('NOT_FOUND')
    }

    const user = await response.json()
    return Ok(user)
  } catch {
    return Err('NETWORK_ERROR')
  }
}

// Consumer code
const result = await fetchUser('123')

if (result.ok) {
  console.log(result.value.email)
} else {
  // result.error is 'NOT_FOUND' | 'NETWORK_ERROR'
  if (result.error === 'NOT_FOUND') {
    console.log('User not found')
  }
}
```

### Const Assertions

```typescript
// ❌ Type is string[]
const colors = ['red', 'green', 'blue']

// ✅ Type is readonly ['red', 'green', 'blue']
const colors = ['red', 'green', 'blue'] as const

// ❌ Type is { method: string, url: string }
const config = { method: 'GET', url: '/api' }

// ✅ Type is { readonly method: 'GET', readonly url: '/api' }
const config = { method: 'GET', url: '/api' } as const

// Create type from const
type Color = typeof colors[number] // 'red' | 'green' | 'blue'
```

### Generic Constraints

```typescript
// Constrain to objects with id
function getById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id)
}

// Constrain to keys of object
function pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
  const result = {} as Pick<T, K>
  for (const key of keys) {
    result[key] = obj[key]
  }
  return result
}

// Usage
const user = { id: '1', name: 'John', email: 'john@example.com', password: 'secret' }
const publicUser = pick(user, ['id', 'name', 'email'])
// Type: { id: string; name: string; email: string }
```

### Mapped Types

```typescript
// Make all properties optional and nullable
type Nullable<T> = {
  [K in keyof T]: T[K] | null
}

// Make all properties required and non-nullable
type Complete<T> = {
  [K in keyof T]-?: NonNullable<T[K]>
}

// Create a type with all properties as functions that return the original type
type Setters<T> = {
  [K in keyof T as `set${Capitalize<string & K>}`]: (value: T[K]) => void
}

interface User {
  name: string
  age: number
}

type UserSetters = Setters<User>
// { setName: (value: string) => void; setAge: (value: number) => void }
```

### Type-Only Imports

```typescript
// ✅ Use type-only imports for types
import type { User, Post } from './types'
import type { Hono } from 'hono'

// ✅ Mixed import with type modifier
import { createUser, type CreateUserInput } from './users'

// This helps with:
// - Smaller bundle size (types are erased)
// - Clearer intent
// - Better compatibility with isolatedModules
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
