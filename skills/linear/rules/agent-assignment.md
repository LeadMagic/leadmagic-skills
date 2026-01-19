---
title: Agent Task Assignment
impact: MEDIUM
impactDescription: Enables effective AI agent work management
tags: agent, assignment, automation, tracking
---

## Agent Task Assignment

AI agents can execute Linear tasks autonomously when issues are properly structured. This rule covers how to create, assign, and track agent work.

**Incorrect (human-oriented issue for agent):**

```typescript
await linear.createIssue({
  teamId: 'TEAM_ID',
  title: 'Improve the codebase',
  description: 'Make the code better and cleaner.',
})
```

Problems:
- Subjective goal
- No verification criteria
- No completion signal

**Correct (agent-optimized issue):**

```typescript
await linear.createIssue({
  teamId: 'TEAM_ID',
  title: '[Agent] Add input validation to user registration endpoint',
  description: `## Objective
Add Zod schema validation to the POST /api/users endpoint.

## Context
- File: \`src/routes/users.ts\`
- Current state: No input validation
- Framework: Hono v4

## Requirements
1. Create Zod schema for user registration:
   - email: valid email format, max 255 chars
   - password: min 8 chars, must contain number
   - name: min 1 char, max 100 chars

2. Add validation middleware to POST /api/users

3. Return 400 with validation errors in format:
   \`\`\`json
   { "error": { "code": "VALIDATION_ERROR", "details": [...] } }
   \`\`\`

## Files to Modify
- \`src/routes/users.ts\` - Add validation
- \`src/schemas/user.ts\` - Create schema (new file)
- \`tests/users.test.ts\` - Add validation tests

## Constraints
- Do not modify existing tests (only add new ones)
- Follow existing code style
- Use existing error response utilities

## Completion Criteria
- [ ] Zod schema created and exported
- [ ] Validation middleware applied to endpoint
- [ ] Invalid inputs return 400 with proper format
- [ ] Valid inputs still work correctly
- [ ] All tests pass: \`npm test\`
- [ ] No lint errors: \`npm run lint\`
- [ ] No type errors: \`npm run typecheck\`

## Verification Commands
\`\`\`bash
npm run lint && npm run typecheck && npm test
\`\`\`

## Agent Config
- **Max Iterations:** 20
- **Success Signal:** \`<promise>COMPLETE</promise>\`
- **Blocked Signal:** \`<promise>BLOCKED: [reason]</promise>\`

## Progress Log
_Agent updates here_`,
  labelIds: ['agent-task-label-id'],
  priority: 3, // Medium
  estimate: 3,
})
```

## Agent Task Lifecycle

### 1. Create Agent Label

```typescript
const agentLabel = await linear.createIssueLabel({
  teamId: 'TEAM_ID',
  name: 'agent-task',
  color: '#6366f1',
  description: 'Tasks assigned to AI coding agents',
})
```

### 2. Issue Creation Workflow

```typescript
async function createAgentTask(
  linear: LinearClient,
  teamId: string,
  task: {
    title: string
    objective: string
    context: string
    files: string[]
    requirements: string[]
    constraints: string[]
    completionCriteria: string[]
    verificationCommands: string[]
    estimate: number
    maxIterations?: number
  }
) {
  const issue = await linear.createIssue({
    teamId,
    title: `[Agent] ${task.title}`,
    description: `## Objective
${task.objective}

## Context
${task.context}

## Files to Modify
${task.files.map(f => `- \`${f}\``).join('\n')}

## Requirements
${task.requirements.map((r, i) => `${i + 1}. ${r}`).join('\n')}

## Constraints
${task.constraints.map(c => `- ${c}`).join('\n')}

## Completion Criteria
${task.completionCriteria.map(c => `- [ ] ${c}`).join('\n')}

## Verification Commands
\`\`\`bash
${task.verificationCommands.join(' && ')}
\`\`\`

## Agent Config
- **Max Iterations:** ${task.maxIterations || 30}
- **Success Signal:** \`<promise>COMPLETE</promise>\`
- **Blocked Signal:** \`<promise>BLOCKED: [reason]</promise>\`

## Progress Log
_Agent updates here_`,
    labelIds: [agentLabel.issueLabel?.id!],
    estimate: task.estimate,
  })

  return issue
}
```

### 3. Agent Progress Updates

```typescript
async function agentProgressUpdate(
  linear: LinearClient,
  issueId: string,
  update: {
    iteration: number
    status: 'started' | 'in_progress' | 'blocked' | 'complete'
    summary: string
    completedCriteria?: string[]
    blockers?: string[]
    filesModified?: string[]
  }
) {
  const emoji = {
    started: '🚀',
    in_progress: '🔄',
    blocked: '🚫',
    complete: '✅',
  }

  await linear.createComment({
    issueId,
    body: `## ${emoji[update.status]} Iteration ${update.iteration}

**Status:** ${update.status}

### Summary
${update.summary}

${update.completedCriteria?.length ? `### Completed Criteria
${update.completedCriteria.map(c => `- ✅ ${c}`).join('\n')}` : ''}

${update.filesModified?.length ? `### Files Modified
${update.filesModified.map(f => `- \`${f}\``).join('\n')}` : ''}

${update.blockers?.length ? `### Blockers
${update.blockers.map(b => `- 🚫 ${b}`).join('\n')}` : ''}`,
  })

  // Update issue state based on status
  if (update.status === 'started' || update.status === 'in_progress') {
    const states = await getWorkflowStates(linear, issueId)
    const inProgressState = states.find(s => s.name === 'In Progress')
    if (inProgressState) {
      await linear.updateIssue(issueId, { stateId: inProgressState.id })
    }
  }

  if (update.status === 'complete') {
    const states = await getWorkflowStates(linear, issueId)
    const doneState = states.find(s => s.type === 'completed')
    if (doneState) {
      await linear.updateIssue(issueId, { stateId: doneState.id })
    }
  }
}
```

### 4. Agent Dashboard

```typescript
async function getAgentTaskDashboard(linear: LinearClient, teamId: string) {
  const issues = await linear.issues({
    filter: {
      team: { id: { eq: teamId } },
      labels: { name: { eq: 'agent-task' } },
    },
    orderBy: LinearDocument.PaginationOrderBy.UpdatedAt,
  })

  const byStatus: Record<string, typeof issues.nodes> = {
    backlog: [],
    in_progress: [],
    blocked: [],
    completed: [],
  }

  for (const issue of issues.nodes) {
    const stateType = issue.state?.type || 'backlog'
    if (stateType === 'started') {
      byStatus.in_progress.push(issue)
    } else if (stateType === 'completed' || stateType === 'canceled') {
      byStatus.completed.push(issue)
    } else {
      byStatus.backlog.push(issue)
    }
  }

  // Check for blocked (from comments)
  for (const issue of byStatus.in_progress) {
    const comments = await issue.comments()
    const lastComment = comments.nodes[0]
    if (lastComment?.body.includes('BLOCKED')) {
      byStatus.blocked.push(issue)
      byStatus.in_progress = byStatus.in_progress.filter(i => i.id !== issue.id)
    }
  }

  return {
    total: issues.nodes.length,
    backlog: byStatus.backlog.length,
    inProgress: byStatus.in_progress.length,
    blocked: byStatus.blocked.length,
    completed: byStatus.completed.length,
    issues: issues.nodes.map(i => ({
      id: i.id,
      identifier: i.identifier,
      title: i.title,
      state: i.state?.name,
      estimate: i.estimate,
      url: i.url,
    })),
  }
}
```

## Best Practices for Agent Tasks

1. **Atomic Scope**: One clear objective per task
2. **Explicit Files**: List exact files to modify
3. **Testable Criteria**: All criteria must be verifiable by commands
4. **Escape Hatches**: Define what to do when blocked
5. **Iteration Limits**: Always set max iterations
6. **No Judgment Calls**: Avoid subjective requirements

## Agent Task Templates by Type

| Task Type | Max Iterations | Typical Estimate |
|-----------|----------------|------------------|
| Bug fix | 15-20 | 1-3 points |
| Add validation | 15-20 | 2-3 points |
| New endpoint | 25-30 | 3-5 points |
| Refactoring | 20-30 | 3-5 points |
| Test coverage | 20-25 | 2-3 points |
| Documentation | 10-15 | 1-2 points |
