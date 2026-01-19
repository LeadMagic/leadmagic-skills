---
title: Internal Package Patterns
impact: HIGH
impactDescription: Shared code across monorepo packages
tags: monorepo, internal-packages, turborepo, typescript
---

## Internal Package Patterns

Internal packages are private packages shared within your monorepo.

### Package Types

| Type | Location | Purpose |
|------|----------|---------|
| Apps | `apps/` | Deployable applications |
| Libraries | `packages/` | Shared code |
| Configs | `packages/config-*` | Shared configurations |

---

## UI Component Library

### Structure

```
packages/ui/
├── src/
│   ├── button.tsx
│   ├── card.tsx
│   ├── input.tsx
│   └── index.ts
├── package.json
└── tsconfig.json
```

### package.json

```json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./dist/index.js"
    },
    "./button": {
      "types": "./src/button.tsx",
      "default": "./dist/button.js"
    },
    "./card": {
      "types": "./src/card.tsx",
      "default": "./dist/card.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "lint": "eslint src/"
  },
  "peerDependencies": {
    "react": "^19.0.0"
  },
  "devDependencies": {
    "@repo/typescript-config": "workspace:*",
    "@types/react": "^19",
    "typescript": "^5"
  }
}
```

### tsconfig.json

```json
{
  "extends": "@repo/typescript-config/react-library.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### Component Example

```tsx
// packages/ui/src/button.tsx
import { forwardRef, type ButtonHTMLAttributes } from "react"

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost"
  size?: "sm" | "md" | "lg"
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = "primary", size = "md", className, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={`btn btn-${variant} btn-${size} ${className}`}
        {...props}
      />
    )
  }
)

Button.displayName = "Button"
```

### Export Barrel

```tsx
// packages/ui/src/index.ts
export * from "./button"
export * from "./card"
export * from "./input"
```

---

## Shared Utilities Package

### Structure

```
packages/utils/
├── src/
│   ├── format.ts
│   ├── validation.ts
│   └── index.ts
├── package.json
└── tsconfig.json
```

### package.json

```json
{
  "name": "@repo/utils",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "vitest"
  },
  "devDependencies": {
    "@repo/typescript-config": "workspace:*",
    "typescript": "^5"
  }
}
```

---

## TypeScript Config Package

### Structure

```
packages/config-typescript/
├── base.json
├── nextjs.json
├── react-library.json
├── node.json
└── package.json
```

### package.json

```json
{
  "name": "@repo/typescript-config",
  "version": "0.0.0",
  "private": true,
  "files": ["*.json"]
}
```

### base.json

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true
  }
}
```

### nextjs.json

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "noEmit": true,
    "module": "esnext",
    "jsx": "preserve",
    "incremental": true
  }
}
```

### react-library.json

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "module": "esnext",
    "target": "esnext",
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true
  }
}
```

### node.json

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["esnext"],
    "module": "esnext",
    "target": "esnext",
    "moduleDetection": "force"
  }
}
```

---

## ESLint Config Package

### Structure

```
packages/config-eslint/
├── base.js
├── next.js
├── react.js
└── package.json
```

### package.json

```json
{
  "name": "@repo/eslint-config",
  "version": "0.0.0",
  "private": true,
  "files": ["*.js"],
  "dependencies": {
    "@typescript-eslint/eslint-plugin": "^8",
    "@typescript-eslint/parser": "^8",
    "eslint-config-prettier": "^9"
  }
}
```

### base.js

```javascript
module.exports = {
  parser: "@typescript-eslint/parser",
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier",
  ],
  rules: {
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
  },
}
```

---

## Consuming Internal Packages

### Add Dependency

```bash
# Add to specific package
pnpm add @repo/ui --filter=@repo/web --workspace

# Or manually in package.json
```

```json
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  },
  "devDependencies": {
    "@repo/typescript-config": "workspace:*",
    "@repo/eslint-config": "workspace:*"
  }
}
```

### Import in Code

```tsx
// apps/web/app/page.tsx
import { Button, Card } from "@repo/ui"
import { formatDate } from "@repo/utils"

export default function Page() {
  return (
    <Card>
      <Button>Click me</Button>
      <p>{formatDate(new Date())}</p>
    </Card>
  )
}
```

---

## Just-in-Time Packages

For packages that don't need building (source directly consumed):

```json
{
  "name": "@repo/ui",
  "exports": {
    "./button": "./src/button.tsx"
  }
}
```

No build step needed - bundler compiles on demand.

---

## Best Practices

1. **Use `workspace:*`** - Always for internal deps
2. **Export types** - Include `types` in exports
3. **Peer dependencies** - Use for React, shared deps
4. **Build dependencies first** - Use `^build` in turbo.json
5. **Private packages** - Set `"private": true`
6. **Consistent naming** - Use `@repo/` prefix
