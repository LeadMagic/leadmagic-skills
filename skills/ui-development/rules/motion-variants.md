---
title: Use Framer Motion Variants
impact: HIGH
impactDescription: Reusable, orchestrated animations
tags: framer-motion, animation, variants
---

## Use Framer Motion Variants

Variants provide a clean way to define animation states and orchestrate complex animations. Use them instead of inline animation objects.

**Incorrect (inline animation objects):**

```typescript
'use client'

import { motion } from 'framer-motion'

function Card() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: -20, scale: 0.95 }}
      transition={{ duration: 0.3 }}
    >
      {/* Repeated for every card, can't orchestrate children */}
    </motion.div>
  )
}

function List({ items }) {
  return (
    <div>
      {items.map((item, i) => (
        // No coordination between items
        <motion.div
          key={item.id}
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: i * 0.1 }} // Manual delay calculation
        >
          {item.name}
        </motion.div>
      ))}
    </div>
  )
}
```

**Correct (using variants):**

```typescript
'use client'

import { motion, type Variants } from 'framer-motion'

// Define reusable variants
const cardVariants: Variants = {
  hidden: {
    opacity: 0,
    y: 20,
    scale: 0.95
  },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      duration: 0.3,
      ease: "easeOut"
    }
  },
  exit: {
    opacity: 0,
    y: -20,
    scale: 0.95,
    transition: {
      duration: 0.2
    }
  },
}

function Card({ children }) {
  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate="visible"
      exit="exit"
    >
      {children}
    </motion.div>
  )
}

// Orchestrated list with stagger
const containerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1, // Automatic stagger!
      delayChildren: 0.2,
    },
  },
}

const itemVariants: Variants = {
  hidden: { opacity: 0, x: -20 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      type: "spring",
      stiffness: 300,
      damping: 24,
    }
  },
}

function List({ items }) {
  return (
    <motion.ul
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {items.map((item) => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.name}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

**Dynamic variants:**

```typescript
const slideVariants: Variants = {
  enter: (direction: number) => ({
    x: direction > 0 ? 300 : -300,
    opacity: 0,
  }),
  center: {
    x: 0,
    opacity: 1,
  },
  exit: (direction: number) => ({
    x: direction < 0 ? 300 : -300,
    opacity: 0,
  }),
}

function Carousel({ page, direction }) {
  return (
    <motion.div
      key={page}
      custom={direction}
      variants={slideVariants}
      initial="enter"
      animate="center"
      exit="exit"
      transition={{ duration: 0.3 }}
    >
      {/* content */}
    </motion.div>
  )
}
```

**Hover and tap variants:**

```typescript
const buttonVariants: Variants = {
  idle: { scale: 1 },
  hover: {
    scale: 1.05,
    transition: { type: "spring", stiffness: 400 }
  },
  tap: { scale: 0.95 },
}

function AnimatedButton({ children }) {
  return (
    <motion.button
      variants={buttonVariants}
      initial="idle"
      whileHover="hover"
      whileTap="tap"
    >
      {children}
    </motion.button>
  )
}
```

Benefits:
- Reusable across components
- Automatic orchestration with staggerChildren
- Cleaner component code
- Easy to test and modify
- Dynamic variants with custom prop
