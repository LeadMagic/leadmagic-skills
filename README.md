# LeadMagic Skills

Official **[Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)** for using LeadMagic — find emails, enrich people and companies, run bulk CSV jobs, check credits, and connect via MCP.

Follows Anthropic’s [skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices): required `name` + `description` (what **and** when), progressive disclosure via `references/`, and SKILL.md bodies kept under 500 lines.

| | |
|---|---|
| **Install** | `npx skills add LeadMagic/leadmagic-skills` |
| **Docs** | [leadmagic.io/docs](https://leadmagic.io/docs) |
| **API** | `https://api.leadmagic.io` · header `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io) |
| **Security** | [SECURITY.md](SECURITY.md) |
| **CI** | Validates every skill on push / PR |

---

## What these skills do

They teach AI agents how to call LeadMagic correctly:

- Which endpoint to use for email, people search, mobile, B2B Profile, company, or bulk
- Auth (`X-API-Key`), credits, and rate-limit basics
- Safe patterns (never leak keys; prefer hosted MCP when possible)
- How to map CSV / bulk uploaders to the right `product`

Product-usage skills only — not engineering playbooks.

---

## Skills

| Skill | Tell your agent… | Tags |
|-------|------------------|------|
| [`leadmagic`](skills/leadmagic/) | “Help me use LeadMagic” | `leadmagic`, `enrichment`, `mcp`, `b2b-profile`, `official` |
| [`api-auth-credits`](skills/api-auth-credits/) | “Set up my API key / check credits” | `api`, `auth`, `credits`, `rate-limits` |
| [`email-enrichment`](skills/email-enrichment/) | “Find or validate this email” | `email-finder`, `email-validation`, `b2b-profile` |
| [`people-search`](skills/people-search/) | “Search for people matching an ICP” | `people-search`, `v3`, `audience` |
| [`people-enrichment`](skills/people-enrichment/) | “Enrich this B2B Profile / find mobile” | `mobile`, `b2b-profile`, `role-finder` |
| [`company-enrichment`](skills/company-enrichment/) | “Research this company / funding” | `company`, `funding`, `technographics` |
| [`bulk-jobs`](skills/bulk-jobs/) | “Enrich this CSV / run a bulk job” | `bulk`, `csv`, `uploader`, `jobs` |
| [`mcp-integration`](skills/mcp-integration/) | “Install LeadMagic MCP” | `mcp`, `oauth`, `cursor` |

Each `SKILL.md` includes YAML frontmatter with:

- **Required:** `name`, `description` (what + when, third person, ≤1024 chars)
- **Recommended:** `license`, `compatibility`, `metadata.author`, `metadata.version`, `metadata.tags`, `metadata.docs`

---

## Install

### Skills CLI (recommended)

```bash
npx skills add LeadMagic/leadmagic-skills
```

Pin for production:

```bash
npx skills add LeadMagic/leadmagic-skills#<commit-sha>
```

### Claude Code

```bash
# Personal
./install.sh                  # → ~/.claude/skills/

# Or project-local
mkdir -p .claude/skills
./install.sh .claude/skills
```

See [Use Skills in Claude Code](https://docs.claude.com/en/docs/claude-code/skills).

### claude.ai

Package a skill zip (or the whole repo’s `dist/` from CI artifacts) and upload via **Settings → Features** (Pro / Max / Team / Enterprise with code execution). See [How to create custom Skills](https://support.claude.com/).

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

Get an API key at [app.leadmagic.io](https://app.leadmagic.io) → Settings → API. Set `LEADMAGIC_API_KEY`. Never paste keys into chat or commit them.

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

Full reference: [leadmagic.io/docs](https://leadmagic.io/docs)

---

## Validation (CI)

Every push and pull request runs Claude Agent Skills checks:

```bash
./scripts/validate.sh   # frontmatter, description, size, B2B wording, no secrets
./scripts/build.sh      # zip each skill → dist/
```

Checks include:

- `name` matches folder; lowercase / hyphens; ≤64 chars; no reserved words
- `description` present, ≤1024 chars, no XML tags, includes when-to-use triggers
- `license` + `metadata` (`author`, `version`, `tags`) recommended
- SKILL.md ≤ 500 lines
- No LinkedIn branding (use **B2B Profile**; MCP tool id `linkedin_profile_to_work_email` allowed as the hosted tool name)

---

## Safety

1. Never echo or commit API keys — use `$LEADMAGIC_API_KEY`.
2. Send enrichment traffic only to `*.leadmagic.io` unless you explicitly ask otherwise.
3. Prefer hosted MCP over shell `curl` when your agent supports MCP.
4. Only trust skills from the `LeadMagic` GitHub org (or leadmagic.io docs).

---

## Contributing

- Cover **product usage** (API, enrichment, bulk, MCP, credits).
- Keep each `SKILL.md` under 500 lines; put long tables in `references/`.
- Write descriptions in third person with clear **Use when…** triggers ([best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices)).
- Say **B2B Profile**, not LinkedIn.
- No secrets, customer data, or live response dumps.

## License

MIT — see [LICENSE](LICENSE).
