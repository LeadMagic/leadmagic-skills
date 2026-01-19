---
title: Visual Design Systems
impact: HIGH
impactDescription: Typography, spacing, color, and elevation scales
tags: typography, spacing, color, shadows, design-tokens
---

## Visual Design Systems

### Typography Scale

```
Display:    32-48px, -0.02em tracking, 700 weight
Heading 1:  24-32px, -0.02em tracking, 600 weight
Heading 2:  20-24px, -0.01em tracking, 600 weight
Heading 3:  16-18px, normal tracking, 600 weight
Body:       14-16px, normal tracking, 400 weight
Caption:    12-13px, +0.01em tracking, 400-500 weight
```

**Best practices:**

- Max 60-75 characters per line for readability
- Line height: 1.4-1.6 for body text, 1.2-1.3 for headings
- Use weight contrast (400 vs 600) more than size contrast
- Limit to 2 font families maximum
- System fonts: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`

---

### Spacing System (8px grid)

```
4px   - Tight: icon padding, inline spacing
8px   - Base: related elements, form field padding
12px  - Comfortable: between form fields
16px  - Standard: section padding, card padding
24px  - Relaxed: between sections
32px  - Spacious: major section breaks
48px  - Generous: page section separation
64px+ - Hero: landing page sections
```

**Spacing principles:**

- Related items closer together (Gestalt proximity)
- Consistent internal padding (all sides equal, or vertical > horizontal)
- White space is not wasted space—it creates focus
- Touch targets minimum 44x44px (Apple HIG)

---

### Color System

**Neutral foundation:**

```
Background:     #FFFFFF / #000000 (dark)
Surface:        #FAFAFA / #111111 (dark)
Border:         #E5E5E5 / #333333 (dark)
Text primary:   #171717 / #EDEDED (dark)
Text secondary: #737373 / #A3A3A3 (dark)
Text tertiary:  #A3A3A3 / #737373 (dark)
```

**Accent usage:**

- Primary action: single brand color, used sparingly
- Interactive elements: consistent color for all clickable items
- Semantic colors: red (error), green (success), yellow (warning), blue (info)
- Hover states: 10% darker or add subtle background
- Focus states: 2px ring with offset, high contrast

**Color principles:**

- WCAG AA minimum: 4.5:1 text, 3:1 UI components
- One primary accent color; avoid rainbow interfaces
- Use opacity for secondary states (hover, disabled)
- Dark mode: don't just invert—reduce contrast, use darker surfaces

---

### Border Radius Scale

```
None (0px):     Tables, dividers, full-bleed images
Small (4px):    Buttons, inputs, tags, badges
Medium (8px):   Cards, modals, dropdowns
Large (12px):   Feature cards, hero elements
Full (9999px):  Avatars, pills, toggle tracks
```

**Principles:**

- Consistency: pick 2-3 radius values and stick to them
- Nested elements: inner radius = outer radius - padding
- Sharp corners feel technical/precise; round feels friendly/approachable

---

### Shadow & Elevation Scale

```
Level 0: none (flat, on surface)
Level 1: 0 1px 2px rgba(0,0,0,0.05)      - Subtle lift (cards)
Level 2: 0 4px 6px rgba(0,0,0,0.07)      - Raised (dropdowns)
Level 3: 0 10px 15px rgba(0,0,0,0.1)     - Floating (modals)
Level 4: 0 20px 25px rgba(0,0,0,0.15)    - High (popovers)
```

**Principles:**

- Shadows should feel like natural light (top-down, slight offset)
- Dark mode: use lighter surface colors instead of shadows
- Combine with subtle border for definition
- Interactive elements can elevate on hover
