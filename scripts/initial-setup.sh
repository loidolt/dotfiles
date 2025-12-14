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
    DISTRO_FAMILY="$(detect_distro_family)"
    
    case "$DISTRO_FAMILY" in
        debian)
            info "Detected Debian-based system - running Debian setup..."
            bash "$SCRIPT_DIR/setup-debian-initial.sh"
            ;;
        fedora)
            info "Detected Fedora/RHEL-based system - running Fedora setup..."
            bash "$SCRIPT_DIR/setup-fedora-initial.sh"
            ;;
        arch)
            info "Detected Arch-based system - running Arch setup..."
            bash "$SCRIPT_DIR/setup-arch-initial.sh"
            ;;
        *)
            error "Unsupported or unrecognized Linux distribution"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                error "Distribution: ${PRETTY_NAME:-$ID}"
            fi
            error ""
            error "This script supports:"
            error "  - Debian-based: Debian, Ubuntu, Kali, Mint, Pop!_OS, etc."
            error "  - Fedora-based: Fedora, RHEL, CentOS, Rocky, AlmaLinux, etc."
            error "  - Arch-based: Arch, Manjaro, EndeavourOS, Garuda, etc."
            error ""
            error "Please manually install: git, curl, xz, ca-certificates"
            error "Then install Nix: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
            exit 1
            ;;
    esac
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
echo "  1. Close this terminal and open a new one"
echo "  2. Clone this repository (if not already done):"
echo "     git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles"
echo "  3. Run the home-manager activation:"
if is_macos; then
    echo "     cd ~/dotfiles && nix run home-manager/master -- switch --flake .#chrisloidolt --impure"
else
    echo "     cd ~/dotfiles && nix run home-manager/master -- switch --flake .#chrisloidolt-linux --impure"
fi
echo "  4. Verify with: bash ~/dotfiles/scripts/health-check.sh"
echo ""
