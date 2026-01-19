---
name: design-lab
description: Conduct design interviews, generate five distinct UI variations in a temporary design lab, collect feedback, and produce implementation plans. Use when the user wants to explore UI design options, redesign existing components, or create new UI with multiple approaches to compare.
license: LeadMagic Proprietary
metadata:
  author: 0xdesign
  version: "1.0.0"
  source: https://github.com/0xdesign/design-plugin
---

# Design Lab Skill

This skill implements a complete design exploration workflow: interview, generate variations, collect feedback, refine, preview, and finalize.

## CRITICAL: Cleanup Behavior

**All temporary files MUST be deleted when the process ends, whether by:**
- User confirms final design → cleanup, then generate plan
- User aborts/cancels → cleanup immediately, no plan generated

**Never leave `.claude-design/` or `__design_lab` routes behind.** If the user says "cancel", "abort", "stop", or "nevermind" at any point, confirm and then delete all temporary artifacts.

---

## Phase 0: Preflight Detection

Before starting the interview, automatically detect:

### Package Manager
Check for lock files in the project root:
- `pnpm-lock.yaml` → use `pnpm`
- `yarn.lock` → use `yarn`
- `package-lock.json` → use `npm`
- `bun.lockb` → use `bun`

### Framework Detection
Check for config files:
- `next.config.js` or `next.config.mjs` or `next.config.ts` → **Next.js**
  - Check for `app/` directory → App Router
  - Check for `pages/` directory → Pages Router
- `vite.config.js` or `vite.config.ts` → **Vite**
- `remix.config.js` → **Remix**
- `nuxt.config.js` or `nuxt.config.ts` → **Nuxt**
- `astro.config.mjs` → **Astro**

### Styling System Detection
Check `package.json` dependencies and config files:
- `tailwind.config.js` or `tailwind.config.ts` → **Tailwind CSS**
- `@mui/material` in dependencies → **Material UI**
- `@chakra-ui/react` in dependencies → **Chakra UI**
- `antd` in dependencies → **Ant Design**
- `styled-components` in dependencies → **styled-components**
- `@emotion/react` in dependencies → **Emotion**
- `.css` or `.module.css` files → **CSS Modules**

### Design Memory Check
Look for existing Design Memory file:
- `docs/design-memory.md`
- `DESIGN_MEMORY.md`
- `.claude-design/design-memory.md`

If found, read it and use to prefill defaults and skip redundant questions.

### Visual Style Inference (CRITICAL)

**DO NOT use generic/predefined styles. Extract visual language from the project:**

**If Tailwind detected**, read `tailwind.config.js` or `tailwind.config.ts`:
```javascript
// Extract and use:
theme.colors      // Color palette
theme.spacing     // Spacing scale
theme.borderRadius // Radius values
theme.fontFamily  // Typography
theme.boxShadow   // Elevation system
```

**If CSS Variables exist**, read `globals.css`, `variables.css`, or `:root` definitions:
```css
:root {
  --color-*     /* Color tokens */
  --spacing-*   /* Spacing tokens */
  --font-*      /* Typography tokens */
  --radius-*    /* Border radius tokens */
}
```

**If UI library detected** (MUI, Chakra, Ant), read the theme configuration:
- MUI: `theme.ts` or `createTheme()` call
- Chakra: `theme/index.ts` or `extendTheme()` call
- Ant: `ConfigProvider` theme prop

**Always scan existing components** to understand patterns:
- Find 2-3 existing buttons → note their styling patterns
- Find 2-3 existing cards → note padding, borders, shadows
- Find existing forms → note input styles, label placement
- Find existing typography → note heading sizes, body text

**Store inferred styles in the Design Brief** for consistent use across all variants.

---

## Phase 1: Interview

Adapt questions based on Design Memory if it exists.

### Step 1.1: Scope & Target

**Question 1: Scope**
- "Are we designing a single component or a full page?"
- Options: Component, Page

**Question 2: New or Redesign**
- "Is this a new design or a redesign of something existing?"
- Options: New, Redesign

If "Redesign", ask for the file path or route of the existing UI.

### Step 1.2: Pain Points & Inspiration

**Question 1: Pain Points** (multiSelect)
- "What are the top pain points?"
- Options: Too cluttered/dense, Unclear hierarchy, Poor mobile experience, Outdated look

