#!/bin/bash
set -e

# LeadMagic Skills - Validation Script
# Validates all skills follow the correct format

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
echo -e "${BLUE}LeadMagic Skills - Validation${NC}"
echo -e "${BLUE}══════════════════════════════${NC}"
echo ""

errors=0

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    # Check SKILL.md exists
    if [ ! -f "$skill_file" ]; then
        echo -e "${RED}✗${NC} $skill_name: Missing SKILL.md"
        ((errors++))
        continue
    fi

    # Extract frontmatter
    yaml_name=$(head -20 "$skill_file" | grep "^name:" | sed 's/name: *//' || echo "")
    description=$(head -20 "$skill_file" | grep "^description:" | sed 's/description: *//' || echo "")

    # Check name field
    if [ -z "$yaml_name" ]; then
        echo -e "${RED}✗${NC} $skill_name: Missing 'name' in frontmatter"
        ((errors++))
        continue
    fi

    # Check description field
    if [ -z "$description" ]; then
        echo -e "${RED}✗${NC} $skill_name: Missing 'description' in frontmatter"
        ((errors++))
        continue
    fi

    # Check name matches folder
    if [ "$yaml_name" != "$skill_name" ]; then
        echo -e "${RED}✗${NC} $skill_name: Name mismatch (name='$yaml_name')"
        ((errors++))
        continue
    fi

    # Check name format
    if echo "$yaml_name" | grep -qE '[^a-z0-9-]'; then
        echo -e "${RED}✗${NC} $skill_name: Invalid name format (must be lowercase, numbers, hyphens)"
        ((errors++))
        continue
    fi

    # Check name length
    if [ ${#yaml_name} -gt 64 ]; then
        echo -e "${RED}✗${NC} $skill_name: Name too long (${#yaml_name} > 64 chars)"
        ((errors++))
        continue
    fi

    # Check reserved words
    if echo "$yaml_name" | grep -qiE 'anthropic|claude'; then
        echo -e "${RED}✗${NC} $skill_name: Contains reserved word"
        ((errors++))
        continue
    fi

    # Check description length
    if [ ${#description} -gt 1024 ]; then
        echo -e "${RED}✗${NC} $skill_name: Description too long (${#description} > 1024 chars)"
        ((errors++))
        continue
    fi

    # Count rules
    rule_count=$(find "$skill_dir/rules" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${GREEN}✓${NC} $skill_name (${rule_count} rules)"
done

echo ""

if [ $errors -gt 0 ]; then
    echo -e "${RED}Validation failed with $errors error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}All skills validated successfully!${NC}"
fi
