#!/usr/bin/env bash
# Stow all packages at once
# Uses -R (restow) for idempotency - safe to run multiple times

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

# Source shared utilities for consistent output
source "$DOTFILES_DIR/scripts/lib/utils.sh"

cd "$STOW_DIR"

# run_stow function is provided by utils.sh

info "Stowing all packages to $HOME..."
failed_packages=()
for pkg in */; do
    pkg="${pkg%/}"
    info "  $pkg"
    # Use -R (restow) to handle already-stowed packages gracefully
    if ! run_stow "$pkg"; then
        warning "Failed to stow $pkg"
        failed_packages+=("$pkg")
    fi
done

if [[ ${#failed_packages[@]} -gt 0 ]]; then
    echo ""
    error "Some packages failed to stow: ${failed_packages[*]}"
    exit 1
fi

echo ""
success "All packages stowed!"
echo ""
info "Restart your shell: exec zsh"
