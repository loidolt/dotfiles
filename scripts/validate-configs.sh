#!/usr/bin/env bash
#
# Validate all configurations build successfully
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

cd "$DOTFILES_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Nix Configuration Validation         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
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

# Build Home Manager configs
info "Building Home Manager config (aarch64-darwin)..."
if nix build .#homeConfigurations.chrisloidolt.activationPackage --dry-run 2>&1; then
    success "Home Manager config builds"
else
    error "Home Manager build failed"
    exit 1
fi
echo ""

# Build Darwin configs (if hosts/darwin exists)
if [[ -d "$DOTFILES_DIR/hosts/darwin" ]]; then
    info "Building darwin-arm64 config..."
    if nix build .#darwinConfigurations.darwin-arm64.system --dry-run 2>&1; then
        success "Darwin ARM64 config builds"
    else
        error "Darwin ARM64 build failed"
        exit 1
    fi
    echo ""
fi

# Build NixOS configs
info "Building NixOS desktop config..."
if nix build .#nixosConfigurations.nixos-desktop.config.system.build.toplevel --dry-run 2>&1; then
    success "NixOS desktop config builds"
else
    error "NixOS desktop build failed"
    exit 1
fi
echo ""

# Build WSL config (if hosts/wsl exists)
if [[ -d "$DOTFILES_DIR/hosts/wsl" ]]; then
    info "Building WSL config..."
    if nix build .#nixosConfigurations.wsl.config.system.build.toplevel --dry-run 2>&1; then
        success "WSL config builds"
    else
        error "WSL build failed"
        exit 1
    fi
    echo ""
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   All configurations valid!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
