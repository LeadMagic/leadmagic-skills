---
name: inngest
description: Durable workflow orchestration for Next.js and serverless. Use when building background jobs, event-driven workflows, scheduled tasks, or multi-step processes. Triggers on "background job", "workflow", "queue", "scheduled task", "event-driven", "retry logic", "inngest".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "2.0.0"
---

# Inngest - Durable Workflows

Inngest provides durable workflow orchestration for serverless environments. Build reliable background jobs, event-driven workflows, and scheduled tasks with automatic retries and observability.

**SDK Version:** v3.0+ (TypeScript)

## When to Apply

Reference these guidelines when:
- Building background jobs that need reliability
- Creating multi-step workflows with durability
- Implementing event-driven architectures
- Scheduling recurring tasks (cron jobs)
- Adding retry logic to critical operations
- Orchestrating long-running processes
- Streaming real-time updates from workflows

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Function Definition | CRITICAL | `fn-` |
| 2 | Step Functions | CRITICAL | `step-` |
| 3 | Event Patterns | HIGH | `event-` |
| 4 | Realtime & Connect | MEDIUM | `realtime-` |
| 5 | Error Handling | MEDIUM | `errors-` |

## Quick Reference

### 1. Function Definition (CRITICAL)

- `fn-idempotency` - Ensure functions are idempotent
- `fn-configuration` - Configure retries, timeouts, concurrency

### 2. Step Functions (CRITICAL)

- `step-run` - Durable step execution
- `step-sleep` - Durable delays
- `step-wait-for-event` - Wait for external events
- `step-invoke` - Call other functions

### 3. New in SDK v3.0

- `step.fetch()` - Durable HTTP requests
- **Connect** - WebSocket gateway for non-HTTP environments
- **Realtime** - Stream updates from functions to clients
- **Checkpointing** - Save state for long-running functions

---

## Installation

```bash
npm install inngest
```

## Next.js Setup

```typescript
// app/api/inngest/route.ts
import { serve } from 'inngest/next'
import { inngest, functions } from '@/lib/inngest'

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions,
})
```

```typescript
// lib/inngest/client.ts
import { Inngest, EventSchemas } from 'inngest'

export const inngest = new Inngest({
  id: 'my-app',
  schemas: new EventSchemas().fromRecord<Events>(),
})
```

---

## Basic Function

```typescript
import { inngest } from './client'

export const processOrder = inngest.createFunction(
  {
    id: 'process-order',
    retries: 3,
  },
  { event: 'order/created' },
  async ({ event, step }) => {
    const { orderId, userId } = event.data

    // Each step is durable - survives failures
    const order = await step.run('fetch-order', async () => {
      return await db.orders.findUnique({ where: { id: orderId } })
    })

    await step.run('charge-payment', async () => {
      return await stripe.charges.create({
        amount: order.total,
        customer: order.customerId,
      })
    })

    await step.run('send-confirmation', async () => {
      return await sendEmail({
        to: order.email,
        template: 'order-confirmation',
        data: order,
      })
    })

    return { success: true, orderId }
  }
)
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Side effects outside step.run | May execute multiple times | Wrap in step.run |
| No retry limit | Infinite retries on permanent failures | Set retries: N |
| Large event payloads | Performance issues | Store data externally, pass IDs |
| No idempotency | Duplicate processing | Use idempotency keys |
| Sync processing | Blocks response | Use Inngest for async |

---

## Best Practices

### Do

- Make functions idempotent - they may run multiple times
- Use `step.run` for all side effects (API calls, DB writes)
- Define typed event schemas
- Set appropriate retry limits
- Use concurrency limits for resource-intensive operations
- Log at the start and end of functions

### Don't

- Don't perform side effects outside of `step.run`
- Don't use global state between steps
- Don't set unlimited retries
- Don't ignore function timeouts
- Don't send PII in event data without encryption

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/step-functions.md    - All step.* methods
rules/events.md            - Event schemas and triggers
rules/patterns.md          - Common workflow patterns
rules/realtime.md          - Streaming updates to clients
rules/connect.md           - Non-HTTP deployment
rules/testing.md           - Testing functions
```

## Resources

- [Inngest Documentation](https://www.inngest.com/docs)
- [SDK v3.0 Migration](https://www.inngest.com/docs/sdk/migration)
- [Next.js Integration](https://www.inngest.com/docs/frameworks/nextjs)
- [Step Functions](https://www.inngest.com/docs/features/inngest-functions/steps-workflows)
- [Realtime](https://www.inngest.com/docs/features/realtime)
