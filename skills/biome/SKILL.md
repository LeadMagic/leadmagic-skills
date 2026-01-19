---
name: biome
description: Biome formatter and linter configuration for TypeScript and JavaScript. Use when setting up code formatting, linting rules, or migrating from ESLint/Prettier. Triggers on "biome", "linting", "formatting", "code style", "eslint migration".
license: MIT
metadata:
  author: leadmagic
  version: "1.1.0"
---

# Biome - Fast Formatter & Linter

Biome is a fast, all-in-one toolchain for JavaScript and TypeScript. It combines formatting (like Prettier) and linting (like ESLint) into a single, performant tool.

## When to Apply

Reference these guidelines when:
- Setting up new projects with Biome
- Migrating from ESLint + Prettier
- Configuring linting rules
- Setting up CI/CD formatting checks
- Customizing code style rules

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Configuration | CRITICAL | `config-` |
| 2 | Rules | HIGH | `rules-` |
| 3 | IDE Integration | MEDIUM | `ide-` |

## Quick Reference

### 1. Configuration (CRITICAL)

- `config-biome-json` - Configure biome.json properly
- `config-ignore` - Set up ignore patterns

### 2. Rules (HIGH)

- `rules-recommended` - Use recommended rule sets
- `rules-custom` - Customize for project needs

---

## Installation

```bash
# npm
npm install --save-dev --save-exact @biomejs/biome

# pnpm
pnpm add --save-dev --save-exact @biomejs/biome

# Initialize configuration
npx @biomejs/biome init
```

---

## Recommended Configuration

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true,
    "defaultBranch": "main"
  },
  "files": {
    "ignoreUnknown": false,
    "ignore": [
      "**/node_modules/**",
      "**/dist/**",
      "**/.next/**",
      "**/coverage/**",
      "**/*.gen.ts"
    ]
  },
  "formatter": {
    "enabled": true,
    "formatWithErrors": false,
    "indentStyle": "tab",
    "indentWidth": 2,
    "lineEnding": "lf",
    "lineWidth": 100,
    "attributePosition": "auto"
  },
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn"
      },
      "suspicious": {
        "noExplicitAny": "warn",
        "noConsoleLog": "warn"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "jsxQuoteStyle": "double",
      "semicolons": "asNeeded",
      "trailingCommas": "all",
      "arrowParentheses": "always"
    }
  }
}
```

---

## Package.json Scripts

```json
{
  "scripts": {
    "lint": "biome lint .",
    "lint:fix": "biome lint --write .",
    "format": "biome format --write .",
    "check": "biome check .",
    "check:fix": "biome check --write .",
    "check:ci": "biome ci ."
  }
}
```

---

## Rule Levels

| Level | Behavior |
|-------|----------|
| `"error"` | Fails CI, shown in editor |
| `"warn"` | Doesn't fail CI, shown in editor |
| `"off"` | Rule disabled |

---

## Ignoring Code

### Inline Suppression

```typescript
// biome-ignore lint/suspicious/noExplicitAny: API returns unknown shape
const data: any = await fetchData()

// biome-ignore format: Keep manual formatting for readability
const matrix = [
  [1, 0, 0],
  [0, 1, 0],
  [0, 0, 1],
]
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using both Prettier and Biome | Conflicts | Remove Prettier |
| Not pinning version | Breaking changes | Use `--save-exact` |
| Ignoring too much | Missing issues | Be specific with ignores |
| Using `--unsafe` in CI | Risky auto-fixes | Only use `--write` |
| Not using `biome ci` in CI | May pass incorrectly | Use `biome ci` command |

---

## Best Practices

### Do

- Use `biome ci` in CI pipelines (stricter than `biome check`)
- Pin Biome version with `--save-exact`
- Configure VS Code to format on save
- Use lint-staged for pre-commit hooks
- Start with recommended rules, then customize

### Don't

- Don't mix Biome with ESLint/Prettier
- Don't ignore warnings without justification
- Don't use `--unsafe` flag in automated scripts
- Don't suppress rules project-wide without discussion

---

## Rule Categories

| Category | Description | Examples |
|----------|-------------|----------|
| `a11y` | Accessibility | Alt text, button types |
| `complexity` | Code complexity | Cognitive complexity, banned types |
| `correctness` | Bug prevention | Unused variables, exhaustive deps |
| `performance` | Performance | Delete non-optional props |
| `security` | Security | No dangerouslySetInnerHTML |
| `style` | Code style | Naming conventions, const usage |
| `suspicious` | Suspicious code | No explicit any, no console |
| `nursery` | Experimental | Sorted classes |

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/react-nextjs.md    - React/Next.js specific rules
rules/vscode-setup.md    - VS Code integration
rules/ci-integration.md  - CI/CD setup
rules/migration.md       - ESLint/Prettier migration
```

## Resources

- [Biome Documentation](https://biomejs.dev/docs)
- [Rules Reference](https://biomejs.dev/linter/rules)
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=biomejs.biome)
- [Migration Guide](https://biomejs.dev/guides/migrate-eslint-prettier)
