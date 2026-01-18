---
title: shadcn/ui Charts with Recharts
impact: HIGH
impactDescription: Data visualization with consistent theming
tags: shadcn, recharts, charts, data-visualization
---

## shadcn/ui Charts with Recharts

shadcn/ui includes chart components built on Recharts. Use these for consistent, themed data visualization that integrates with your design system.

**Installation:**

```bash
# Add chart components
npx shadcn@latest add chart

# This installs:
# - ChartContainer
# - ChartTooltip, ChartTooltipContent
# - ChartLegend, ChartLegendContent
# - CSS variables for chart colors
```

**Required CSS Variables:**

```css
/* globals.css - Add chart colors */
@layer base {
  :root {
    --chart-1: 12 76% 61%;      /* hsl for chart color 1 */
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;
  }

  .dark {
    --chart-1: 220 70% 50%;
    --chart-2: 160 60% 45%;
    --chart-3: 30 80% 55%;
    --chart-4: 280 65% 60%;
    --chart-5: 340 75% 55%;
  }
}
```

**Basic Bar Chart:**

```typescript
'use client'

import { Bar, BarChart, XAxis, YAxis } from 'recharts'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  ChartLegend,
  ChartLegendContent,
  type ChartConfig,
} from '@/components/ui/chart'

const data = [
  { month: 'Jan', desktop: 186, mobile: 80 },
  { month: 'Feb', desktop: 305, mobile: 200 },
  { month: 'Mar', desktop: 237, mobile: 120 },
  { month: 'Apr', desktop: 73, mobile: 190 },
  { month: 'May', desktop: 209, mobile: 130 },
]

const chartConfig = {
  desktop: {
    label: 'Desktop',
    color: 'hsl(var(--chart-1))',
  },
  mobile: {
    label: 'Mobile',
    color: 'hsl(var(--chart-2))',
  },
} satisfies ChartConfig

export function RevenueChart() {
  return (
    <ChartContainer config={chartConfig} className="min-h-[300px] w-full">
      <BarChart data={data} accessibilityLayer>
        <XAxis
          dataKey="month"
          tickLine={false}
          tickMargin={10}
          axisLine={false}
        />
        <YAxis tickLine={false} axisLine={false} />
        <ChartTooltip content={<ChartTooltipContent />} />
        <ChartLegend content={<ChartLegendContent />} />
        <Bar dataKey="desktop" fill="var(--color-desktop)" radius={4} />
        <Bar dataKey="mobile" fill="var(--color-mobile)" radius={4} />
      </BarChart>
    </ChartContainer>
  )
}
```

**Line Chart:**

```typescript
import { Line, LineChart, XAxis, YAxis, CartesianGrid } from 'recharts'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/components/ui/chart'

const chartConfig = {
  views: {
    label: 'Page Views',
    color: 'hsl(var(--chart-1))',
  },
} satisfies ChartConfig

export function AnalyticsChart({ data }) {
  return (
    <ChartContainer config={chartConfig} className="h-[300px]">
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
        <XAxis dataKey="date" tickLine={false} axisLine={false} />
        <YAxis tickLine={false} axisLine={false} />
        <ChartTooltip content={<ChartTooltipContent />} />
        <Line
          type="monotone"
          dataKey="views"
          stroke="var(--color-views)"
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </ChartContainer>
  )
}
```

**Pie/Donut Chart:**

```typescript
import { Pie, PieChart, Cell } from 'recharts'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/components/ui/chart'

const data = [
  { name: 'Chrome', value: 275, fill: 'var(--color-chrome)' },
  { name: 'Safari', value: 200, fill: 'var(--color-safari)' },
  { name: 'Firefox', value: 187, fill: 'var(--color-firefox)' },
  { name: 'Edge', value: 173, fill: 'var(--color-edge)' },
]

const chartConfig = {
  chrome: { label: 'Chrome', color: 'hsl(var(--chart-1))' },
  safari: { label: 'Safari', color: 'hsl(var(--chart-2))' },
  firefox: { label: 'Firefox', color: 'hsl(var(--chart-3))' },
  edge: { label: 'Edge', color: 'hsl(var(--chart-4))' },
} satisfies ChartConfig

export function BrowserChart() {
  return (
    <ChartContainer config={chartConfig} className="h-[300px]">
      <PieChart>
        <ChartTooltip content={<ChartTooltipContent />} />
        <Pie
          data={data}
          dataKey="value"
          nameKey="name"
          innerRadius={60}  // Makes it a donut
          outerRadius={100}
          strokeWidth={2}
        />
      </PieChart>
    </ChartContainer>
  )
}
```

**Area Chart:**

```typescript
import { Area, AreaChart, XAxis, YAxis } from 'recharts'
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '@/components/ui/chart'

export function TrendChart({ data }) {
  return (
    <ChartContainer config={chartConfig} className="h-[200px]">
      <AreaChart data={data}>
        <defs>
          <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%" stopColor="hsl(var(--chart-1))" stopOpacity={0.8} />
            <stop offset="95%" stopColor="hsl(var(--chart-1))" stopOpacity={0.1} />
          </linearGradient>
        </defs>
        <XAxis dataKey="date" tickLine={false} axisLine={false} />
        <YAxis tickLine={false} axisLine={false} />
        <ChartTooltip content={<ChartTooltipContent />} />
        <Area
          type="monotone"
          dataKey="value"
          stroke="hsl(var(--chart-1))"
          fill="url(#colorValue)"
        />
      </AreaChart>
    </ChartContainer>
  )
}
```

**ChartConfig Type:**

```typescript
// The config object maps data keys to labels and colors
type ChartConfig = {
  [key: string]: {
    label: string
    color: string  // Use CSS variable: 'hsl(var(--chart-1))'
    icon?: React.ComponentType
  }
}

// Colors are injected as CSS custom properties:
// --color-{key} becomes available in the chart
```

**Best Practices:**

| Do | Don't |
|----|-------|
| Use `ChartContainer` wrapper | Render Recharts without container |
| Define colors in chartConfig | Hardcode hex colors |
| Use CSS variables for theming | Ignore dark mode |
| Add `accessibilityLayer` prop | Skip accessibility |
| Use `ChartTooltip` components | Build custom tooltips from scratch |

**Responsive Charts:**

```typescript
// Charts are responsive by default in ChartContainer
// Use className to set dimensions

<ChartContainer config={config} className="h-[200px] sm:h-[300px] lg:h-[400px]">
  {/* chart */}
</ChartContainer>

// Or use aspect ratio
<ChartContainer config={config} className="aspect-video">
  {/* chart */}
</ChartContainer>
```

**Available Recharts Components:**

- `AreaChart`, `Area`
- `BarChart`, `Bar`
- `LineChart`, `Line`
- `PieChart`, `Pie`, `Cell`
- `RadarChart`, `Radar`, `PolarGrid`, `PolarAngleAxis`
- `RadialBarChart`, `RadialBar`
- `ScatterChart`, `Scatter`
- `ComposedChart` (mix multiple types)
- `XAxis`, `YAxis`, `CartesianGrid`
- `Tooltip`, `Legend`, `Label`
- `ResponsiveContainer` (handled by ChartContainer)
