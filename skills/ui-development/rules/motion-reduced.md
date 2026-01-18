---
title: Respect Reduced Motion Preferences
impact: HIGH
impactDescription: Accessibility for users with vestibular disorders
tags: framer-motion, accessibility, reduced-motion
---

## Respect Reduced Motion Preferences

Some users experience motion sickness or vestibular disorders. Always respect the `prefers-reduced-motion` media query.

**Incorrect (ignoring reduced motion):**

```typescript
'use client'

import { motion } from 'framer-motion'

function AnimatedComponent() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 100, rotate: 10 }}
      animate={{ opacity: 1, y: 0, rotate: 0 }}
      transition={{ duration: 0.8, type: "spring" }}
    >
      {/* Animates regardless of user preference */}
    </motion.div>
  )
}
```

**Correct (using useReducedMotion hook):**

```typescript
'use client'

import { motion, useReducedMotion, type Variants } from 'framer-motion'

function AnimatedComponent({ children }) {
  const shouldReduceMotion = useReducedMotion()

  const variants: Variants = {
    hidden: {
      opacity: 0,
      y: shouldReduceMotion ? 0 : 20,
      scale: shouldReduceMotion ? 1 : 0.95,
    },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        duration: shouldReduceMotion ? 0.01 : 0.3,
      }
    },
  }

  return (
    <motion.div
      variants={variants}
      initial="hidden"
      animate="visible"
    >
      {children}
    </motion.div>
  )
}
```

**Better: Create accessible variants:**

```typescript
'use client'

import { motion, useReducedMotion, type Variants } from 'framer-motion'

// Factory for accessible variants
function createAccessibleVariants(
  full: Variants,
  reduced: Variants
): () => Variants {
  return function useAccessibleVariants() {
    const shouldReduce = useReducedMotion()
    return shouldReduce ? reduced : full
  }
}

// Define both versions
const fullMotionVariants: Variants = {
  hidden: { opacity: 0, y: 20, scale: 0.95 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: { duration: 0.3, type: "spring" }
  },
}

const reducedMotionVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { duration: 0.01 }
  },
}

const useCardVariants = createAccessibleVariants(
  fullMotionVariants,
  reducedMotionVariants
)

function Card({ children }) {
  const variants = useCardVariants()

  return (
    <motion.div
      variants={variants}
      initial="hidden"
      animate="visible"
    >
      {children}
    </motion.div>
  )
}
```

**CSS fallback for non-Framer animations:**

```css
/* globals.css */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

**Best practices:**

```typescript
// ✅ Fade only (usually safe)
const safeVariants: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
}

// ⚠️ Movement (check reduced motion)
const movementVariants: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
}

// ❌ Avoid for reduced motion users:
// - Parallax scrolling
// - Auto-playing carousels
// - Infinite animations
// - Large scale transforms
// - Rotating animations
// - Bouncing/shaking effects
```

**Testing reduced motion:**

```typescript
// In browser DevTools:
// 1. Open DevTools → Rendering
// 2. Check "Emulate CSS media feature prefers-reduced-motion"

// Or in system preferences:
// macOS: System Preferences → Accessibility → Display → Reduce motion
// Windows: Settings → Ease of Access → Display → Show animations
```

Guidelines:
- Always check `useReducedMotion()` for non-essential animations
- Fade transitions are generally acceptable
- Transform animations (scale, rotate, translate) should be reduced
- Keep essential state changes visible (just faster)
- Test with reduced motion enabled
