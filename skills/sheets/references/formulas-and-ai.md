# Formulas, AI on OpenRouter, and sheet ideas

Formula and JSON columns are free and recompute by themselves when their inputs change. AI columns run on the user's own model key. Put cheap, deterministic work in formulas, judgement and writing in AI, and spend LeadMagic credits only on the lookups.

## Formulas

A formula is a pure function of **one row**. Columns are `{Column Name}` (exact name, case and spaces included); strings use `"…"` or `'…'`.

Operators: `&` (join text), `+ - * /`, `= <> != < <= > >=`, `TRUE`, `FALSE`.

| Group | Functions |
|---|---|
| Text | `CONCAT(v, …)`, `TRIM`, `UPPER`, `LOWER`, `PROPER`, `LEN`, `LEFT(t, n)`, `RIGHT(t, n)`, `MID(t, start, n)`, `REPLACE(t, find, with)`, `SPLIT(t, sep, index)` (1-based) |
| Regex | `REGEX_MATCH(t, pattern)`, `REGEX_EXTRACT(t, pattern)` (first match or first group), `REGEX_REPLACE(t, pattern, with)` |
| Logic | `IF(c, then, else)`, `IFS(c1, v1, c2, v2, …)`, `AND`, `OR`, `NOT`, `COALESCE(v, …)` (first non-blank), `ISBLANK` |
| Numbers | `ROUND(n, digits)`, `FLOOR`, `CEILING`, `ABS`, `MIN`, `MAX`, `SUM`, `NUMBER(text)` |
| People & web | `DOMAIN(url or email)`, `EMAIL_USER(email)`, `FIRST_WORD`, `LAST_WORD`, `CLEAN_PERSON_NAME` (drops titles, suffixes, credentials), `NAME_FIRST(full name)`, `NAME_LAST(full name)` |
| Dates & ids | `TODAY()` (YYYY-MM-DD), `YEAR`, `MONTH`, `DAY`, `RECORD_ID()` |

Limits: 32 levels of nesting, 64 KB per built value, regex patterns ≤200 characters. There are no cross-row references or ranges — every row stands alone.

Handy formulas:

| Goal | Formula |
|---|---|
| First name from a messy full name | `NAME_FIRST(CLEAN_PERSON_NAME({Full Name}))` |
| Domain from a website or an email | `DOMAIN(COALESCE({Website}, {Email}))` |
| Role inbox flag | `REGEX_MATCH(EMAIL_USER({Email}), "^(info\|sales\|support\|admin\|hello\|contact\|team)$")` |
| Safe greeting | `IF(ISBLANK({First Name}), "Hi there", "Hi " & PROPER({First Name}))` |
| Best email available | `COALESCE({Work Email}, {Email})` |
| Routing from an AI tier | `IFS({Tier} = "A", "Call this week", {Tier} = "B", "Sequence", TRUE, "Nurture")` |
| Clean phone digits | `REGEX_REPLACE({Phone}, "[^0-9+]", "")` |

Set one with `configure_sheet_column` (`kind: "formula"`, `formula: "…"`) or in a recipe as `{ "kind": "formula", "src": "…" }`.

## AI columns on OpenRouter (one-time setup)

OpenRouter gives one key for hundreds of models, so it is the simplest way to light up AI columns.

1. Create a key at [openrouter.ai/keys](https://openrouter.ai/keys) (it starts with `sk-or-`) and add credit there. Model usage bills to that account, not to LeadMagic credits.
2. In the app: Sheet Enrichment → **Vault** → add the key under **OpenRouter** and make it the default. Never paste the key into chat or a recipe.
3. On an AI column set `provider: "openrouter"` and a `model` in `vendor/model` form — the app's default is `openai/gpt-5.4-mini`; any model id OpenRouter lists works. For `category`, `boolean`, `number` or `json` output, pick a model that supports structured output (the app's model picker marks them).
4. Run it. A column without its own key uses the default saved key for its provider; if none is saved the run reports `ai_key_required` — send the user back to step 2.

Cost control: AI output tokens are the user's spend on OpenRouter. Start every AI column with `sample_size: 5`, keep prompts short, and use `short` / `label` styles for classification.

## Sheet ideas

Each idea lists its columns left to right: **manual** inputs, then *(formula)*, *(AI)*, and *(credits)* columns. All of them are a few clicks in the app or one `add_sheet_columns` call.

