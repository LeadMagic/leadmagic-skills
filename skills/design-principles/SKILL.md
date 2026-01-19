---
name: design-principles
description: Foundational design principles and visual design systems reference. Use when creating UI designs, choosing typography/spacing/color values, designing components, or needing UX heuristics. Triggers on "design system", "spacing scale", "typography scale", "color palette", "UX principles".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
  source: https://github.com/0xdesign/design-plugin
---

# Design Principles Reference

Curated best practices from world-class designers and design systems.

## Quick Reference

| Topic | Rule File |
|-------|-----------|
| Typography, spacing, color | `rules/visual-design.md` |
| Buttons, forms, cards, tables | `rules/component-patterns.md` |
| Timing, easing, animations | `rules/motion-animation.md` |
| WCAG, ARIA, keyboard nav | `rules/accessibility.md` |

---

## UX Foundations

### Nielsen's 10 Usability Heuristics

1. **Visibility of system status** - Keep users informed through feedback
2. **Match between system and real world** - Use familiar language
3. **User control and freedom** - Provide undo, cancel, back
4. **Consistency and standards** - Follow platform conventions
5. **Error prevention** - Eliminate error-prone conditions
6. **Recognition over recall** - Make options visible
7. **Flexibility and efficiency** - Provide shortcuts for experts
8. **Aesthetic and minimalist design** - Remove irrelevant info
9. **Help users recover from errors** - Clear error messages
10. **Help and documentation** - Task-focused help when needed

### Don Norman's Principles

- **Affordances** - Design suggests usage
- **Signifiers** - Visual cues for actions
- **Mapping** - Controls relate spatially to effects
- **Feedback** - Every action gets a response
- **Conceptual model** - Users understand how it works

### Cognitive Load

- **Limit choices** - 5-7 items max in navigation
- **Progressive disclosure** - Show only what's needed
- **Chunking** - Group related items
- **Visual hierarchy** - Guide attention with size, color, contrast

---

## Visual Design Quick Reference

See `rules/visual-design.md` for complete scales.

### Typography

```
Display:    32-48px, 700 weight
Heading 1:  24-32px, 600 weight
Body:       14-16px, 400 weight
Caption:    12-13px, 400 weight
```

### Spacing (8px grid)

```
4px  - Tight      16px - Standard
8px  - Base       24px - Relaxed
12px - Comfortable 32px+ - Spacious
```

### Color

```
Text primary:   #171717 / #EDEDED (dark)
Text secondary: #737373 / #A3A3A3 (dark)
Border:         #E5E5E5 / #333333 (dark)
```

- WCAG AA: 4.5:1 text, 3:1 UI components
- One primary accent color

---

## Component Quick Reference

See `rules/component-patterns.md` for detailed patterns.

### Buttons

| Type | Use |
|------|-----|
| Primary | One per view, main action |
| Secondary | Supporting actions |
| Tertiary | Low-emphasis |
| Destructive | Delete with confirmation |

### Forms

- Labels above inputs
- Validate on blur
- Specific error messages
- Single column preferred

### Cards

- Entire card clickable
- 16-24px padding
- Max 2 visible actions

---

## Interaction Patterns

### Feedback Timing

| Duration | Feedback |
|----------|----------|
| 0-100ms | None needed |
| 100-300ms | Subtle change |
| 300ms-1s | Spinner |
| 1s+ | Skeleton + progress |

### Component States

```
Default → Hover → Focus → Active → Loading → Disabled → Error → Success
```

### Progressive Disclosure

- Show essential options first
- "Advanced" for power features
- Inline expansion over navigation
- Tooltips for supplementary info

---

## Motion Quick Reference

See `rules/motion-animation.md` for easing curves.

```
Micro:  100-150ms (buttons, toggles)
Small:  150-200ms (dropdowns)
Medium: 200-300ms (modals)
Large:  300-500ms (page transitions)
```

Always respect `prefers-reduced-motion`.

---

## Accessibility Quick Reference

See `rules/accessibility.md` for ARIA patterns.

### WCAG Essentials

- **Contrast**: 4.5:1 text, 3:1 components
- **Touch targets**: 44x44px minimum
- **Keyboard**: All functionality accessible
- **Focus**: Visible focus indicators

---

## Design System References

**For Clarity:**
- Linear, Stripe, Vercel

**For Warmth:**
- Airbnb, Notion, Slack

**For Data:**
- Figma, GitHub

**For Motion:**
- Apple, Framer

---

## Decision Framework

When unsure, ask:

1. **Is it clear?** → User knows what to do
2. **Is it fast?** → Minimum steps
3. **Is it consistent?** → Matches existing patterns
4. **Is it accessible?** → Keyboard, screen reader, contrast
5. **Is it calm?** → No unnecessary elements
