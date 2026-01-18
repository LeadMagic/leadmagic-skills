---
title: Use Schema for Structured Responses
impact: HIGH
impactDescription: Predictable, type-safe AI outputs
tags: output, schema, structured, zod
---

## Use Schema for Structured Responses

When you need structured data from the AI (not just text), use `generateObject` or `streamObject` with a Zod schema. This ensures predictable, validated outputs.

**Incorrect (parsing text manually):**

```typescript
import { generateText } from 'ai'

async function getProductDetails(description: string) {
  const { text } = await generateText({
    model: openai('gpt-4-turbo'),
    prompt: `Extract product details from: ${description}

    Return JSON with: name, price, category, features`,
  })

  // Manual parsing - brittle and error-prone
  try {
    const data = JSON.parse(text)
    return data // Type is 'any', no validation
  } catch {
    // AI might not return valid JSON
    return null
  }
}
```

**Correct (using generateObject with schema):**

```typescript
import { generateObject } from 'ai'
import { z } from 'zod'

const productSchema = z.object({
  name: z.string().describe('Product name'),
  price: z.number().positive().describe('Price in USD'),
  category: z.enum(['electronics', 'clothing', 'home', 'food', 'other'])
    .describe('Product category'),
  features: z.array(z.string()).min(1).describe('Key product features'),
  inStock: z.boolean().describe('Whether the product is available'),
  rating: z.number().min(0).max(5).optional().describe('Average rating'),
})

type Product = z.infer<typeof productSchema>

async function getProductDetails(description: string): Promise<Product> {
  const { object } = await generateObject({
    model: openai('gpt-4-turbo'),
    schema: productSchema,
    prompt: `Extract product details from this description: ${description}`,
  })

  // object is fully typed and validated
  return object
}

// With streaming for large objects
async function* streamProductDetails(description: string) {
  const { partialObjectStream } = await streamObject({
    model: openai('gpt-4-turbo'),
    schema: productSchema,
    prompt: `Extract product details from: ${description}`,
  })

  for await (const partialObject of partialObjectStream) {
    // Receive partial updates as fields are generated
    yield partialObject
  }
}
```

**Using with arrays:**

```typescript
const productsSchema = z.array(productSchema)

async function extractMultipleProducts(text: string) {
  const { object } = await generateObject({
    model: openai('gpt-4-turbo'),
    schema: productsSchema,
    prompt: `Extract all products mentioned in: ${text}`,
  })

  return object // Product[]
}
```

**Combining with enum for specific outputs:**

```typescript
const sentimentSchema = z.object({
  sentiment: z.enum(['positive', 'negative', 'neutral']),
  confidence: z.number().min(0).max(1),
  keywords: z.array(z.string()),
  summary: z.string().max(200),
})

async function analyzeSentiment(text: string) {
  const { object } = await generateObject({
    model: openai('gpt-4-turbo'),
    schema: sentimentSchema,
    prompt: `Analyze the sentiment of: ${text}`,
  })

  return object
}
```

Benefits:
- Guaranteed valid JSON output
- Full TypeScript type inference
- Runtime validation
- Schema acts as documentation
- Reduces prompt engineering for format
