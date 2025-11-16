#!/bin/bash
# Session Archive/Delete Tool
# Helps archive or delete completed sessions after knowledge extraction

set -e

SESSIONS_DIR="docs/sessions/current"
NOTABLE_DIR="docs/sessions/notable"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Session Archive Tool ===${NC}\n"

# Check if sessions/current exists
if [ ! -d "$SESSIONS_DIR" ]; then
    echo -e "${RED}Error: $SESSIONS_DIR not found${NC}"
    exit 1
fi

# List current sessions
echo -e "${YELLOW}Current sessions:${NC}"
sessions=($(ls -1 $SESSIONS_DIR/*.md 2>/dev/null | grep -v "README\|template" || echo ""))

if [ ${#sessions[@]} -eq 0 ] || [ "${sessions[0]}" = "" ]; then
    echo -e "${GREEN}No sessions to archive. All clean!${NC}"
    exit 0
fi

# Display sessions with numbers
for i in "${!sessions[@]}"; do
    filename=$(basename "${sessions[$i]}")
    echo "  [$i] $filename"
done

echo ""
read -p "Select session number to archive (or 'q' to quit): " selection

if [ "$selection" = "q" ]; then
    echo "Cancelled."
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge "${#sessions[@]}" ]; then
    echo -e "${RED}Invalid selection${NC}"
    exit 1
fi

SESSION_FILE="${sessions[$selection]}"
SESSION_NAME=$(basename "$SESSION_FILE")

echo -e "\n${BLUE}Selected: $SESSION_NAME${NC}\n"

# Extract knowledge checklist
echo -e "${YELLOW}Checking knowledge extraction...${NC}"

# Check if extraction checklist exists in the file
if ! grep -q "Extraction Checklist" "$SESSION_FILE"; then
    echo -e "${RED}⚠️  Warning: No 'Extraction Checklist' found in session${NC}"
    echo "Please add extraction checklist before archiving."
    exit 1
fi

# Display extraction section
echo -e "${BLUE}Knowledge Extraction Status:${NC}"
sed -n '/## 📚 Knowledge Extraction/,/^## /p' "$SESSION_FILE" | head -n -1

echo ""
echo -e "${YELLOW}Has all knowledge been extracted?${NC}"
echo "1) Yes - Delete immediately (knowledge fully extracted)"
echo "2) No - Need to extract first (cancel)"
echo "3) Yes - Move to notable/ (major architectural significance)"
echo "4) Cancel"
read -p "Choice: " extract_choice

case $extract_choice in
    1)
        # Delete
        echo -e "\n${YELLOW}Preparing to delete session...${NC}"

        # Check for referenced files
        echo -e "\n${BLUE}Knowledge preserved in:${NC}"
        grep -E "docs/(ADR|architecture|api|patterns)" "$SESSION_FILE" | grep -E "\.md|Created|Updated" | head -5 || echo "  (Please manually list preserved files)"

        echo ""
        read -p "Commit message (or press Enter for default): " commit_msg

        if [ -z "$commit_msg" ]; then
            commit_msg="chore: remove session after knowledge extraction

Session: $SESSION_NAME
All knowledge has been extracted to permanent documentation."
        fi

        git rm "$SESSION_FILE"
        git commit -m "$commit_msg"

        echo -e "\n${GREEN}✅ Session deleted and committed${NC}"
        ;;

    2)
        # Cancel - need to extract
        echo -e "\n${YELLOW}Please extract knowledge first using:${NC}"
        echo "  1. Create/update ADR in docs/ADR/"
        echo "  2. Update docs/architecture/"
        echo "  3. Update docs/api/ if needed"
        echo "  4. Update CHANGELOG.md"
        echo ""
        echo "Then run this script again."
        exit 0
        ;;

    3)
        # Move to notable
        echo -e "\n${YELLOW}Moving to notable/...${NC}"

        # Extract date from filename or use current date
        if [[ $SESSION_NAME =~ ^([0-9]{2})- ]]; then
            day="${BASH_REMATCH[1]}"
            # Get current year-month
            year_month=$(date +%Y-%m)
            notable_name="${year_month}-${day}-${SESSION_NAME#*-}"
        else
            notable_name="$(date +%Y-%m-%d)-${SESSION_NAME}"
        fi

        mkdir -p "$NOTABLE_DIR"

        read -p "Reason for keeping in notable/ (major refactor/unique insights/etc): " reason

        git mv "$SESSION_FILE" "$NOTABLE_DIR/$notable_name"
        git commit -m "docs: preserve session in notable/

Session: $SESSION_NAME
Reason: $reason

This session contains unique insights worth preserving."

        echo -e "\n${GREEN}✅ Session moved to notable/ and committed${NC}"
        ;;

    4)
        echo "Cancelled."
        exit 0
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac
