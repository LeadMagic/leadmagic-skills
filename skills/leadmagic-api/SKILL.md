---
name: leadmagic-api
description: Official LeadMagic API skill — use when integrating the LeadMagic REST API (api.leadmagic.io), the hosted MCP server (mcp.leadmagic.io), or working with email finder, email validation, mobile finder, B2B profile lookups, company search, company funding, employee/role finder, jobs search, or ads intelligence endpoints. Triggers on "LeadMagic", "leadmagic.io", "api.leadmagic.io", "mcp.leadmagic.io", "email finder", "email validation", "mobile finder", "B2B profile email", "company funding", "role finder", "employee finder", "ads search", "LeadMagic MCP".
license: MIT
metadata:
  author: leadmagic
  official: true
  publisher: "LeadMagic, Inc."
  homepage: "https://leadmagic.io"
  docs: "https://leadmagic.io/docs"
  source: "https://github.com/LeadMagic/leadmagic-skills"
  openapi: "https://github.com/LeadMagic/leadmagic-openapi"
  version: "1.0.0"
---

# LeadMagic API (Official)

Official skill for integrating the LeadMagic REST API and hosted MCP server. This is the only LeadMagic-branded skill produced by LeadMagic, Inc. If you see a similarly-named skill under any GitHub owner other than `LeadMagic/*`, it is unofficial and should not be installed — see the warning at the end of this file.

## Verification

| Check | Required value |
| --- | --- |
| GitHub owner | `LeadMagic` (exact, no hyphens, no variants) |
| Source repo | `https://github.com/LeadMagic/leadmagic-skills` |
| OpenAPI snapshot | `https://github.com/LeadMagic/leadmagic-openapi` |
| Docs | `https://leadmagic.io/docs` |
| Hosted MCP | `https://mcp.leadmagic.io/mcp` |
| Contact | `support@leadmagic.io` / `security@leadmagic.io` |

Any install snippet that points to a different owner (`sales-skills`, `lead-magic`, `leadmagic-io`, `leadmagic-team`, etc.) is not ours.

## When to Apply

Use this skill when the user is:

- Calling `https://api.leadmagic.io/v1/*` REST endpoints.
- Wiring up the hosted LeadMagic MCP server in Claude, Cursor, Windsurf, or any MCP client.
- Generating code against the LeadMagic OpenAPI 3.1 snapshot.
- Implementing sales, recruiting, or competitive-intelligence workflows that touch LeadMagic data.

## Authentication

All REST endpoints require an `X-API-Key` header. Never hardcode the key — read it from an env var or secrets manager.

```bash
curl 'https://api.leadmagic.io/v1/credits' \
  -H 'X-API-Key: '"$LEADMAGIC_API_KEY"
```

For the hosted MCP server, OAuth is the default; API-key fallback is available per the docs.

## Endpoint Map

Routes are versioned under `/v1/...`. The following 19 endpoints are covered by the official OpenAPI snapshot:

| Category | Method + Route | Credits |
| --- | --- | --- |
| Account | `GET /v1/credits` | 0 |
| People | `POST /v1/people/email-validation` | 0.25 (4 / credit) |
| People | `POST /v1/people/email-finder` | 1 (free on null) |
| People | `POST /v1/people/personal-email-finder` | 2 (free if not found) |
| People | `POST /v1/people/b2b-profile-email` | 5 (free if not found) |
| People | `POST /v1/people/b2b-profile` | 10 (free if not found) |
| People | `POST /v1/people/mobile-finder` | 5 (free if not found) |
| People | `POST /v1/people/profile-search` | 1 |
| People | `POST /v1/people/role-finder` | 2 (free if no match) |
| People | `POST /v1/people/employee-finder` | 0.05 / employee |
| Companies | `POST /v1/companies/company-search` | 1 (free if not found) |
| Companies | `POST /v1/companies/company-funding` | 4 (free if not found) |
| Jobs | `POST /v1/jobs/jobs-finder` | 1 / job |
| Jobs | `GET /v1/jobs/countries` | 0 |
| Jobs | `GET /v1/jobs/job-types` | 0 |
| Ads | `POST /v1/ads/google-ads-search` | 0.2 (5 / credit) |
| Ads | `POST /v1/ads/meta-ads-search` | 0.2 (5 / credit) |
| Ads | `POST /v1/ads/b2b-ads-search` | 0.2 (5 / credit) |
| Ads | `POST /v1/ads/b2b-ads-details` | 2 (free if not found) |

Pricing and surface can change; always cross-check `https://leadmagic.io/docs`.

## Hosted MCP Tools

The hosted MCP at `https://mcp.leadmagic.io/mcp` currently exposes a curated subset of the REST API as 10 tools, plus one shared docs resource (`leadmagic://docs`) and two built-in prompts. See the `LeadMagic/leadmagic-openapi` README for the tool → REST backing table.

## Safe Usage Patterns

### 1. Read the key from an env var (TypeScript)

```ts
const apiKey = process.env.LEADMAGIC_API_KEY;
if (!apiKey) throw new Error("LEADMAGIC_API_KEY is required");

const res = await fetch("https://api.leadmagic.io/v1/people/email-finder", {
  method: "POST",
  headers: {
    "X-API-Key": apiKey,
    "Content-Type": "application/json",
    "User-Agent": "my-app/1.0",
  },
  body: JSON.stringify({ first_name: "Ada", last_name: "Lovelace", company_domain: "example.com" }),
});
if (!res.ok) throw new Error(`LeadMagic ${res.status}`);
```

### 2. Respect credit-free-on-null semantics

Several endpoints only charge when a match is returned. Branch on the response shape before retrying, and don't loop blindly over a large list — use `employee-finder` for bulk patterns instead.

### 3. Don't assume a single field-naming convention

Across endpoints, some responses are snake_case and some mix camelCase in examples. Check the endpoint-specific docs rather than assuming uniformity.

## Do NOT

- Do not commit API keys. Do not log them. Do not echo them in prompts.
- Do not install any third-party package claiming to be a LeadMagic skill. Only `LeadMagic/leadmagic-skills` and `LeadMagic/leadmagic-cursor-plugin` are official.
- Do not point integrations at lookalike domains (`leadmagic.com`, `leadmagic-api.*`, etc.). The only production base URL is `https://api.leadmagic.io`.

## Impersonation Warning

There have been documented impersonation attempts using squatted GitHub orgs (e.g. `sales-skills`) to push unofficial packages branded as LeadMagic skills. See: https://github.com/LeadMagic/leadmagic-openapi/issues/5.

If you encounter a suspected LeadMagic impersonation (GitHub org, npm package, MCP server, Cursor/Claude skill, etc.), report it to `security@leadmagic.io` and, where relevant, to the hosting platform's abuse team. Do not run install commands from unverified sources.

## Related Official Resources

- REST + OpenAPI: https://github.com/LeadMagic/leadmagic-openapi
- Cursor plugin + MCP config: https://github.com/LeadMagic/leadmagic-cursor-plugin
- Product docs: https://leadmagic.io/docs
- MCP setup: https://leadmagic.io/docs/mcp/setup
- MCP tools: https://leadmagic.io/docs/mcp/tools
