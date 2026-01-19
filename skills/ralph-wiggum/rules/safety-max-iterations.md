---
title: Iteration Limits and Safety
impact: HIGH
impactDescription: Prevents runaway loops and wasted resources
tags: safety, limits, termination
---

## Iteration Limits and Safety

Always set a maximum iteration limit. Without one, an impossible task or unclear completion criteria can cause infinite loops, wasting time and API credits.

**Incorrect (no safety limits):**

```bash
/ralph-loop:ralph-loop "Fix all the bugs in the codebase."
# No --max-iterations = potential infinite loop
# Vague goal = may never complete
```

**Correct (with safety limits and escape hatches):**

```bash
/ralph-loop:ralph-loop "Fix the login bug where users get 401 errors.

Steps:
1. Reproduce: Hit /api/login with valid credentials
2. Find the cause in auth middleware
3. Implement fix
4. Add regression test
5. Verify: Login should return 200 with token

## Escape Hatch
After 10 iterations without fix:
- Document what you've tried
- List potential root causes
- Suggest next steps for human review
- Output <promise>NEEDS_HELP</promise>

After 15 iterations (hard limit):
- Stop and summarize progress
- Output <promise>TIMED_OUT</promise>

Output <promise>FIXED</promise> when resolved." --max-iterations 15 --completion-promise "FIXED"
```

## Iteration Limit Guidelines

| Task Type | Recommended Limit | Rationale |
|-----------|-------------------|-----------|
| Bug fix | 10-20 | Should be targeted |
| Small feature | 20-30 | Moderate complexity |
| Large feature | 30-50 | Multiple components |
| Refactoring | 15-25 | Well-defined scope |
| TDD feature | 40-60 | Test-fix cycles add iterations |

## Escape Hatch Patterns

### Soft Limit (Warning)

```markdown
## At 50% of max iterations
If [completion criteria] not met after [N/2] iterations:
- List what's working
- List what's blocking progress
- Assess if goal is achievable
- Continue if progress is being made
```

### Hard Limit (Termination)

```markdown
## At max iterations
If [completion criteria] not met:
- Save all progress
- Document blocking issues
- List attempted approaches
- Provide recommendations
- Output <promise>TIMED_OUT</promise>
```

### Blocked Detection

```markdown
## If same error occurs 3 times in a row
- You may be in a loop
- Try a completely different approach
- If no alternatives, output <promise>STUCK</promise>
```

## Cost Awareness

```markdown
## API Cost Tracking
Approximate cost per iteration: $0.05 - $0.50 (varies by context size)

| Iterations | Estimated Cost |
|------------|----------------|
| 10         | $0.50 - $5     |
| 30         | $1.50 - $15    |
| 50         | $2.50 - $25    |
| 100        | $5 - $50       |

Set limits accordingly based on task value.
```

## Pre-Loop Checklist

Before starting a Ralph loop:

- [ ] Is the task clearly defined?
- [ ] Are completion criteria verifiable?
- [ ] Is there a test or command to check success?
- [ ] Is --max-iterations set appropriately?
- [ ] Is there an escape hatch for getting stuck?
- [ ] Has the prompt been tested manually first?
