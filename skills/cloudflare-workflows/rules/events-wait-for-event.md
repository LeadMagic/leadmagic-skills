---
title: Wait for External Events Properly
impact: HIGH
impactDescription: Enables human-in-the-loop and webhook-driven workflows
tags: workflow, events, webhooks, async
---

## Wait for External Events Properly

Use `step.waitForEvent()` to pause workflows until external events arrive (webhooks, user actions, approvals).

**Incorrect (polling or blocking):**

```typescript
export class ApprovalWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    const { requestId } = event.payload

    // ❌ Polling wastes resources and has race conditions
    let approved = false
    while (!approved) {
      await step.sleep('check-approval', '30 seconds')

      const status = await step.do('check-status', async () => {
        return await this.env.DB
          .prepare('SELECT status FROM approvals WHERE id = ?')
          .bind(requestId)
          .first()
      })

      approved = status?.status === 'approved'
    }

    return { approved }
  }
}
```

**Correct (event-driven waiting):**

```typescript
// Workflow types
interface ApprovalEvent {
  decision: 'approved' | 'rejected'
  approverId: string
  comment?: string
}

export class ApprovalWorkflow extends WorkflowEntrypoint<Env, Params> {
  async run(event: WorkflowEvent<Params>, step: WorkflowStep) {
    const { requestId, requesterId } = event.payload

    // Step 1: Create the approval request
    await step.do('create-request', async () => {
      await this.env.DB
        .prepare(`
          INSERT INTO approvals (id, requester_id, status, created_at)
          VALUES (?, ?, 'pending', ?)
        `)
        .bind(requestId, requesterId, Date.now())
        .run()
    })

    // Step 2: Notify approvers
    await step.do('notify-approvers', async () => {
      const approvers = await getApprovers(requestId)
      await Promise.all(
        approvers.map(a => sendNotification(a.id, {
          type: 'approval_needed',
          requestId,
          approvalUrl: `https://app.example.com/approve/${requestId}`,
        }))
      )
    })

    // ✅ Step 3: Wait for approval event (up to 7 days)
    // 'type' must match the type sent via instance.sendEvent()
    const approvalEvent = await step.waitForEvent<ApprovalEvent>(
      'wait-for-approval',
      {
        type: 'approval-decision',  // Matches sendEvent type
        timeout: '7 days',
      }
    )

    // Handle timeout
    if (!approvalEvent) {
      await step.do('handle-timeout', async () => {
        await this.env.DB
          .prepare('UPDATE approvals SET status = ? WHERE id = ?')
          .bind('expired', requestId)
          .run()

        await notifyRequester(requesterId, 'Your request expired')
      })

      return { status: 'expired' }
    }

    // Step 4: Process the decision
    const { decision, approverId, comment } = approvalEvent.payload

    await step.do('record-decision', async () => {
      await this.env.DB
        .prepare(`
          UPDATE approvals
          SET status = ?, approved_by = ?, comment = ?, decided_at = ?
          WHERE id = ?
        `)
        .bind(decision, approverId, comment, Date.now(), requestId)
        .run()
    })

    // Step 5: Take action based on decision
    if (decision === 'approved') {
      await step.do('process-approval', async () => {
        await processApprovedRequest(requestId)
        await notifyRequester(requesterId, 'Your request was approved!')
      })
    } else {
      await step.do('process-rejection', async () => {
        await notifyRequester(requesterId, `Your request was rejected: ${comment}`)
      })
    }

    return { status: decision, approverId }
  }
}
```

**Sending events to workflows:**

```typescript
// Worker endpoint to receive approval decisions
app.post('/approvals/:requestId/decide', async (c) => {
  const requestId = c.req.param('requestId')
  const { decision, comment } = await c.req.json()
  const approverId = c.get('userId') // From auth middleware

  // Get the workflow instance by its ID
  const instance = await c.env.APPROVAL_WORKFLOW.get(`approval-${requestId}`)

  // Send the event - 'type' must match waitForEvent's type option
  await instance.sendEvent({
    type: 'approval-decision',  // This matches waitForEvent({ type: 'approval-decision' })
    payload: {
      decision,
      approverId,
      comment,
    },
  })

  return c.json({ sent: true })
})

// Webhook handler for external events
app.post('/webhooks/payment', async (c) => {
  const event = await c.req.json()

  if (event.type === 'payment.completed') {
    const orderId = event.data.metadata.orderId
    const instance = await c.env.ORDER_WORKFLOW.get(`order-${orderId}`)

    await instance.sendEvent({
      type: 'payment-received',
      payload: {
        paymentId: event.data.id,
        amount: event.data.amount,
      },
    })
  }

  return c.text('OK')
})
```

**Racing multiple event types:**

```typescript
// Use Promise.race to wait for first of multiple event types
const event = await Promise.race([
  step.waitForEvent<ApprovalEvent>('wait-approval', {
    type: 'approved',
    timeout: '7 days',
  }),
  step.waitForEvent<RejectionEvent>('wait-rejection', {
    type: 'rejected',
    timeout: '7 days',
  }),
  step.waitForEvent<CancellationEvent>('wait-cancel', {
    type: 'cancelled',
    timeout: '7 days',
  }),
])

if (!event) {
  return { status: 'expired' }
}

// Handle based on which event was received
// The event.type will indicate which one resolved first
```
