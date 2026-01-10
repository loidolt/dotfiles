#!/usr/bin/env bash
# Uninstall dotfiles (remove symlinks)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

# Source shared utilities
source "$DOTFILES_DIR/scripts/lib/utils.sh"

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
    if stow -D -v -t "$HOME" "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
        success "$package removed"
    else
        warning "Failed to remove $package (may not have been installed)"
    fi
done

success "Uninstallation complete!"
info "Your config files are still in: $DOTFILES_DIR"
info "Backup files (*.backup-*) were not removed"
