#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== Dotfiles Sync Script ===${NC}"
echo -e "${BLUE}Syncing from: ${REPO_DIR}${NC}"
echo ""

sync_item() {
    local source="$1"
    local dest="$2"
    
    if [ -e "$source" ]; then
        dest_dir=$(dirname "$dest")
        if [ ! -d "$dest_dir" ]; then
            echo -e "${YELLOW}Creating directory: ${dest_dir}${NC}"
            mkdir -p "$dest_dir"
        fi
        
        if [ -e "$dest" ]; then
            if ! diff -rq "$source" "$dest" > /dev/null 2>&1; then
                backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
                echo -e "${YELLOW}Backing up: ${dest} -> ${backup}${NC}"
                cp -r "$dest" "$backup"
            fi
        fi
        
        # Sync the item
        if [ -d "$source" ]; then
            echo -e "${GREEN}Syncing directory: ${source} -> ${dest}${NC}"
            rsync -av --delete "$source/" "$dest/"
        else
            echo -e "${GREEN}Syncing file: ${source} -> ${dest}${NC}"
            cp "$source" "$dest"
        fi
    else
        echo -e "${RED}Source not found: ${source}${NC}"
        return 1
    fi
}

echo -e "${YELLOW}This will sync dotfiles from the repo to your system.${NC}"
echo -e "${YELLOW}Existing files will be backed up with a timestamp.${NC}"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi
echo

echo -e "${BLUE}Syncing home directory dotfiles...${NC}"
sync_item "${REPO_DIR}/.zshrc" "$HOME/.zshrc"
sync_item "${REPO_DIR}/.gitconfig" "$HOME/.gitconfig"

# Special handling for .vimrc (it's in .config/vim/ in the repo)
if [ -f "${REPO_DIR}/.config/vim/.vimrc" ]; then
    sync_item "${REPO_DIR}/.config/vim/.vimrc" "$HOME/.vimrc"
fi

echo

# Sync .config subdirectories
echo -e "${BLUE}Syncing .config subdirectories...${NC}"
for dir in "${REPO_DIR}/.config"/*; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        
        if [ "$dirname" = "vim" ]; then
            for file in "$dir"/*; do
                if [ -f "$file" ] && [ "$(basename "$file")" != ".vimrc" ]; then
                    sync_item "$file" "$HOME/.config/vim/$(basename "$file")"
                fi
            done
        else
            sync_item "$dir" "$HOME/.config/$dirname"
        fi
    fi
done

echo
echo -e "${GREEN}=== Sync complete! ===${NC}"
echo -e "${BLUE}Tip: Run ./diff-with-system.sh to see any differences${NC}"