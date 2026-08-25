# LeadMagic Skills

Official agent skills for **using LeadMagic** — 400M+ people, 25M+ companies, and 46M+ job postings, plus email finder & validation, B2B Profile enrichment, bulk CSV jobs, credits, and hosted MCP.

Built for [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) (and compatible skill loaders — Codex, Cursor, and friends). Authoring follows Anthropic's [best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices).

| | |
|---|---|
| **Install skills** | `npx skills add LeadMagic/leadmagic-skills` |
| **MCP** | `https://mcp.leadmagic.io/mcp` (OAuth — sign in, no key) |
| **API base** | `https://api.leadmagic.io` · `X-API-Key` |
| **API docs** | [leadmagic.io/docs](https://leadmagic.io/docs) |
| **Dashboard** | [app.leadmagic.io](https://app.leadmagic.io) |
| **License** | MIT |

> **Unlimited search on Professional & Ultimate plans:** `POST /v3/people/search`, `POST /v3/companies/search`, and `POST /v3/jobs/search` are **credit-free with no volume cap** — rate-limited only, at 5 req/s (Professional) or 10 req/s (Ultimate). The skills teach your agent to use that: go broad, page with cursors, never ration.

---

## Install

### Any agent (skills CLI)

```bash
npx skills add LeadMagic/leadmagic-skills
```

Pin a commit in production: `npx skills add LeadMagic/leadmagic-skills#<commit-sha>`

### Claude Code — paste this prompt

Copy the block below into Claude Code and it sets everything up itself:

```text
Set up LeadMagic for me.

1. Install the official skills: run `npx skills add LeadMagic/leadmagic-skills`
   (or copy this repo's skills/ into ~/.claude/skills/).
2. Register the hosted MCP server. LeadMagic connects by OAuth sign-in, not an
   API key — so don't ask me for one, and don't add any --header flag (a stored
   credential suppresses the sign-in flow). Run exactly:
     claude mcp add --transport http --scope user leadmagic https://mcp.leadmagic.io/mcp
   If a leadmagic server already exists, remove it first with
     claude mcp remove leadmagic --scope user
3. Tell me to run /mcp, select leadmagic, choose Authenticate, and sign in at
   app.leadmagic.io. If I don't have an account, I create one there first.
4. Verify before calling it done: confirm the leadmagic tools are listed, or run
   "check my LeadMagic credit balance" (free).

Only if the sign-in genuinely fails: ask me for an API key from
app.leadmagic.io → Settings → API and re-add the server with
--header "Authorization: Bearer MY_KEY" (paste the key literally — env-var
substitution in headers fails silently in Claude Code).
```

Or by hand:

```bash
npx skills add LeadMagic/leadmagic-skills
claude mcp add --transport http --scope user leadmagic https://mcp.leadmagic.io/mcp
```

Then `/mcp` → `leadmagic` → **Authenticate**.

### Claude.ai / Claude Desktop

1. Open [claude.ai/customize](https://claude.ai/customize) (or **Customize** in the desktop app)
2. **Connectors** → **+ Add custom connector**
3. Name it `leadmagic`, URL: `https://mcp.leadmagic.io/mcp`
4. **Connect**, sign in, **Allow** — then ask Claude to find leads

### ChatGPT

1. Open **chatgpt.com → Settings → Apps → Advanced settings**
2. Turn on **Developer mode**, press **Create app**
3. Name it `leadmagic`, Connection: `https://mcp.leadmagic.io/mcp`
4. **Sign in with LeadMagic** — done

### Codex — paste this prompt

```text
Set up the LeadMagic MCP server for me in Codex.

LeadMagic connects by OAuth sign-in, not an API key — don't ask me for one.

1. Add a streamable-HTTP MCP server named `leadmagic` to my Codex config.toml
   (~/.codex/config.toml on Mac/Linux) with just:
     [mcp_servers.leadmagic]
     url = "https://mcp.leadmagic.io/mcp"
   Leave auth at its default (oauth); don't set bearer_token_env_var. If a
   leadmagic block already exists, update it in place.
2. Tell me to fully quit and reopen Codex.
3. Get me signed in: desktop/IDE → Authenticate next to leadmagic in the MCP
   servers list; CLI → run `codex mcp login leadmagic`. I log in at
   app.leadmagic.io and press Allow.
4. Verify before calling it done: /mcp lists leadmagic and its tools, or run
   "check my LeadMagic credit balance".
```

### Cursor / Windsurf / VS Code / anything MCP

URL-only config, OAuth in the client:

```jsonc
{ "mcpServers": { "leadmagic": { "url": "https://mcp.leadmagic.io/mcp" } } }
```

Full per-client walkthroughs: [leadmagic.io/docs/mcp/setup](https://leadmagic.io/docs/mcp/setup)

---

## Skills

| Skill | When to use | Tags |
|-------|-------------|------|
| [`leadmagic`](skills/leadmagic/) | General LeadMagic help — routes to the skills below | `leadmagic`, `enrichment`, `mcp`, `official` |
| [`people-search`](skills/people-search/) | Audience / ICP search — 400M+ people (`POST /v3/people/search`) | `people-search`, `v3`, `unlimited` |
| [`company-search`](skills/company-search/) | Account lists & lookalikes — 25M+ companies (`POST /v3/companies/search`) | `company-search`, `v3`, `unlimited` |
| [`job-search`](skills/job-search/) | Job postings & hiring signals — 46M+ jobs (`POST /v3/jobs/search`) | `job-search`, `v3`, `unlimited` |
| [`api-auth-credits`](skills/api-auth-credits/) | API keys, credit balance, 401 / 429 | `api`, `auth`, `credits` |
| [`email-enrichment`](skills/email-enrichment/) | Find or validate email; B2B Profile ↔ email | `email-finder`, `email-validation` |
| [`people-enrichment`](skills/people-enrichment/) | B2B Profile, mobile, role, employees | `mobile`, `b2b-profile`, `role-finder` |
| [`company-enrichment`](skills/company-enrichment/) | V1 company enrichment & funding | `company`, `funding`, `technographics` |
| [`bulk-jobs`](skills/bulk-jobs/) | CSV / async bulk submit & status | `bulk`, `csv`, `jobs` |
| [`mcp-integration`](skills/mcp-integration/) | Hosted MCP setup for every client | `mcp`, `oauth` |

Each skill's `SKILL.md` has:

- **Required:** `name`, `description` (what it does **and** when to use it)
- **Recommended:** `license`, `compatibility`, `metadata` (`author`, `version`, `tags`, `docs`)

---

## Quick example

```bash
curl -sS "https://api.leadmagic.io/v1/credits" \
  -H "X-API-Key: $LEADMAGIC_API_KEY"

# Unlimited on Professional/Ultimate — no credit burn, 5–10 req/s:
curl -sS -X POST "https://api.leadmagic.io/v3/people/search" \
  -H "X-API-Key: $LEADMAGIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"company_filters":{"company_domain":["acme.com"]},"people_filters":{"contact_job_function":["Sales"]},"limit":25}'
```

Paginate every search the same way: send the response's `next_cursor` back as `cursor` with the **same filters**, never alongside a nonzero `offset`, pages of ≤50, stop when `has_more` is false.

More examples: [People Search](https://leadmagic.io/docs/api-reference/people-search) · [Company Search](https://leadmagic.io/docs/api-reference/company-search-v3) · [Job Search](https://leadmagic.io/docs/api-reference/job-search) · [full docs](https://leadmagic.io/docs)

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
