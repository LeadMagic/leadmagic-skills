---
title: Motion & Animation
impact: MEDIUM
impactDescription: Timing, easing, and animation patterns
tags: motion, animation, transitions, easing, reduced-motion
---

## Motion & Animation

### Timing Guidelines

```
Micro-interactions:     100-150ms (buttons, toggles, hover)
Small transitions:      150-200ms (dropdowns, tooltips)
Medium transitions:     200-300ms (modals, panels)
Large transitions:      300-500ms (page transitions, complex reveals)
Staggered lists:        50-100ms between items
```

---

### Easing Functions

```css
/* Standard easings */
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);      /* Entrances */
--ease-in: cubic-bezier(0.7, 0, 0.84, 0);       /* Exits */
--ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);  /* Move/resize */

/* Expressive easings */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);  /* Playful bounce */
--ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);       /* Material standard */
```

---

### Animation Patterns

**Entrances:**

- Fade in + slide up (8-16px)
- Scale from 0.95 to 1 + fade
- Stagger children by 50ms

**Exits:**

- Fade out (faster than entrance)
- Scale to 0.95 + fade
- Slide in direction of dismissal

**Hover/Focus:**

- TranslateY -2px (lift)
- Scale 1.02-1.05 (grow)
- Shadow increase
- Background color shift

**Loading:**

- Skeleton shimmer (gradient animation)
- Pulse (opacity 0.5-1)
- Spinner (rotate continuously)

---

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

Always respect user preferences. Replace motion with:

- Instant state changes
- Opacity transitions only
- No parallax or auto-playing video
