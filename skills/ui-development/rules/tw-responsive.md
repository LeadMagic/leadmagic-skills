---
title: Mobile-First Responsive Design
impact: HIGH
impactDescription: Consistent layouts across all devices
tags: tailwind, responsive, mobile-first, breakpoints
---

## Mobile-First Responsive Design

Tailwind uses mobile-first breakpoints. Start with mobile styles, then add larger screen overrides.

**Tailwind Breakpoints:**

```css
/* Default (no prefix) = mobile: 0px+ */
/* sm: 640px+  - Small tablets */
/* md: 768px+  - Tablets */
/* lg: 1024px+ - Laptops */
/* xl: 1280px+ - Desktops */
/* 2xl: 1536px+ - Large desktops */
```

**Incorrect (desktop-first):**

```typescript
// Starting with desktop styles and overriding for mobile
function Card() {
  return (
    <div className="
      flex-row gap-8 p-8        // Desktop styles first
      max-md:flex-col           // Override for mobile
      max-md:gap-4
      max-md:p-4
    ">
      {/* content */}
    </div>
  )
}
```

**Correct (mobile-first):**

```typescript
// Start with mobile, add breakpoint prefixes for larger screens
function Card() {
  return (
    <div className="
      flex flex-col gap-4 p-4    // Mobile styles (default)
      md:flex-row md:gap-8 md:p-8 // Tablet and up
    ">
      {/* content */}
    </div>
  )
}
```

**Responsive Layout Pattern:**

```typescript
function PageLayout({ children }) {
  return (
    <div className="
      flex flex-col             // Mobile: stack vertically
      lg:flex-row               // Desktop: side by side
    ">
      {/* Sidebar */}
      <aside className="
        w-full                   // Mobile: full width
        lg:w-64                  // Desktop: fixed width
        lg:shrink-0              // Desktop: don't shrink
        border-b                 // Mobile: bottom border
        lg:border-b-0 lg:border-r // Desktop: right border
      ">
        <nav className="p-4">
          {/* Navigation */}
        </nav>
      </aside>

      {/* Main content */}
      <main className="
        flex-1
        p-4                      // Mobile: small padding
        md:p-6                   // Tablet: medium padding
        lg:p-8                   // Desktop: large padding
      ">
        {children}
      </main>
    </div>
  )
}
```

**Responsive Grid:**

```typescript
function ProductGrid({ products }) {
  return (
    <div className="
      grid gap-4
      grid-cols-1              // Mobile: 1 column
      sm:grid-cols-2           // Small: 2 columns
      lg:grid-cols-3           // Large: 3 columns
      xl:grid-cols-4           // Extra large: 4 columns
    ">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}
```

**Responsive Typography:**

```typescript
function Hero() {
  return (
    <div className="text-center">
      <h1 className="
        text-2xl font-bold        // Mobile: small
        sm:text-3xl               // Small: medium
        md:text-4xl               // Tablet: large
        lg:text-5xl               // Desktop: extra large
      ">
        Welcome to Our Platform
      </h1>
      <p className="
        mt-4 text-base            // Mobile
        md:text-lg                // Tablet
        lg:text-xl                // Desktop
        text-muted-foreground
      ">
        Build something amazing
      </p>
    </div>
  )
}
```

**Responsive Spacing:**

```typescript
function Section({ children }) {
  return (
    <section className="
      py-8                       // Mobile: 2rem vertical
      md:py-12                   // Tablet: 3rem
      lg:py-16                   // Desktop: 4rem

      px-4                       // Mobile: 1rem horizontal
      sm:px-6                    // Small: 1.5rem
      lg:px-8                    // Large: 2rem
    ">
      {children}
    </section>
  )
}
```

**Show/Hide Elements:**

```typescript
function Navigation() {
  return (
    <nav>
      {/* Mobile menu button - hidden on desktop */}
      <button className="lg:hidden">
        <Menu className="h-6 w-6" />
      </button>

      {/* Desktop nav - hidden on mobile */}
      <div className="hidden lg:flex lg:gap-6">
        <a href="/about">About</a>
        <a href="/products">Products</a>
        <a href="/contact">Contact</a>
      </div>
    </nav>
  )
}
```

**Responsive Container:**

```typescript
function Container({ children, className }) {
  return (
    <div className={cn(
      "mx-auto w-full",
      "px-4 sm:px-6 lg:px-8",     // Responsive padding
      "max-w-7xl",                 // Max width
      className
    )}>
      {children}
    </div>
  )
}

// Usage
<Container>
  <Content />
</Container>

<Container className="max-w-4xl">
  <NarrowContent />
</Container>
```

**Responsive Flex Direction:**

```typescript
// Cards that stack on mobile, row on desktop
function FeatureSection() {
  return (
    <div className="
      flex flex-col gap-6
      md:flex-row md:items-center
    ">
      <div className="md:w-1/2">
        <h2>Feature Title</h2>
        <p>Description text</p>
      </div>
      <div className="md:w-1/2">
        <Image src="/feature.png" />
      </div>
    </div>
  )
}

// Reverse order on desktop
function AlternateFeature() {
  return (
    <div className="
      flex flex-col gap-6
      md:flex-row-reverse md:items-center
    ">
      {/* Same content, reversed on desktop */}
    </div>
  )
}
```

**Common Responsive Patterns:**

| Pattern | Mobile | Desktop |
|---------|--------|---------|
| Navigation | Hamburger menu | Horizontal links |
| Sidebar | Bottom sheet / hidden | Fixed left column |
| Grid | 1-2 columns | 3-4 columns |
| Cards | Stacked | Side by side |
| Form | Single column | Two columns |
| Hero | Smaller text, stacked | Large text, side by side |
| Table | Card view / scroll | Full table |
