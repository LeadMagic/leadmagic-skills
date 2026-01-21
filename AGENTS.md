# LeadMagic Skills - Agent Instructions

This file provides guidance to AI coding agents (Claude, Cursor, Copilot, etc.) when working with LeadMagic codebases.

## Overview

This repository contains **52 Claude Skills** for building production applications with the LeadMagic stack:

| Layer | Technologies |
|-------|--------------|
| **Edge Platform** | Cloudflare Workers, D1, KV, R2, Durable Objects, Workflows |
| **API Framework** | Hono v4 |
| **Frontend** | Next.js 16, React 19, TypeScript |
| **UI** | shadcn/ui, Tailwind v4 |
| **AI** | Vercel AI SDK, Cloudflare AI Gateway |

---

## Skills Reference (52 Total)

### Cloudflare Platform (10)

| Skill | Use When |
|-------|----------|
| `cloudflare-workers` | Creating Workers, handling requests, bindings |
| `cloudflare-d1` | SQLite database queries, schema design |
| `cloudflare-kv` | Key-value storage, caching, sessions |
| `cloudflare-r2` | Object storage, file uploads, streaming |
| `cloudflare-durable-objects` | Real-time features, WebSockets, state |
| `cloudflare-workflows` | Background jobs, orchestration, events |
| `cloudflare-ai-gateway` | LLM routing, caching, rate limiting |
| `cloudflare-observability` | Workers logs, Logpush, OTel export |
| `hono-v4` | Building APIs, routes, middleware |
| `wrangler` | Configuration, deployment, local dev |

### Data & State (5)

| Skill | Use When |
|-------|----------|
| `drizzle-orm` | Type-safe ORM, schemas, migrations |
| `tanstack-query` | Server state, data fetching, caching |
| `tanstack-table` | Data tables, sorting, filtering, pagination |
| `zustand` | Global state management, stores |
| `upstash` | Redis, QStash, rate limiting |

### Authentication (4)

| Skill | Use When |
|-------|----------|
| `authentication` | Auth patterns overview, JWT, sessions |
| `clerk` | Clerk auth, organizations, webhooks |
| `better-auth` | Self-hosted auth, framework-agnostic |
| `security-best-practices` | Input validation, CSRF, XSS prevention |

### Frontend & UI (7)

| Skill | Use When |
|-------|----------|
| `react-best-practices` | React 19 patterns, performance |
| `nextjs-app-router` | App Router, Server Components, Actions |
| `typescript-best-practices` | Type safety, strict mode, patterns |
| `ui-development` | Component patterns, Framer Motion |
| `shadcn-ui` | shadcn/ui components, theming |
| `tailwind-v4` | CSS-first config, OKLCH, theme tokens |
| `caching-strategies` | Next.js caching, SWR, Cache API |

### Forms & Validation (2)

| Skill | Use When |
|-------|----------|
| `zod` | Schema validation, type inference |
| `react-hook-form` | Form handling, validation patterns |

### Backend Services (7)

| Skill | Use When |
|-------|----------|
| `api-development` | REST design, versioning, rate limiting |
| `stripe-payments` | Payments, subscriptions, webhooks |
| `resend` | Email sending, React Email templates |
| `inngest` | Durable workflows, background jobs |
| `tinybird` | Real-time analytics, ClickHouse APIs |
| `env-variables` | Environment configuration, secrets |
| `doppler` | Secrets management across environments |

### Observability (5)

| Skill | Use When |
|-------|----------|
| `logging-best-practices` | Wide events, structured logging |
| `error-handling` | Error boundaries, API errors |
| `sentry` | Error tracking, performance monitoring |
| `axiom` | Log analytics, APL queries |
| `opentelemetry` | Distributed tracing, spans, metrics |

### Quality & Tooling (3)

| Skill | Use When |
|-------|----------|
| `testing-best-practices` | Vitest, Testing Library, Playwright |
| `biome` | Fast linting/formatting, ESLint replacement |
| `monorepo` | Turborepo, pnpm workspaces |

### AI & Automation (3)

| Skill | Use When |
|-------|----------|
| `vercel-ai-sdk` | AI streaming, tools, chat interfaces |
| `ralph-wiggum` | Iterative AI loops, autonomous coding |
| `linear` | Project management, agent task assignment |

### Design System (5)

| Skill | Use When |
|-------|----------|
| `design-principles` | UX heuristics, visual design systems |
| `design-review` | UI code review checklist |
| `design-antipatterns` | Common UI/UX mistakes to avoid |
| `design-lab` | Structured design exploration workflow |
| `web-design-guidelines` | Vercel design guidelines |

### Deployment (1)

| Skill | Use When |
|-------|----------|
| `vercel-deploy-claimable` | Deploy to Vercel with claimable link |

---

## Quick Lookup by Task

| Task | Skills |
|------|--------|
| **Build an API** | `hono-v4`, `api-development`, `cloudflare-workers` |
| **Add authentication** | `clerk`, `better-auth`, `authentication` |
| **Create a form** | `react-hook-form`, `zod`, `shadcn-ui` |
| **Build a data table** | `tanstack-table`, `tanstack-query` |
| **Add payments** | `stripe-payments` |
| **Send emails** | `resend` |
| **Background jobs** | `inngest`, `cloudflare-workflows` |
| **Real-time features** | `cloudflare-durable-objects`, `upstash` |
| **Error tracking** | `sentry`, `error-handling` |
| **Style components** | `tailwind-v4`, `shadcn-ui`, `ui-development` |
| **AI features** | `vercel-ai-sdk`, `cloudflare-ai-gateway` |

---

## Creating a New Skill

### Directory Structure

```
skills/
  {skill-name}/           # kebab-case directory name
    SKILL.md              # Required: skill definition
    rules/                # Optional: detailed rule files
      {rule-name}.md      # Individual rules with examples
    scripts/              # Optional: executable scripts
      {script-name}.sh    # Bash scripts (preferred)
```

### Naming Conventions

| Item | Format | Example |
|------|--------|---------|
| Skill directory | `kebab-case` | `hono-v4`, `cloudflare-d1` |
| SKILL.md | Uppercase | `SKILL.md` |
| Rules | `prefix-name.md` | `types-env-bindings.md` |
| Scripts | `kebab-case.sh` | `deploy.sh` |

---

## SKILL.md Format

```markdown
---
name: {skill-name}
description: {One sentence. Include trigger phrases.}
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# {Skill Title}

{Brief description.}

## When to Apply

Reference these guidelines when:
- Scenario 1
- Scenario 2

## Quick Reference

{Concise patterns and code examples}

## How to Use

Read individual rule files for details:
- `rules/pattern-name.md`
```

### Rule File Format

```markdown
---
title: Rule Title
impact: CRITICAL | HIGH | MEDIUM | LOW
tags: tag1, tag2
---

## Rule Title

{Why this matters.}

**Incorrect:**
```typescript
// Bad example
```

**Correct:**
```typescript
// Good example
```
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Keep SKILL.md under 500 lines | Put details in rules/ files |
| Write specific descriptions | Helps agent know when to activate |
| Use progressive disclosure | Reference files read only when needed |
| Prioritize by impact | CRITICAL > HIGH > MEDIUM > LOW |

---

## Installation

**Claude Code / Cursor:**

```bash
./install.sh
# Or: cp -r skills/{skill-name} ~/.claude/skills/
```

**claude.ai:**

Upload skill `.zip` to project knowledge or paste `SKILL.md` contents.
