---
name: ralph-wiggum
description: Iterative AI development loops for persistent code generation. Use when running autonomous coding sessions, overnight development, TDD loops, or any task requiring iteration until completion. Triggers on "run until done", "iterate until passing", "autonomous coding", "overnight development", "TDD loop", "keep trying until it works".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# Ralph Wiggum - AI Loop Technique

An iterative AI development methodology for persistent, self-referential development loops. Named after The Simpsons character, it embodies the philosophy of persistent iteration despite setbacks.

## Core Philosophy

| Principle | Description |
|-----------|-------------|
| **Iteration > Perfection** | Don't aim for perfect on first try. Let the loop refine the work. |
| **Failures Are Data** | Deterministically bad means failures are predictable and informative. |
| **Operator Skill Matters** | Success depends on writing good prompts, not just having a good model. |
| **Persistence Wins** | Keep trying until success. The loop handles retry logic automatically. |

## When to Apply

Use Ralph Wiggum when:
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (e.g., getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)
- Overnight/weekend automated development
- TDD workflows requiring repeated test-fix cycles
- Bug fixing with clear reproduction steps

## When NOT to Use

Skip Ralph Wiggum for:
- Tasks requiring human judgment or design decisions
- One-shot operations that need immediate results
- Tasks with unclear or subjective success criteria
- Production debugging (use targeted debugging instead)
- Tasks requiring external approvals or human-in-the-loop

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Prompt Engineering | CRITICAL | `prompt-` |
| 2 | Completion Criteria | CRITICAL | `completion-` |
| 3 | Safety Controls | HIGH | `safety-` |
| 4 | Advanced Patterns | MEDIUM | `advanced-` |

## Quick Reference

### 1. Prompt Engineering (CRITICAL)

- `prompt-completion-criteria` - Define clear, verifiable completion conditions
- `prompt-incremental-goals` - Break complex tasks into phases
- `prompt-self-correction` - Include test-fix-verify patterns

### 2. Completion Criteria (CRITICAL)

- `completion-promise` - Use exact string matching for completion signals
- `completion-verification` - Include automated verification steps

### 3. Safety Controls (HIGH)

- `safety-max-iterations` - Always set iteration limits
- `safety-escape-hatches` - Document what to do when stuck

### 4. Advanced Patterns (MEDIUM)

- `advanced-parallel-loops` - Git worktrees for parallel development
- `advanced-batch-overnight` - Queue work for unattended execution

## Essential Patterns

### The Basic Loop

```bash
# Simplest form - repeat prompt until completion
while :; do cat PROMPT.md | claude ; done
```

### Plugin Commands (Claude Code)

```bash
# Install the plugin
/plugin install ralph-loop@claude-plugins-official

# Start a loop
/ralph-loop:ralph-loop "Build a hello world API" --completion-promise "DONE" --max-iterations 10

# Cancel active loop
/ralph-loop:cancel-ralph

# Get help
/ralph-loop:help
```

### Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `--max-iterations <n>` | Stop after N iterations (safety net) | unlimited |
| `--completion-promise "<text>"` | Phrase that signals completion (exact match) | none |

## Prompt Writing Best Practices

### 1. Clear Completion Criteria

**Bad:**

```
Build a todo API and make it good.
```

**Good:**

```markdown
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

### 2. Incremental Goals

**Bad:**

```
Create a complete e-commerce platform.
```

**Good:**

```markdown
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

### 3. Self-Correction Pattern

**Bad:**

```
Write code for feature X.
```

**Good:**

```markdown
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

## Ready-to-Use Templates

### Feature Implementation

```bash
/ralph-loop:ralph-loop "Implement [FEATURE_NAME].

Requirements:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

Success criteria:
- All requirements implemented
- Tests passing with >80% coverage
- No linter errors
- Documentation updated

Output <promise>COMPLETE</promise> when done." --max-iterations 30 --completion-promise "COMPLETE"
```

### TDD Development

```bash
/ralph-loop:ralph-loop "Implement [FEATURE] using TDD.

Process:
1. Write failing test for next requirement
2. Implement minimal code to pass
3. Run tests
4. If failing, fix and retry
5. Refactor if needed
6. Repeat for all requirements

Requirements: [LIST]

Output <promise>DONE</promise> when all tests green." --max-iterations 50 --completion-promise "DONE"
```

### Bug Fixing

```bash
/ralph-loop:ralph-loop "Fix bug: [DESCRIPTION]

