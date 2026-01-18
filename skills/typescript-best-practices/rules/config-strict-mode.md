---
title: Enable Strict Mode and All Strict Checks
impact: CRITICAL
impactDescription: Catches 90% of common TypeScript bugs at compile time
tags: config, strict, tsconfig
---

## Enable Strict Mode and All Strict Checks

Enable `strict: true` plus additional strict checks in your `tsconfig.json` to catch bugs before they reach production.

**Incorrect (loose configuration):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext"
    // No strict settings - many bugs slip through
  }
}
```

```typescript
// These bugs compile without errors:

function greet(name) {           // name is implicitly 'any'
  return "Hello " + name.toUppercase()  // typo: toUppercase vs toUpperCase
}

function getUser(id: string) {
  // Missing return - returns undefined
  const user = db.get(id)
}

const users = ["Alice", "Bob"]
const first = users[10]          // undefined but typed as string
console.log(first.toUpperCase()) // runtime crash!
```

**Correct (strict configuration):**

```json
{
  "compilerOptions": {
    // Enable all strict checks at once
    "strict": true,

    // Additional checks beyond "strict"
    "noUncheckedIndexedAccess": true,      // Array access might be undefined
    "noImplicitOverride": true,            // Require 'override' keyword
    "noPropertyAccessFromIndexSignature": true,  // Use bracket notation for index signatures
    "exactOptionalPropertyTypes": true,    // undefined !== missing property
    "noFallthroughCasesInSwitch": true,   // Require break in switch cases

    // These are included in "strict" but shown for clarity:
    // "noImplicitAny": true,
    // "strictNullChecks": true,
    // "strictFunctionTypes": true,
    // "strictBindCallApply": true,
    // "strictPropertyInitialization": true,
    // "noImplicitThis": true,
    // "useUnknownInCatchVariables": true,
    // "alwaysStrict": true,

    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler"
  }
}
```

```typescript
// Now TypeScript catches all the bugs:

function greet(name) {           // Error: Parameter 'name' implicitly has 'any' type
  return "Hello " + name.toUppercase()  // Error: Property 'toUppercase' does not exist
}

function greet(name: string) {   // ✅ Fixed
  return "Hello " + name.toUpperCase()
}

function getUser(id: string) {
  const user = db.get(id)        // Error: Not all code paths return a value
}

function getUser(id: string): User | undefined {  // ✅ Fixed
  return db.get(id)
}

const users = ["Alice", "Bob"]
const first = users[10]          // Type is now 'string | undefined'
console.log(first.toUpperCase()) // Error: 'first' is possibly 'undefined'

if (first) {                     // ✅ Fixed
  console.log(first.toUpperCase())
}
```

**What each strict flag catches:**

| Flag | Catches |
|------|---------|
| `noImplicitAny` | Untyped variables and parameters |
| `strictNullChecks` | Null/undefined access errors |
| `strictFunctionTypes` | Function type mismatches |
| `noUncheckedIndexedAccess` | Array/object out-of-bounds access |
| `exactOptionalPropertyTypes` | Confusion between undefined and missing |
| `noImplicitReturns` | Missing return statements |

Start with `strict: true` on new projects. For existing projects, enable flags incrementally.
