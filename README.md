# LeadMagic Skills

Claude Skills for building production applications with the **LeadMagic Stack** — Hono v4, Cloudflare Workers, Next.js 16, React 19, and TypeScript.

[![Skills](https://img.shields.io/badge/skills-52-blue)]()
[![Internal](https://img.shields.io/badge/visibility-internal-orange)]()
[![License](https://img.shields.io/badge/license-proprietary-red)]()

## Overview

This repository contains **52 Claude Skills** that provide AI coding agents with best practices, patterns, and guidelines for building production applications. Skills are automatically loaded by Claude Code, Cursor, and other AI assistants when installed.

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

You should see all 52 skill directories.

---

## Skills Catalog (52 Total)

### Cloudflare Platform (10)

| Skill | Description |
|-------|-------------|
| `cloudflare-workers` | Workers runtime, bindings, fetch handlers |
| `cloudflare-d1` | SQLite database, prepared statements, migrations |
| `cloudflare-kv` | Key-value storage, caching, sessions |
| `cloudflare-r2` | Object storage, uploads, streaming |
| `cloudflare-durable-objects` | Stateful coordination, WebSockets, alarms |
| `cloudflare-workflows` | Durable execution, steps, events |
| `cloudflare-ai-gateway` | LLM routing, caching, rate limiting |
| `cloudflare-observability` | Logs, Logpush, OpenTelemetry export |
| `hono-v4` | API framework, routes, middleware |
| `wrangler` | CLI, configuration, local dev, deployment |

### Data & State (5)

| Skill | Description |
|-------|-------------|
| `drizzle-orm` | Type-safe ORM, schemas, migrations |
| `tanstack-query` | Server state, data fetching, caching |
| `tanstack-table` | Data tables, sorting, filtering, pagination |
| `zustand` | Global state management, stores |
| `upstash` | Redis, QStash, rate limiting |

### Authentication (4)

| Skill | Description |
|-------|-------------|
| `authentication` | Auth patterns overview, JWT, sessions |
| `clerk` | Clerk auth, organizations, webhooks |
| `better-auth` | Self-hosted, framework-agnostic auth |
| `security-best-practices` | Input validation, CSRF, XSS |

### Frontend & UI (7)

| Skill | Description |
|-------|-------------|
| `react-best-practices` | React 19 patterns, performance |
| `nextjs-app-router` | App Router, Server Components, Actions |
| `typescript-best-practices` | Type safety, strict mode, patterns |
| `ui-development` | Component patterns, Framer Motion |
| `shadcn-ui` | shadcn/ui components, theming |
| `tailwind-v4` | CSS-first config, OKLCH, theme tokens |
| `caching-strategies` | Next.js caching, SWR, Cache API |

### Forms & Validation (2)

| Skill | Description |
|-------|-------------|
| `zod` | Schema validation, type inference |
| `react-hook-form` | Form handling, Zod integration |

### Backend Services (7)

| Skill | Description |
|-------|-------------|
| `api-development` | REST design, versioning, rate limiting |
| `stripe-payments` | Payments, subscriptions, webhooks |
| `resend` | Email sending, React Email templates |
| `inngest` | Durable workflows, background jobs |
| `tinybird` | Real-time analytics, ClickHouse APIs |
| `env-variables` | Environment configuration |
| `doppler` | Secrets management |

### Observability (5)

| Skill | Description |
|-------|-------------|
| `logging-best-practices` | Wide events, structured logging |
| `error-handling` | Error boundaries, API errors |
| `sentry` | Error tracking, performance monitoring |
| `axiom` | Log analytics, APL queries |
| `opentelemetry` | Distributed tracing, spans, metrics |

### Quality & Tooling (3)

| Skill | Description |
|-------|-------------|
| `testing-best-practices` | Vitest, Testing Library, Playwright |
| `biome` | Fast linting/formatting |
| `monorepo` | Turborepo, pnpm workspaces |

### AI & Automation (3)

| Skill | Description |
|-------|-------------|
| `vercel-ai-sdk` | AI streaming, tools, chat interfaces |
| `ralph-wiggum` | Iterative AI loops, autonomous coding |
| `linear` | Project management, agent tasks |

### Design System (5)

| Skill | Description |
|-------|-------------|
| `design-principles` | UX heuristics, visual design |
| `design-review` | UI code review checklist |
| `design-antipatterns` | Common UI/UX mistakes |
| `design-lab` | Structured design workflow |
| `web-design-guidelines` | Vercel design guidelines |

### Deployment (1)

| Skill | Description |
|-------|-------------|
| `vercel-deploy-claimable` | Deploy to Vercel with claimable link |

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
- Name format is valid (lowercase, hyphens, numbers)
- Description length under 1024 chars

### Check Freshness Against Context7

```bash
./scripts/check-freshness.sh
```

Skills are mapped to Context7 library IDs in `context7-mappings.json`. The CI runs a weekly freshness check to identify skills that may need updates.

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

## Keeping Skills Up to Date

### Context7 Integration

Skills are mapped to their upstream documentation via [Context7](https://context7.com/). This ensures skills stay current with the latest API changes.

**Mapping File:** `context7-mappings.json`

| Skill | Context7 Library |
|-------|-----------------|
| `hono-v4` | hono/hono |
| `react-best-practices` | facebook/react |
| `nextjs-app-router` | vercel/next.js |
| `cloudflare-*` | cloudflare/workers-sdk |
| `drizzle-orm` | drizzle-team/drizzle-orm |
| `tanstack-query` | tanstack/query |
| `tanstack-table` | tanstack/table |
| `vercel-ai-sdk` | vercel/ai |
| `stripe-payments` | stripe/stripe-node |
| `inngest` | inngest/inngest-js |
| `biome` | biomejs/biome |

### Updating a Skill with Context7

1. **Setup Context7 MCP** (add to `~/.claude/mcp.json`):

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

2. **Update skill using Claude Code:**

```bash
npx @anthropic-ai/claude-code "Update skills/hono-v4 using Context7 for latest Hono v4 docs"
```

3. **Or use Context7 MCP directly:**

```
use_mcp_tool context7 resolve {"libraryName": "hono/hono"}
use_mcp_tool context7 get_library_docs {"context7CompatibleLibraryID": "/hono/hono"}
```

### Automated Freshness Checks

The CI runs weekly to check skills against Context7:

- **Schedule:** Every Monday at 9:00 UTC
- **Manual trigger:** Go to Actions → "Validate Skills" → "Run workflow"

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
