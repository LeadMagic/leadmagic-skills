#!/usr/bin/env bash
# PreToolUse approval policy for LeadMagic MCP tools (mcp__plugin_leadmagic_leadmagic__*
# from this plugin, mcp__leadmagic__* when the server was added by hand).
#
# Auto-approves every LeadMagic tool except ASK_BEFORE_TOOLS, which still prompt
# because they queue paid jobs, start paid runs, move data in or out of connected
# systems, or delete. Emits no decision at all (Claude Code's normal permission
# flow) when stdin cannot be parsed, the tool is not a LeadMagic tool, or
# LEADMAGIC_ASK_ALL=1 is set.
#
# The ASK_BEFORE_TOOLS array mirrors the Claude Code permissions snippet on
# app.leadmagic.io (Settings -> API -> AI tooling). One "tool:group" entry per
# line, double-quoted, sorted. Groups: bulk | run | import | push | delete.
# Tools not listed by name still ask when their name starts with an acting verb
# (import_, push_, publish_, run_, resume_, submit_, restart_, delete_, remove_).
#
# Bash 3.2 compatible (macOS /bin/bash): no associative arrays, no lowercasing.
set -euo pipefail

ASK_BEFORE_TOOLS=(
  "create_bulk_upload_session:bulk"
  "delete_sheet_column:delete"
  "delete_sheet_rows:delete"
  "find_local_leads:bulk"
  "import_sheet_recipe:import"
  "process_attached_csv:bulk"
  "restart_bulk_job:bulk"
  "resume_bulk_job:run"
  "run_sheet_column:run"
  "save_sheet_http_request:push"
  "set_sheet_column_auto_run:run"
  "submit_bulk_job:bulk"
  "submit_detected_bulk_job:bulk"
  "test_sheet_http_request:push"
  "update_sheet_http_request:push"
)

# Always drain stdin first, even when we decide to say nothing.
input="$(cat || true)"

# Escape hatch: fall back to Claude Code's own permission rules for every tool.
if [[ "${LEADMAGIC_ASK_ALL:-}" == "1" ]]; then
  exit 0
fi

# Leftmost match wins. Claude Code emits tool_name before tool_input, so a
# "tool_name" string inside tool_input cannot shadow the real key.
tool_name_pattern='"tool_name"[[:space:]]*:[[:space:]]*"([^"]*)"'
tool=""
if [[ "$input" =~ $tool_name_pattern ]]; then
  tool="${BASH_REMATCH[1]}"
fi

# Only decide for well-formed LeadMagic tool names; anything else gets no output.
# The strict charset is also what makes $name safe to interpolate into JSON below.
# Claude Code scopes a plugin-bundled server's tools as
# mcp__plugin_<plugin>_<server>__<tool>; a server added by hand is mcp__<server>__<tool>.
if [[ ! "$tool" =~ ^mcp__(plugin_leadmagic_)?leadmagic__([a-z0-9_]+)$ ]]; then
  exit 0
fi
name="${BASH_REMATCH[2]}"

group=""
for entry in "${ASK_BEFORE_TOOLS[@]}"; do
  if [[ "${entry%%:*}" == "$name" ]]; then
    group="${entry##*:}"
    break
  fi
done

# Name-agnostic fallback: anything that imports, pushes, runs, queues or deletes.
if [[ -z "$group" ]]; then
  case "$name" in
    import_*) group="import" ;;
    push_*) group="push" ;;
    publish_*|run_*|resume_*) group="run" ;;
    submit_*|restart_*) group="bulk" ;;
    delete_*|remove_*) group="delete" ;;
  esac
fi

emit() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$2"
}

if [[ -z "$group" ]]; then
  emit allow "LeadMagic ${name}: read or single-record tool, auto-approved by the LeadMagic plugin. Set LEADMAGIC_ASK_ALL=1 to prompt for every tool."
  exit 0
fi

# The hosted server runs these tools only when the call carries the
# confirmation_token its first, preview-only call returned. So the preview runs
# unprompted and the person is asked once, on the call that would act. The two
# widget openers carry no token and always ask.
case "$name" in
  create_bulk_upload_session|process_attached_csv) ;;
  *)
    token_pattern='"confirmation_token"[[:space:]]*:[[:space:]]*"'
    if [[ ! "$input" =~ $token_pattern ]]; then
      emit allow "LeadMagic ${name}: preview only. Nothing runs until you approve the follow-up call that carries its confirmation_token."
      exit 0
    fi ;;
esac

case "$group" in
  bulk)
    reason="LeadMagic ${name} queues a paid bulk job that bills every row. Check preview_cost and check_credit_balance, confirm the row count, then approve." ;;
  run)
    reason="LeadMagic ${name} starts a paid run. Confirm the max credits shown by the preview call before approving." ;;
  import)
    reason="LeadMagic ${name} imports records from a connected CRM or sequencer into a LeadMagic sheet. Check platform, object and maxRows before approving." ;;
  push)
    reason="LeadMagic ${name} writes sheet rows out to a connected CRM or sequencer. Review the selected rows and destination before approving." ;;
  delete)
    reason="LeadMagic ${name} deletes rows or list members in your LeadMagic workspace. Confirm the ids before approving." ;;
  *)
    reason="LeadMagic ${name} needs explicit approval under the LeadMagic plugin policy." ;;
esac
emit ask "$reason"
