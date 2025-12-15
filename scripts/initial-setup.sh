#!/usr/bin/env bash
# Initial setup script - detects OS and runs appropriate setup
# This installs ONLY the bare minimum to get Nix working

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

section "Dotfiles Initial Setup"
info "OS: $(detect_os)"
info "This will install the bare minimum required for Nix to manage your environment"
echo ""

# Detect OS and run appropriate setup script
if is_macos; then
    info "Detected macOS - running macOS setup..."
    bash "$SCRIPT_DIR/setup-macos-initial.sh"
elif is_linux; then
    info "Detected Linux system - running consolidated Linux setup..."
    bash "$SCRIPT_DIR/setup-linux-initial.sh"
else
    error "Unsupported operating system: $OSTYPE"
    error "For Windows, please run scripts/setup-windows-initial.ps1 in PowerShell"
    exit 1
fi

echo ""
section "Setup Complete!"
success "Nix and essential dependencies are now installed"
echo ""
info "Next steps:"
echo "  1. Close this terminal and open a new one (IMPORTANT!)"
echo "     This ensures Nix is properly loaded in your PATH"
echo ""
echo "  2. If you haven't already, clone this repository:"
echo "     git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles"
echo ""
echo "  3. Run the dotfiles installation script:"
echo "     bash ~/dotfiles/scripts/install-dotfiles.sh"
echo ""
echo "  4. After installation, verify everything:"
echo "     bash ~/dotfiles/scripts/health-check.sh"
echo ""
info "The install-dotfiles.sh script will:"
echo "  - Detect your platform automatically"
echo "  - Install Home Manager configuration"
echo "  - Set up ZSH, Neovim, Tmux, and all development tools"
echo "  - Verify the installation"
echo ""