**Question 2: Visual Inspiration** (multiSelect)
- "What products should I reference for visual inspiration?"
- Options: Stripe (clean, minimal), Linear (dense, developer-focused), Notion (flexible, playful), Apple (premium, spacious)

**Question 3: Functional Inspiration**
- "What interaction patterns should I emulate?"
- Options: Inline editing, Progressive disclosure, Optimistic updates, Keyboard shortcuts

### Step 1.3: Brand & Style Direction

**Question 1: Brand Adjectives** (multiSelect)
- "What adjectives describe the desired brand feel?"
- Options: Minimal, Premium, Playful, Utilitarian

**Question 2: Density**
- "What information density do you prefer?"
- Options: Compact, Comfortable, Spacious

**Question 3: Dark Mode**
- "Is dark mode required?"
- Options: Yes, No, Nice to have

### Step 1.4: Persona & Jobs-to-be-Done

**Question 1: Primary User**
- Options: Developer, Designer, Business user, End consumer

**Question 2: Context**
- Options: Desktop-first, Mobile-first, Both equally

**Question 3: Key Tasks**
- "What are the top 3 tasks users must complete?"

### Step 1.5: Constraints

**Question 1: Must-Keep Elements**
- Options: Existing copy/labels, Current fields/inputs, Navigation structure, None

**Question 2: Technical Constraints** (multiSelect)
- Options: No new dependencies, Use existing components, Must be accessible (WCAG), None

---

## Phase 2: Generate Design Brief

Save to `.claude-design/design-brief.json`:

```json
{
  "scope": "component|page",
  "isRedesign": true|false,
  "targetPath": "src/components/Example.tsx",
  "targetName": "Example",
  "painPoints": ["Too dense", "Primary action unclear"],
  "inspiration": {
    "visual": ["Stripe", "Linear"],
    "functional": ["Inline validation"]
  },
  "brand": {
    "adjectives": ["minimal", "trustworthy"],
    "density": "comfortable",
    "darkMode": true
  },
  "persona": {
    "primary": "Developer",
    "context": "desktop-first",
    "keyTasks": ["Complete checkout", "Review order", "Apply discount"]
  },
  "constraints": {
    "mustKeep": ["existing fields"],
    "technical": ["no new dependencies", "WCAG accessible"]
  },
  "framework": "nextjs-app",
  "packageManager": "pnpm",
  "stylingSystem": "tailwind"
}
```

---

## Phase 3: Generate Design Lab

### Directory Structure

```
.claude-design/
├── lab/
│   ├── page.tsx                 # Main lab page
│   ├── variants/
│   │   ├── VariantA.tsx
│   │   ├── VariantB.tsx
│   │   ├── VariantC.tsx
│   │   ├── VariantD.tsx
│   │   └── VariantE.tsx
│   ├── components/
│   │   └── LabShell.tsx
│   └── data/
│       └── fixtures.ts          # Shared mock data
├── design-brief.json
└── run-log.md
```

### Route Integration

- **Next.js App Router:** Create `app/__design_lab/page.tsx`
- **Next.js Pages Router:** Create `pages/__design_lab.tsx`
- **Vite:** Add route or use `?design_lab=true` query param

### Variant Generation Guidelines

Each variant MUST explore a different design axis—make them meaningfully distinct:

**Variant A: Information Hierarchy Focus**
- Restructure content hierarchy
- Apply Gestalt proximity
- One primary action per view

**Variant B: Layout Model Exploration**
- Different layout approach (card vs list vs table vs split-pane)
- Consider responsive behavior

**Variant C: Density Variation**
- If brief says "comfortable", try compact
- If brief says "compact", try spacious
- Show tradeoffs

**Variant D: Interaction Model**
- Different interaction pattern (modal vs inline vs panel vs drawer)
- Implement all required states (loading, error, empty, disabled)

**Variant E: Expressive Direction**
- Push the brand direction from interview
- Explore different uses of design tokens
- Apply motion where it adds meaning

### Lab Page Requirements

1. **Header** with Design Brief summary
2. **Variant Grid** with labels (A-E), rationale, rendered variant
3. **Responsive behavior**: Desktop grid, mobile scroll/tabs
4. **Shared Data**: All variants use same fixtures

