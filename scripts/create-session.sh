#!/bin/bash
# Create Session from GitHub Issue
# Uses GitHub CLI to fetch issue details and create session file

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SESSIONS_DIR="docs/sessions"
TEMPLATE="$SESSIONS_DIR/template.md"

echo -e "${BLUE}=== Create Session from GitHub Issue ===${NC}\n"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}Not authenticated with GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}Error: Template not found at $TEMPLATE${NC}"
    exit 1
fi

# Option 1: Create from Issue
# Option 2: Create manually
echo -e "${YELLOW}How do you want to create the session?${NC}"
echo "1) From GitHub Issue (fetch issue details)"
echo "2) Manual (just create empty session)"
read -p "Choice: " choice

case $choice in
    1)
        # Fetch open issues
        echo -e "\n${YELLOW}Fetching open issues...${NC}\n"

        # Get issues and display
        issues=$(gh issue list --limit 20 --json number,title,labels --jq '.[] | "\(.number)|\(.title)|\([.labels[].name] | join(","))"')

        if [ -z "$issues" ]; then
            echo -e "${YELLOW}No open issues found.${NC}"
            echo "Would you like to:"
            echo "1) Create issue first"
            echo "2) Create manual session"
            read -p "Choice: " no_issue_choice

            case $no_issue_choice in
                1)
                    echo -e "\n${BLUE}Opening browser to create issue...${NC}"
                    gh issue create --web
                    echo -e "${YELLOW}After creating issue, run this script again.${NC}"
                    exit 0
                    ;;
                2)
                    choice=2  # Fall through to manual creation
                    ;;
                *)
                    echo "Cancelled."
                    exit 0
                    ;;
            esac
        else
            # Display issues
            echo -e "${BLUE}Open Issues:${NC}"
            echo "$issues" | while IFS='|' read -r number title labels; do
                if [ -n "$labels" ]; then
                    echo -e "  ${GREEN}#$number${NC} - $title ${YELLOW}[$labels]${NC}"
                else
                    echo -e "  ${GREEN}#$number${NC} - $title"
                fi
            done

            echo ""
            read -p "Enter issue number (or 'q' to quit): " issue_number

            if [ "$issue_number" = "q" ]; then
                echo "Cancelled."
                exit 0
            fi

            # Fetch issue details
            echo -e "\n${YELLOW}Fetching issue #$issue_number...${NC}"

            issue_json=$(gh issue view $issue_number --json number,title,body,labels,assignees)

            if [ $? -ne 0 ]; then
                echo -e "${RED}Error: Could not fetch issue #$issue_number${NC}"
                exit 1
            fi

            issue_title=$(echo "$issue_json" | jq -r '.title')
            issue_body=$(echo "$issue_json" | jq -r '.body // ""')
            issue_labels=$(echo "$issue_json" | jq -r '[.labels[].name] | join(", ")')

            # Generate session filename
            current_date=$(date +%d)
            current_month=$(date +%Y-%m)

            # Slugify title for filename
            slug=$(echo "$issue_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)

            session_file="$SESSIONS_DIR/$current_month/${current_date}-${slug}.md"

            # Create month directory if needed
            mkdir -p "$SESSIONS_DIR/$current_month"

            # Copy template
            cp "$TEMPLATE" "$session_file"

            # Replace placeholders
            # Update title
            sed -i "s/# Session: \[Feature Name\]/# $issue_title/" "$session_file"

            # Update metadata
            sed -i "s/\*\*Date\*\*: YYYY-MM-DD/**Date**: $(date +%Y-%m-%d)/" "$session_file"
            sed -i "s/\*\*Status\*\*: 🔄 In Progress.*/**Status**: 🔄 In Progress/" "$session_file"

            # Add issue reference
            sed -i "/^## 📋 Overview/a \\
\\
**Issue**: #$issue_number\\
**Labels**: $issue_labels" "$session_file"

            # Add issue body to Context section if exists
            if [ -n "$issue_body" ]; then
                # Escape special characters for sed
                escaped_body=$(echo "$issue_body" | sed 's/[&/\]/\\&/g')
                sed -i "/### Problem/a \\
\\
**From Issue #$issue_number:**\\
\\
$escaped_body" "$session_file"
            fi

            echo -e "\n${GREEN}✅ Session created: $session_file${NC}"
            echo -e "\n${BLUE}Issue Details:${NC}"
            echo -e "  Number: #$issue_number"
            echo -e "  Title: $issue_title"
            if [ -n "$issue_labels" ]; then
                echo -e "  Labels: $issue_labels"
            fi

            # Ask if want to open in editor
            read -p $'\n'"Open in editor? (y/n): " open_editor
            if [ "$open_editor" = "y" ]; then
                ${EDITOR:-vim} "$session_file"
            fi

            echo -e "\n${YELLOW}Next steps:${NC}"
            echo "1. Fill in Plan section (approach, decisions)"
            echo "2. Fill in Implementation section (phases, tasks)"
            echo "3. Start coding!"
            echo ""
            echo "Reference in commits:"
            echo -e "${GREEN}git commit -m \"feat: implement feature\n\nPart of $session_file\"${NC}"
            ;;
    esac
    ;;

    2)
        # Manual creation
        echo ""
        read -p "Feature name (e.g., offline-sync): " feature_name

        if [ -z "$feature_name" ]; then
            echo -e "${RED}Feature name cannot be empty${NC}"
            exit 1
        fi

        current_date=$(date +%d)
        current_month=$(date +%Y-%m)

        # Slugify
        slug=$(echo "$feature_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

        session_file="$SESSIONS_DIR/$current_month/${current_date}-${slug}.md"

        # Create month directory
        mkdir -p "$SESSIONS_DIR/$current_month"

        # Copy template
        cp "$TEMPLATE" "$session_file"

        # Update date
        sed -i "s/\*\*Date\*\*: YYYY-MM-DD/**Date**: $(date +%Y-%m-%d)/" "$session_file"

        echo -e "\n${GREEN}✅ Session created: $session_file${NC}"

        # Open in editor
        read -p $'\n'"Open in editor? (y/n): " open_editor
        if [ "$open_editor" = "y" ]; then
            ${EDITOR:-vim} "$session_file"
        fi
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac
