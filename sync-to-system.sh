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

if [ -f "${REPO_DIR}/.config/vim/.vimrc" ]; then
    sync_item "${REPO_DIR}/.config/vim/.vimrc" "$HOME/.vimrc"
fi

echo

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

if [[ "$1" == "--system" ]]; then
    echo -e "${BLUE}=== Syncing system files (requires sudo) ===${NC}"
    echo -e "${YELLOW}You'll need to run the following commands manually:${NC}"
    echo
    
    if [ -d "${REPO_DIR}/etc" ]; then
        echo -e "${CYAN}# /etc configuration files:${NC}"
        echo "sudo cp ${REPO_DIR}/etc/greetd/config.toml /etc/greetd/config.toml"
        echo "sudo cp ${REPO_DIR}/etc/systemd/logind.conf /etc/systemd/logind.conf"
        echo "sudo cp ${REPO_DIR}/etc/tlp.conf /etc/tlp.conf"
        echo "sudo cp ${REPO_DIR}/etc/keyd/default.conf /etc/keyd/default.conf"
        
        if [ -d "${REPO_DIR}/etc/tuned/profiles" ]; then
            echo
            echo -e "${CYAN}# tuned profiles:${NC}"
            for profile_dir in "${REPO_DIR}/etc/tuned/profiles"/*; do
                if [ -d "$profile_dir" ]; then
                    profile_name=$(basename "$profile_dir")
                    echo "sudo mkdir -p /etc/tuned/profiles/$profile_name"
                    echo "sudo cp -r $profile_dir/* /etc/tuned/profiles/$profile_name/"
                fi
            done
        fi
        
        if [ -d "${REPO_DIR}/etc/udev/rules.d" ]; then
            echo
            echo -e "${CYAN}# udev rules:${NC}"
            for rule in "${REPO_DIR}/etc/udev/rules.d"/*.rules; do
                if [ -f "$rule" ]; then
                    echo "sudo cp $rule /etc/udev/rules.d/$(basename "$rule")"
                fi
            done
            echo "sudo udevadm control --reload-rules && sudo udevadm trigger"
        fi
    fi
    
    echo
    
    if [ -d "${REPO_DIR}/usr/local/bin" ]; then
        echo -e "${CYAN}# /usr/local/bin scripts:${NC}"
        for script in "${REPO_DIR}/usr/local/bin"/*; do
            if [ -f "$script" ]; then
                echo "sudo cp $script /usr/local/bin/$(basename "$script")"
                echo "sudo chmod +x /usr/local/bin/$(basename "$script")"
            fi
        done
    fi
    
    echo
    echo -e "${YELLOW}Copy and run the commands above to sync system files.${NC}"
else
    echo -e "${GREEN}=== Sync complete! ===${NC}"
    echo -e "${YELLOW}Note: System files in /etc and /usr/local/bin were NOT synced.${NC}"
    echo -e "${YELLOW}      Run with --system flag to see commands for syncing those.${NC}"
fi

echo -e "${BLUE}Tip: Run ./diff-with-system.sh to see any differences${NC}"