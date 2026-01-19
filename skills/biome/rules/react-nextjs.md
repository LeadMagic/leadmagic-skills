# React/Next.js Rules

Recommended Biome rules for React and Next.js projects.

## Configuration

```json
{
  "linter": {
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn",
        "useHookAtTopLevel": "error"
      },
      "suspicious": {
        "noExplicitAny": "warn",
        "noArrayIndexKey": "warn"
      },
      "a11y": {
        "useButtonType": "error",
        "useAltText": "error"
      },
      "nursery": {
        "useSortedClasses": {
          "level": "warn",
          "options": {
            "attributes": ["class", "className", "classList"],
            "functions": ["clsx", "cn", "cva", "twMerge"]
          }
        }
      }
    }
  }
}
```

## Key Rules Explained

### useExhaustiveDependencies

Warns when React hooks have missing or unnecessary dependencies:

```typescript
// Warning: Missing dependency 'userId'
useEffect(() => {
  fetchUser(userId)
}, []) // Should include [userId]
```

### useHookAtTopLevel

Ensures hooks are only called at the top level:

```typescript
// Error: Hook called conditionally
if (condition) {
  const [state, setState] = useState() // Not allowed
}
```

### noArrayIndexKey

Warns against using array index as React key:

```typescript
// Warning: Avoid index as key
{items.map((item, index) => (
  <Item key={index} /> // Use item.id instead
))}
```

### useSortedClasses (Tailwind)

Automatically sorts Tailwind CSS classes:

```typescript
// Before
<div className="p-4 flex bg-blue-500 items-center" />

// After (sorted)
<div className="flex items-center bg-blue-500 p-4" />
```
