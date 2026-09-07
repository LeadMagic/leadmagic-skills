# LeadMagic Agent Skills: B2B Enrichment, Search and API Workflows

<img src="https://raw.githubusercontent.com/LeadMagic/.github/main/profile/assets/leadmagic.svg" width="64" height="64" alt="LeadMagic logo">

Agent skills and a Claude Code plugin for LeadMagic B2B data enrichment: email finding and validation, people and company search, bulk CSV workflows, public REST API guidance, and hosted Model Context Protocol (MCP) integration.

[LeadMagic B2B enrichment](https://leadmagic.io?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-intro) · [API documentation](https://leadmagic.io/docs?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-intro) · [Pricing and credits](https://leadmagic.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-intro)

Built for [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) and [Claude Code plugins](https://docs.claude.com/en/docs/claude-code/plugins) (compatible with other skill loaders).

| | |
|---|---|
| **Install (skills)** | `npx skills add LeadMagic/leadmagic-skills` |
| **Install (plugin)** | `/plugin marketplace add LeadMagic/leadmagic-skills` → `/plugin install leadmagic@leadmagic` |
| **API docs** | [leadmagic.io/docs](https://leadmagic.io/docs?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-intro) |
| **API base** | `https://api.leadmagic.io` · `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` (OAuth) |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-intro) |
| **License** | MIT |

---

## Current integration contract

Reviewed against [LeadMagic's public documentation](https://leadmagic.io/docs?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-current-integration-contract) on 2026-09-06. REST uses `https://api.leadmagic.io` and `X-API-Key`; hosted MCP uses `https://mcp.leadmagic.io/mcp` with OAuth; lm-tui uses `lm login`. Keep credentials and customer data out of committed examples.

Email Finder returns validated work emails. Use Email Validation for externally sourced addresses. Check the [current pricing and credit rules](https://leadmagic.io/docs/v1/credits?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-current-integration-contract) before paid work; costs are endpoint- and plan-dependent. API-only integrations must not send app-only `preview` options.


## What's inside

### Product skills

| Skill | When to use | Covers |
|-------|-------------|--------|
| [`leadmagic`](skills/leadmagic/) | Router + complete references | Endpoint quickref, plans & limits, recipes |
| [`api-auth-credits`](skills/api-auth-credits/) | Keys, credits, plans, 401/402/403/429 | `/v1/credits`, plan ladder, error contract |
| [`email-enrichment`](skills/email-enrichment/) | Find/validate email, B2B Profile ↔ email | 5 email endpoints + waterfall order |
| [`people-search`](skills/people-search/) | Audience/ICP discovery | `POST /v3/people/search` + 8 variants, filters, cursors |
| [`people-enrichment`](skills/people-enrichment/) | Known-person enrichment | Profile, mobile, role, employees, job change, posts |
| [`company-enrichment`](skills/company-enrichment/) | Company research | Search, funding, tech, lookalikes, competitors, posts |
| [`company-search`](skills/company-search/) | Account lists / TAM | `POST /v3/companies/search` filters, cursors, lookalikes |
| [`job-search`](skills/job-search/) | Job postings search | `POST /v3/jobs/search` vector/facets/deep, export |
| [`jobs-hiring-intent`](skills/jobs-hiring-intent/) | Hiring signals & triggers | Company signals, 14 intent lenses, bulk domain sweeps |
| [`ads-intelligence`](skills/ads-intelligence/) | Competitor ad research | Google / Meta / B2B ads + details |
| [`bulk-jobs`](skills/bulk-jobs/) | Any list ≥ 50 rows | `/bulk/*` submit, lifecycle, errors, mini-batches |
| [`analytics-observability`](skills/analytics-observability/) | Spend & quality reporting | 11 free `/v1/analytics/*` endpoints |
| [`outbound-recipes`](skills/outbound-recipes/) | Multi-step GTM workflows | 13 credit-aware recipes |
| [`mcp-integration`](skills/mcp-integration/) | Hosted MCP setup | OAuth config, tool→REST map |

### Commands (plugin) — `/leadmagic:<name>`

`check-credits` · `build-list` · `enrich-csv` · `clean-list` · `account-brief` · `decision-makers` · `waterfall-email` · `hiring-signals` · `job-change-sweep` · `competitor-ads` · `lookalikes` · `tam-map` · `usage-report`

### Agents (plugin)

- `leadmagic-outbound` — composes products into pipelines (research, lists, waterfalls, triggers)
- `leadmagic-bulk` — file / multi-row jobs with credit-safe operation

### Hooks (plugin)

A PreToolUse hook asks before any bulk write tool queues a paid job. Free helpers (`check_credit_balance`, `preview_cost`, analytics, catalogs) never prompt.

---

## Install

### Skills only (any agent)

```bash
npx skills add LeadMagic/leadmagic-skills
```

Pin a commit in production: `npx skills add LeadMagic/leadmagic-skills#<sha>`. Or locally:

```bash
./install.sh                 # → ~/.claude/skills/
./install.sh .claude/skills  # project-local
```

### Claude Code plugin (skills + MCP + commands + agents + hooks)

```text
/plugin marketplace add LeadMagic/leadmagic-skills
/plugin install leadmagic@leadmagic
```

The plugin loads the hosted MCP server automatically — complete OAuth in the browser on first use. No API keys in the client.

### Other agent stacks (Codex, Cursor, Windsurf, custom)

- **Skills**: `npx skills add LeadMagic/leadmagic-skills` or copy `skills/` into your loader's skills directory — plain `SKILL.md` + YAML frontmatter, no Claude-specific syntax.
- **AGENTS.md**: agents that follow the [AGENTS.md](AGENTS.md) convention (Codex, Cursor, and most coding agents) pick up the repo rules automatically.
- **MCP**: any MCP-capable client can add `https://mcp.leadmagic.io/mcp` (streamable HTTP, OAuth) — see [`mcp-integration`](skills/mcp-integration/).
- **LLM-native index**: [`llms.txt`](llms.txt) at the repo root maps the whole surface for retrieval tools.

### REST only

Create a key at [app.leadmagic.io](https://app.leadmagic.io?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-install) → Settings → API, set `LEADMAGIC_API_KEY` in your environment. Never paste keys into chat or commit them.

```bash
curl -sS "https://api.leadmagic.io/v1/credits" -H "X-API-Key: $LEADMAGIC_API_KEY"

curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","domain":"example.com"}'
```

---

## Pricing and search access

Use [current LeadMagic pricing](https://leadmagic.io/pricing?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-pricing-and-search-access) and [credit documentation](https://leadmagic.io/docs/v1/credits?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills&utm_content=readme-pricing-and-search-access) to confirm costs, search access, and rate limits for your account. Check your balance before paid workflows. The [plans and limits reference](skills/leadmagic/references/plans-and-limits.md) explains how the skills handle account entitlements.

## Validate

```bash
./scripts/validate.sh          # skill authoring rules
claude plugin validate .       # plugin manifest
```

## Related

- [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi) — OpenAPI snapshot
- [LeadMagic/gtm-skills](https://github.com/LeadMagic/gtm-skills) — GTM strategy playbooks (this repo = the product; that repo = the playbooks)

## Security

No secrets, keys, or customer PII belong in this repo — see [SECURITY.md](SECURITY.md). Only trust skills installed from `github:LeadMagic/*`.

## Public examples and publication

Examples are fictional unless an explicit public source is cited. See [PUBLICATION.md](PUBLICATION.md) for data, claims, attribution, and disclosure requirements.

## License and contributions

[MIT license](LICENSE) · [Third-party materials and contribution policy](LICENSE-NOTES.md). Reuse is allowed under the license; changes to this repository require maintainer review.
