---
title: Define Tools with Zod Schemas
impact: CRITICAL
impactDescription: Type safety and validation for tool inputs
tags: tools, zod, schema, validation
---

## Define Tools with Zod Schemas

Always define tool parameters using Zod schemas. This provides type safety, validation, and better model guidance through descriptions.

**Incorrect (no schema or loose schema):**

```typescript
import { tool } from 'ai'

// No parameter validation
const searchTool = tool({
  description: 'Search for information',
  parameters: {}, // No schema!
  execute: async (params: any) => {
    // params could be anything - runtime errors likely
    const query = params.query
    return { results: [] }
  },
})

// Loose typing
const weatherTool = tool({
  description: 'Get weather',
  parameters: {
    type: 'object',
    properties: {
      location: { type: 'string' },
    },
  },
  execute: async ({ location }) => {
    // location could be undefined
    return { temp: 72 }
  },
})
```

**Correct (with Zod schema):**

```typescript
import { tool } from 'ai'
import { z } from 'zod'

const searchTool = tool({
  description: 'Search the database for information',
  parameters: z.object({
    query: z.string().min(1).describe('The search query'),
    limit: z.number().min(1).max(100).default(10).describe('Max results'),
    filters: z.object({
      category: z.enum(['all', 'docs', 'code', 'issues']).optional(),
      dateRange: z.object({
        start: z.string().datetime().optional(),
        end: z.string().datetime().optional(),
      }).optional(),
    }).optional().describe('Optional filters'),
  }),
  execute: async ({ query, limit, filters }) => {
    // All parameters are properly typed and validated
    // query: string (guaranteed non-empty)
    // limit: number (guaranteed 1-100, defaults to 10)
    // filters: properly typed optional object

    const results = await db.search(query, { limit, ...filters })
    return { results, query, count: results.length }
  },
})

const weatherTool = tool({
  description: 'Get current weather for a location',
  parameters: z.object({
    location: z.string().describe('City name or coordinates'),
    units: z.enum(['celsius', 'fahrenheit']).default('celsius')
      .describe('Temperature units'),
  }),
  execute: async ({ location, units }) => {
    // location is guaranteed to be a string
    // units is guaranteed to be 'celsius' or 'fahrenheit'
    const weather = await fetchWeather(location, units)
    return weather
  },
})
```

Benefits of Zod schemas:
- Compile-time type checking
- Runtime validation
- Default values
- Descriptions guide the model
- Self-documenting code
