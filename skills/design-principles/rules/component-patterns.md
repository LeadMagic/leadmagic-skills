---
title: Component Patterns
impact: HIGH
impactDescription: Standard patterns for buttons, forms, cards, tables
tags: components, buttons, forms, cards, tables, navigation
---

## Component Patterns

### Buttons

**Hierarchy:**

1. **Primary** - One per view, main action, filled with brand color
2. **Secondary** - Supporting actions, outlined or ghost style
3. **Tertiary** - Low-emphasis actions, text-only with hover state
4. **Destructive** - Delete/remove actions, red with confirmation

**States:**

- Default → Hover (+shadow or darken) → Active (scale 0.98) → Disabled (50% opacity)
- Loading: replace text with spinner, maintain width
- Min width: 80px; min height: 36px (touch-friendly: 44px)

**Best practices:**

- Verb + noun labels: "Create project" not "Create"
- Sentence case, not ALL CAPS
- Icon left of text (or icon-only with tooltip)
- Primary button right-aligned in forms/dialogs

---

### Forms

**Input anatomy:**

```
┌─────────────────────────────────┐
│ Label                           │
│ ┌─────────────────────────────┐ │
│ │ Placeholder / Value         │ │
│ └─────────────────────────────┘ │
│ Helper text or error message    │
└─────────────────────────────────┘
```

**Best practices:**

- Labels above inputs (not inside—accessibility)
- Placeholder ≠ label; use for format hints only
- Inline validation on blur, not on every keystroke
- Error messages: specific and actionable ("Email must include @")
- Success state: checkmark icon, green border (brief)
- Required fields: mark optional ones instead of required
- Single column forms outperform multi-column

---

### Cards

**Anatomy:**

```
┌────────────────────────────────┐
│ [Media/Image]                  │  ← Optional
├────────────────────────────────┤
│ Eyebrow · Metadata             │  ← Optional
│ Title                          │  ← Required
│ Description text that can      │  ← Optional
│ wrap to multiple lines...      │
├────────────────────────────────┤
│ [Actions]              [More]  │  ← Optional
└────────────────────────────────┘
```

**Best practices:**

- Entire card clickable for primary action
- Consistent padding (16-24px)
- Image aspect ratios: 16:9, 4:3, 1:1 (be consistent)
- Limit to 2 actions max; overflow to menu
- Hover: subtle lift (translateY -2px + shadow increase)

---

### Tables

**Best practices:**

- Left-align text, right-align numbers
- Zebra striping OR row hover, not both
- Sticky header on scroll
- Sortable columns: show current sort indicator
- Actions: row hover reveals action buttons (or kebab menu)
- Empty state: helpful message + action
- Pagination vs infinite scroll: pagination for data accuracy, infinite for browsing
- Min row height: 48px for touch; 40px for dense

---

### Navigation

**Patterns by scale:**

- **2-5 items**: Tab bar / horizontal tabs
- **5-10 items**: Side navigation (collapsible)
- **10+ items**: Side nav with sections/groups

**Best practices:**

- Current location always visible
- Breadcrumbs for deep hierarchy (not for flat structures)
- Mobile: bottom nav for primary actions (thumb-friendly)
- Icons + labels together; icon-only needs tooltip
- Consistent order across pages
