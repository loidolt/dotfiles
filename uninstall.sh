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

# Determine the actual user's home directory (even when run with sudo)
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

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
echo -e "${BLUE}Uninstalling for user: ${SUDO_USER:-$(whoami)} (${USER_HOME})${NC}"
echo ""

# Remove OpenCode configuration
remove_symlink "$USER_HOME/.config/opencode" "OpenCode configuration"
echo ""

# Remove WezTerm configuration
remove_symlink "$USER_HOME/.config/wezterm" "WezTerm configuration"
echo ""

# Remove Neovim configuration
remove_symlink "$USER_HOME/.config/nvim" "Neovim configuration"
echo ""

echo -e "${GREEN}=== Uninstallation Complete ===${NC}"
echo ""
echo -e "${BLUE}Notes:${NC}"
echo -e "  - If you had backups, you can restore them manually"
echo -e "  - Backups are named with .backup.YYYYMMDD_HHMMSS suffix"
