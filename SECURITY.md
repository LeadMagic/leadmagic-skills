# Security Policy — LeadMagic Skills

## Reporting a vulnerability

Email **[security@leadmagic.io](mailto:security@leadmagic.io)** with the skill path, commit SHA, and reproduction steps.

Do **not** open a public GitHub issue for security reports.

## Official sources only

A skill is official **only** if it comes from:

- [`LeadMagic/leadmagic-skills`](https://github.com/LeadMagic/leadmagic-skills) — this repo
- [`LeadMagic/leadmagic-cursor-plugin`](https://github.com/LeadMagic/leadmagic-cursor-plugin)
- [`LeadMagic/leadmagic-openapi`](https://github.com/LeadMagic/leadmagic-openapi)
- `https://leadmagic.io/docs/...`

Always verify the GitHub **owner** is `LeadMagic`. Do not trust frontmatter claims alone.

If you installed an unverified skill, remove it and rotate your API key at [app.leadmagic.io](https://app.leadmagic.io).

## Agent safety rules

1. Never log or echo `LEADMAGIC_API_KEY`.
2. Never POST enrichment bodies to hosts outside `*.leadmagic.io` unless the user explicitly asks in that turn.
3. Prefer hosted MCP (`https://mcp.leadmagic.io/mcp`) over hand-rolled shell calls.

## Pin installs

```bash
npx skills add LeadMagic/leadmagic-skills#<full-commit-sha>
```
