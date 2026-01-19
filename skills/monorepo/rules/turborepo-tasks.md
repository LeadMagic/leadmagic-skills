---
title: Turborepo Task Configuration
impact: HIGH
impactDescription: Configure task pipelines and caching
tags: monorepo, turborepo, tasks, caching
---

## Turborepo Task Configuration

### Task Definition

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "inputs": ["$TURBO_DEFAULT$", ".env.production"],
      "env": ["NODE_ENV", "API_URL"]
    }
  }
}
```

---

## dependsOn Syntax

### Topological (Dependencies First)

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}
```

If `web` depends on `ui`, runs: `ui#build` → `web#build`

### Same Package First

```json
{
  "tasks": {
    "test": {
      "dependsOn": ["build"]
    }
  }
}
```

Runs `build` in same package before `test`.

### Specific Package Task

```json
{
  "tasks": {
    "deploy": {
      "dependsOn": ["^build", "test", "lint"]
    }
  }
}
```

### No Dependencies

```json
{
  "tasks": {
    "lint": {}
  }
}
```

Can run in parallel with everything.

---

## Outputs (Caching)

```json
{
  "tasks": {
    "build": {
      "outputs": [
        "dist/**",
        ".next/**",
        "!.next/cache/**",
        "build/**"
      ]
    }
  }
}
```

| Pattern | Meaning |
|---------|---------|
| `dist/**` | All files in dist |
| `!.next/cache/**` | Exclude Next.js cache |
| `build/**` | All files in build |

### No Outputs

```json
{
  "tasks": {
    "lint": {
      "outputs": []
    }
  }
}
```

---

## Inputs (Hash Sources)

```json
{
  "tasks": {
    "build": {
      "inputs": [
        "$TURBO_DEFAULT$",
        ".env.production",
        ".env.local",
        "!**/*.test.ts"
      ]
    }
  }
}
```

| Pattern | Meaning |
|---------|---------|
| `$TURBO_DEFAULT$` | Default file inputs |
| `.env.production` | Include env file |
| `!**/*.test.ts` | Exclude test files |

---

## Environment Variables

### Task-Specific

```json
{
  "tasks": {
    "build": {
      "env": ["DATABASE_URL", "API_KEY"]
    }
  }
}
```

### Global

```json
{
  "globalEnv": ["CI", "NODE_ENV", "VERCEL"]
}
```

### Wildcards

```json
{
  "tasks": {
    "build": {
      "env": [
        "NEXT_PUBLIC_*",
        "!NEXT_PUBLIC_DEBUG"
      ]
    }
  }
}
```

---

## Special Tasks

### Development (No Cache)

```json
{
  "tasks": {
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

### Clean

```json
{
  "tasks": {
    "clean": {
      "cache": false
    }
  }
}
```

### Type Check

```json
{
  "tasks": {
    "typecheck": {
      "dependsOn": ["^build"],
      "outputs": []
    }
  }
}
```

---

## Package-Specific Overrides

```json
{
  "tasks": {
    "build": {
      "outputs": ["dist/**"]
    },
    "web#build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**"],
      "env": ["NEXT_PUBLIC_API_URL"]
    },
    "api#build": {
      "outputs": ["dist/**"],
      "env": ["DATABASE_URL"]
    }
  }
}
```

---

## Complete Example

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "globalEnv": ["CI", "NODE_ENV"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "env": ["NODE_ENV"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "clean": {
      "cache": false
    },
    "web#build": {
      "env": ["NEXT_PUBLIC_*"]
    },
    "api#build": {
      "env": ["DATABASE_URL", "REDIS_URL"]
    }
  }
}
```

---

## Filtering Tasks

```bash
# By package name
turbo build --filter=@repo/web

# By directory
turbo build --filter=./apps/*

# Exclude
turbo build --filter=!@repo/docs

# Changed since
turbo build --filter=[HEAD^1]
turbo build --filter=...[origin/main]

# Package and dependencies
turbo build --filter=@repo/web...

# Package and dependents
turbo build --filter=...@repo/ui

# Combine
turbo build --filter=./apps/* --filter=!./apps/admin
```

---

## CI Optimization

```bash
# Only run affected
turbo build --filter=[origin/main...HEAD]

# Dry run to see what would run
turbo build --dry --filter=[origin/main...HEAD]

# Summary
turbo build --summarize
```
