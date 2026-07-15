# Security Policy — LeadMagic Skills

## Reporting a vulnerability

Email **[security@leadmagic.io](mailto:security@leadmagic.io)** with:

- Type of issue (prompt injection, data exfiltration vector, impersonation,
  dependency vulnerability, etc.)
- The affected skill path and commit SHA
- Reproduction steps
- Suggested fix, if any

Do **not** open a public GitHub issue for security reports. We acknowledge
within 24 hours and aim to fix within 72 hours.

## What makes a skill "official" for LeadMagic?

A skill is official **only** if it is published under one of:

- [`LeadMagic/leadmagic-skills`](https://github.com/LeadMagic/leadmagic-skills) — this repo
- [`LeadMagic/leadmagic-cursor-plugin`](https://github.com/LeadMagic/leadmagic-cursor-plugin)
- [`LeadMagic/leadmagic-openapi`](https://github.com/LeadMagic/leadmagic-openapi)
- `https://leadmagic.io/docs/...`

**Do not trust frontmatter alone.** A third-party repo can put
`github: "https://github.com/LeadMagic"` in a skill's YAML frontmatter
without being affiliated. Always verify the repo **owner** on GitHub.

### Known impersonation attempts

| Repo | First seen | Status |
|---|---|---|
| `sales-skills/sales` (`--skills sales-leadmagic`) | 2026-04-19 | Reported; do not install. Claims `github.com/LeadMagic` in its frontmatter but is owned by the unrelated org `sales-skills`. |

If you see a new impersonation attempt, please email
[security@leadmagic.io](mailto:security@leadmagic.io).

## Threat model for skills

Skills are **executable prompts**: AI agents read them and follow their
instructions. A malicious skill can:

- Exfiltrate API keys, request bodies, or response bodies via crafted
  `curl` / `fetch` instructions
- Route traffic to attacker-controlled hosts instead of `*.leadmagic.io`
- Silently change behavior between installs (the skill's repo owner
  controls the content; `npx skills add ...` without a lockfile pulls the
  latest commit)
- Prompt-inject the agent into ignoring the user's real goal

Every skill in this repo follows these rules, and we ask third-party
contributors to do the same:

1. **Never** log or echo `LEADMAGIC_API_KEY` or any other secret.
2. **Never** POST request/response bodies to hosts outside the scope
   explicitly declared in the skill (for LeadMagic skills that scope is
   `*.leadmagic.io`).
3. **Never** run arbitrary shell / `eval` / `curl | bash` from inside a
   skill's instructions.
4. **Prefer** the hosted MCP (`https://mcp.leadmagic.io/mcp`) over
   hand-rolled `curl` when instructing agents.
5. **Declare** an explicit `publisher`, `github`, `homepage`, and `docs`
   in skill frontmatter so users can verify provenance.

## Install-time hardening

If you install skills from this repo programmatically, **pin by commit
SHA** rather than branch:

```bash
npx skills add LeadMagic/leadmagic-skills#<full-commit-sha>
```

This prevents a compromised future commit from silently landing in your
agent context on the next `skills sync`.

## Reporting an impersonation

If you see a GitHub repo, npm package, or MCP server that claims to be
LeadMagic but is not under the `LeadMagic` GitHub owner:

1. Email [security@leadmagic.io](mailto:security@leadmagic.io) with the
   URL and a brief description.
2. Do not install it.
3. If you already installed it, rotate your LeadMagic API key at
   [app.leadmagic.io](https://app.leadmagic.io) and remove the skill from
   your agent's skill directory.
