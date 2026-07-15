# LeadMagic Skills

**Official agent skills for using the LeadMagic product** — REST APIs, enrichments, bulk CSV uploaders, credits, and hosted MCP.

| | |
|---|---|
| **Install** | `npx skills add LeadMagic/leadmagic-skills` or `./install.sh` |
| **Docs** | [leadmagic.io/docs](https://leadmagic.io/docs) |
| **API** | `https://api.leadmagic.io` · header `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` |
| **Security** | [SECURITY.md](SECURITY.md) |

## Skills

| Skill | When to load |
|-------|----------------|
| [`leadmagic`](skills/leadmagic/) | Router / overview |
| [`api-auth-credits`](skills/api-auth-credits/) | Keys, `GET /v1/credits`, 401/429 |
| [`email-enrichment`](skills/email-enrichment/) | Email finder, validation, LinkedIn↔email |
| [`people-search`](skills/people-search/) | `POST /v3/people/search` audiences |
| [`people-enrichment`](skills/people-enrichment/) | Mobile, profile, role, employees |
| [`company-enrichment`](skills/company-enrichment/) | Company search & funding |
| [`bulk-jobs`](skills/bulk-jobs/) | `POST /bulk/submit`, CSV uploaders, job status |
| [`mcp-integration`](skills/mcp-integration/) | Hosted MCP in Claude / Cursor / etc. |

## Quick install

```bash
# Claude Code / skills CLI
npx skills add LeadMagic/leadmagic-skills

# Or clone + local install
git clone https://github.com/LeadMagic/leadmagic-skills.git
cd leadmagic-skills
./install.sh                  # → ~/.claude/skills/
./install.sh ./my-skills-dir  # custom target
```

Pin by commit SHA for production agents (see [SECURITY.md](SECURITY.md)).

## Agent safety

1. Never echo or commit API keys — use `$LEADMAGIC_API_KEY`.
2. Only send enrichment traffic to `*.leadmagic.io` unless the user explicitly asks otherwise.
3. Prefer hosted MCP over shell `curl` when the agent can use MCP.
4. Trust only skills under the `LeadMagic` GitHub org (or leadmagic.io docs).

## Repo layout

```
skills/     # product skills (installed)
dist/       # packaged zips from scripts/build.sh
scripts/    # build / validate helpers
```

```bash
./scripts/build.sh      # zip skills → dist/
./scripts/validate.sh   # frontmatter checks (if present)
```

## Contributing

- New skills must be **product usage** (API, enrichment, bulk, MCP, credits).
- Keep each `SKILL.md` under 500 lines; put tables in `references/`.
- Never put secrets, customer PII, or live response dumps in skills or learnings.
- Update `skills/leadmagic/references/learnings.md` with durable gotchas.

## License

MIT — see [LICENSE](LICENSE).
