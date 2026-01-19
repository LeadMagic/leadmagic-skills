---
title: Parallel Development with Git Worktrees
impact: MEDIUM
impactDescription: 2-3× throughput for independent features
tags: advanced, git, parallel, worktrees
---

## Parallel Development with Git Worktrees

Run multiple Ralph loops simultaneously by using Git worktrees. Each worktree is an isolated copy of your repo at a different branch, allowing truly parallel development.

**Incorrect (sequential development):**

```bash
# One feature at a time, waiting for each to complete
/ralph-loop:ralph-loop "Implement auth feature..." --max-iterations 30
# Wait 2 hours...
/ralph-loop:ralph-loop "Implement API feature..." --max-iterations 30
# Wait 2 hours...
```

**Correct (parallel with worktrees):**

```bash
# Setup: Create isolated worktrees for each feature
git worktree add ../myproject-auth -b feature/auth
git worktree add ../myproject-api -b feature/api
git worktree add ../myproject-ui -b feature/ui

# Terminal 1: Auth feature
cd ../myproject-auth
/ralph-loop:ralph-loop "Implement authentication:
- User registration
- Login/logout
- JWT tokens
- Password reset

Tests: npm test -- --grep auth
Output <promise>AUTH_DONE</promise>" --max-iterations 30

# Terminal 2: API feature (simultaneously)
cd ../myproject-api
/ralph-loop:ralph-loop "Build REST API:
- CRUD endpoints for resources
- Input validation
- Error handling

Tests: npm test -- --grep api
Output <promise>API_DONE</promise>" --max-iterations 30

# Terminal 3: UI components (simultaneously)
cd ../myproject-ui
/ralph-loop:ralph-loop "Create UI components:
- Form components
- Table components
- Modal system

Tests: npm test -- --grep components
Output <promise>UI_DONE</promise>" --max-iterations 30
```

## Worktree Management

```bash
# List all worktrees
git worktree list

# Create a worktree
git worktree add <path> -b <branch-name>

# Remove a worktree (after merging)
git worktree remove <path>

# Clean up stale worktrees
git worktree prune
```

## Best Practices for Parallel Loops

1. **Independent Features Only**
   - Features must not depend on each other
   - No shared state changes during development
   - Merge conflicts resolved at the end

2. **Separate Test Scopes**
   - Each loop should run different tests
   - Use `--grep` to isolate test suites
   - Avoid running full test suite until merge

3. **Resource Considerations**
   - Each loop uses API tokens
   - Monitor rate limits across instances
   - Consider staggered start times

4. **Merge Strategy**
   ```bash
   # After all loops complete
   git checkout main
   git merge feature/auth
   git merge feature/api
   git merge feature/ui
   
   # Run full test suite to catch integration issues
   npm test
   ```

## Dependency Graph Template

```markdown
## Feature Dependencies

```
feature/auth ──────┐
                   ├──→ feature/dashboard (depends on auth)
feature/api ───────┘
                   
feature/ui ────────────→ Can run independently
```

## Parallel Opportunities
- auth + api can run in parallel (no dependencies)
- ui can run in parallel with both
- dashboard must wait for auth + api

## Execution Plan
Round 1 (parallel): auth, api, ui
Round 2 (sequential): dashboard (after auth + api merge)
```

## Monitoring Multiple Loops

```bash
# Watch all worktree directories for changes
watch -n 5 'for dir in ../myproject-*; do echo "=== $dir ==="; tail -5 "$dir/.ralph-log" 2>/dev/null || echo "No log"; done'

# Check status of all branches
git branch -a --list 'feature/*' -v
```
