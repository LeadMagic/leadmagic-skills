---
title: Clear Completion Criteria
impact: CRITICAL
impactDescription: Determines whether the loop terminates successfully
tags: prompt, completion, termination
---

## Clear Completion Criteria

The most important aspect of a Ralph loop prompt is defining exactly when the task is complete. Without clear criteria, the loop either never terminates or terminates prematurely.

**Incorrect (vague criteria):**

```markdown
Build a todo API and make it good.

Let me know when you're done.
```

Problems:
- "Good" is subjective
- No verification steps
- No specific completion signal

**Correct (specific, verifiable criteria):**

```markdown
Build a REST API for todos with the following endpoints:
- GET /todos - List all todos
- GET /todos/:id - Get single todo
- POST /todos - Create todo
- PATCH /todos/:id - Update todo
- DELETE /todos/:id - Delete todo

Completion criteria (ALL must be true):
1. All 5 endpoints return correct status codes
2. Input validation rejects invalid payloads
3. All tests pass: `npm test` exits with code 0
4. No TypeScript errors: `npm run typecheck` exits with code 0
5. Coverage > 80%: Check coverage report

When ALL criteria are met, output exactly:
<promise>COMPLETE</promise>

If after 10 iterations any criterion fails, output:
<promise>BLOCKED</promise>
And list which criteria are failing.
```

## Key Principles

1. **Quantifiable conditions** - "Coverage > 80%" not "good coverage"
2. **Verifiable commands** - Include the exact commands to run
3. **Exit codes matter** - Check for `exit code 0` explicitly
4. **Exact completion string** - Use `<promise>` tags for reliable matching
5. **Failure handling** - Define what to do when stuck

## Completion Signal Patterns

```markdown
# Simple completion
Output <promise>DONE</promise> when complete.

# Multi-phase completion
Output <promise>PHASE1_COMPLETE</promise> after phase 1.
Output <promise>PHASE2_COMPLETE</promise> after phase 2.
Output <promise>ALL_COMPLETE</promise> when all phases done.

# Conditional completion
If successful: <promise>SUCCESS</promise>
If blocked: <promise>BLOCKED: [reason]</promise>
```

## Verification Checklist Template

```markdown
## Verification Steps (run in order)

1. [ ] `npm run lint` - No errors
2. [ ] `npm run typecheck` - No errors  
3. [ ] `npm test` - All tests pass
4. [ ] `npm run build` - Build succeeds
5. [ ] Manual smoke test of main feature

Run these checks before claiming completion.
If any fail, fix the issue and re-verify all steps.
```
