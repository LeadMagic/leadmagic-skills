#!/usr/bin/env bash
# Validate LeadMagic skills against Claude Agent Skills authoring rules:
# https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}LeadMagic Skills — validation${NC}"
echo -e "${BLUE}(Claude Agent Skills best practices)${NC}"
echo ""

errors=0
warnings=0
skill_count=0

fail() {
  echo -e "${RED}✗${NC} $1"
  errors=$((errors + 1))
}

warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  warnings=$((warnings + 1))
}

ok() {
  echo -e "${GREEN}✓${NC} $1"
}

# Extract YAML frontmatter (between first --- pair)
frontmatter() {
  local file="$1"
  awk '
    BEGIN { in_fm=0 }
    /^---[[:space:]]*$/ {
      if (in_fm==0) { in_fm=1; next }
      else { exit }
    }
    in_fm==1 { print }
  ' "$file"
}

fm_get() {
  local fm="$1" key="$2"
  # Support "key: value" and "key: \"value\""
  printf '%s\n' "$fm" | grep -E "^${key}:" | head -1 | sed -E "s/^${key}:[[:space:]]*//" | sed -E 's/^["'\'']//; s/["'\'']$//'
}

has_metadata_key() {
  local fm="$1" key="$2"
  printf '%s\n' "$fm" | grep -Eq "^[[:space:]]+${key}:"
}

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  skill_count=$((skill_count + 1))

  if [ ! -f "$skill_file" ]; then
    fail "$skill_name: missing SKILL.md"
    continue
  fi

  if ! head -1 "$skill_file" | grep -q '^---'; then
    fail "$skill_name: SKILL.md must start with YAML frontmatter (---)"
    continue
  fi

  fm=$(frontmatter "$skill_file")
  yaml_name=$(fm_get "$fm" "name")
  description=$(fm_get "$fm" "description")
  license=$(fm_get "$fm" "license")

  # Required: name
  if [ -z "$yaml_name" ]; then
    fail "$skill_name: missing required frontmatter field 'name'"
    continue
  fi
  if [ "$yaml_name" != "$skill_name" ]; then
    fail "$skill_name: name '$yaml_name' must match folder name"
    continue
  fi
  if [ ${#yaml_name} -gt 64 ]; then
    fail "$skill_name: name exceeds 64 characters (${#yaml_name})"
    continue
  fi
  if echo "$yaml_name" | grep -qE '[^a-z0-9-]'; then
    fail "$skill_name: name must be lowercase letters, numbers, hyphens only"
    continue
  fi
  if echo "$yaml_name" | grep -qiE 'anthropic|claude'; then
    fail "$skill_name: name contains reserved word (anthropic|claude)"
    continue
  fi

  # Required: description (what + when)
  if [ -z "$description" ]; then
    fail "$skill_name: missing required frontmatter field 'description'"
    continue
  fi
  if [ ${#description} -gt 1024 ]; then
    fail "$skill_name: description exceeds 1024 characters (${#description})"
    continue
  fi
  if echo "$description" | grep -qE '[<>]'; then
    fail "$skill_name: description must not contain XML tags (< or >)"
    continue
  fi
  # Heuristic: should include when-to-use language
  if ! echo "$description" | grep -qiE 'use when|when the user|when working|when calling|when setting|when installing|when enriching|when debugging|when researching|when submitting|when asking'; then
    warn "$skill_name: description should include when-to-use triggers (e.g. 'Use when…')"
  fi

  # Recommended: license + metadata block
  if [ -z "$license" ]; then
    warn "$skill_name: missing optional 'license' (recommend MIT)"
  fi
  if ! printf '%s\n' "$fm" | grep -q '^metadata:'; then
    warn "$skill_name: missing 'metadata' block (author, version, tags, docs)"
  else
    for mk in author version tags; do
      if ! has_metadata_key "$fm" "$mk"; then
        warn "$skill_name: metadata missing '$mk'"
      fi
    done
  fi

  # Body length (Claude recommends under 500 lines)
  line_count=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$line_count" -gt 500 ]; then
    fail "$skill_name: SKILL.md is $line_count lines (max 500 — split into references/)"
    continue
  elif [ "$line_count" -gt 400 ]; then
    warn "$skill_name: SKILL.md is $line_count lines (approaching 500)"
  fi

  # No LinkedIn branding (use B2B Profile). Allow only the hosted MCP tool id.
  if grep -niE 'linkedin' "$skill_file" | grep -viE 'linkedin_profile_to_work_email' | grep -q .; then
    fail "$skill_name: contains LinkedIn branding — use 'B2B Profile' instead"
    grep -niE 'linkedin' "$skill_file" | grep -viE 'linkedin_profile_to_work_email' || true
    continue
  fi

  # No secrets patterns
  if grep -qiE 'lm_live_|sk_live_|BEGIN (RSA |OPENSSH )?PRIVATE' "$skill_file"; then
    fail "$skill_name: possible secret material detected"
    continue
  fi

  ok "$skill_name ($line_count lines)"
done

# Repo-wide LinkedIn branding scan (allow MCP tool id only)
if rg -ni 'linkedin' "$SKILLS_DIR" -g '!**/.*' 2>/dev/null | grep -viE 'linkedin_profile_to_work_email' | grep -q .; then
  fail "skills/ still contains LinkedIn branding — use B2B Profile wording"
  rg -ni 'linkedin' "$SKILLS_DIR" | grep -viE 'linkedin_profile_to_work_email' || true
fi

echo ""
echo "Skills checked: $skill_count"
if [ "$warnings" -gt 0 ]; then
  echo -e "${YELLOW}Warnings: $warnings${NC}"
fi

if [ "$errors" -gt 0 ]; then
  echo -e "${RED}Failed with $errors error(s)${NC}"
  exit 1
fi

echo -e "${GREEN}All skills validated successfully${NC}"
