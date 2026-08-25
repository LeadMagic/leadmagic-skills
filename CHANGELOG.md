# Changelog

All notable changes to this repository. Format follows [Keep a Changelog](https://keepachangelog.com/); versions track the `leadmagic` router skill / plugin version.

## [3.0.0] — 2026-08-25

### Added
- **Claude Code plugin**: `.claude-plugin/plugin.json` + `marketplace.json`, bundled hosted MCP (`.mcp.json` → `https://mcp.leadmagic.io/mcp`), PreToolUse credit-guard hook on bulk writes.
- **New skills**: `jobs-hiring-intent` (company signals, 14 intent lenses, bulk domain sweeps), `ads-intelligence` (Google/Meta/B2B ads), `analytics-observability` (11 free `/v1/analytics/*` endpoints), `outbound-recipes` (recipe index + operating rules).
- **References**: complete endpoint quickref synced from the live API contract (costs, per-minute rate limits, aliases); `plans-and-limits.md` (plan ladder, Search API entitlements, 402/429 playbook); `outbound-recipes.md` (13 credit-aware recipes).
- **13 slash commands** (`/leadmagic:build-list`, `enrich-csv`, `clean-list`, `account-brief`, `decision-makers`, `waterfall-email`, `hiring-signals`, `job-change-sweep`, `competitor-ads`, `lookalikes`, `tam-map`, `usage-report`, `check-credits`).
- **Agents**: `leadmagic-outbound` (pipeline builder), `leadmagic-bulk` (CSV operator).
- Root `llms.txt` for LLM-native discovery.

### Changed
- All existing skills rewritten with plan awareness (credit-free Search API on Professional/Ultimate), cost-ordered waterfalls, exact field contracts, and MCP tool maps; versions bumped to 3.0.0.
- `validate.sh` now also checks plugin manifests (JSON parse + referenced paths), command/agent frontmatter, hook script executability; CI adds shellcheck and `claude plugin validate`.
- README/AGENTS.md/install.sh refreshed for the 14-skill, plugin-first layout.

## [2.x]
- V3 search skills (`job-search`, `company-search`), cursor pagination docs, agent-first install.

## [1.x]
- Initial 8 product skills.
