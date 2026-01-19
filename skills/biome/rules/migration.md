# ESLint/Prettier Migration

Migrate from ESLint + Prettier to Biome.

## Automatic Migration

```bash
# Generate biome config from existing ESLint config
npx @biomejs/biome migrate eslint --write

# Generate from Prettier config
npx @biomejs/biome migrate prettier --write
```

## Remove Old Dependencies

```bash
npm uninstall \
  eslint \
  prettier \
  eslint-config-prettier \
  eslint-plugin-react \
  eslint-plugin-react-hooks \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser
```

## Update Scripts

```json
// Before (ESLint + Prettier)
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "format": "prettier --write ."
  }
}

// After (Biome)
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write ."
  }
}
```

## Remove Config Files

Delete these files after migration:

- `.eslintrc.js` / `.eslintrc.json`
- `.prettierrc` / `.prettierrc.json`
- `.eslintignore`
- `.prettierignore`

## Rule Mapping

Common ESLint rules and their Biome equivalents:

| ESLint Rule | Biome Rule |
|-------------|------------|
| `no-unused-vars` | `correctness/noUnusedVariables` |
| `no-explicit-any` | `suspicious/noExplicitAny` |
| `react-hooks/exhaustive-deps` | `correctness/useExhaustiveDependencies` |
| `react-hooks/rules-of-hooks` | `correctness/useHookAtTopLevel` |
| `no-console` | `suspicious/noConsoleLog` |

## Notes

- Some ESLint rules may not have direct Biome equivalents
- Check [Biome Rules Reference](https://biomejs.dev/linter/rules) for all available rules
- Consider using the recommended rule set as a starting point
