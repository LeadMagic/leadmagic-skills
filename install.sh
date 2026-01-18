#!/bin/bash
set -e

# LeadMagic Skills Installer
# Installs all skills to ~/.claude/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="${1:-$HOME/.claude/skills}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}LeadMagic Skills Installer${NC}"
echo -e "${BLUE}══════════════════════════${NC}"
echo ""

# Create target directory
mkdir -p "$TARGET_DIR"

# Dynamically install all skills from the skills directory
echo -e "${YELLOW}Installing skills...${NC}"
echo ""

installed=0
failed=0

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")

    # Skip if not a directory or no SKILL.md
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        continue
    fi

    cp -r "$skill_dir" "$TARGET_DIR/"
    echo -e "  ${GREEN}✓${NC} $skill_name"
    ((installed++))
done

echo ""
echo -e "${GREEN}Done!${NC} Installed ${BLUE}$installed${NC} skills to: ${BLUE}$TARGET_DIR${NC}"
echo ""

# Show categories
echo -e "${YELLOW}Installed Skills by Category:${NC}"
echo ""

echo "  Core Stack:"
for s in hono-v4 cloudflare-workers wrangler typescript-best-practices; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Data & Storage:"
for s in cloudflare-d1 cloudflare-kv cloudflare-r2 cloudflare-durable-objects drizzle-orm upstash; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Backend:"
for s in api-development cloudflare-workflows cloudflare-ai-gateway authentication caching-strategies; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Frontend:"
for s in react-best-practices nextjs-app-router ui-development vercel-ai-sdk; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Quality & Security:"
for s in testing-best-practices security-best-practices error-handling env-variables; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Design:"
for s in web-design-guidelines design-review design-principles design-lab design-antipatterns; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo "  Deployment:"
for s in vercel-deploy-claimable; do
    [ -d "$TARGET_DIR/$s" ] && echo "    • $s"
done

echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  ./install.sh              # Install to ~/.claude/skills/"
echo "  ./install.sh ./my-dir     # Install to custom directory"
echo ""
