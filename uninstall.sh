#!/usr/bin/env bash

# Dotfiles Uninstallation Script
# This script will remove symlinks created by install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to remove a symlink
remove_symlink() {
    local target="$1"
    local description="$2"

    echo -e "${YELLOW}Removing ${description}...${NC}"

    # Check if target exists and is a symlink
    if [ -L "$target" ]; then
        echo -e "  Removing symlink: $target"
        rm "$target"
        echo -e "${GREEN}  Successfully removed${NC}"
    elif [ -e "$target" ]; then
        echo -e "${RED}  Not a symlink (skipping): $target${NC}"
    else
        echo -e "  Does not exist (skipping): $target"
    fi
}

echo -e "${BLUE}=== Uninstalling Dotfiles ===${NC}"
echo ""

# Remove OpenCode configuration
remove_symlink "$HOME/.config/opencode" "OpenCode configuration"
echo ""

# Remove WezTerm configuration
remove_symlink "$HOME/.wezterm.lua" "WezTerm configuration"
echo ""

# Remove Neovim configuration
remove_symlink "$HOME/.config/nvim" "Neovim configuration"
echo ""

echo -e "${GREEN}=== Uninstallation Complete ===${NC}"
echo ""
echo -e "${BLUE}Notes:${NC}"
echo -e "  - If you had backups, you can restore them manually"
echo -e "  - Backups are named with .backup.YYYYMMDD_HHMMSS suffix"
