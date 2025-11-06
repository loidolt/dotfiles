#!/usr/bin/env bash

# Dotfiles Installation Script
# This script will create symlinks for all configuration files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Dotfiles Directory: ${DOTFILES_DIR}${NC}"
echo ""

# Function to create a symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    echo -e "${YELLOW}Installing ${description}...${NC}"

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo -e "${RED}  Error: Source does not exist: $source${NC}"
        return 1
    fi

    # Get the target directory
    local target_dir="$(dirname "$target")"

    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        echo -e "  Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # If it's already the correct symlink, skip
        if [ -L "$target" ] && [ "$(readlink "$target")" == "$source" ]; then
            echo -e "${GREEN}  Already linked correctly${NC}"
            return 0
        fi

        # Backup existing file/directory
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "  Backing up existing config to: $backup"
        mv "$target" "$backup"
    fi

    # Create the symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}  Successfully linked: $target -> $source${NC}"
}

echo -e "${BLUE}=== Installing Dotfiles ===${NC}"
echo ""

# Install OpenCode configuration
if [ -d "$DOTFILES_DIR/opencode" ]; then
    create_symlink \
        "$DOTFILES_DIR/opencode" \
        "$HOME/.config/opencode" \
        "OpenCode configuration"
    echo ""
fi

# Install WezTerm configuration
if [ -d "$DOTFILES_DIR/wezterm" ]; then
    create_symlink \
        "$DOTFILES_DIR/wezterm" \
        "$HOME/.config/wezterm" \
        "WezTerm configuration"
    echo ""
fi

# Install Neovim configuration
if [ -d "$DOTFILES_DIR/neovim" ]; then
    create_symlink \
        "$DOTFILES_DIR/neovim" \
        "$HOME/.config/nvim" \
        "Neovim configuration"
    echo ""
fi

echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo -e "${BLUE}Notes:${NC}"
echo -e "  - Your original configs have been backed up with timestamp"
echo -e "  - Restart your applications for changes to take effect"
echo -e "  - For Neovim, plugins will be installed automatically on first launch"
