---
title: Prefer Utilities Over Custom CSS
impact: CRITICAL
impactDescription: Consistent, maintainable styling
tags: tailwind, utilities, css
---

## Prefer Utilities Over Custom CSS

Tailwind's utility-first approach means using utility classes directly in markup. Avoid writing custom CSS when utilities exist.

**Incorrect (unnecessary custom CSS):**

```css
/* styles.css */
.card-container {
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  background-color: white;
  border-radius: 0.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.card-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 0.5rem;
}

.card-button {
  background-color: #3b82f6;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
}

.card-button:hover {
  background-color: #2563eb;
}
```

```typescript
import './styles.css'

function Card() {
  return (
    <div className="card-container">
      <h2 className="card-title">Title</h2>
      <button className="card-button">Click</button>
    </div>
  )
}
```

**Correct (utility classes):**

```typescript
function Card() {
  return (
    <div className="flex flex-col p-6 bg-white rounded-lg shadow-sm">
      <h2 className="text-xl font-semibold text-gray-800 mb-2">Title</h2>
      <button className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors">
        Click
      </button>
    </div>
  )
}
```

**When to use @apply (sparingly):**

```css
/* Only for truly reusable patterns */
@layer components {
  .btn-primary {
    @apply bg-primary text-primary-foreground px-4 py-2 rounded-md
           hover:bg-primary/90 transition-colors focus-visible:ring-2;
  }
}
```

**Better: Use component abstraction:**

```typescript
// components/Button.tsx
function Button({ children, className, ...props }) {
  return (
    <button
      className={cn(
        "bg-primary text-primary-foreground px-4 py-2 rounded-md",
        "hover:bg-primary/90 transition-colors focus-visible:ring-2",
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}
```

**Organizing long class strings:**

```typescript
// Group related utilities on separate lines
function ComplexCard() {
  return (
    <div className={cn(
      // Layout
      "flex flex-col gap-4",
      // Spacing
      "p-6 md:p-8",
      // Colors & Background
      "bg-card text-card-foreground",
      // Border & Shadow
      "rounded-xl border shadow-sm",
      // Transitions
      "transition-shadow hover:shadow-md"
    )}>
      {/* content */}
    </div>
  )
}
```

Benefits of utility-first:
- No context switching between files
- No naming things (hard problem solved)
- Dead code elimination automatic
- Consistent spacing/sizing scale
- Easy responsive design with prefixes
