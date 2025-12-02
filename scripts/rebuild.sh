#!/usr/bin/env bash
# Simplified rebuild script - Home Manager only

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib/utils.sh"

# Detect platform
if [[ "$(uname -s)" == "Darwin" ]]; then
    CONFIG="${USER}"
else
    CONFIG="${USER}-linux"
fi

echo ""
echo -e "${BLUE}Home Manager Rebuild${NC}"
echo ""

info "Config: $CONFIG"
info "Directory: $DOTFILES_DIR"

cd "$DOTFILES_DIR"

# Build or switch
if [[ "${1:-}" == "--build" ]]; then
    info "Building configuration..."
    nix build ".#homeConfigurations.${CONFIG}.activationPackage"
else
    info "Switching configuration..."
    home-manager switch --flake ".#${CONFIG}"
fi

success "Done! Restart your terminal to see changes."
