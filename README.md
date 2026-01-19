# LeadMagic Skills

Claude Skills for building production applications with **Next.js + Cloudflare + TypeScript**.

## Quick Start

```bash
# Install all skills to Claude
./install.sh

# Or install to a custom directory
./install.sh ./my-project/.claude/skills
```

## Skills (36 Total)

### Core Stack

| Skill | Description |
|-------|-------------|
| **hono-v4** | Hono v4 APIs - routes, middleware, validation |
| **cloudflare-workers** | Workers fundamentals - requests, bindings, caching |
| **wrangler** | Wrangler CLI - configuration, deployment |
| **typescript-best-practices** | TypeScript - strict mode, types, patterns |

### Data & Storage

| Skill | Description |
|-------|-------------|
| **cloudflare-d1** | D1 SQLite - schema, queries, migrations |
| **cloudflare-kv** | KV storage - caching, sessions |
| **cloudflare-r2** | R2 storage - uploads, streaming |
| **cloudflare-durable-objects** | Durable Objects - state, WebSockets |
| **drizzle-orm** | Drizzle ORM - type-safe queries, relations |
| **upstash** | QStash, Redis, Workflows, Ratelimit |

### Backend

| Skill | Description |
|-------|-------------|
| **api-development** | API design, rate limiting, errors, versioning |
| **cloudflare-workflows** | Workflows - durable execution |
| **cloudflare-ai-gateway** | AI Gateway - routing, caching |
| **authentication** | Auth patterns - Clerk, Auth.js, JWT, sessions |
| **caching-strategies** | Caching - ISR, SWR, Cache API |

### Frontend

| Skill | Description |
|-------|-------------|
| **react-best-practices** | React 19 optimization patterns |
| **nextjs-app-router** | Next.js 16 App Router - RSC, Server Actions |
| **ui-development** | shadcn/ui, Tailwind v4, Framer Motion, Recharts |
| **vercel-ai-sdk** | AI SDK - chat, streaming, tools, agents |

### Quality & Security

| Skill | Description |
|-------|-------------|
| **testing-best-practices** | Vitest, Testing Library, Playwright, MSW |
| **security-best-practices** | Input validation, CSRF, rate limiting, CSP |
| **error-handling** | Error boundaries, API errors, logging |
| **env-variables** | Environment variable patterns |

### Design

| Skill | Description |
|-------|-------------|
| **web-design-guidelines** | Vercel Web Interface Guidelines |
| **design-review** | WCAG 2.1 accessibility + design constraints |
| **design-principles** | Foundational design principles |
| **design-lab** | Interactive design exploration workflow |
| **design-antipatterns** | Avoiding "AI slop" patterns |

### Deployment

| Skill | Description |
|-------|-------------|
| **vercel-deploy-claimable** | Deploy to Vercel instantly |

## Directory Structure

```
leadmagic-skills/
├── skills/                 # All skills
│   ├── hono-v4/
│   │   ├── SKILL.md        # Main instructions (<500 lines)
│   │   └── rules/          # Detailed patterns
│   ├── nextjs-app-router/
│   └── ...
├── scripts/
│   ├── build.sh            # Package skills
│   └── validate.sh         # Validate format
├── .github/workflows/      # CI/CD
├── AGENTS.md               # AI agent instructions
├── README.md
└── install.sh
```

## Installation

### Claude Code / Claude Desktop

```bash
./install.sh
```

Skills install to `~/.claude/skills/`

### Cursor

```bash
mkdir -p .cursor/skills
cp -r skills/hono-v4 .cursor/skills/
```

### claude.ai

Upload skill `.zip` from releases to project knowledge.

## Development

### Validate Skills

```bash
./scripts/validate.sh
```

### Package Skills

```bash
./scripts/build.sh
```

## Skill Format

Based on [Anthropic Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) best practices:

- **SKILL.md** - Under 500 lines, concise quick reference
- **rules/** - Detailed patterns, progressive disclosure
- **name** - Lowercase, hyphens, max 64 chars
- **description** - What + when to use, max 1024 chars

### Example Structure

```markdown
---
name: my-skill
description: What it does. Use when X. Triggers on "keyword".
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# My Skill

Quick reference and essential patterns.

## Quick Reference
[Concise patterns]

See `rules/detailed-pattern.md` for more.
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add/modify skills following templates
4. Run `./scripts/validate.sh`
5. Submit a pull request

## License

MIT
