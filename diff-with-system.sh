#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== Dotfiles Diff ===${NC}"
echo ""

DIFFERENCES_FOUND=0

diff_item() {
    local repo_path="$1"
    local system_path="$2"
    local item_name="$3"
    
    echo -e "${CYAN}Checking: ${item_name}${NC}"
    
    if [ ! -e "$repo_path" ]; then
        echo -e "  ${YELLOW}⚠ Not in repo: ${repo_path}${NC}"
        return
    fi
    
    if [ ! -e "$system_path" ]; then
        echo -e "  ${RED}✗ Not on system: ${system_path}${NC}"
        DIFFERENCES_FOUND=1
        return
    fi
    
    if [ -d "$repo_path" ]; then
        if diff -rq "$repo_path" "$system_path" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Identical${NC}"
        else
            echo -e "  ${RED}✗ Differences found${NC}"
            DIFFERENCES_FOUND=1
            
            if [[ "$*" == *"--verbose"* ]] || [[ "$*" == *"-v"* ]]; then
                echo -e "  ${YELLOW}Detailed differences:${NC}"
                diff -rq "$repo_path" "$system_path" 2>/dev/null | head -10 | sed 's/^/    /'
                
                diff_count=$(diff -rq "$repo_path" "$system_path" 2>/dev/null | wc -l)
                if [ "$diff_count" -gt 10 ]; then
                    echo -e "    ${YELLOW}... and $((diff_count - 10)) more differences${NC}"
                fi
            fi
        fi
    else
        if diff -q "$repo_path" "$system_path" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Identical${NC}"
        else
            echo -e "  ${RED}✗ Different${NC}"
            DIFFERENCES_FOUND=1
            
            # Show actual diff if --verbose flag is used
            if [[ "$*" == *"--verbose"* ]] || [[ "$*" == *"-v"* ]]; then
                echo -e "  ${YELLOW}Differences:${NC}"
                diff -u "$system_path" "$repo_path" 2>/dev/null | head -20 | sed 's/^/    /' || true
            fi
        fi
    fi
}

show_detailed_diff() {
    local repo_path="$1"
    local system_path="$2"
    
    if [ -e "$repo_path" ] && [ -e "$system_path" ]; then
        if [ -d "$repo_path" ]; then
            diff -ru "$system_path" "$repo_path" || true
        else
            diff -u "$system_path" "$repo_path" || true
        fi
    fi
}

# Parse command line arguments
VERBOSE=false
SHOW_DIFF=""
for arg in "$@"; do
    case $arg in
        -v|--verbose)
            VERBOSE=true
            ;;
        --diff=*)
            SHOW_DIFF="${arg#*=}"
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose       Show detailed differences"
            echo "  --diff=ITEM        Show full diff for specific item (e.g., --diff=.zshrc)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Quick overview of differences"
            echo "  $0 -v               # Show detailed differences"
            echo "  $0 --diff=.zshrc    # Show full diff for .zshrc"
            exit 0
            ;;
    esac
done

# specific diff
if [ -n "$SHOW_DIFF" ]; then
    case "$SHOW_DIFF" in
        .zshrc)
            show_detailed_diff "${REPO_DIR}/.zshrc" "$HOME/.zshrc"
            ;;
        .gitconfig)
            show_detailed_diff "${REPO_DIR}/.gitconfig" "$HOME/.gitconfig"
            ;;
        .vimrc)
            show_detailed_diff "${REPO_DIR}/.config/vim/.vimrc" "$HOME/.vimrc"
            ;;
        *)
            show_detailed_diff "${REPO_DIR}/.config/$SHOW_DIFF" "$HOME/.config/$SHOW_DIFF"
            ;;
    esac
    exit 0
fi

# standalones
echo -e "${BLUE}=== zshrc and gitconfig ===${NC}"
diff_item "${REPO_DIR}/.zshrc" "$HOME/.zshrc" ".zshrc"
diff_item "${REPO_DIR}/.gitconfig" "$HOME/.gitconfig" ".gitconfig"

if [ -f "${REPO_DIR}/.config/vim/.vimrc" ]; then
    diff_item "${REPO_DIR}/.config/vim/.vimrc" "$HOME/.vimrc" ".vimrc"
fi

echo

echo -e "${BLUE}=== .config Subdirectories ===${NC}"
for dir in "${REPO_DIR}/.config"/*; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        
        if [ "$dirname" != "vim" ]; then
            diff_item "$dir" "$HOME/.config/$dirname" ".config/$dirname"
        else
            for file in "$dir"/*; do
                if [ -f "$file" ] && [ "$(basename "$file")" != ".vimrc" ]; then
                    filename=$(basename "$file")
                    diff_item "$file" "$HOME/.config/vim/$filename" ".config/vim/$filename"
                fi
            done
        fi
    fi
done

echo
echo -e "${BLUE}=== Summary ===${NC}"
if [ $DIFFERENCES_FOUND -eq 0 ]; then
    echo -e "${GREEN}All files are in sync!${NC}"
else
    echo -e "${YELLOW}Differences found between repo and system${NC}"
    echo -e "${BLUE}Run with -v flag for detailed differences${NC}"
    echo -e "${BLUE}Run with --diff=ITEM to see full diff for a specific item${NC}"
fi