Steps:
1. Reproduce the bug
2. Identify root cause
3. Implement fix
4. Write regression test
5. Verify fix works
6. Check no new issues introduced

After 15 iterations if not fixed:
- Document blocking issues
- List attempted approaches
- Suggest alternatives

Output <promise>FIXED</promise> when resolved." --max-iterations 20 --completion-promise "FIXED"
```

### Refactoring

```bash
/ralph-loop:ralph-loop "Refactor [COMPONENT] for [GOAL].

Constraints:
- All existing tests must pass
- No behavior changes
- Incremental commits

Checklist:
- [ ] Tests passing before start
- [ ] Apply refactoring step
- [ ] Tests still passing
- [ ] Repeat until done

Output <promise>REFACTORED</promise> when complete." --max-iterations 25 --completion-promise "REFACTORED"
```

## Advanced Patterns

### Parallel Development with Git Worktrees

Run multiple Ralph loops simultaneously on different branches:

```bash
# Create isolated worktrees for parallel development
git worktree add ../project-feature1 -b feature/auth
git worktree add ../project-feature2 -b feature/api

# Terminal 1: Auth feature
cd ../project-feature1
/ralph-loop:ralph-loop "Implement authentication..." --max-iterations 30

# Terminal 2: API feature (simultaneously)
cd ../project-feature2
/ralph-loop:ralph-loop "Build REST API..." --max-iterations 30
```

### Multi-Phase Development

Chain multiple Ralph loops for complex projects:

```bash
# Phase 1: Core implementation
/ralph-loop:ralph-loop "Phase 1: Build core data models and database schema.
Output <promise>PHASE1_DONE</promise>" --max-iterations 20

# Phase 2: API layer
/ralph-loop:ralph-loop "Phase 2: Build API endpoints for existing models.
Output <promise>PHASE2_DONE</promise>" --max-iterations 25

# Phase 3: Frontend
/ralph-loop:ralph-loop "Phase 3: Build UI components.
Output <promise>PHASE3_DONE</promise>" --max-iterations 30
```

### Overnight Batch Processing

Queue up work to run while you sleep:

```bash
#!/bin/bash
# overnight-work.sh

cd /path/to/project1
claude -p "/ralph-loop:ralph-loop 'Task 1...' --max-iterations 50"

cd /path/to/project2
claude -p "/ralph-loop:ralph-loop 'Task 2...' --max-iterations 50"
```

```bash
chmod +x overnight-work.sh
./overnight-work.sh
```

## Prompt Tuning Technique

1. **Start with no guardrails** - Let Ralph build the playground first
2. **Add signs when Ralph fails** - When Ralph falls off the slide, add a sign saying "SLIDE DOWN, DON'T JUMP"
3. **Iterate on failures** - Each failure teaches you what guardrails to add
4. **Eventually get a new Ralph** - Once prompts are tuned, the defects disappear

## Safety Guidelines

| Safety Measure | Why It Matters |
|----------------|----------------|
| Always use `--max-iterations` | Prevents infinite loops on impossible tasks |
| Include stuck handling | Document what to do after N failed iterations |
| Use exact completion strings | `--completion-promise` uses exact string matching |
| Test prompts manually first | Validate the task is achievable before automating |

## Real-World Results

| Achievement | Details |
|-------------|---------|
| 6 repos at YC Hackathon | Successfully generated 6 repositories overnight |
| $50k contract for $297 | One contract completed, tested, and reviewed for $297 in API costs |
| CURSED Language | Created an entire programming language over 3 months |

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| No iteration limit | Infinite loops | Always set `--max-iterations` |
| Vague completion criteria | Never terminates | Use specific, verifiable conditions |
| Combining multiple queries | Search confusion | One goal per prompt |
| No verification step | False positives | Include test/lint/check steps |
| Human judgment required | Loop can't decide | Use for objective tasks only |

## How to Use

For detailed explanations of each pattern, read the rule files:

```
rules/prompt-completion-criteria.md
rules/prompt-incremental-goals.md
rules/prompt-self-correction.md
rules/advanced-parallel-loops.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect approach example
- Correct approach example
- Additional tips and gotchas

## Resources

- [Awesome Claude - Ralph Wiggum](https://awesomeclaude.ai/ralph-wiggum)
- [Official Plugin Repository](https://github.com/anthropics/claude-code-plugins)
- [Geoffrey Huntley's Blog](https://ghuntley.com) - Original technique creator
