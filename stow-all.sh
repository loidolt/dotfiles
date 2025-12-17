#!/usr/bin/env bash
# Quick command to stow all packages at once

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

cd "$STOW_DIR"

echo "Stowing all packages..."
for pkg in */; do
    pkg="${pkg%/}"
    echo "  - $pkg"
    stow -v "$pkg" 2>&1 | grep -v "BUG in find_stowed_path" || true
done

echo ""
echo "✓ All packages stowed!"
echo ""
echo "Restart your shell: exec zsh"
