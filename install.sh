#!/bin/bash
set -e

# LeadMagic product skills installer
# Installs skills/ into Claude (or a custom) skills directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="${1:-$HOME/.claude/skills}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}LeadMagic Product Skills${NC}"
echo -e "${BLUE}════════════════════════${NC}"
echo ""

mkdir -p "$TARGET_DIR"

echo -e "${YELLOW}Installing product skills...${NC}"
echo ""

installed=0

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")

    if [ ! -f "$skill_dir/SKILL.md" ]; then
        continue
    fi

    cp -r "$skill_dir" "$TARGET_DIR/"
    echo -e "  ${GREEN}✓${NC} $skill_name"
    installed=$((installed + 1))
done

echo ""
echo -e "${GREEN}Done!${NC} Installed ${BLUE}$installed${NC} skills to: ${BLUE}$TARGET_DIR${NC}"
echo ""
echo -e "${YELLOW}Product skills:${NC}"
echo "  • leadmagic            — router / overview"
echo "  • api-auth-credits     — keys, credits, rate limits"
echo "  • email-enrichment     — find / validate email"
echo "  • people-search        — POST /v3/people/search"
echo "  • people-enrichment    — mobile, profile, role"
echo "  • company-enrichment   — company + funding"
echo "  • bulk-jobs            — CSV / async bulk uploaders"
echo "  • mcp-integration      — hosted MCP setup"
echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  ./install.sh              # ~/.claude/skills/"
echo "  ./install.sh ./my-dir     # custom directory"
echo "  npx skills add LeadMagic/leadmagic-skills"
echo ""
