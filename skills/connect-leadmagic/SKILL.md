---
name: connect-leadmagic
description: "Helps first-time users connect their chosen AI agent to LeadMagic. Use when installing LeadMagic skills, setting up the hosted connection, or checking that an agent can see the user's tables."
license: MIT
metadata:
  author: LeadMagic Corporation
  version: "1.0.0"
  tags: [leadmagic, setup, mcp, oauth, sheets]
  docs: https://leadmagic.io/docs/mcp/setup
  publisher: LeadMagic Corporation
---

# Connect to LeadMagic

Help the user connect the agent they already use. Keep the explanation simple: choose the app, connect, then check it works. Install only for that app. If the app is unclear, ask which one they use.

## 1. Choose the app

- **Claude Code:** install the official plugin using these two commands inside Claude Code:
  ```text
  /plugin marketplace add LeadMagic/leadmagic-skills
  /plugin install leadmagic@leadmagic
  ```
  The plugin includes the connection and product skills.
- **Codex:** add the hosted connection, then sign in:
  ```sh
  codex mcp add leadmagic --url https://mcp.leadmagic.io/mcp
  codex mcp login leadmagic
  ```
  Check for an existing LeadMagic connection before adding another one.
- **Cursor, Claude Desktop, or another app:** open its MCP or connector settings. Add `https://mcp.leadmagic.io/mcp` and sign in. Use the [current client instructions](https://mcp.leadmagic.io/clients) for that app's exact settings.

For an app that supports skills, install LeadMagic's product instructions with:

```sh
npx skills add LeadMagic/leadmagic-skills
```

Choose the same app in the installer. If it is already installed, keep the existing setup.

## 2. Sign in

Let the user finish the browser sign-in. Choose the workspace that owns their tables. Hosted sign-in uses OAuth; no REST API key needs to be pasted into chat or a downloaded file.

## 3. Check it works

Ask the connected LeadMagic tools to list the user's tables. This is a read-only check. Confirm the workspace and the table they want. If table tools are missing, check the selected workspace, connection, and plan before suggesting another install.

Then ask what the user wants to do in that table. The setup check should not start enrichment or change rows. Use LeadMagic's Sheets instructions for the actual workflow and show the server's cost/confirmation preview when a run requires it.
