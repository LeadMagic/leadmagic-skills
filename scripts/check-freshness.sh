#!/bin/bash
set -e

# LeadMagic Skills - Context7 Freshness Check
# Validates skills against latest documentation from Context7

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}LeadMagic Skills - Context7 Freshness Check${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

# Skill to Context7 library mapping
# Format: skill_name:context7_library_id
MAPPINGS=(
    "hono-v4:hono/hono"
    "react-best-practices:facebook/react"
    "nextjs-app-router:vercel/next.js"
    "cloudflare-workers:cloudflare/workers-sdk"
    "cloudflare-d1:cloudflare/workers-sdk"
    "cloudflare-kv:cloudflare/workers-sdk"
    "cloudflare-r2:cloudflare/workers-sdk"
    "cloudflare-durable-objects:cloudflare/workers-sdk"
    "cloudflare-workflows:cloudflare/workers-sdk"
    "cloudflare-ai-gateway:cloudflare/workers-sdk"
    "wrangler:cloudflare/workers-sdk"
    "drizzle-orm:drizzle-team/drizzle-orm"
    "tanstack-query:tanstack/query"
    "tanstack-table:tanstack/table"
    "vercel-ai-sdk:vercel/ai"
    "typescript-best-practices:microsoft/TypeScript"
    "stripe-payments:stripe/stripe-node"
    "inngest:inngest/inngest-js"
    "biome:biomejs/biome"
    "upstash:upstash/redis"
    "opentelemetry:open-telemetry/opentelemetry-js"
    "tinybird:tinybirdco/tinybird-typescript-sdk"
    "axiom:axiomhq/axiom-js"
)

echo -e "${BLUE}Technology Mappings:${NC}"
echo ""
printf "  %-30s %s\n" "SKILL" "CONTEXT7 LIBRARY"
printf "  %-30s %s\n" "─────────────────────────────" "─────────────────────────────"

for mapping in "${MAPPINGS[@]}"; do
    skill_name="${mapping%%:*}"
    library_id="${mapping##*:}"

    skill_file="$SKILLS_DIR/$skill_name/SKILL.md"

    if [ -f "$skill_file" ]; then
        printf "  ${GREEN}%-30s${NC} %s\n" "$skill_name" "$library_id"
    else
        printf "  ${YELLOW}%-30s${NC} %s ${YELLOW}(skill not found)${NC}\n" "$skill_name" "$library_id"
    fi
done

echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}How to Update Skills with Context7:${NC}"
echo ""
echo "  1. Use Claude Code with Context7 MCP enabled:"
echo ""
echo "     npx @anthropic-ai/claude-code"
echo ""
echo "  2. Ask Claude to update a skill using Context7:"
echo ""
echo "     \"Update the hono-v4 skill using Context7 to fetch"
echo "      the latest Hono v4 documentation and patterns\""
echo ""
echo "  3. Or use the MCP tool directly:"
echo ""
echo "     use_mcp_tool context7 resolve {\"libraryName\": \"hono/hono\"}"
echo "     use_mcp_tool context7 get_library_docs {\"context7CompatibleLibraryID\": \"/hono/hono\"}"
echo ""
echo -e "${BLUE}Context7 MCP Setup:${NC}"
echo ""
echo "  Add to ~/.claude/mcp.json:"
echo ""
echo "  {"
echo "    \"mcpServers\": {"
echo "      \"context7\": {"
echo "        \"command\": \"npx\","
echo "        \"args\": [\"-y\", \"@anthropic-ai/context7-mcp\"]"
echo "      }"
echo "    }"
echo "  }"
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
