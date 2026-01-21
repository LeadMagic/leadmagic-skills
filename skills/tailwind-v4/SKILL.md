---
name: tailwind-v4
description: Tailwind CSS v4 patterns with CSS-first configuration. Use when styling components, configuring themes, or migrating from v3. Triggers on "Tailwind", "CSS", "styling", "theme", "dark mode", "responsive", "tailwind.config".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Tailwind CSS v4

CSS-first configuration with native CSS features.

## What's New in v4

| Feature | Description |
|---------|-------------|
| **CSS-first config** | Configure in CSS, not JS |
| **`@theme`** | Define design tokens in CSS |
| **`@plugin`** | Load plugins in CSS |
| **`@import "tailwindcss"`** | Single import |
| **No PostCSS** | Built-in processing (optional) |
| **3-5x faster** | Oxide engine rewrite |
| **Native CSS nesting** | No preprocessor needed |

## Installation

```bash
npm install tailwindcss@next @tailwindcss/vite
```

### Vite Setup

```typescript
// vite.config.ts
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [tailwindcss()],
})
```

### Next.js Setup

```bash
npm install tailwindcss@next @tailwindcss/postcss
```

```javascript
// postcss.config.mjs
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
```

---

## CSS-First Configuration

### Basic Setup (app.css)

```css
/* Import Tailwind */
@import "tailwindcss";

/* Load plugins */
@plugin "@tailwindcss/typography";
@plugin "@tailwindcss/forms";

/* Custom theme */
@theme {
  /* Colors */
  --color-primary: oklch(0.6 0.2 250);
  --color-secondary: oklch(0.8 0.1 250);
  --color-accent: oklch(0.7 0.25 150);
  
  /* Fonts */
  --font-sans: "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;
  
  /* Spacing */
  --spacing-18: 4.5rem;
  --spacing-128: 32rem;
  
  /* Border radius */
  --radius-xl: 1rem;
  --radius-2xl: 1.5rem;
  
  /* Shadows */
  --shadow-soft: 0 2px 8px oklch(0 0 0 / 0.08);
  
  /* Animations */
  --animate-fade-in: fade-in 0.3s ease-out;
}

/* Custom keyframes */
@keyframes fade-in {
  from { opacity: 0; transform: translateY(-4px); }
  to { opacity: 1; transform: translateY(0); }
}
```

---

## Theme Tokens

### Colors (OKLCH Recommended)

```css
@theme {
  /* Brand colors */
  --color-brand-50: oklch(0.97 0.01 250);
  --color-brand-100: oklch(0.93 0.03 250);
  --color-brand-500: oklch(0.6 0.2 250);
  --color-brand-900: oklch(0.3 0.1 250);
  
  /* Semantic colors */
  --color-success: oklch(0.7 0.2 145);
  --color-warning: oklch(0.8 0.15 85);
  --color-error: oklch(0.6 0.25 25);
  
  /* Surfaces */
  --color-surface: oklch(0.99 0 0);
  --color-surface-secondary: oklch(0.97 0 0);
}
```

### Typography

```css
@theme {
  /* Font families */
  --font-display: "Cal Sans", system-ui;
  --font-body: "Inter", sans-serif;
  
  /* Font sizes */
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  
  /* Line heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;
  
  /* Letter spacing */
  --tracking-tight: -0.02em;
  --tracking-wide: 0.02em;
}
```

---

## Dark Mode

### CSS Variables Approach

```css
@theme {
  /* Light mode (default) */
  --color-bg: oklch(0.99 0 0);
  --color-text: oklch(0.2 0 0);
  --color-border: oklch(0.9 0 0);
}

/* Dark mode overrides */
@media (prefers-color-scheme: dark) {
  @theme {
    --color-bg: oklch(0.15 0.02 250);
    --color-text: oklch(0.95 0 0);
    --color-border: oklch(0.3 0.02 250);
  }
}

/* Or class-based dark mode */
.dark {
  --color-bg: oklch(0.15 0.02 250);
  --color-text: oklch(0.95 0 0);
}
```

### Using Dark Variant

```tsx
<div className="bg-white dark:bg-zinc-900">
  <h1 className="text-zinc-900 dark:text-white">
    Adapts to color scheme
  </h1>
</div>
```

---

## New v4 Features

### Native Container Queries

