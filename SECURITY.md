# Security Policy — LeadMagic Skills

## Reporting a vulnerability

Email **[security@leadmagic.io](mailto:security@leadmagic.io)** with:

- Type of issue (prompt injection, data exfiltration, impersonation, etc.)
- Affected skill path and commit SHA
- Reproduction steps

Do **not** open a public GitHub issue for security reports.

## Official sources only

A skill is official **only** if it comes from:

- [`LeadMagic/leadmagic-skills`](https://github.com/LeadMagic/leadmagic-skills) — this repo
- [`LeadMagic/leadmagic-cursor-plugin`](https://github.com/LeadMagic/leadmagic-cursor-plugin)
- [`LeadMagic/leadmagic-openapi`](https://github.com/LeadMagic/leadmagic-openapi)
- `https://leadmagic.io/docs/...`

**Do not trust frontmatter alone.** Third-party repos can claim affiliation in YAML. Always verify the GitHub **owner** is `LeadMagic`.

### Known impersonation

| Source | Status |
|---|---|
| `sales-skills/sales` (`sales-leadmagic`) | Unofficial — do not install |

Report new impersonation attempts to [security@leadmagic.io](mailto:security@leadmagic.io).

## Agent safety rules (this repo)

1. Never log or echo `LEADMAGIC_API_KEY`.
2. Never POST enrichment bodies to hosts outside `*.leadmagic.io` unless the user explicitly asks in that turn.
3. Prefer hosted MCP (`https://mcp.leadmagic.io/mcp`) over hand-rolled shell calls.
4. Declare `publisher`, `github`, `homepage`, and `docs` in skill frontmatter.

## Pin installs

```bash
npx skills add LeadMagic/leadmagic-skills#<full-commit-sha>
```

If you installed an unverified skill, remove it and rotate your key at [app.leadmagic.io](https://app.leadmagic.io).
