---
name: design-antipatterns
description: Avoid generic AI-generated aesthetics and create distinctive designs. Use when reviewing UI for "AI slop" tells, making designs more memorable, or avoiding common AI design pitfalls. Triggers on "looks generic", "AI-generated", "too safe", "boring design", "make it distinctive".
license: Apache-2.0
metadata:
  author: leadmagic
  version: "1.0.0"
  source: https://impeccable.style
---

# Design Anti-Patterns

Avoid generic "AI slop" aesthetics. Create distinctive, memorable interfaces that don't look like every other AI-generated design.

## The AI Slop Test

**Critical quality check**: If you showed this interface to someone and said "AI made this," would they believe you immediately? If yes, that's the problem.

A distinctive interface should make someone ask "how was this made?" not "which AI made this?"

---

## Anti-Patterns: What NOT to Do

### The AI Color Palette (AVOID)

```
❌ Cyan on dark backgrounds
❌ Purple-to-blue gradients
❌ Neon accents on dark backgrounds
❌ Gradient text for "impact" (especially on metrics)
❌ Pure black (#000) or pure white (#fff)
❌ Gray text on colored backgrounds
```

**Instead:**
- Tint neutrals toward your brand hue
- Use a shade of the background color for text on colored surfaces
- Commit to ONE bold accent color
- Always tint black/white slightly—pure values never appear in nature

### The AI Layout Template (AVOID)

```
❌ Hero metric layout: big number + small label + supporting stats + gradient accent
❌ Identical card grids: same-sized cards with icon + heading + text, repeated
❌ Cards nested inside cards
❌ Everything wrapped in cards (not everything needs a container)
❌ Everything centered
❌ Same spacing everywhere (no rhythm)
```

**Instead:**
- Create visual rhythm through varied spacing
- Use asymmetry and unexpected compositions
- Break the grid intentionally for emphasis
- Flatten hierarchy—remove unnecessary containers
- Left-align with asymmetric layouts feels more designed

### The AI Typography (AVOID)

```
❌ Overused fonts: Inter, Roboto, Arial, Open Sans, system defaults
❌ Monospace as lazy shorthand for "technical/developer" vibes
❌ Large icons with rounded corners above every heading
❌ Generic placeholder copy
```

**Instead:**
- Choose distinctive fonts that match your brand
- Pair a display font with a refined body font
- Use weight contrast (400 vs 700) more than size contrast
- Make every word earn its place

### The AI Effects (AVOID)

```
❌ Glassmorphism everywhere (blur effects, glass cards, glow borders)
❌ Rounded rectangles with generic drop shadows
❌ Rounded elements with thick colored border on one side
❌ Sparklines as decoration (charts that look sophisticated but convey nothing)
❌ Bounce or elastic easing (feels dated and tacky)
❌ Modals for everything
```

**Instead:**
- Use effects purposefully, not decoratively
- Real objects decelerate smoothly—use ease-out-quart/quint/expo
- Use modals only when there's truly no better alternative
- Let decorative elements reinforce brand, not fill space

### The AI Dark Mode (AVOID)

```
❌ Default to dark mode with glowing accents
❌ Just invert colors
❌ Low contrast "moody" aesthetic
```

**Instead:**
- Dark mode: reduce contrast, use darker surfaces (not inverted)
- Make deliberate light/dark theme decisions
- Ensure contrast meets WCAG standards in both modes

---

## Bold Creative Direction

### Commit to a Direction

Don't be safe. Pick an extreme:
- Brutally minimal
- Maximalist chaos
- Retro-futuristic
- Organic/natural
- Luxury/refined
- Playful/toy-like
- Editorial/magazine
- Brutalist/raw
- Art deco/geometric
- Soft/pastel
- Industrial/utilitarian

**The key is intentionality, not intensity.** Bold maximalism and refined minimalism both work.

### What Makes It Memorable?

Ask yourself:
- What's the ONE thing someone will remember?
- What makes this UNFORGETTABLE?
- Is there a hero moment?
- Does it have a clear aesthetic point-of-view?

### Typography That Stands Out

```css
/* Create dramatic scale jumps */
--text-hero: clamp(3rem, 8vw, 6rem);    /* 3-5x larger than body */
--text-display: clamp(2rem, 5vw, 3rem);
--text-body: 1rem;

/* Use weight contrast */
font-weight: 900;  /* Headlines */
font-weight: 200;  /* Contrast with thin weights */

/* Negative tracking for large text */
letter-spacing: -0.02em;
```

### Spatial Drama

- **Extreme scale jumps**: Make important elements 3-5x larger
- **Break the grid**: Let hero elements escape containers
- **Generous space**: 100-200px gaps, not 20-40px
- **Asymmetric layouts**: Create tension, not balance
- **Overlap**: Layer elements intentionally for depth

### Color That Commands

- **Dominant color**: Let ONE bold color own 60% of the design
- **Sharp accents**: High-contrast colors that pop
- **Tinted neutrals**: Never pure gray—add subtle color tint
- **Rich gradients**: Multi-stop, intentional (not purple-to-blue)

---

## Verification Questions

Before shipping, ask:

1. **Is it generic?** Does this look like every other AI output? If yes, start over.
2. **Is it memorable?** Will users remember this experience?
3. **Is there a hero moment?** What's the ONE thing that stands out?
4. **Is it intentional?** Can you explain every design decision?
5. **Is it coherent?** Does everything feel unified with a clear POV?

---

## Quick Reference: DO vs DON'T

| DON'T | DO |
|-------|-----|
| Purple-to-blue gradients | Single bold accent color |
| Cyan on dark | Intentional color palette |
| Cards on cards | Flat hierarchy, use spacing |
| Same spacing everywhere | Varied spacing rhythm |
| Everything centered | Asymmetric, left-aligned |
| Gray on colored bg | Tinted shade of bg color |
| Pure black/white | Always tint slightly |
| Glassmorphism | Purposeful effects |
| Bounce easing | Smooth deceleration (ease-out-expo) |
| Inter/Roboto/Arial | Distinctive font choices |
| Icon + heading + text grid | Varied card layouts |
| Gradient text on metrics | Clean typography |
| Modals for everything | Inline interactions |
| Generic dark mode | Deliberate theme design |

---

## Motion Anti-Patterns

### AVOID
```css
/* Bounce/elastic - feels dated */
transition: transform 0.3s cubic-bezier(0.68, -0.55, 0.27, 1.55);

/* Linear - feels robotic */
transition: opacity 0.3s linear;

/* Animating layout properties */
transition: width 0.3s, height 0.3s, padding 0.3s;
```

### USE
```css
/* Natural deceleration */
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);

/* Only transform and opacity */
transition: transform 0.2s var(--ease-out-expo),
            opacity 0.2s var(--ease-out-expo);

/* Height via grid (not height property) */
grid-template-rows: 0fr;
transition: grid-template-rows 0.3s var(--ease-out-expo);
```

---

## Implementation Principle

Match implementation complexity to aesthetic vision:
- **Maximalist designs** → elaborate code, extensive animations, rich effects
- **Minimalist designs** → restraint, precision, careful spacing and typography

**NEVER converge on common choices.** Vary between:
- Light and dark themes
- Different fonts
- Different aesthetics
- Different layouts

No two designs should look the same.
