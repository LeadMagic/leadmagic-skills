---
name: design-review
description: Review UI code for accessibility (WCAG 2.1) and apply opinionated design constraints. Use when asked to "review my UI", "check accessibility", "audit design", "review for WCAG", or when building UI components. Combines accessibility auditing with design best practices.
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
  sources:
    - https://rams.ai/
    - https://ui-skills.com/
---

# Design Review

Review UI code for accessibility issues and design quality. Combines WCAG 2.1 accessibility auditing with opinionated design constraints.

## How to Use

- **Review a file**: Analyze for accessibility and design issues, output violations with fixes
- **Apply constraints**: Use these rules when building or reviewing UI components

If no file specified, ask which file(s) to review or scan for component files.

---

## Part 1: Accessibility Review (WCAG 2.1)

### Critical (Must Fix)

| Check | WCAG | What to Look For |
|-------|------|------------------|
| Images without alt | 1.1.1 | `<img>` without `alt` attribute |
| Icon-only buttons | 4.1.2 | `<button>` with only SVG/icon, no `aria-label` |
| Form inputs without labels | 1.3.1 | `<input>`, `<select>`, `<textarea>` without `<label>` or `aria-label` |
| Non-semantic click handlers | 2.1.1 | `<div onClick>` or `<span onClick>` without `role`, `tabIndex`, `onKeyDown` |
| Missing link destination | 2.1.1 | `<a>` without `href` using only `onClick` |
| Paste blocked | 2.1.1 | `onPaste` with `preventDefault` on inputs |

### Serious (Should Fix)

| Check | WCAG | What to Look For |
|-------|------|------------------|
| Focus outline removed | 2.4.7 | `outline-none` without visible focus replacement |
| Missing keyboard handlers | 2.1.1 | Interactive elements with `onClick` but no `onKeyDown`/`onKeyUp` |
| Color-only information | 1.4.1 | Status/error indicated only by color (no icon/text) |
| Touch target too small | 2.5.5 | Clickable elements smaller than 44x44px |
| Low contrast | 1.4.3 | Text contrast ratio below 4.5:1 |

### Moderate (Consider Fixing)

| Check | WCAG | What to Look For |
|-------|------|------------------|
| Heading hierarchy | 1.3.1 | Skipped heading levels (h1 → h3) |
| Positive tabIndex | 2.4.3 | `tabIndex` > 0 (disrupts natural tab order) |
| Role without attributes | 4.1.2 | `role="button"` without `tabIndex="0"` |

---

## Part 2: Design Constraints (MUST/NEVER)

### Components

| Rule | Constraint |
|------|------------|
| Accessible primitives | MUST use `Base UI`, `React Aria`, or `Radix` for keyboard/focus behavior |
| Existing components | MUST use project's existing primitives first |
| Mixed systems | NEVER mix primitive systems in same interaction surface |
| Icon buttons | MUST add `aria-label` to icon-only buttons |
| Custom keyboard | NEVER rebuild keyboard/focus behavior by hand |
| Destructive actions | MUST use `AlertDialog` for destructive/irreversible actions |

### Animation

| Rule | Constraint |
|------|------------|
| Add animation | NEVER add unless explicitly requested |
| Compositor props | MUST animate only `transform`, `opacity` |
| Layout props | NEVER animate `width`, `height`, `top`, `left`, `margin`, `padding` |
| Feedback timing | NEVER exceed `200ms` for interaction feedback |
| Off-screen | MUST pause looping animations when off-screen |
| Reduced motion | SHOULD respect `prefers-reduced-motion` |
| Large blur | NEVER animate large `blur()` or `backdrop-filter` surfaces |
| Easing | SHOULD use `ease-out` on entrance; NEVER custom curves unless requested |

### Layout & Spacing

| Rule | Constraint |
|------|------------|
| Viewport height | NEVER use `h-screen`, use `h-dvh` |
| Safe areas | MUST respect `safe-area-inset` for fixed elements |
| Z-index | MUST use fixed scale (no arbitrary `z-*`) |
| Square elements | SHOULD use `size-*` instead of `w-*` + `h-*` |

### Typography

| Rule | Constraint |
|------|------------|
| Headings | MUST use `text-balance` for headings |
| Body text | MUST use `text-pretty` for paragraphs |
| Numbers | MUST use `tabular-nums` for data |
| Dense UI | SHOULD use `truncate` or `line-clamp` |
| Letter spacing | NEVER modify `tracking-*` unless requested |

### Forms & Interaction

| Rule | Constraint |
|------|------------|
| Error placement | MUST show errors next to where action happens |
| Paste | NEVER block paste in `input` or `textarea` |
| Loading states | SHOULD use structural skeletons |

### Design & Color

| Rule | Constraint |
|------|------------|
| Gradients | NEVER use unless explicitly requested |
| Purple gradients | NEVER use purple or multicolor gradients |
| Glow effects | NEVER use as primary affordances |
| Shadows | SHOULD use Tailwind default shadow scale |
| Empty states | MUST give one clear next action |
| Accent colors | SHOULD limit to one per view |
| Color tokens | SHOULD use existing theme tokens first |

### Performance

| Rule | Constraint |
|------|------------|
| will-change | NEVER apply outside active animation |
| useEffect | NEVER use for render logic |
| Class utility | MUST use `cn` utility (`clsx` + `tailwind-merge`) |

---

## Part 3: Visual Design Checklist

### Layout & Spacing
- [ ] Consistent spacing values (using design tokens)
- [ ] No overflow issues or alignment problems
- [ ] No z-index conflicts

### Typography
- [ ] Consistent font families and weights
- [ ] Appropriate line heights
- [ ] Font fallbacks defined

### Color & Contrast
- [ ] Contrast ratio ≥ 4.5:1 for text
- [ ] Hover and focus states present
- [ ] Dark mode works correctly

### Component States
- [ ] Button states: default, hover, active, focus, disabled, loading
- [ ] Form states: default, focus, error, success, disabled
- [ ] Consistent borders, shadows, icon sizing

---

## Output Format

When reviewing files, use this format:

```
═══════════════════════════════════════════════════
DESIGN REVIEW: [filename]
═══════════════════════════════════════════════════

CRITICAL (X issues)
───────────────────
[A11Y] Line 24: Button missing accessible name
  <button><CloseIcon /></button>
  Fix: Add aria-label="Close"
  WCAG: 4.1.2

[CONSTRAINT] Line 45: Animation on layout property
  transition: height 0.3s
  Fix: Use grid-template-rows or transform instead
  Rule: NEVER animate layout properties

SERIOUS (X issues)
──────────────────
...

MODERATE (X issues)
───────────────────
...

═══════════════════════════════════════════════════
SUMMARY: X critical, X serious, X moderate
Score: XX/100
═══════════════════════════════════════════════════
```

---

## Review Guidelines

1. **Read the file(s) first** before making assessments
2. **Be specific** with line numbers and code snippets
3. **Provide fixes**, not just problems
4. **Prioritize** critical accessibility issues first
5. **Offer to fix** issues directly if asked

---

## Quick Reference

### Always Check
- `aria-label` on icon-only buttons
- `alt` on images
- Labels on form inputs
- Visible focus states
- Keyboard accessibility
- Touch targets ≥ 44px

### Always Avoid
- `outline-none` without replacement
- `div onClick` without keyboard support
- Animation on layout properties
- `h-screen` (use `h-dvh`)
- Blocking paste
- Gradients (unless requested)
