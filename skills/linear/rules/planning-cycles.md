---
title: Sprint/Cycle Planning
impact: HIGH
impactDescription: Enables predictable delivery and capacity management
tags: planning, cycles, sprints, capacity
---

## Sprint/Cycle Planning

Cycles (Linear's term for sprints) help organize work into time-boxed iterations. Proper cycle planning ensures realistic commitments and steady progress.

**Incorrect (no planning, ad-hoc):**

```typescript
// Just dump issues into a cycle without planning
for (const issue of allBacklogIssues) {
  await linear.updateIssue(issue.id, { cycleId: currentCycle.id })
}
```

Problems:
- No capacity consideration
- No priority ordering
- Risk of overcommitment

**Correct (capacity-based planning):**

```typescript
async function planCycle(
  linear: LinearClient,
  teamId: string,
  config: {
    name: string
    startDate: string
    endDate: string
    teamCapacity: number // Story points
    priorities: string[] // Must-have issue IDs
    goals: string[]
  }
) {
  // 1. Create cycle with clear goals
  const cycle = await linear.createCycle({
    teamId,
    name: config.name,
    startsAt: config.startDate,
    endsAt: config.endDate,
    description: `## Sprint Goals
${config.goals.map(g => `- ${g}`).join('\n')}

## Capacity
- Team capacity: ${config.teamCapacity} points
- Target commitment: ${Math.floor(config.teamCapacity * 0.8)} points (80%)

## Focus Areas
_Derived from committed issues_`,
  })

  const cycleId = cycle.cycle?.id!
  let committedPoints = 0
  const targetCommitment = Math.floor(config.teamCapacity * 0.8)

  // 2. First, commit priority items
  for (const priorityId of config.priorities) {
    const issue = await linear.issue(priorityId)
    if (issue) {
      await linear.updateIssue(issue.id, { cycleId })
      committedPoints += issue.estimate || 0
    }
  }

  // 3. Fill remaining capacity from prioritized backlog
  const backlog = await linear.issues({
    filter: {
      team: { id: { eq: teamId } },
      cycle: { null: true },
      state: { type: { in: ['backlog', 'unstarted'] } },
    },
    orderBy: LinearDocument.PaginationOrderBy.Priority,
  })

  for (const issue of backlog.nodes) {
    const estimate = issue.estimate || 0
    if (committedPoints + estimate <= targetCommitment) {
      await linear.updateIssue(issue.id, { cycleId })
      committedPoints += estimate
    }
  }

  return {
    cycleId,
    committedPoints,
    remainingCapacity: config.teamCapacity - committedPoints,
    utilizationPercent: Math.round((committedPoints / config.teamCapacity) * 100),
  }
}
```

## Capacity Calculation

```typescript
interface TeamMember {
  id: string
  name: string
  availability: number // 0-1 (percentage)
  velocityMultiplier: number // Historical accuracy
}

function calculateTeamCapacity(
  members: TeamMember[],
  sprintDays: number,
  pointsPerPersonDay: number = 1
): number {
  return members.reduce((total, member) => {
    const memberCapacity = sprintDays * pointsPerPersonDay * member.availability * member.velocityMultiplier
    return total + memberCapacity
  }, 0)
}

// Example: 2-week sprint, 3 developers
const capacity = calculateTeamCapacity([
  { id: '1', name: 'Alice', availability: 1.0, velocityMultiplier: 1.2 },
  { id: '2', name: 'Bob', availability: 0.8, velocityMultiplier: 1.0 }, // 1 day PTO
  { id: '3', name: 'Carol', availability: 1.0, velocityMultiplier: 0.8 }, // New to team
], 10, 1)
// Result: 10*1.2 + 8*1.0 + 10*0.8 = 28 points
```

## Sprint Ceremony Automation

### Sprint Planning

```typescript
async function generateSprintPlanningAgenda(
  linear: LinearClient,
  cycleId: string
) {
  const cycle = await linear.cycle(cycleId)
  const issues = await linear.issues({
    filter: { cycle: { id: { eq: cycleId } } },
  })

  const unestimated = issues.nodes.filter(i => !i.estimate)
  const unassigned = issues.nodes.filter(i => !i.assignee)
  const totalEstimate = issues.nodes.reduce((s, i) => s + (i.estimate || 0), 0)

  return `# Sprint Planning: ${cycle?.name}

## Pre-Planning Checklist
- [ ] Review previous sprint outcomes
- [ ] Discuss carryover items
- [ ] Review team capacity

## Issues Needing Attention

### Unestimated (${unestimated.length})
${unestimated.map(i => `- ${i.identifier}: ${i.title}`).join('\n') || '_None_'}

### Unassigned (${unassigned.length})
${unassigned.map(i => `- ${i.identifier}: ${i.title}`).join('\n') || '_None_'}

## Current Commitment
- Total points: ${totalEstimate}
- Issue count: ${issues.nodes.length}

## Discussion Topics
1. Are sprint goals clear?
2. Any blockers or dependencies?
3. Any risks to commitment?`
}
```

### Sprint Review

```typescript
async function generateSprintReview(
  linear: LinearClient,
  cycleId: string
) {
  const issues = await linear.issues({
    filter: { cycle: { id: { eq: cycleId } } },
  })

  const completed = issues.nodes.filter(i => i.state?.type === 'completed')
  const incomplete = issues.nodes.filter(i => i.state?.type !== 'completed')

  const completedPoints = completed.reduce((s, i) => s + (i.estimate || 0), 0)
  const totalPoints = issues.nodes.reduce((s, i) => s + (i.estimate || 0), 0)

  return `# Sprint Review

## Summary
- **Completed:** ${completed.length} issues (${completedPoints} points)
- **Incomplete:** ${incomplete.length} issues
- **Velocity:** ${completedPoints} points
- **Completion Rate:** ${Math.round((completed.length / issues.nodes.length) * 100)}%

## Completed Work
${completed.map(i => `- ${i.identifier}: ${i.title}`).join('\n')}

## Carryover
${incomplete.map(i => `- ${i.identifier}: ${i.title} (${i.state?.name})`).join('\n') || '_None_'}

## Demo Items
_List items to demo_

## Discussion
- What went well?
- What could improve?
- Any learnings?`
}
```

## Cycle Metrics

```typescript
async function getCycleMetrics(linear: LinearClient, cycleId: string) {
  const issues = await linear.issues({
    filter: { cycle: { id: { eq: cycleId } } },
  })

  const byState = issues.nodes.reduce((acc, issue) => {
    const state = issue.state?.type || 'unknown'
    acc[state] = (acc[state] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const totalEstimate = issues.nodes.reduce((s, i) => s + (i.estimate || 0), 0)
  const completedEstimate = issues.nodes
    .filter(i => i.state?.type === 'completed')
    .reduce((s, i) => s + (i.estimate || 0), 0)

  return {
    issueCount: issues.nodes.length,
    byState,
    totalEstimate,
    completedEstimate,
    burndownPercent: Math.round((completedEstimate / totalEstimate) * 100),
    velocity: completedEstimate, // Points completed this cycle
  }
}
```

## Best Practices

1. **80% Rule**: Only commit to 80% of capacity to allow for unknowns
2. **Carryover Limit**: If >20% carries over, reassess estimation/capacity
3. **Goal-Driven**: Each cycle should have 2-3 clear, measurable goals
4. **Balance**: Mix of features, bugs, and tech debt
5. **Dependencies First**: Schedule dependent work early in the cycle
