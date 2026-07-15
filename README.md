# LeadMagic Skills

Official **agent skills** for using LeadMagic — find emails, enrich people and companies, run bulk CSV jobs, check credits, and connect via MCP.

Install once. Your agent loads the right skill when you ask for LeadMagic help.

| | |
|---|---|
| **Install** | `npx skills add LeadMagic/leadmagic-skills` |
| **Docs** | [leadmagic.io/docs](https://leadmagic.io/docs) |
| **API** | `https://api.leadmagic.io` · header `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io) |
| **Security** | [SECURITY.md](SECURITY.md) |

---

## What these skills do

They teach AI agents (Claude, Cursor, and similar) how to call LeadMagic correctly:

- Which endpoint to use for email, people search, mobile, company, or bulk
- Auth (`X-API-Key`), credits, and rate-limit basics
- Safe patterns (never leak keys; prefer hosted MCP when possible)
- How to map CSV / bulk uploaders to the right `product`

They are **not** engineering playbooks for building software. They are product-usage skills.

---

## Skills

| Skill | Tell your agent… | Covers |
|-------|------------------|--------|
| [`leadmagic`](skills/leadmagic/) | “Help me use LeadMagic” | Router — picks the right skill below |
| [`api-auth-credits`](skills/api-auth-credits/) | “Set up my API key / check credits” | Keys, `GET /v1/credits`, 401 / 429 |
| [`email-enrichment`](skills/email-enrichment/) | “Find or validate this email” | Email finder, validation, LinkedIn ↔ email |
| [`people-search`](skills/people-search/) | “Search for people matching an ICP” | `POST /v3/people/search` filters |
| [`people-enrichment`](skills/people-enrichment/) | “Enrich this LinkedIn / find mobile” | Profile, mobile, role, employees |
| [`company-enrichment`](skills/company-enrichment/) | “Research this company / funding” | Company search & funding |
| [`bulk-jobs`](skills/bulk-jobs/) | “Enrich this CSV / run a bulk job” | `POST /bulk/submit`, status, callbacks |
| [`mcp-integration`](skills/mcp-integration/) | “Install LeadMagic MCP” | Hosted MCP in Claude / Cursor / etc. |

---

## Install

### Skills CLI (recommended)

```bash
npx skills add LeadMagic/leadmagic-skills
```

For production agents, pin a commit:

```bash
npx skills add LeadMagic/leadmagic-skills#<commit-sha>
```

### Local install

```bash
git clone https://github.com/LeadMagic/leadmagic-skills.git
cd leadmagic-skills
./install.sh                 # → ~/.claude/skills/
./install.sh ./my-skills-dir # custom directory
```

### Hosted MCP (optional)

```jsonc
{
  "mcpServers": {
    "leadmagic": {
      "url": "https://mcp.leadmagic.io/mcp"
    }
  }
}
```

Get an API key at [app.leadmagic.io](https://app.leadmagic.io) → Settings → API. Set `LEADMAGIC_API_KEY` in your environment. Never paste keys into chat or commit them.

---

## Quick example

```bash
# Credits (free)
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"

# Email Finder (1 credit; free if not found)
curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","company_name":"acme.com"}'
```

Full reference: [leadmagic.io/docs](https://leadmagic.io/docs)

---

## Safety

1. Never echo or commit API keys — use `$LEADMAGIC_API_KEY`.
2. Send enrichment traffic only to `*.leadmagic.io` unless you explicitly ask otherwise.
3. Prefer hosted MCP over shell `curl` when your agent supports MCP.
4. Only trust skills from the `LeadMagic` GitHub org (or leadmagic.io docs).

---

## Contributing

- Skills must cover **product usage** (API, enrichment, bulk, MCP, credits).
- Keep each `SKILL.md` under 500 lines; put long tables in `references/`.
- No secrets, customer data, or live response dumps in skills.
- Durable gotchas go in `skills/leadmagic/references/learnings.md`.

```bash
./scripts/validate.sh   # frontmatter checks
./scripts/build.sh      # zip packages → dist/
```

## License

MIT — see [LICENSE](LICENSE).
