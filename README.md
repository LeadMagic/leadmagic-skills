# LeadMagic Skills & Plugin

Official agent skills **and Claude Code plugin** for using LeadMagic — every public API endpoint, plan-aware credit guidance, bulk CSV jobs, hosted MCP, and 13 outbound-system recipes.

Built for [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) and [Claude Code plugins](https://docs.claude.com/en/docs/claude-code/plugins) (compatible with other skill loaders).

| | |
|---|---|
| **Install (skills)** | `npx skills add LeadMagic/leadmagic-skills` |
| **Install (plugin)** | `/plugin marketplace add LeadMagic/leadmagic-skills` → `/plugin install leadmagic@leadmagic` |
| **API docs** | [leadmagic.io/docs](https://leadmagic.io/docs?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills) |
| **API base** | `https://api.leadmagic.io` · `X-API-Key` |
| **MCP** | `https://mcp.leadmagic.io/mcp` (OAuth) |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills) |
| **License** | MIT |

---

## What's inside

### Skills — full API coverage

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

Create a key at [app.leadmagic.io](https://app.leadmagic.io?utm_source=github&utm_medium=readme&utm_campaign=leadmagic-skills) → Settings → API, set `LEADMAGIC_API_KEY` in your environment. Never paste keys into chat or commit them.

```bash
curl -sS "https://api.leadmagic.io/v1/credits" -H "X-API-Key: $LEADMAGIC_API_KEY"

curl -sS -X POST "https://api.leadmagic.io/v1/people/email-finder" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" -H "Content-Type: application/json" \
  -d '{"first_name":"Jane","last_name":"Doe","domain":"acme.com"}'
```

---

## Plans at a glance

| Plan | Monthly | Credits/mo | Search API |
|---|---|---|---|
| Basic | $49.99 | 2,000 | metered |
| Essential | $99 | 5,000 | metered |
| Growth | $249 | 20,000 | metered |
| Professional | $499 | 50,000 | **credit-free @ 5 req/s** |
| Ultimate | $849 | 100,000 | **credit-free @ 10 req/s** |

Annual = 12× credits up front at ~2 months free. Full detail: [`plans-and-limits.md`](skills/leadmagic/references/plans-and-limits.md).

## Validate

```bash
./scripts/validate.sh          # skill authoring rules
claude plugin validate .       # plugin manifest
```

## Related

- [LeadMagic/leadmagic-openapi](https://github.com/LeadMagic/leadmagic-openapi) — OpenAPI snapshot
- [LeadMagic/gtm-skills](https://github.com/LeadMagic/gtm-skills) — 205 GTM strategy skills (this repo = the product; that repo = the playbooks)

## Security

No secrets, keys, or customer PII belong in this repo — see [SECURITY.md](SECURITY.md). Only trust skills installed from `github:LeadMagic/*`.
