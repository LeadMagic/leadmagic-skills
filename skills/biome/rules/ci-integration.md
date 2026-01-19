# CI Integration

Set up Biome in CI/CD pipelines.

## GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Biome
        uses: biomejs/setup-biome@v2
        with:
          version: latest

      - name: Run Biome
        run: biome ci .
```

## Pre-commit Hook (with Husky)

```bash
# Install husky
npm install --save-dev husky lint-staged
npx husky init
```

```json
// package.json
{
  "lint-staged": {
    "*.{js,ts,tsx,json}": ["biome check --write --no-errors-on-unmatched"]
  }
}
```

```bash
# .husky/pre-commit
npx lint-staged
```

## CI vs Check Commands

| Command | Use Case |
|---------|----------|
| `biome check` | Local development, allows warnings |
| `biome ci` | CI pipelines, stricter (fails on formatted files) |
| `biome check --write` | Auto-fix locally |
| `biome lint` | Lint only (no format) |
| `biome format` | Format only (no lint) |

## Important

Always use `biome ci` in CI pipelines instead of `biome check`:

```yaml
# Correct
- run: biome ci .

# Incorrect (may pass when files need formatting)
- run: biome check .
```
