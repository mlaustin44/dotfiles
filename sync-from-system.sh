#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== Sync From System to Repo ===${NC}"
echo -e "${BLUE}Target repo: ${REPO_DIR}${NC}"
echo ""

are_different() {
    local source="$1"
    local dest="$2"
    
    if [ ! -e "$source" ]; then
        return 1  # source doesn't exist
    fi
    
    if [ ! -e "$dest" ]; then
        return 0  # Dest doesn't exist -> different
    fi
    
    if ! diff -rq "$source" "$dest" > /dev/null 2>&1; then
        return 0  # different
    else
        return 1  # the same
    fi
}

sync_item() {
    local source="$1"
    local dest="$2"
    local item_name="$3"
    
    if [ ! -e "$source" ]; then
        echo -e "${YELLOW} Skipping ${item_name}: not found on system${NC}"
        return 0
    fi
    
    if are_different "$source" "$dest"; then
        echo -e "${GREEN} Syncing ${item_name}: system -> repo${NC}"
        if [ -d "$source" ]; then
            mkdir -p "$dest"
            rsync -av --delete "$source/" "$dest/"
        else
            cp "$source" "$dest"
        fi
        return 0
    else
        echo -e "${CYAN} Skipping ${item_name}: identical${NC}"
        return 0
    fi
}

echo -e "${YELLOW}This will sync dotfiles FROM your system TO the repo.${NC}"
echo -e "${YELLOW}Only files/directories already in the repo will be updated.${NC}"
echo -e "${YELLOW}Files will only be copied if they differ from repo versions.${NC}"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi
echo

changes_made=false

echo -e "${BLUE}=== Checking root-level dotfiles ===${NC}"

# .zshrc
if [ -f "${REPO_DIR}/.zshrc" ]; then
    if sync_item "$HOME/.zshrc" "${REPO_DIR}/.zshrc" ".zshrc"; then
        changes_made=true
    fi
fi

# .gitconfig
if [ -f "${REPO_DIR}/.gitconfig" ]; then
    if sync_item "$HOME/.gitconfig" "${REPO_DIR}/.gitconfig" ".gitconfig"; then
        changes_made=true
    fi
fi

if [ -f "${REPO_DIR}/.config/vim/.vimrc" ]; then
    if sync_item "$HOME/.vimrc" "${REPO_DIR}/.config/vim/.vimrc" ".vimrc"; then
        changes_made=true
    fi
fi

echo

echo -e "${BLUE}=== Checking .config subdirectories ===${NC}"

for repo_dir in "${REPO_DIR}/.config"/*; do
    if [ -d "$repo_dir" ]; then
        dirname=$(basename "$repo_dir")
        system_dir="$HOME/.config/$dirname"
        
        if sync_item "$system_dir" "$repo_dir" ".config/$dirname"; then
            changes_made=true
        fi
    fi
done

# Sync /etc files
echo
echo -e "${BLUE}=== Checking /etc configuration files ===${NC}"

# Individual /etc files
if sync_item "/etc/tlp.conf" "${REPO_DIR}/etc/tlp.conf" "/etc/tlp.conf"; then
    changes_made=true
fi

if sync_item "/etc/greetd/config.toml" "${REPO_DIR}/etc/greetd/config.toml" "/etc/greetd/config.toml"; then
    changes_made=true
fi

if sync_item "/etc/systemd/logind.conf" "${REPO_DIR}/etc/systemd/logind.conf" "/etc/systemd/logind.conf"; then
    changes_made=true
fi

if sync_item "/etc/keyd/default.conf" "${REPO_DIR}/etc/keyd/default.conf" "/etc/keyd/default.conf"; then
    changes_made=true
fi

# udev rules
for rule_file in "${REPO_DIR}/etc/udev/rules.d"/*.rules; do
    if [ -f "$rule_file" ]; then
        rule_name=$(basename "$rule_file")
        if sync_item "/etc/udev/rules.d/$rule_name" "$rule_file" "/etc/udev/rules.d/$rule_name"; then
            changes_made=true
        fi
    fi
done

# Sync /usr/local/bin scripts
echo
echo -e "${BLUE}=== Checking /usr/local/bin scripts ===${NC}"

# Create the usr/local/bin directory if it doesn't exist
mkdir -p "${REPO_DIR}/usr/local/bin"

# Sync all executable scripts from /usr/local/bin (excluding symlinks)
for system_script in /usr/local/bin/*; do
    if [ -f "$system_script" ] && [ ! -L "$system_script" ] && [ -x "$system_script" ]; then
        script_name=$(basename "$system_script")
        repo_script="${REPO_DIR}/usr/local/bin/$script_name"
        if sync_item "$system_script" "$repo_script" "/usr/local/bin/$script_name"; then
            changes_made=true
        fi
    fi
done

echo
if [ "$changes_made" = true ]; then
    echo -e "${GREEN}=== Sync complete! Changes were made. ===${NC}"
    echo -e "${BLUE}     Run './diff-with-system.sh' to verify the sync${NC}"
else
    echo -e "${GREEN}=== Sync complete! No changes needed. ===${NC}"
    echo -e "${CYAN}All tracked files are already in sync.${NC}"
fi