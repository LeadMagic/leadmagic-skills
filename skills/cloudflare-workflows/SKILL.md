---
name: cloudflare-workflows
description: Best practices for building durable, multi-step workflows with Cloudflare Workflows. Use when orchestrating long-running tasks, handling retries, waiting for external events, or building reliable background jobs. Triggers on "Workflow", "durable execution", "orchestration", "multi-step", "background job".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.2.0"
---

# Cloudflare Workflows Best Practices

Comprehensive guide for building durable, reliable workflows on Cloudflare Workers. **Workflows is now GA.**

## What's New (2025 GA)

- **Production Ready** - Workflows is now Generally Available
- **Instance Lifecycle** - `pause()`, `resume()`, `terminate()`, `restart()` methods
- **waitForEvent** - Wait for external events with `type` matching and timeout
- **sendEvent** - Send events to waiting workflow instances
- **Child Workflows** - Trigger workflows from within other workflows
- **Python Support** - Python workflows now in beta

## When to Apply

Reference these guidelines when:
- Building multi-step background processes
- Orchestrating tasks that may take hours or days
- Implementing retry logic for unreliable operations
- Waiting for external events (webhooks, user actions)
- Building human-in-the-loop approval systems

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Steps & Durability | CRITICAL | `step-` |
| 2 | Events & Scheduling | HIGH | `events-` |

## Quick Reference

### 1. Steps & Durability (CRITICAL)

- `step-do-durable` - Use step.do() for durable operations
- `step-idempotency` - Make steps idempotent
- `step-payload-limits` - Keep step payloads small (<1MB)

### 2. Events & Scheduling (HIGH)

- `events-wait-for-event` - Wait for external events properly

## Essential Patterns

### Basic Workflow Definition

```typescript
import { WorkflowEntrypoint, WorkflowEvent, WorkflowStep } from 'cloudflare:workers'

interface Env {
  MY_WORKFLOW: Workflow
  DB: D1Database
  BUCKET: R2Bucket
}

// Define workflow parameters
interface OrderParams {
  orderId: string
  userId: string
  items: Array<{ productId: string; quantity: number }>
}

// Define workflow return type
interface OrderResult {
  orderId: string
  status: 'completed' | 'failed'
  trackingNumber?: string
}

export class OrderWorkflow extends WorkflowEntrypoint<Env, OrderParams> {
  async run(event: WorkflowEvent<OrderParams>, step: WorkflowStep): Promise<OrderResult> {
    const { orderId, userId, items } = event.payload

    // Step 1: Validate inventory (durable)
    const inventoryValid = await step.do('validate-inventory', async () => {
      return await this.env.DB
        .prepare('SELECT * FROM inventory WHERE product_id IN (?)')
        .bind(items.map(i => i.productId).join(','))
        .all()
    })

    if (!inventoryValid) {
      return { orderId, status: 'failed' }
    }

    // Step 2: Process payment (with retries)
    const paymentResult = await step.do('process-payment', {
      retries: {
        limit: 3,
        delay: '10 seconds',
        backoff: 'exponential',
      },
    }, async () => {
      return await processPayment(orderId, userId)
    })

    // Step 3: Ship order
    const trackingNumber = await step.do('ship-order', async () => {
      return await shipOrder(orderId, items)
    })

    // Step 4: Send confirmation email
    await step.do('send-confirmation', async () => {
      await sendEmail(userId, { orderId, trackingNumber })
    })

    return { orderId, status: 'completed', trackingNumber }
  }
}
```

### Triggering Workflows

```typescript
import { Hono } from 'hono'

type Bindings = {
  ORDER_WORKFLOW: Workflow
}

const app = new Hono<{ Bindings: Bindings }>()

app.post('/orders', async (c) => {
  const order = await c.req.json<OrderParams>()

  // Create workflow instance with meaningful ID (idempotent)
  const instance = await c.env.ORDER_WORKFLOW.create({
    id: `order-${order.orderId}`,  // Idempotent: same ID = same instance
    params: order,
  })

  return c.json({
    workflowId: instance.id,
    status: await instance.status(),
  }, 202)
})

// Check workflow status
app.get('/orders/:orderId/status', async (c) => {
  const orderId = c.req.param('orderId')

  const instance = await c.env.ORDER_WORKFLOW.get(`order-${orderId}`)
  const status = await instance.status()

  return c.json({
    workflowId: instance.id,
    status: status.status,
    output: status.output,
    error: status.error,
  })
})
```

### Waiting for External Events

