---
title: Webhooks and Automation
impact: HIGH
impactDescription: Enables event-driven workflows and integrations
tags: webhooks, automation, events, integrations
---

## Webhooks and Automation

Linear webhooks enable real-time automation when issues, comments, or other resources change. Use them to trigger CI/CD, notify teams, or start agent workflows.

**Incorrect (polling for changes):**

```typescript
// Don't poll - it's slow and wastes resources
setInterval(async () => {
  const issues = await linear.issues({ updatedAt: { gt: lastCheck } })
  // Process changes...
}, 60000)
```

**Correct (webhook-driven):**

```typescript
import { Hono } from 'hono'
import crypto from 'crypto'

const app = new Hono()

app.post('/webhooks/linear', async (c) => {
  // 1. Verify signature
  const signature = c.req.header('linear-signature')
  const body = await c.req.text()

  if (!verifySignature(body, signature!, process.env.LINEAR_WEBHOOK_SECRET!)) {
    return c.json({ error: 'Invalid signature' }, 401)
  }

  // 2. Parse event
  const event = JSON.parse(body)

  // 3. Route by event type
  await routeEvent(event)

  return c.json({ received: true })
})

function verifySignature(body: string, signature: string, secret: string): boolean {
  const hmac = crypto.createHmac('sha256', secret)
  hmac.update(body)
  const expected = hmac.digest('hex')
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))
}
```

## Webhook Setup

### 1. Create Webhook in Linear

```
Settings → API → Webhooks → New Webhook
- URL: https://your-domain.com/webhooks/linear
- Events: Select relevant events
- Save → Copy signing secret
```

### 2. Event Types

| Event | Trigger |
|-------|---------|
| `Issue` | Issue created, updated, deleted |
| `Comment` | Comment created, updated, deleted |
| `IssueLabel` | Label added/removed from issue |
| `Cycle` | Cycle created, updated, completed |
| `Project` | Project changes |
| `Reaction` | Emoji reaction added/removed |

### 3. Event Payload Structure

```typescript
interface LinearWebhookPayload {
  action: 'create' | 'update' | 'remove'
  type: 'Issue' | 'Comment' | 'Cycle' | 'Project' | ...
  data: {
    id: string
    // Type-specific fields
  }
  createdAt: string
  organizationId: string
  webhookId: string
  webhookTimestamp: number
}
```

## Event Routing

```typescript
async function routeEvent(event: LinearWebhookPayload) {
  const handlers: Record<string, (event: LinearWebhookPayload) => Promise<void>> = {
    'Issue:create': handleIssueCreate,
    'Issue:update': handleIssueUpdate,
    'Comment:create': handleCommentCreate,
    'Cycle:update': handleCycleUpdate,
  }

  const key = `${event.type}:${event.action}`
  const handler = handlers[key]

  if (handler) {
    await handler(event)
  }
}
```

## Common Automation Patterns

### Auto-Assign Based on Label

```typescript
async function handleIssueCreate(event: LinearWebhookPayload) {
  const { data } = event

  // Check if agent-task label
  if (data.labelIds?.includes(AGENT_TASK_LABEL_ID)) {
    // Trigger agent workflow
    await triggerAgentWorkflow(data.id)
  }

  // Auto-assign based on component
  const componentAssignments: Record<string, string> = {
    'frontend-label-id': 'frontend-team-member-id',
    'backend-label-id': 'backend-team-member-id',
    'infra-label-id': 'infra-team-member-id',
  }

  for (const [labelId, assigneeId] of Object.entries(componentAssignments)) {
    if (data.labelIds?.includes(labelId) && !data.assigneeId) {
      await linear.updateIssue(data.id, { assigneeId })
      break
    }
  }
}
```

### Notify on Status Change

```typescript
async function handleIssueUpdate(event: LinearWebhookPayload) {
  const { data } = event

  // Issue moved to "In Review"
  if (data.stateId === IN_REVIEW_STATE_ID) {
    await slack.postMessage({
      channel: '#code-reviews',
      text: `🔍 <${data.url}|${data.identifier}> is ready for review`,
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*<${data.url}|${data.identifier}: ${data.title}>*\nAssignee: ${data.assignee?.name || 'Unassigned'}`,
          },
        },
      ],
    })
  }

  // Issue completed
  if (data.state?.type === 'completed') {
    await notifyCompletion(data)
  }
}
```

### Agent Command Detection

```typescript
async function handleCommentCreate(event: LinearWebhookPayload) {
  const { data } = event
  const body = data.body || ''

  // Detect agent commands in comments
  if (body.includes('@agent:start')) {
    await triggerAgentWorkflow(data.issueId)
  }

  if (body.includes('@agent:stop')) {
    await stopAgentWorkflow(data.issueId)
  }

  // Detect completion signals
  if (body.includes('<promise>COMPLETE</promise>')) {
    await linear.updateIssue(data.issueId, { stateId: DONE_STATE_ID })
    await notifyAgentCompletion(data.issueId)
  }

  if (body.includes('<promise>BLOCKED')) {
    await notifyAgentBlocked(data.issueId, body)
  }
}
```

### Cycle Completion Report

```typescript
async function handleCycleUpdate(event: LinearWebhookPayload) {
  const { data } = event

  // Cycle completed
  if (data.completedAt && !event.previousData?.completedAt) {
    const report = await generateCycleReport(data.id)

    await slack.postMessage({
      channel: '#team-updates',
      text: `📊 Sprint ${data.name} completed!`,
      blocks: [
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*Sprint ${data.name} Complete*\n\n` +
              `✅ Completed: ${report.completed} issues (${report.completedPoints} pts)\n` +
              `🔄 Carryover: ${report.carryover} issues\n` +
              `📈 Velocity: ${report.velocity} points`,
          },
        },
      ],
    })
  }
}
```

## GitHub Integration

### Link PRs to Issues

```typescript
// GitHub webhook handler
app.post('/webhooks/github', async (c) => {
  const event = c.req.header('x-github-event')
  const payload = await c.req.json()

  if (event === 'pull_request') {
    await handlePullRequest(payload)
  }

  return c.json({ received: true })
})

async function handlePullRequest(payload: any) {
  const { action, pull_request } = payload
  const prBody = pull_request.body || ''
  const prTitle = pull_request.title || ''

  // Extract Linear issue ID from PR title or body
  // Format: TEAM-123 or [TEAM-123]
  const issueMatch = (prBody + ' ' + prTitle).match(/\[?([A-Z]+-\d+)\]?/)

  if (issueMatch) {
    const issueIdentifier = issueMatch[1]
    const issue = await linear.issue(issueIdentifier)

    if (issue) {
      if (action === 'opened') {
        // Add PR as attachment
        await linear.createAttachment({
          issueId: issue.id,
          title: `PR #${pull_request.number}`,
          url: pull_request.html_url,
          iconUrl: 'https://github.githubassets.com/favicons/favicon.svg',
        })

        // Move to "In Review"
        await linear.updateIssue(issue.id, { stateId: IN_REVIEW_STATE_ID })
      }

      if (action === 'closed' && pull_request.merged) {
        // Move to "Done" on merge
        await linear.updateIssue(issue.id, { stateId: DONE_STATE_ID })
      }
    }
  }
}
```

## Best Practices

1. **Always verify signatures** - Never trust unverified webhooks
2. **Idempotent handlers** - Webhooks may be delivered multiple times
3. **Async processing** - Respond quickly, process asynchronously
4. **Error handling** - Log and alert on handler failures
5. **Rate limiting** - Don't overwhelm downstream services