1. **Lead list cleanup → work emails.** Full Name, Website → First Name *(formula `NAME_FIRST(CLEAN_PERSON_NAME({Full Name}))`)*, Last Name *(formula `NAME_LAST(…)`)*, Domain *(formula `DOMAIN({Website})`)* → Work Email *(credits: `email_finder` on first/last/domain)*. Formulas do the cleanup for free, so the finder hits more rows.
2. **Inbound triage.** Email, Message (from a webhook or paste) → Domain *(formula)*, Role Inbox *(formula regex)* → Company *(credits: `company_search` on Domain)* → Intent *(AI on OpenRouter, category `Buying / Support / Job seeker / Spam`)* → Route *(formula `IFS(...)` on Intent)*.
3. **Account tiering.** Domain → Company *(credits: `company_search`)* → Tier *(AI category `A / B / C` with your ICP in the prompt)* → Next Step *(formula routing from Tier)*. Re-run only Tier when the ICP changes — no credits.
4. **First-line personalisation.** First Name, Company Name, Title, Domain → Greeting *(formula safe greeting)* → Opener *(AI text, ≤25 words, prompt names `{Title}` and `{Company Name}`)* → Line *(formula `{Greeting} & ", " & {Opener}`)*. Pair with `email_finder` when the email is missing.
5. **Email hygiene before a send.** Email → Email Domain *(formula `DOMAIN({Email})`)*, Role Inbox *(formula)* → Validation *(credits: `email_validation`, the cheapest product)* → Send? *(formula `AND(NOT({Role Inbox}), {Validation} <> "")` — tighten once you see the Validation fields with `list_sheet_column_fields`)*.
6. **Job-change sweep for a customer list.** Profile URL, Domain, Company Name → Job Change *(credits: `job_change_detector`)* → JSON-extracted status fields → Talk Track *(AI text on OpenRouter for the changed rows only — run with a `filter`)*.
7. **Decision makers per account.** Domain, Company Name, Job Title → Decision Maker *(credits: `role_finder`)* → First / Last / Profile URL *(json columns)* → Work Email *(credits: `email_finder`)*. One `run_sheet_column` with `also_column_keys` runs the chain in order.

Turn any idea that works into a template with `export_sheet_recipe`, and share it with the team via **From a recipe**.

## Recipe with formulas + OpenRouter

```json
{
  "kind": "leadmagic.sheet-recipe",
  "v": 1,
  "name": "Clean, find and personalise",
  "columns": [
    { "ref": "full-name", "name": "Full Name" },
    { "ref": "company-name", "name": "Company Name" },
    { "ref": "website", "name": "Website" },
    { "ref": "title", "name": "Title" },
    { "ref": "first-name", "name": "First Name", "action": { "kind": "formula", "src": "NAME_FIRST(CLEAN_PERSON_NAME({Full Name}))" } },
    { "ref": "last-name", "name": "Last Name", "action": { "kind": "formula", "src": "NAME_LAST(CLEAN_PERSON_NAME({Full Name}))" } },
    { "ref": "domain", "name": "Domain", "action": { "kind": "formula", "src": "DOMAIN({Website})" } },
    {
      "ref": "work-email",
      "name": "Work Email",
      "action": {
        "kind": "gateway",
        "product": "email_finder",
        "inputs": { "first_name": "first-name", "last_name": "last-name", "domain": "domain", "company_name": "company-name" }
      }
    },
    {
      "ref": "opener",
      "name": "Opener",
      "action": {
        "kind": "ai",
        "style": "short",
        "provider": "openrouter",
        "model": "openai/gpt-5.4-mini",
        "connection": "openrouter",
        "prompt": "Write one friendly opening line (max 25 words) for {First Name}, {Title} at {Company Name}. No flattery, no questions.",
        "output": { "type": "text" }
      }
    },
    {
      "ref": "line",
      "name": "Line",
      "action": { "kind": "formula", "src": "IF(ISBLANK({First Name}), \"Hi there\", \"Hi \" & PROPER({First Name})) & \", \" & {Opener}" }
    }
  ],
  "connections": [
    { "ref": "openrouter", "kind": "ai", "provider": "openrouter", "label": "OpenRouter key" }
  ]
}
```

Import it from **From a recipe** in the app (it asks which saved OpenRouter key to use), or over MCP with `import_sheet_recipe` — pass `ai_keys: {"openrouter": "<vault key id>"}` when you have the id, or leave it out and the column runs on the default saved OpenRouter key.
