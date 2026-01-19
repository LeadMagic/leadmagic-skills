---
name: linear
description: Linear project management for AI agents and teams. Use when creating issues, managing projects, planning sprints/cycles, reviewing backlogs, or building project plans. Triggers on "create Linear issue", "plan sprint", "manage backlog", "project planning", "track work", "Linear API".
license: MIT
metadata:
  author: leadmagic
  version: "1.1.0"
---

# Linear Project Management

Comprehensive guide for using Linear to manage work for AI agents and human teams. Covers API integration, issue management, project planning, and workflow automation.

## When to Apply

Reference these guidelines when:
- Creating or updating Linear issues programmatically
- Planning sprints/cycles for teams or agents
- Building project roadmaps and milestones
- Reviewing backlogs and prioritizing work
- Integrating Linear with CI/CD or automation
- Managing work assignments for AI agents
- Generating project plans from requirements

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | API Integration | CRITICAL | `api-` |
| 2 | Issue Management | CRITICAL | `issue-` |
| 3 | Project Planning | HIGH | `planning-` |
| 4 | Workflow Automation | HIGH | `workflow-` |
| 5 | Agent Management | MEDIUM | `agent-` |

## Quick Reference

### 1. API Integration (CRITICAL)

- `api-authentication` - API key and OAuth setup
- `api-graphql` - GraphQL query patterns
- `api-sdk` - Using the Linear SDK

### 2. Issue Management (CRITICAL)

- `issue-creation` - Creating well-structured issues
- `issue-templates` - Standard issue templates
- `issue-linking` - Relations, blocks, duplicates

### 3. Project Planning (HIGH)

- `planning-cycles` - Sprint/cycle management
- `planning-projects` - Project and milestone setup
- `planning-roadmaps` - Long-term planning

### 4. Workflow Automation (HIGH)

- `workflow-webhooks` - Event-driven automation
- `workflow-integrations` - GitHub, Slack, CI/CD

### 5. Agent Management (MEDIUM)

- `agent-assignment` - Assigning work to AI agents
- `agent-tracking` - Monitoring agent progress

---

## Linear API Setup

### Authentication

```typescript
import { LinearClient } from '@linear/sdk'

// API Key authentication (for server-side)
const linear = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY
})

// OAuth (for user-facing apps)
const linear = new LinearClient({
  accessToken: userAccessToken
})
```

### Environment Variables

```bash
# .env
LINEAR_API_KEY=lin_api_xxxxxxxxxxxxx
LINEAR_TEAM_ID=TEAM-xxx
LINEAR_WEBHOOK_SECRET=whsec_xxxxx
```

---

## Core API Operations

### Creating Issues

```typescript
const issue = await linear.createIssue({
  teamId: 'TEAM_ID',
  title: 'Implement user authentication',
  description: `## Overview
Add JWT-based authentication to the API.

## Requirements
- [ ] User registration endpoint
- [ ] Login endpoint with JWT
- [ ] Password reset flow

## Acceptance Criteria
- All tests passing
- API documentation updated`,
  priority: 2, // 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
  estimate: 5, // Story points
  labelIds: ['label-id-1'],
  assigneeId: 'user-id',
  projectId: 'project-id',
  cycleId: 'cycle-id',
})

console.log(`Created issue: ${issue.identifier}`)
```

### Querying Issues

```typescript
const issues = await linear.issues({
  filter: {
    team: { id: { eq: 'TEAM_ID' } },
    state: { type: { in: ['started', 'unstarted'] } },
    assignee: { id: { eq: 'USER_ID' } },
  },
  orderBy: LinearDocument.PaginationOrderBy.UpdatedAt,
})

// Get specific issue by identifier
const issue = await linear.issue('TEAM-123')

// Search issues
const searchResults = await linear.issueSearch('authentication bug')
```

### Updating Issues

```typescript
await linear.updateIssue(issueId, {
  stateId: 'in-progress-state-id',
  assigneeId: 'new-assignee-id',
  priority: 1,
})

// Add a comment
await linear.createComment({
  issueId: issueId,
  body: `## Progress Update
- Completed database schema
- API endpoints in progress`,
})

// Link issues
await linear.createIssueRelation({
  issueId: issueId,
  relatedIssueId: otherIssueId,
  type: 'blocks', // 'blocks', 'duplicate', 'related'
})
```

---

## Project & Cycle Management

### Creating Projects

```typescript
const project = await linear.createProject({
  teamIds: ['TEAM_ID'],
  name: 'Q1 2024 - Platform Redesign',
  description: `## Objectives
- Modernize UI with new design system
- Improve performance by 50%`,
  targetDate: '2024-03-31',
  state: 'planned',
})
```

### Managing Cycles (Sprints)

```typescript
const team = await linear.team('TEAM_ID')
const activeCycle = await team.activeCycle

const cycle = await linear.createCycle({
  teamId: 'TEAM_ID',
  name: 'Sprint 24',
  startsAt: '2024-01-15',
  endsAt: '2024-01-29',
})

// Add issues to cycle
await linear.updateIssue(issueId, {
  cycleId: cycle.cycle?.id,
})
```

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/api-authentication.md  - API setup and auth
rules/issue-templates.md     - Standard templates
rules/planning-cycles.md     - Sprint management
rules/agent-assignment.md    - AI agent workflows
rules/workflow-webhooks.md   - Webhook handling
```

## Resources

- [Linear API Documentation](https://developers.linear.app/docs)
- [Linear SDK (npm)](https://www.npmjs.com/package/@linear/sdk)
- [Linear GraphQL Explorer](https://linear.app/graphiql)
- [Webhooks Guide](https://developers.linear.app/docs/graphql/webhooks)
