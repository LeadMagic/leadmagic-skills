---
title: Issue Templates
impact: CRITICAL
impactDescription: Ensures consistent, actionable issues
tags: issues, templates, structure, documentation
---

## Issue Templates

Well-structured issues reduce ambiguity and improve execution speed. Use templates to ensure consistency across your team and agents.

**Incorrect (vague issue):**

```typescript
await linear.createIssue({
  teamId: 'TEAM_ID',
  title: 'Fix login',
  description: 'Login is broken'
})
```

Problems:
- No reproduction steps
- No expected vs actual behavior
- No acceptance criteria

**Correct (structured issue):**

```typescript
await linear.createIssue({
  teamId: 'TEAM_ID',
  title: '[Bug] Login returns 500 error for SSO users',
  description: `## Description
SSO users receive a 500 Internal Server Error when attempting to log in via Google OAuth.

## Steps to Reproduce
1. Go to /login
2. Click "Sign in with Google"
3. Complete Google OAuth flow
4. Observe 500 error on redirect

## Expected Behavior
User should be logged in and redirected to dashboard.

## Actual Behavior
500 error page displayed. No user session created.

## Environment
- Browser: Chrome 120
- OS: macOS 14.2
- Environment: Production

## Error Logs
\`\`\`
Error: Cannot read property 'email' of undefined
    at GoogleOAuthHandler.callback (auth.ts:145)
\`\`\`

## Acceptance Criteria
- [ ] SSO login completes successfully
- [ ] User session is created
- [ ] Regression test added`,
  priority: 1, // Urgent
  labelIds: ['bug-label-id', 'auth-label-id'],
})
```

## Standard Templates

### Feature Request

```typescript
const featureTemplate = (data: {
  title: string
  problem: string
  solution: string
  userStory: string
  requirements: string[]
  outOfScope?: string[]
}) => `## User Story
${data.userStory}

## Problem
${data.problem}

## Proposed Solution
${data.solution}

## Requirements
${data.requirements.map(r => `- [ ] ${r}`).join('\n')}

${data.outOfScope ? `## Out of Scope
${data.outOfScope.map(o => `- ${o}`).join('\n')}` : ''}

## Design
_Link to Figma/design specs_

## Technical Approach
_To be filled during refinement_

## Acceptance Criteria
_To be derived from requirements_`
```

### Technical Task

```typescript
const technicalTemplate = (data: {
  title: string
  context: string
  approach: string
  tasks: string[]
  testPlan: string[]
  rollback?: string
}) => `## Context
${data.context}

## Technical Approach
${data.approach}

## Tasks
${data.tasks.map(t => `- [ ] ${t}`).join('\n')}

## Test Plan
${data.testPlan.map(t => `- [ ] ${t}`).join('\n')}

${data.rollback ? `## Rollback Plan
${data.rollback}` : ''}

## Documentation
- [ ] README updated
- [ ] API docs updated (if applicable)
- [ ] Runbook updated (if applicable)`
```

### Agent Task

```typescript
const agentTaskTemplate = (data: {
  objective: string
  context: string[]
  files: string[]
  constraints: string[]
  completionCriteria: string[]
  maxIterations: number
}) => `## Objective
${data.objective}

## Context
${data.context.map(c => `- ${c}`).join('\n')}

## Files to Modify
${data.files.map(f => `- \`${f}\``).join('\n')}

## Constraints
${data.constraints.map(c => `- ${c}`).join('\n')}

## Completion Criteria
${data.completionCriteria.map(c => `- [ ] ${c}`).join('\n')}

## Agent Configuration
- **Max Iterations:** ${data.maxIterations}
- **Completion Signal:** \`<promise>COMPLETE</promise>\`
- **Blocked Signal:** \`<promise>BLOCKED: [reason]</promise>\`

## Verification Commands
\`\`\`bash
npm run lint && npm run typecheck && npm test
\`\`\`

## Progress Log
_Agent updates progress here_`
```

### Spike/Research

```typescript
const spikeTemplate = (data: {
  question: string
  background: string
  areas: string[]
  timebox: string
  deliverables: string[]
}) => `## Research Question
${data.question}

## Background
${data.background}

## Areas to Investigate
${data.areas.map(a => `- [ ] ${a}`).join('\n')}

## Timebox
${data.timebox}

## Deliverables
${data.deliverables.map(d => `- [ ] ${d}`).join('\n')}

## Findings
_To be updated during research_

## Recommendation
_Final recommendation based on findings_`
```

## Template Factory

```typescript
type TemplateType = 'feature' | 'bug' | 'task' | 'agent' | 'spike'

function createIssueFromTemplate(
  type: TemplateType,
  data: any,
  teamId: string
) {
  const templates: Record<TemplateType, (d: any) => { title: string; description: string; labels: string[] }> = {
    feature: (d) => ({
      title: `[Feature] ${d.title}`,
      description: featureTemplate(d),
      labels: ['feature'],
    }),
    bug: (d) => ({
      title: `[Bug] ${d.title}`,
      description: bugTemplate(d),
      labels: ['bug'],
    }),
    task: (d) => ({
      title: `[Task] ${d.title}`,
      description: technicalTemplate(d),
      labels: ['task'],
    }),
    agent: (d) => ({
      title: `[Agent] ${d.title}`,
      description: agentTaskTemplate(d),
      labels: ['agent-task'],
    }),
    spike: (d) => ({
      title: `[Spike] ${d.title}`,
      description: spikeTemplate(d),
      labels: ['spike', 'research'],
    }),
  }

  const template = templates[type](data)

  return {
    teamId,
    title: template.title,
    description: template.description,
    labelIds: template.labels.map(l => getLabelId(l)),
  }
}
```
