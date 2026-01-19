---
title: Self-Correction Pattern
impact: CRITICAL
impactDescription: Enables the loop to fix its own mistakes
tags: prompt, tdd, debugging, iteration
---

## Self-Correction Pattern

The most powerful Ralph prompts include explicit instructions for detecting and fixing errors. This creates a feedback loop where failures lead to corrections.

**Incorrect (no feedback loop):**

```markdown
Write code for the user authentication feature.
Make sure it works correctly.
```

Problems:
- No verification step
- No instructions for handling failures
- Model may claim success without testing

**Correct (explicit test-fix cycle):**

```markdown
Implement user authentication following TDD:

## Process (repeat until all tests green)

1. **Write Test First**
   - Write a failing test for the next requirement
   - Run `npm test` - confirm it fails (expected)

2. **Implement Feature**
   - Write minimal code to pass the test
   - Run `npm test` - check result

3. **If Tests Fail**
   - Read the error message carefully
   - Identify the root cause
   - Fix the code (not the test, unless test is wrong)
   - Run `npm test` again
   - Repeat until passing

4. **If Tests Pass**
   - Run `npm run lint` - fix any issues
   - Run `npm run typecheck` - fix any type errors
   - Move to next requirement

5. **Refactor (Optional)**
   - If code is messy, refactor
   - Re-run all tests to confirm no regressions

## Requirements
1. User registration with email validation
2. Password hashing with bcrypt
3. Login returns JWT token
4. Protected route middleware

## Completion
When all 4 requirements have passing tests:
<promise>COMPLETE</promise>
```

## The Debug Loop

```markdown
## When Something Breaks

1. Read the FULL error message
2. Identify the file and line number
3. Check the relevant code
4. Form a hypothesis about the cause
5. Make ONE targeted fix
6. Re-run the failing command
7. If still failing, go to step 1
8. If passing, run full test suite to check for regressions
```

## Error Recovery Template

```markdown
## Error Handling Protocol

### On Test Failure
- Do NOT skip the test
- Do NOT modify the test unless it's genuinely wrong
- Fix the implementation to match the expected behavior

### On Lint Error
- Fix the lint error immediately
- Do not disable the rule unless absolutely necessary
- If disabling, add a comment explaining why

### On Type Error
- Fix the types, don't use `any`
- If stuck on types, add a TODO comment and continue
- Return to fix types before completion

### On Build Failure
- Check for missing imports
- Check for circular dependencies
- Verify all files are saved

### After 5 Failed Attempts on Same Error
- Document what you've tried
- Look for alternative approaches
- Consider if requirements need clarification
```

## Verification Commands Template

```markdown
## Commands to Run After Each Change

```bash
# Quick check (run after every code change)
npm run typecheck && npm test

# Full check (run before claiming completion)
npm run lint && npm run typecheck && npm test && npm run build
```

Always run the full check before outputting the completion signal.
```
