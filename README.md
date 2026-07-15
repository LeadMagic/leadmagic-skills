# LeadMagic Skills

Official agent skills for **using LeadMagic** — email finder & validation, people search, B2B Profile enrichment, company research, bulk CSV jobs, credits, and hosted MCP.

Built for [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) (and compatible skill loaders). Authoring follows Anthropic’s [best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices).

| | |
|---|---|
| **Install** | `npx skills add LeadMagic/leadmagic-skills` |
| **API docs** | [leadmagic.io/docs](https://leadmagic.io/docs) |
| **API base** | `https://api.leadmagic.io` · `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io) |
| **License** | MIT |

---

## Skills

| Skill | When to use | Tags |
|-------|-------------|------|
| [`leadmagic`](skills/leadmagic/) | General LeadMagic help — routes to the skills below | `leadmagic`, `enrichment`, `mcp`, `b2b-profile`, `official` |
| [`api-auth-credits`](skills/api-auth-credits/) | API keys, credit balance, 401 / 429 | `api`, `auth`, `credits`, `rate-limits` |
| [`email-enrichment`](skills/email-enrichment/) | Find or validate email; B2B Profile ↔ email | `email-finder`, `email-validation`, `b2b-profile` |
| [`people-search`](skills/people-search/) | Audience / ICP search (`POST /v3/people/search`) | `people-search`, `v3`, `audience` |
| [`people-enrichment`](skills/people-enrichment/) | B2B Profile, mobile, role, employees | `mobile`, `b2b-profile`, `role-finder` |
| [`company-enrichment`](skills/company-enrichment/) | Company search & funding | `company`, `funding`, `technographics` |
| [`bulk-jobs`](skills/bulk-jobs/) | CSV / async bulk submit & status | `bulk`, `csv`, `uploader`, `jobs` |
| [`mcp-integration`](skills/mcp-integration/) | Hosted MCP setup | `mcp`, `oauth`, `cursor` |

Each skill’s `SKILL.md` has:

- **Required:** `name`, `description` (what it does **and** when to use it)
- **Recommended:** `license`, `compatibility`, `metadata` (`author`, `version`, `tags`, `docs`)

---

## Install

```bash
npx skills add LeadMagic/leadmagic-skills
```

Pin a commit in production:

```bash
npx skills add LeadMagic/leadmagic-skills#<commit-sha>
```

### Claude Code

```bash
./install.sh                 # → ~/.claude/skills/
./install.sh .claude/skills  # project-local
```

### Hosted MCP

```jsonc
{
  "mcpServers": {
    "leadmagic": {
      "url": "https://mcp.leadmagic.io/mcp"
    }
  }
}
```

Create an API key in [app.leadmagic.io](https://app.leadmagic.io) → Settings → API and set `LEADMAGIC_API_KEY` in your environment. Never paste keys into chat or commit them.

---

## Quick example

```bash
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"

curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}'
```

More examples: [People Search](https://leadmagic.io/docs/api-reference/people-search) · [Bulk submit](https://leadmagic.io/docs/api-reference/bulk-jobs-submit) · [full docs](https://leadmagic.io/docs)

---

## Safety

1. Never echo or commit API keys — use `$LEADMAGIC_API_KEY`.
2. Send enrichment traffic only to `*.leadmagic.io` unless you explicitly ask otherwise.
3. Prefer hosted MCP over shell `curl` when your agent supports MCP.
4. Only trust skills published under the `LeadMagic` GitHub org (see [SECURITY.md](SECURITY.md)).

CI runs `./scripts/validate.sh` on every push and pull request (frontmatter, size limits, public-safe wording).

---

## Contributing

- Skills cover **product usage** only (APIs, enrichments, bulk, MCP, credits).
- Keep each `SKILL.md` under 500 lines; put long tables in `references/`.
- Use **B2B Profile** wording (not third-party brand names).
- No secrets, customer data, or live API responses in the repo.

```bash
./scripts/validate.sh
./scripts/build.sh
```

## License

MIT — see [LICENSE](LICENSE).
