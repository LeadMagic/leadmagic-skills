# LeadMagic Skills

Claude Skills for building production applications with the **LeadMagic Stack** — Hono v4, Cloudflare Workers, Next.js 16, React 19, and TypeScript.

[![Skills](https://img.shields.io/badge/skills-43-blue)]()
[![Internal](https://img.shields.io/badge/visibility-internal-orange)]()
[![License](https://img.shields.io/badge/license-proprietary-red)]()

## Overview

This repository contains **43 Claude Skills** that provide AI coding agents with best practices, patterns, and guidelines for building production applications. Skills are automatically loaded by Claude Code, Cursor, and other AI assistants when installed.

### What Are Skills?

Skills are structured knowledge files that teach AI agents how to write better code. Each skill contains:

- **SKILL.md** — Main instruction file (under 500 lines)
- **rules/** — Detailed patterns with correct/incorrect examples
- **scripts/** — Optional automation scripts

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/LeadMagic/leadmagic-skills.git
cd leadmagic-skills

# Install all skills to Claude
./install.sh

# Or install to a custom directory
./install.sh ./my-project/.claude/skills
```

### Verify Installation

```bash
ls ~/.claude/skills/
```

You should see all 43 skill directories.

---

## Skills Catalog (43 Total)

### Core Stack (10 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `hono-v4` | Hono v4 APIs — routes, middleware, validation, type-safe bindings | 4 |
| `cloudflare-workers` | Workers fundamentals — requests, bindings, caching | 2 |
| `cloudflare-d1` | D1 SQLite — prepared statements, batch operations | 2 |
| `cloudflare-kv` | KV storage — caching, sessions, eventual consistency | 2 |
| `cloudflare-r2` | R2 storage — uploads, streaming | 1 |
| `cloudflare-durable-objects` | Durable Objects — state, WebSockets, hibernation | 3 |
| `cloudflare-workflows` | Workflows — durable execution, steps, events | 4 |
| `cloudflare-ai-gateway` | AI Gateway — routing, caching, guardrails | 3 |
| `cloudflare-observability` | Observability — Logpush, OTel export | 2 |
| `wrangler` | Wrangler CLI — configuration, deployment | - |

### Data & Storage (5 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `drizzle-orm` | Drizzle ORM — type-safe queries, schemas | 2 |
| `tinybird` | Real-time analytics — ClickHouse APIs, pipes | 3 |
| `upstash` | QStash, Redis, Workflows, Ratelimit | 3 |
| `tanstack-query` | TanStack Query v5 — server state, caching, mutations | 7 |
| `tanstack-table` | TanStack Table v8 — sorting, filtering, pagination | 8 |

### Backend (9 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `api-development` | REST design, versioning, rate limiting, errors | 8 |
| `authentication` | Clerk, Auth.js, JWT, sessions, Workers auth | 2 |
| `caching-strategies` | Next.js caching, SWR, Cache API | - |
| `error-handling` | Error boundaries, API errors, Server Actions | 3 |
| `env-variables` | Environment variable patterns | - |
| `security-best-practices` | Input validation, CSRF, XSS, CSP | - |
| `doppler` | Secrets management across environments | 2 |
| `inngest` | Durable workflows, background jobs, event-driven | 6 |
| `stripe-payments` | Checkout, subscriptions, webhooks, billing | 4 |

### Frontend (5 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `react-best-practices` | React 19 optimization patterns | 53 |
| `nextjs-app-router` | Next.js 16 App Router — RSC, Server Actions | 2 |
| `typescript-best-practices` | TypeScript — strict mode, types, patterns | 3 |
| `ui-development` | shadcn/ui, Tailwind v4, Framer Motion | 18 |
| `vercel-ai-sdk` | AI SDK — chat, streaming, tools, agents | 10 |

### Quality (6 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `testing-best-practices` | Vitest, Testing Library, Playwright, MSW | 3 |
| `logging-best-practices` | Wide events, structured logging | 4 |
| `opentelemetry` | Distributed tracing, spans, metrics | 2 |
| `axiom` | Log analytics, APL queries | 1 |
| `monorepo` | Turborepo, pnpm workspaces | 2 |
| `biome` | Fast linting/formatting, ESLint/Prettier replacement | 4 |

### Automation & Planning (2 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `ralph-wiggum` | Iterative AI loops, autonomous coding, TDD cycles | 5 |
| `linear` | Project management, sprints, agent task assignment | 5 |

### Design (5 skills)

| Skill | Description | Rules |
|-------|-------------|-------|
| `design-principles` | UX heuristics, visual design systems | 4 |
| `design-review` | WCAG 2.1 accessibility + design constraints | - |
| `design-antipatterns` | Avoiding "AI slop" patterns | - |
| `design-lab` | Interactive design exploration workflow | - |
| `web-design-guidelines` | Vercel Web Interface Guidelines | - |

### Deployment (1 skill)

| Skill | Description | Rules |
|-------|-------------|-------|
| `vercel-deploy-claimable` | Deploy to Vercel with claimable link | - |

---

## Installation Methods

### Claude Code / Claude Desktop

```bash
# Run the install script
./install.sh

# Skills are installed to ~/.claude/skills/
```

### Cursor IDE

```bash
# Copy skills to project
mkdir -p .cursor/skills
cp -r skills/* .cursor/skills/
```

### Individual Skill

```bash
# Install a single skill
cp -r skills/hono-v4 ~/.claude/skills/
```

### claude.ai (Web)

1. Download the skill `.zip` from releases
2. Upload to Project Knowledge
3. Or paste `SKILL.md` contents directly into conversation

---

## Updating Skills

### Branch Protection

The `main` branch is protected with the following rules:

- **Require pull request reviews** — At least 1 approval required
- **Require status checks** — Validation must pass
- **No direct pushes** — All changes must go through PRs

### How to Update

1. **Create a feature branch**

```bash
git checkout -b feature/update-skill-name
```

2. **Make your changes**

```bash
# Edit existing skill
vim skills/hono-v4/SKILL.md

# Or create a new skill
mkdir -p skills/my-new-skill/rules
touch skills/my-new-skill/SKILL.md
```

3. **Validate your changes**

```bash
./scripts/validate.sh
```

4. **Commit with a descriptive message**

```bash
git add -A
git commit -m "feat(hono-v4): add new middleware pattern"
```

5. **Push and create a PR**

```bash
git push -u origin feature/update-skill-name
gh pr create --title "feat: update hono-v4 skill" --body "Description of changes"
```

6. **Get review and merge**

- Request review from a team member
- Address any feedback
- Merge after approval

### Commit Message Format

```
<type>(<scope>): <description>

Types:
- feat: New skill or feature
- fix: Bug fix or correction
- docs: Documentation only
- refactor: Code change that neither fixes nor adds
- chore: Maintenance tasks
```

---

## Creating a New Skill

### Directory Structure

```
skills/
  my-skill/                # kebab-case directory name
    SKILL.md               # Required: main skill file
    rules/                 # Optional: detailed patterns
      pattern-name.md      # Individual rule files
    scripts/               # Optional: automation
      script-name.sh       # Executable scripts
```

### SKILL.md Template

```markdown
---
name: my-skill
description: What it does. Use when X. Triggers on "keyword", "another keyword".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.0.0"
---

# My Skill Title

Brief description of what this skill covers.

## When to Apply

Reference these guidelines when:
- Scenario 1
- Scenario 2
- Scenario 3

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Category Name | CRITICAL | `prefix-` |

## Quick Reference

### 1. Category Name (CRITICAL)

- `rule-name` - Brief description

## Essential Patterns

[Code examples here]

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Bad pattern | Good pattern |
```

### Rule File Template (rules/pattern-name.md)

```markdown
---
title: Pattern Name
impact: CRITICAL | HIGH | MEDIUM | LOW
impactDescription: Brief impact (e.g., "2-10× improvement")
tags: tag1, tag2
---

## Pattern Name

Why this pattern matters.

**Incorrect:**

```typescript
// Bad example
```

**Correct:**

```typescript
// Good example
```

Additional context.
```

### Best Practices

- **Keep SKILL.md under 500 lines** — Put details in rules/
- **Write specific descriptions** — Include trigger keywords
- **Use progressive disclosure** — Link to rules for depth
- **Prioritize by impact** — CRITICAL > HIGH > MEDIUM > LOW
- **Include code examples** — Show correct AND incorrect patterns

---

## Validation

### Run Validation

```bash
./scripts/validate.sh
```

This checks:
- All skills have required `SKILL.md`
- Frontmatter is properly formatted
- Line count is under 500
- No broken rule references

### Manual Checks

```bash
# Count skills
find skills -name "SKILL.md" | wc -l

# Check skill line counts
wc -l skills/*/SKILL.md | sort -n

# Find skills with rules
find skills -type d -name "rules" | wc -l
```

---

## Development Workflow

### Local Development

```bash
# 1. Clone and enter repo
git clone https://github.com/LeadMagic/leadmagic-skills.git
cd leadmagic-skills

# 2. Create feature branch
git checkout -b feature/my-changes

# 3. Make changes
# ...

# 4. Validate
./scripts/validate.sh

# 5. Test installation
./install.sh ~/test-skills

# 6. Commit and push
git add -A
git commit -m "feat: description"
git push -u origin feature/my-changes

# 7. Create PR
gh pr create
```

### CI/CD

GitHub Actions automatically:
- Validates skill format on every PR
- Packages skills as `.zip` on release
- Runs validation checks

---

## Project Structure

```
leadmagic-skills/
├── skills/                    # All 43 skills
│   ├── hono-v4/
│   │   ├── SKILL.md           # Main skill file
│   │   └── rules/             # Detailed patterns
│   │       ├── types-env-bindings.md
│   │       └── middleware-order.md
│   ├── react-best-practices/
│   │   ├── SKILL.md
│   │   ├── AGENTS.md          # Compiled rules (generated)
│   │   └── rules/             # 53 rule files
│   └── ...
├── scripts/
│   ├── build.sh               # Package skills
│   └── validate.sh            # Validate format
├── .github/
│   └── workflows/             # CI/CD pipelines
├── AGENTS.md                  # AI agent instructions
├── README.md                  # This file
├── install.sh                 # Installation script
└── LICENSE
```

---

## Troubleshooting

### Skills Not Loading

```bash
# Verify installation path
ls -la ~/.claude/skills/

# Re-install skills
./install.sh
```

### Validation Failing

```bash
# Check specific skill
./scripts/validate.sh skills/my-skill

# Common issues:
# - Missing frontmatter
# - SKILL.md over 500 lines
# - Invalid YAML in frontmatter
```

### Permission Issues

```bash
# Fix script permissions
chmod +x install.sh scripts/*.sh
```

---

## Contributing

### Who Can Contribute

All LeadMagic organization members have access to this internal repository.

### Contribution Guidelines

1. Follow the existing skill format
2. Include both correct and incorrect code examples
3. Keep SKILL.md concise (under 500 lines)
4. Add rules for detailed patterns
5. Run validation before submitting PR
6. Get at least 1 review approval

### Need Help?

- Check existing skills for examples
- Read `AGENTS.md` for detailed format specs
- Ask in #engineering Slack channel

---

## License

**LeadMagic Proprietary** — Internal use only. No sharing, distribution, or reproduction permitted. See [LICENSE](LICENSE) for details.

---

## Links

- **Repository:** https://github.com/LeadMagic/leadmagic-skills
- **Organization:** https://github.com/LeadMagic
- **Claude Skills Docs:** https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/skills