### Code Quality

- Follow project's existing conventions
- Use detected styling system
- Semantic HTML, keyboard navigation
- All states: Default, Hover, Focus, Active, Disabled, Loading, Error, Empty
- Motion: 150-200ms micro-interactions, ease-out entrances
- Respect `prefers-reduced-motion`

---

## Phase 4: Present Design Lab

**Do NOT start the dev server yourself** (it runs forever).

Output:
```
✅ Design Lab created!

I've generated 5 design variants in `.claude-design/lab/`

To view them:
1. Make sure your dev server is running
2. Open: http://localhost:3000/__design_lab

Take your time reviewing, then tell me:
- Which variant wins (A-E)
- What you like about it
- What should change
```

---

## Phase 5: Collect Feedback

### Stage 1: Check for a Winner

- "Is there one variant you like as is?"
- Options: Yes - I found one I like, No - I like parts of different ones

### Stage 2A: If Winner Found

- "Which variant?" (A-E)
- "Any tweaks needed?" (Good as is / Minor tweaks needed)

→ Proceed to Phase 7

### Stage 2B: If Synthesizing

- "What do you like about each variant?"

Example format:
```
- A: Love the card layout
- B: The color scheme feels right
- C: The hover interaction is great
- E: Typography hierarchy is clearest
```

→ Proceed to Phase 6

---

## Phase 6: Synthesize New Variant

1. Create **Variant F** combining user's favorite elements
2. Update Design Lab to show Variant F prominently
3. Ask for feedback again until satisfied

---

## Phase 7: Final Preview

1. Create `.claude-design/preview/` with final design
2. Create route at `/__design_preview`
3. For redesigns, show before/after comparison
4. Ask for confirmation:
   - "Yes, finalize it" → Phase 8
   - "No, needs changes" → iterate
   - "Abort" → cleanup, no plan

---

## Abort Handling

On "cancel", "abort", "stop", "nevermind":

1. Confirm: "Are you sure? This will delete all design lab files."
2. If confirmed:
   - Delete `.claude-design/` entirely
   - Delete temporary routes
   - Do NOT generate plan
3. Acknowledge: "Design exploration cancelled. All temporary files cleaned up."

---

## Phase 8: Finalize

### 8.1: Cleanup

Delete:
- `.claude-design/` directory
- `app/__design_lab/`, `pages/__design_lab.tsx`
- `app/__design_preview/`, `pages/__design_preview.tsx`

**Safety:** Only delete files the skill created. Never delete user files.

### 8.2: Generate Implementation Plan

Create `DESIGN_PLAN.md`:

```markdown
# Design Implementation Plan: [TargetName]

## Summary
- **Scope:** [component/page]
- **Target:** [file path]
- **Winner variant:** [A-E]
- **Key improvements:** [from feedback]

## Files to Change
- [ ] `src/components/Example.tsx` - Main refactor
- [ ] `src/styles/example.css` - Style updates

## Implementation Steps
1. [Specific step]
2. [Next step]

## Required UI States
- Loading, Empty, Error, Disabled, Validation

## Accessibility Checklist
- [ ] Keyboard navigation
- [ ] Focus states visible
- [ ] Labels and aria-* correct
- [ ] Color contrast WCAG AA
- [ ] Screen reader tested
```

### 8.3: Update Design Memory

Create/update `DESIGN_MEMORY.md` with:
- Brand tone & adjectives
- Layout & spacing preferences
- Typography patterns
- Color tokens
- Interaction patterns
- Accessibility rules
- Repo conventions

---

## Example Session Flow

1. User: "Design a new CheckoutSummary component"
2. Detect: Next.js App Router, Tailwind, pnpm
3. Interview: 5 question groups
4. Generate: Design Brief summary
5. Create: `.claude-design/lab/` with 5 variants
6. Present: "Open http://localhost:3000/__design_lab"
7. User reviews variants
8. Ask: "Which variant wins?"
9. User: "Variant C, but change X and Y"
10. Refine: Update Variant C
11. Preview: `/__design_preview`
12. User: "Confirmed"
13. Cleanup: Delete all temp files
14. Output: `DESIGN_PLAN.md` + `DESIGN_MEMORY.md`
15. Done: "See DESIGN_PLAN.md for implementation steps"
