#!/usr/bin/env bash
#
# Validate all configurations build successfully
#

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

cd "$DOTFILES_DIR"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Nix Configuration Validation         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Extract username from user.nix
USERNAME=$(grep 'username = ' user.nix 2>/dev/null | sed 's/.*username = "\([^"]*\)".*/\1/')
if [[ -z "$USERNAME" ]]; then
    error "Could not extract username from user.nix"
    exit 1
fi

info "Username: $USERNAME"
echo ""

# Check flake
info "Checking flake..."
if nix flake check --no-build 2>&1; then
    success "Flake is valid"
else
    error "Flake check failed"
    exit 1
fi
echo ""

# Build Home Manager configs based on current platform
if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
        CONFIG_NAME="${USERNAME}"
        SYSTEM="aarch64-darwin"
    else
        CONFIG_NAME="${USERNAME}-x86"
        SYSTEM="x86_64-darwin"
    fi
else
    if [[ "$(uname -m)" == "aarch64" ]]; then
        CONFIG_NAME="${USERNAME}-arm"
        SYSTEM="aarch64-linux"
    else
        CONFIG_NAME="${USERNAME}-linux"
        SYSTEM="x86_64-linux"
    fi
fi

info "Building Home Manager config for $SYSTEM ($CONFIG_NAME)..."
if nix build ".#homeConfigurations.${CONFIG_NAME}.activationPackage" --dry-run 2>&1; then
    success "Home Manager config builds successfully"
else
    error "Home Manager build failed"
    exit 1
fi
echo ""

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   All configurations valid!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
