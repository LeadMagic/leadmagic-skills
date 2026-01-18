#!/bin/bash
set -e

# LeadMagic Skills - Build Script
# Packages all skills into dist/ directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"
DIST_DIR="$ROOT_DIR/dist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}LeadMagic Skills - Build${NC}"
echo -e "${BLUE}════════════════════════${NC}"
echo ""

# Create dist directory
mkdir -p "$DIST_DIR"

# Clean existing zips
rm -f "$DIST_DIR"/*.zip

echo -e "${YELLOW}Packaging skills...${NC}"
echo ""

cd "$SKILLS_DIR"

for skill_dir in */; do
    skill_name="${skill_dir%/}"

    # Skip if not a directory
    [ -d "$skill_name" ] || continue

    # Package
    zip -rq "$DIST_DIR/$skill_name.zip" "$skill_name/"

    # Get stats
    rule_count=$(find "$skill_name/rules" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    size=$(ls -lh "$DIST_DIR/$skill_name.zip" | awk '{print $5}')

    echo -e "  ${GREEN}✓${NC} $skill_name ($rule_count rules, $size)"
done

echo ""
echo -e "${GREEN}Done!${NC} Packages in: ${BLUE}$DIST_DIR${NC}"
echo ""
echo "Total packages: $(ls -1 "$DIST_DIR"/*.zip | wc -l | tr -d ' ')"
echo ""
