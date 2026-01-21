---
name: monorepo
description: Monorepo patterns with Turborepo and pnpm workspaces. Use when setting up monorepos, configuring task pipelines, caching, or managing internal packages. Triggers on "monorepo", "Turborepo", "turbo", "workspaces", "pnpm workspace".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
  context7: vercel/turborepo
---

# Monorepo Best Practices

Patterns for Turborepo + pnpm workspaces monorepos.

## Quick Setup

```bash
# Create new monorepo
npx create-turbo@latest

# Or add to existing project
npm install turbo --save-dev
```

---

## Directory Structure

```
my-monorepo/
├── apps/
│   ├── web/              # Next.js app
│   │   └── package.json
│   ├── api/              # Hono API
│   │   └── package.json
│   └── docs/             # Documentation
│       └── package.json
├── packages/
│   ├── ui/               # Shared React components
│   │   └── package.json
│   ├── config-typescript/# Shared tsconfig
│   │   └── package.json
│   ├── config-eslint/    # Shared ESLint config
│   │   └── package.json
│   └── utils/            # Shared utilities
│       └── package.json
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

---

## pnpm Workspace

### pnpm-workspace.yaml

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

### Root package.json

```json
{
  "name": "my-monorepo",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "test": "turbo test",
    "clean": "turbo clean"
  },
  "devDependencies": {
    "turbo": "^2"
  },
  "packageManager": "pnpm@9.0.0"
}
```

---

## Turborepo Configuration

### turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["build"]
    },
    "clean": {
      "cache": false
    }
  }
}
```

### Key Concepts

| Symbol | Meaning |
|--------|---------|
| `^build` | Run `build` in dependencies first (topological) |
| `build` | Run `build` in same package first |
| `outputs` | Files to cache |
| `cache: false` | Never cache this task |
| `persistent` | Long-running task (dev servers) |

---

## Environment Variables

```json
{
  "globalEnv": ["CI", "NODE_ENV"],
  "tasks": {
    "build": {
      "env": ["DATABASE_URL", "API_KEY"],
      "inputs": ["$TURBO_DEFAULT$", ".env.production", ".env"]
    },
    "dev": {
      "env": ["DATABASE_URL"],
      "inputs": ["$TURBO_DEFAULT$", ".env.local", ".env"]
    }
  }
}
```

---

## Running Tasks

```bash
# Run all
turbo build
turbo dev

# Filter by package
turbo build --filter=@repo/web
turbo build --filter=web

# Filter by directory
turbo build --filter=./apps/*

# Specific package#task
turbo run web#build docs#lint

# Exclude packages
turbo build --filter=!@repo/docs

# Changed packages (Git)
turbo build --filter=[HEAD^1]
turbo build --filter=...[origin/main]

# Dry run (preview)
turbo build --dry
```

---

## Internal Packages

See `rules/internal-packages.md` for detailed patterns.

### Package Structure

```
packages/ui/
├── src/
│   ├── button.tsx
│   └── index.ts
├── package.json
└── tsconfig.json
```

### package.json (Internal)

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
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "lint": "eslint src/"
  },
  "devDependencies": {
    "@repo/typescript-config": "workspace:*",
    "typescript": "^5"
  }
}
```

### Consuming Internal Package

```json
{
  "name": "@repo/web",
  "dependencies": {
    "@repo/ui": "workspace:*"
  }
}
```

```tsx
// apps/web/app/page.tsx
import { Button } from "@repo/ui/button"
```

---

## Shared Configs

### TypeScript Config Package

```json
// packages/config-typescript/package.json
{
  "name": "@repo/typescript-config",
  "version": "0.0.0",
  "private": true,
  "files": ["base.json", "nextjs.json", "react-library.json"]
}
```

```json
// packages/config-typescript/base.json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  }
}
```

### Consuming Config

```json
// apps/web/tsconfig.json
{
  "extends": "@repo/typescript-config/nextjs.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
```

---

## Remote Caching

```bash
# Login to Vercel
npx turbo login

# Link repo
npx turbo link

# Now caches are shared across team/CI
```

### turbo.json (Remote Cache)

```json
{
  "remoteCache": {}
}
```

---

## Common Commands

| Task | Command |
|------|---------|
| Install deps | `pnpm install` |
| Build all | `turbo build` |
| Dev all | `turbo dev` |
| Build one | `turbo build --filter=web` |
| Add dep to package | `pnpm add react --filter=@repo/ui` |
| Add dev dep | `pnpm add -D typescript --filter=@repo/ui` |
| Add workspace dep | `pnpm add @repo/ui --filter=@repo/web --workspace` |
| Run script in package | `pnpm --filter=web dev` |

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `^` in dependsOn | Use `^build` for topological order |
| Caching dev tasks | Set `cache: false, persistent: true` |
| Wrong workspace protocol | Use `workspace:*` in dependencies |
| Missing outputs | Define `outputs` array for caching |
| Env var cache issues | Add env vars to `env` array |
| Not linking remote cache | Run `turbo login && turbo link` |

---

## Quick Reference

| Concept | Configuration |
|---------|---------------|
| Workspace file | `pnpm-workspace.yaml` |
| Turbo config | `turbo.json` |
| Topological deps | `"dependsOn": ["^build"]` |
| Filter package | `--filter=@repo/web` |
| Internal dep | `"@repo/ui": "workspace:*"` |
| Disable cache | `"cache": false` |
| Remote cache | `npx turbo login && turbo link` |
