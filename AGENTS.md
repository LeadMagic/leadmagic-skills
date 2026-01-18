# LeadMagic Skills - Agent Instructions

This file provides guidance to AI coding agents (Claude, Cursor, Copilot, etc.) when working with LeadMagic codebases.

## Overview

This repository contains Claude Skills for building production applications with the LeadMagic stack:

- **Hono v4** - High-performance API framework
- **Cloudflare Workers** - Edge serverless platform
- **D1** - SQLite at the edge
- **Durable Objects** - Stateful coordination
- **R2** - Object storage
- **Workflows** - Durable execution
- **AI Gateway** - AI API management
- **TypeScript** - Type-safe development

## Using Skills

Skills are automatically loaded when installed to `~/.claude/skills/`. Reference them when:

| Skill | Use When |
|-------|----------|
| `hono-v4` | Building APIs, routes, middleware |
| `cloudflare-workers` | Creating Workers, handling requests |
| `wrangler` | Configuring wrangler.toml, deploying |
| `cloudflare-d1` | Database queries, schema design |
| `cloudflare-durable-objects` | Real-time features, WebSockets |
| `cloudflare-r2` | File uploads, object storage |
| `cloudflare-kv` | Caching, sessions, key-value storage |
| `cloudflare-workflows` | Background jobs, orchestration |
| `cloudflare-ai-gateway` | LLM routing, caching, rate limiting |
| `typescript-best-practices` | Type safety, configuration |

## Creating a New Skill

### Directory Structure

```
skills/
  {skill-name}/           # kebab-case directory name
    SKILL.md              # Required: skill definition
    scripts/              # Optional: executable scripts
      {script-name}.sh    # Bash scripts (preferred)
    rules/                # Optional: detailed rule files
      {rule-name}.md      # Individual rules with examples
  {skill-name}.zip        # Required: packaged for distribution
```

### Naming Conventions

- **Skill directory**: `kebab-case` (e.g., `hono-v4`, `cloudflare-d1`)
- **SKILL.md**: Always uppercase, always this exact filename
- **Scripts**: `kebab-case.sh` (e.g., `deploy.sh`, `fetch-logs.sh`)
- **Rules**: `prefix-name.md` (e.g., `types-env-bindings.md`)
- **Zip file**: Must match directory name exactly: `{skill-name}.zip`

---

## Skill Format: Best Practices (Recommended)

Use this format for coding guidelines, patterns, and best practices.

### SKILL.md Format

```markdown
---
name: {skill-name}
description: {One sentence. Include trigger phrases like "Use when X", "Triggers on Y".}
license: MIT
metadata:
  author: leadmagic
  version: "1.0.0"
---

# {Skill Title}

{Brief description of what the skill covers.}

## When to Apply

Reference these guidelines when:
- Scenario 1
- Scenario 2
- Scenario 3

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Category Name | CRITICAL | `prefix-` |
| 2 | Category Name | HIGH | `prefix-` |

## Quick Reference

### 1. Category Name (CRITICAL)

- `rule-name` - Brief description
- `rule-name` - Brief description

## Essential Patterns

{Show 2-3 common code patterns with examples}

## How to Use

Read individual rule files for detailed explanations:

```
rules/prefix-rule-name.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect code example
- Correct code example
```

### Rule File Format (rules/{rule-name}.md)

```markdown
---
title: Rule Title
impact: CRITICAL | HIGH | MEDIUM | LOW
impactDescription: Brief impact statement (e.g., "2-10× improvement")
tags: tag1, tag2, tag3
---

## Rule Title

{Explanation of why this rule matters.}

**Incorrect (description):**

```typescript
// Bad code example
```

**Correct (description):**

```typescript
// Good code example
```

{Additional context, references, or notes.}
```

---

## Skill Format: Script-Based

Use this format for skills that execute scripts/automation.

### SKILL.md Format

```markdown
---
name: {skill-name}
description: {One sentence describing when to use. Include trigger phrases like "Deploy my app", "Check logs".}
metadata:
  author: leadmagic
  version: "1.0.0"
---

# {Skill Title}

{Brief description of what the skill does.}

## How It Works

1. Step one of the workflow
2. Step two of the workflow
3. Step three of the workflow

## Usage

```bash
bash /mnt/skills/user/{skill-name}/scripts/{script}.sh [args]
```

**Arguments:**
- `arg1` - Description (defaults to X)

**Examples:**

```bash
# Example 1
bash /mnt/skills/user/{skill-name}/scripts/{script}.sh arg1

# Example 2
bash /mnt/skills/user/{skill-name}/scripts/{script}.sh --flag value
```

## Output

```
{Example output users will see}
```

## Present Results to User

{Template for how Claude should format results when presenting to users}

## Troubleshooting

### Common Issue 1

{Description and solution}

### Common Issue 2

{Description and solution}
```

### Script Requirements

- Use `#!/bin/bash` shebang
- Use `set -e` for fail-fast behavior
- Write status messages to stderr: `echo "Message" >&2`
- Write machine-readable output (JSON) to stdout
- Include a cleanup trap for temp files

---

## Best Practices for Context Efficiency

Skills are loaded on-demand — only the skill name and description are loaded at startup. The full `SKILL.md` loads into context only when the agent decides the skill is relevant.

- **Keep SKILL.md under 500 lines** — put detailed reference material in rules/ files
- **Write specific descriptions** — helps the agent know exactly when to activate the skill
- **Use progressive disclosure** — reference supporting files that get read only when needed
- **Prefer scripts over inline code** — script execution doesn't consume context (only output does)
- **File references work one level deep** — link directly from SKILL.md to supporting files
- **Prioritize rules by impact** — CRITICAL > HIGH > MEDIUM > LOW

## Creating the Zip Package

After creating or updating a skill:

```bash
cd skills
zip -r {skill-name}.zip {skill-name}/
```

## Installation

**Claude Code / Claude Desktop:**
```bash
cp -r skills/{skill-name} ~/.claude/skills/
```

**claude.ai:**
Add the skill to project knowledge or paste SKILL.md contents into the conversation.

If the skill requires network access, instruct users to add required domains at `claude.ai/settings/capabilities`.
