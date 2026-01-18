---
title: Avoid any, Use unknown for Unknown Types
impact: HIGH
impactDescription: Maintains type safety throughout codebase
tags: types, safety, any, unknown
---

## Avoid any, Use unknown for Unknown Types

`any` disables all type checking. Use `unknown` for truly unknown types - it requires type narrowing before use.

**Incorrect (any spreads through codebase):**

```typescript
// ❌ any disables all type checking
function processData(data: any) {
  // No errors, but all of these could crash at runtime:
  console.log(data.user.email.toUpperCase())
  data.items.forEach((item: any) => item.process())
  return data.result + 10
}

// ❌ any is contagious - it spreads
const result = processData(someValue)  // result is 'any'
const email = result.user.email         // email is 'any'
email.toUpperCase()                     // No error, might crash

// ❌ JSON.parse returns 'any'
const config = JSON.parse(rawConfig)
config.server.port  // No type checking
```

**Correct (use unknown with type guards):**

```typescript
// ✅ unknown requires narrowing before use
function processData(data: unknown) {
  // Error: Object is of type 'unknown'
  // console.log(data.user.email)

  // Must narrow type first
  if (isValidData(data)) {
    console.log(data.user.email.toUpperCase())
  }
}

// ✅ Type guard function
interface ValidData {
  user: { email: string }
  items: Array<{ process: () => void }>
  result: number
}

function isValidData(data: unknown): data is ValidData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'user' in data &&
    typeof (data as ValidData).user?.email === 'string' &&
    Array.isArray((data as ValidData).items) &&
    typeof (data as ValidData).result === 'number'
  )
}

// ✅ Use Zod for runtime validation with types
import { z } from 'zod'

const DataSchema = z.object({
  user: z.object({
    email: z.string().email(),
  }),
  items: z.array(z.object({
    id: z.string(),
  })),
  result: z.number(),
})

type ValidData = z.infer<typeof DataSchema>

function processDataSafe(raw: unknown): ValidData {
  return DataSchema.parse(raw)  // Throws if invalid, returns typed data
}

// ✅ JSON.parse with validation
function parseConfig(raw: string): Config {
  const parsed: unknown = JSON.parse(raw)
  return ConfigSchema.parse(parsed)
}

// ✅ Catch blocks use unknown by default (with useUnknownInCatchVariables)
try {
  await riskyOperation()
} catch (error: unknown) {
  // Must narrow before use
  if (error instanceof Error) {
    console.error(error.message)
  } else {
    console.error('Unknown error:', error)
  }
}

// ✅ When you truly need flexibility, use generics
function wrapValue<T>(value: T): { wrapped: T } {
  return { wrapped: value }
}

const wrappedString = wrapValue('hello')  // { wrapped: string }
const wrappedNumber = wrapValue(42)        // { wrapped: number }
```

**When `any` is acceptable (rare):**

```typescript
// Migration from JavaScript (temporary)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function legacyFunction(data: any): any {
  // TODO: Add proper types
}

// Third-party library with broken types
declare module 'broken-lib' {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  export function brokenFunction(arg: any): any
}
```

**ESLint rule to enforce:**

```json
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-call": "error"
  }
}
```
