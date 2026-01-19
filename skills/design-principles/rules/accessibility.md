---
title: Accessibility Essentials
impact: CRITICAL
impactDescription: WCAG compliance and inclusive design
tags: accessibility, wcag, aria, focus, screen-reader
---

## Accessibility Essentials

### WCAG Quick Reference

**Perceivable:**

- Color contrast: 4.5:1 text, 3:1 UI components
- Don't rely on color alone (add icons, patterns)
- Text resizable to 200% without loss
- Captions for video; transcripts for audio

**Operable:**

- All functionality via keyboard
- No keyboard traps
- Skip links for repeated content
- Touch targets: 44x44px minimum

**Understandable:**

- Consistent navigation
- Identify input errors clearly
- Labels and instructions for forms

**Robust:**

- Semantic HTML elements
- ARIA only when HTML isn't enough
- Tested with screen readers

---

### Focus Management

```css
/* Visible focus for keyboard users */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Remove default only if custom focus exists */
:focus:not(:focus-visible) {
  outline: none;
}
```

---

### ARIA Patterns

```html
<!-- Button (when not using <button>) -->
<div role="button" tabindex="0" aria-pressed="false">

<!-- Modal -->
<div role="dialog" aria-modal="true" aria-labelledby="title">

<!-- Tab panel -->
<div role="tablist">
  <button role="tab" aria-selected="true" aria-controls="panel1">
</div>
<div role="tabpanel" id="panel1">

<!-- Live region (for dynamic updates) -->
<div aria-live="polite" aria-atomic="true">

<!-- Loading state -->
<button aria-busy="true" aria-describedby="loading-text">
```

---

### Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | Move to next focusable element |
| Shift+Tab | Move to previous focusable element |
| Enter/Space | Activate button/link |
| Escape | Close modal/dropdown |
| Arrow keys | Navigate within components |

### Testing Checklist

- [ ] Navigate entire page with keyboard only
- [ ] Test with screen reader (VoiceOver, NVDA)
- [ ] Check color contrast with tools
- [ ] Verify focus indicators are visible
- [ ] Test at 200% zoom
- [ ] Verify form errors are announced
