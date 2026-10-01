# Sheet recipes (templates)

A recipe is a sheet minus its data: the columns, in order, and what fills each. Pass one to `import_sheet_recipe` (or **From a recipe** in the app) to build a new sheet; get one from a working sheet with `export_sheet_recipe`. Importing runs nothing and spends nothing — the user still runs columns with `run_sheet_column`.

## Format

```json
{
  "kind": "leadmagic.sheet-recipe",
  "v": 1,
  "name": "Recipe name",
  "description": "Optional, ≤2000 chars",
  "author": { "name": "Display name, never an email" },
  "columns": [ { "ref": "domain", "name": "Domain" } ],
  "connections": []
}
```

Rules:

- `ref` is a lowercase-hyphen id (`^[a-z0-9][a-z0-9-]{0,63}$`). Columns reference each other by `ref`, never by `col_` key.
- `name` is kept verbatim on import, because prompts, formulas and HTTP templates resolve `{Column Name}` by **name**. Keep names unique.
- Document order is the grid order; run order follows the references.
- Up to 200 columns, 50 connections, 10 webhook sources, 256 KB per document.
- Never put keys, tokens, personal data, or workspace ids in a recipe. Account-bound things are **declared** as `connections` and supplied by the importer (`ai_keys`, `leadmagic_keys` on `import_sheet_recipe`).
- Recipes whose API requests need a secret header must be imported in the app, not over MCP.

## Column actions

| `action.kind` | Shape | Notes |
|---|---|---|
| `gateway` | `{ "kind": "gateway", "product": "email_finder", "inputs": { "<product field>": "<column ref>" } }` | Any Sheets enrichment product (see the SKILL.md table) |
| `ai` | `{ "kind": "ai", "style": "text" \| "short" \| "label", "prompt": "… {Column Name} …", "output": { … } }` | `output.type`: `text`, `category` (with `options`, optional `allowEmpty`), `number` (`decimals`), `boolean`, `json`, `email`. Optional `provider` + `model` + `connection` (an `ai` connection) |
| `http` | `{ "kind": "http", "connection": "<http connection ref>", "field": "…", "inputs": { … } }` | The request lives in `connections` as `{ref, kind: "http", label, template, vars, fields}`; secret headers carry no value |
| `formula` | `{ "kind": "formula", "src": "{First Name} & \" \" & {Last Name}" }` | ≤8000 chars |
| `json` | `{ "kind": "json", "source": "<column ref>", "path": ["field", 0, "sub"] }` | One field of another column's response |

A column with no `action` is a manual (input) column. Note the recipe calls category labels `options`; the column tools call them `categories`.

## Ready recipes

### 1. Work emails from name + company

Input: first name, last name, company domain (company name optional). Email Finder returns validated work emails, so no separate validation column is needed.

```json
{
  "kind": "leadmagic.sheet-recipe",
  "v": 1,
  "name": "Work emails from name + domain",
  "columns": [
    { "ref": "first-name", "name": "First Name" },
    { "ref": "last-name", "name": "Last Name" },
    { "ref": "company-name", "name": "Company Name" },
    { "ref": "domain", "name": "Domain" },
    {
      "ref": "work-email",
      "name": "Work Email",
      "action": {
        "kind": "gateway",
        "product": "email_finder",
        "inputs": {
          "first_name": "first-name",
          "last_name": "last-name",
          "company_name": "company-name",
          "domain": "domain"
        }
      }
    }
  ],
  "connections": []
}
```

### 2. Clean an existing email list

Input: emails from another source. Validate before sending.

```json
{
  "kind": "leadmagic.sheet-recipe",
  "v": 1,
  "name": "Validate an email list",
  "columns": [
    { "ref": "email", "name": "Email" },
    {
      "ref": "validation",
      "name": "Validation",
      "action": { "kind": "gateway", "product": "email_validation", "inputs": { "email": "email" } }
    }
  ],
  "connections": []
}
```

### 3. Account qualification

Input: company domains. Enrich the company, then label fit and segment with AI. The AI columns run on the importer's own AI key — map it with `ai_keys`, or the run reports `ai_key_required` and the user adds a key in Sheets → Vault.

```json
{
  "kind": "leadmagic.sheet-recipe",
  "v": 1,
  "name": "Account qualification",
  "columns": [
    { "ref": "domain", "name": "Domain" },
    {
      "ref": "company",
      "name": "Company",
      "action": { "kind": "gateway", "product": "company_search", "inputs": { "domain": "domain" } }
    },
    {
      "ref": "b2b-fit",
      "name": "B2B Fit",
      "action": {
        "kind": "ai",
        "style": "label",
        "prompt": "Based on {Company}, does {Domain} sell to other businesses? Answer true or false.",
        "output": { "type": "boolean" }
      }
    },
    {
      "ref": "segment",
      "name": "Segment",
      "action": {
        "kind": "ai",
        "style": "label",
        "prompt": "Based on {Company}, which segment best fits {Domain}?",
        "output": { "type": "category", "options": ["SMB", "Mid-market", "Enterprise"], "allowEmpty": true }
      }
    }
  ],
  "connections": []
}
```

After the first sample run, call `list_sheet_column_fields` on **Company** and add `extract_sheet_json_field` columns for the fields the user wants (industry, headcount, location…). Don't guess paths before the column has run.

### 4. Decision makers at target accounts

Input: domain + the title to look for. Role Finder returns the person; then find their work email from the extracted name.

1. Import a recipe with `Domain`, `Company Name`, `Job Title` manual columns and a `Decision Maker` column: `{ "kind": "gateway", "product": "role_finder", "inputs": { "domain": "domain", "company_name": "company-name", "job_title": "job-title" } }`.
2. Sample-run `Decision Maker`, then `list_sheet_column_fields` → `extract_sheet_json_field` for first name, last name, and profile URL.
3. Add a `Work Email` enrichment column (`email_finder`) mapped to the extracted first name, last name, the domain, and the company name. Run both with one `run_sheet_column` (`also_column_keys`) — the email column waits for its inputs.

## Turning someone else's workflow into a recipe

When a user describes a workflow from another tool ("find the email, then check it, then write an opener"):

1. Map each step to a column kind: lookup → `gateway`, judgement/writing → `ai`, third-party API → `http`, string assembly → `formula`, pick-a-field → `json`.
2. Write the recipe, show it to the user, then `import_sheet_recipe`.
3. Steps with no Sheets product (job postings, ads, people search) stay outside the sheet — run them with their own skills and add the results as rows.