```typescript
export class ApprovalWorkflow extends WorkflowEntrypoint<Env, ApprovalParams> {
  async run(event: WorkflowEvent<ApprovalParams>, step: WorkflowStep) {
    const { requestId, requesterId } = event.payload

    // Step 1: Create approval request
    await step.do('create-request', async () => {
      await this.env.DB
        .prepare('INSERT INTO approvals (id, requester_id, status) VALUES (?, ?, ?)')
        .bind(requestId, requesterId, 'pending')
        .run()
    })

    // Step 2: Notify approvers
    await step.do('notify-approvers', async () => {
      await notifyApprovers(requestId)
    })

    // Step 3: Wait for approval event (up to 7 days)
    // NOTE: Use 'type' to match events sent via instance.sendEvent()
    const approval = await step.waitForEvent<ApprovalEvent>('wait-for-approval', {
      type: 'approval-decision',  // Matches sendEvent type
      timeout: '7 days',
    })

    if (!approval || approval.payload.decision === 'rejected') {
      await step.do('handle-rejection', async () => {
        await updateStatus(requestId, 'rejected')
        await notifyRequester(requesterId, 'rejected')
      })
      return { status: 'rejected' }
    }

    // Step 4: Process approval
    await step.do('process-approval', async () => {
      await processApproval(requestId)
      await notifyRequester(requesterId, 'approved')
    })

    return { status: 'approved', approvedBy: approval.payload.approverId }
  }
}
```

### Sending Events to Workflows

```typescript
// Send event to a waiting workflow instance
app.post('/approvals/:requestId/decide', async (c) => {
  const requestId = c.req.param('requestId')
  const { decision, comment } = await c.req.json()
  const approverId = c.get('userId')

  const instance = await c.env.APPROVAL_WORKFLOW.get(`approval-${requestId}`)

  // type must match the waitForEvent type
  await instance.sendEvent({
    type: 'approval-decision',
    payload: { approverId, decision, comment },
  })

  return c.json({ sent: true })
})
```

### Instance Lifecycle Management

```typescript
// Get instance and check status
const instance = await env.MY_WORKFLOW.get('instance-id')
const status = await instance.status()
// status.status: 'queued' | 'running' | 'paused' | 'errored' | 
//                'terminated' | 'complete' | 'waiting' | 'waitingForPause' | 'unknown'

// Pause a running instance
await instance.pause()

// Resume a paused instance
await instance.resume()

// Terminate (stop) an instance permanently
await instance.terminate()

// Restart from beginning (erases state)
await instance.restart()
```

### Scheduled Delays

```typescript
export class TrialExpiryWorkflow extends WorkflowEntrypoint<Env, TrialParams> {
  async run(event: WorkflowEvent<TrialParams>, step: WorkflowStep) {
    const { userId, trialEndDate } = event.payload

    // Step 1: Send welcome email immediately
    await step.do('welcome-email', async () => {
      await sendEmail(userId, 'welcome')
    })

    // Step 2: Wait until 3 days before trial ends
    const reminderDate = new Date(trialEndDate)
    reminderDate.setDate(reminderDate.getDate() - 3)

    await step.sleepUntil('wait-for-reminder', reminderDate)

    // Step 3: Send reminder
    await step.do('reminder-email', async () => {
      await sendEmail(userId, 'trial-ending-soon')
    })

    // Step 4: Wait until trial ends
    await step.sleepUntil('wait-for-expiry', new Date(trialEndDate))

    // Step 5: Check if converted
    const converted = await step.do('check-conversion', async () => {
      const user = await getUser(userId)
      return user.subscription !== 'trial'
    })

    if (!converted) {
      // Step 6: Handle expiry
      await step.do('handle-expiry', async () => {
        await expireTrial(userId)
        await sendEmail(userId, 'trial-expired')
      })
    }

    return { converted }
  }
}
```

### Retry Configuration

```typescript
// Step with custom retry policy
await step.do('call-external-api', {
  retries: {
    limit: 5,           // Max 5 attempts
    delay: '30 seconds', // Initial delay
    backoff: 'exponential', // exponential backoff
  },
  timeout: '2 minutes', // Timeout per attempt
}, async () => {
  const response = await fetch('https://api.example.com/process', {
    method: 'POST',
    body: JSON.stringify(data),
  })

  if (!response.ok) {
    // Throw to trigger retry
    throw new Error(`API error: ${response.status}`)
  }

  return response.json()
})
```

## Wrangler Configuration

```toml
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

# Workflow binding
[[workflows]]
name = "ORDER_WORKFLOW"
binding = "ORDER_WORKFLOW"
class_name = "OrderWorkflow"

[[workflows]]
name = "APPROVAL_WORKFLOW"
binding = "APPROVAL_WORKFLOW"
class_name = "ApprovalWorkflow"

# Other bindings workflows can use
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "xxx"
```

## Workflow Limits

| Resource | Limit |
|----------|-------|
| Max workflow duration | 30 days |
| Max step payload | 1MB |
| Max steps per workflow | 1000 |
| Max concurrent instances | 100 per account |
| Event wait timeout | 30 days |

