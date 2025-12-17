#!/usr/bin/env bash
# Uninstall dotfiles (remove symlinks)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warning() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    Dotfiles Uninstallation (Stow)    ║"
echo "╚══════════════════════════════════════╝"
echo ""

warning "This will remove all symlinks created by stow"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Uninstallation cancelled"
    exit 0
fi

if [[ ! -d "$STOW_DIR" ]]; then
    error "Stow directory not found: $STOW_DIR"
    exit 1
fi

info "Removing symlinks..."
cd "$STOW_DIR"

for package in */; do
    package=${package%/}
    info "Removing $package..."
    if stow -D -v "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
        success "$package removed"
    else
        warning "Failed to remove $package (may not have been installed)"
    fi
done

success "Uninstallation complete!"
info "Your config files are still in: $DOTFILES_DIR"
info "Backup files (*.backup-*) were not removed"