```css
@theme {
  --container-sm: 20rem;
  --container-md: 28rem;
  --container-lg: 32rem;
}
```

```tsx
<div className="@container">
  <div className="@sm:flex @md:grid @lg:grid-cols-3">
    {/* Responsive to container, not viewport */}
  </div>
</div>
```

### 3D Transforms

```tsx
<div className="perspective-1000">
  <div className="rotate-x-12 rotate-y-6 transform-3d">
    3D transformed element
  </div>
</div>
```

### Gradient Improvements

```tsx
{/* Gradient with oklch colors */}
<div className="bg-gradient-to-r from-brand-500 to-accent via-secondary" />

{/* Radial gradients */}
<div className="bg-radial-[at_top_left] from-brand-500 to-transparent" />

{/* Conic gradients */}
<div className="bg-conic from-red-500 via-yellow-500 to-red-500" />
```

---

## Component Patterns

### Card Component

```tsx
<div className="rounded-xl border border-border bg-surface p-6 shadow-soft">
  <h3 className="text-lg font-semibold text-text">Card Title</h3>
  <p className="mt-2 text-sm text-text/70">Card description</p>
</div>
```

### Button Variants

```tsx
{/* Primary */}
<button className="rounded-lg bg-brand-500 px-4 py-2 text-white 
  hover:bg-brand-600 active:bg-brand-700 
  transition-colors duration-150">
  Primary
</button>

{/* Secondary */}
<button className="rounded-lg border border-border bg-surface px-4 py-2 
  text-text hover:bg-surface-secondary 
  transition-colors duration-150">
  Secondary
</button>

{/* Ghost */}
<button className="rounded-lg px-4 py-2 text-text 
  hover:bg-surface-secondary 
  transition-colors duration-150">
  Ghost
</button>
```

### Input Field

```tsx
<input
  type="text"
  className="w-full rounded-lg border border-border bg-surface px-4 py-2 
    text-text placeholder:text-text/50
    focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/20
    transition-all duration-150"
  placeholder="Enter text..."
/>
```

---

## Migration from v3

### Config Changes

```javascript
// v3: tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: '#3b82f6',
      },
    },
  },
}

// v4: app.css
@theme {
  --color-brand: #3b82f6;
}
```

### Plugin Loading

```css
/* v4: Load in CSS */
@plugin "@tailwindcss/typography";
@plugin "@tailwindcss/forms";
@plugin "@tailwindcss/container-queries";
```

### Automatic Migration

```bash
npx @tailwindcss/upgrade
```

---

## Best Practices

### Use OKLCH Colors

```css
/* More perceptually uniform than hex/rgb */
@theme {
  --color-blue-500: oklch(0.6 0.2 250);  /* Vivid blue */
  --color-blue-600: oklch(0.5 0.2 250);  /* Darker, same saturation */
}
```

### Semantic Tokens

```css
@theme {
  /* Don't: color-blue-500 everywhere */
  /* Do: semantic names */
  --color-interactive: var(--color-brand-500);
  --color-interactive-hover: var(--color-brand-600);
  --color-danger: var(--color-red-500);
}
```

### Group Related Utilities

```tsx
{/* Group hover/focus states */}
<button className="
  bg-brand-500 text-white
  hover:bg-brand-600 
  focus:ring-2 focus:ring-brand-500/50 focus:outline-none
  active:bg-brand-700
  disabled:opacity-50 disabled:cursor-not-allowed
  transition-colors duration-150
">
  Button
</button>
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using JS config in v4 | Move to CSS with `@theme` |
| Old color format | Use OKLCH for v4 |
| Missing plugin import | Add `@plugin "..."` in CSS |
| PostCSS not configured | Use `@tailwindcss/postcss` for Next.js |

---

## Quick Reference

| v3 | v4 |
|----|-----|
| `tailwind.config.js` | `@theme { }` in CSS |
| `require('@tailwindcss/...')` | `@plugin "@tailwindcss/..."` |
| `@tailwind base/components/utilities` | `@import "tailwindcss"` |

| Feature | Class |
|---------|-------|
| Container query | `@container`, `@sm:`, `@md:` |
| 3D transform | `perspective-*`, `rotate-x-*` |
| Gradient | `bg-radial-*`, `bg-conic` |
| Dark mode | `dark:*` |

## References

- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
- [OKLCH Color Picker](https://oklch.com)
