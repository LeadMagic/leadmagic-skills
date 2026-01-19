---
title: Incremental Goals
impact: CRITICAL
impactDescription: Prevents overwhelming the model with too much scope
tags: prompt, phases, incremental, scope
---

## Incremental Goals

Large tasks should be broken into phases. Each phase should be completable in a reasonable number of iterations with clear intermediate checkpoints.

**Incorrect (overwhelming scope):**

```markdown
Create a complete e-commerce platform with user authentication,
product catalog, shopping cart, checkout flow, payment processing,
order management, admin dashboard, and email notifications.
```

Problems:
- Too many concerns at once
- No clear order of operations
- Impossible to verify partial progress
- Model gets confused about priorities

**Correct (phased approach):**

```markdown
Build an e-commerce platform in phases. Complete each phase before
moving to the next. Each phase must have passing tests.

## Phase 1: User Authentication
- [ ] User registration with email/password
- [ ] Login/logout functionality
- [ ] Password reset flow
- [ ] Tests for all auth endpoints

Checkpoint: `npm test -- --grep "auth"` passes
Output <promise>PHASE1_DONE</promise>

## Phase 2: Product Catalog
- [ ] Product model with CRUD operations
- [ ] Category and tag support
- [ ] Search and filtering
- [ ] Pagination

Checkpoint: `npm test -- --grep "product"` passes
Output <promise>PHASE2_DONE</promise>

## Phase 3: Shopping Cart
- [ ] Add/remove items
- [ ] Update quantities
- [ ] Calculate totals
- [ ] Persist cart state

Checkpoint: `npm test -- --grep "cart"` passes
Output <promise>PHASE3_DONE</promise>

## Final Completion
When all phases complete: <promise>ALL_PHASES_COMPLETE</promise>
```

## Phase Design Principles

1. **Each phase is independently verifiable** - Has its own tests
2. **Phases build on each other** - Clear dependencies
3. **3-5 tasks per phase** - Manageable scope
4. **Checkpoint after each phase** - Verify before continuing

## Scope Sizing Guide

| Phase Size | Typical Iterations | Recommended |
|------------|-------------------|-------------|
| 1-2 tasks | 5-10 | Too small, combine |
| 3-5 tasks | 10-20 | Ideal |
| 6-10 tasks | 20-30 | Consider splitting |
| 10+ tasks | 30+ | Too large, split |

## Phase Dependency Template

```markdown
## Dependencies
- Phase 2 requires Phase 1 (auth needed for user context)
- Phase 3 requires Phase 2 (cart needs products)
- Phase 4 can run parallel to Phase 3 (independent feature)

## Execution Order
Sequential: Phase 1 → Phase 2 → Phase 3
Parallel opportunity: Phase 3 and Phase 4 after Phase 2
```
