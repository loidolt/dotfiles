#!/usr/bin/env bash
# Debian/Ubuntu initial setup - installs bare minimum for Nix
# Requirements: git, curl, xz-utils, ca-certificates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

section "Debian/Ubuntu Initial Setup"

# Check if we're on a Debian-based system
if ! is_linux; then
    error "This script is for Linux only"
    exit 1
fi

if ! is_debian_based; then
    error "This script is for Debian-based systems only"
    error "Detected distribution family: $(detect_distro_family)"
    exit 1
fi

# Get distribution name for display
if [ -f /etc/os-release ]; then
    . /etc/os-release
    info "Detected: ${PRETTY_NAME:-$ID}"
fi

# Check for internet connection
if ! check_internet; then
    error "Internet connection required for setup"
    exit 1
fi

# Check if we need sudo
NEED_SUDO=false
if ! command_exists git || ! command_exists curl || ! command_exists xz; then
    NEED_SUDO=true
fi

if $NEED_SUDO && ! command_exists sudo; then
    error "sudo is not installed. Please run as root or install sudo first:"
    error "  su -c 'apt-get update && apt-get install -y sudo'"
    exit 1
fi

# Install prerequisites
section "Installing Prerequisites"
info "Required packages: git, curl, xz-utils, ca-certificates"

PACKAGES_TO_INSTALL=()

if ! command_exists git; then
    PACKAGES_TO_INSTALL+=("git")
fi

if ! command_exists curl; then
    PACKAGES_TO_INSTALL+=("curl")
fi

if ! command_exists xz; then
    PACKAGES_TO_INSTALL+=("xz-utils")
fi

# Always ensure ca-certificates is installed (needed for HTTPS)
if ! dpkg -l ca-certificates &>/dev/null; then
    PACKAGES_TO_INSTALL+=("ca-certificates")
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    info "Installing: ${PACKAGES_TO_INSTALL[*]}"
    
    if is_sudo; then
        apt-get update
        apt-get install -y "${PACKAGES_TO_INSTALL[@]}"
    else
        sudo apt-get update
        sudo apt-get install -y "${PACKAGES_TO_INSTALL[@]}"
    fi
    
    success "Prerequisites installed"
else
    success "All prerequisites already installed"
fi

# Verify installations
if command_exists git; then
    success "git is available: $(git --version)"
else
    error "git installation failed"
    exit 1
fi

if command_exists curl; then
    success "curl is available: $(curl --version | head -n1)"
else
    error "curl installation failed"
    exit 1
fi

if command_exists xz; then
    success "xz is available: $(xz --version | head -n1)"
else
    error "xz installation failed"
    exit 1
fi

# Install Nix using Determinate Systems installer
section "Installing Nix"
if command_exists nix; then
    success "Nix is already installed: $(nix --version)"
    
    # Check if flakes are enabled
    if nix-command --version &>/dev/null || grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf 2>/dev/null; then
        success "Nix flakes are enabled"
    else
        warning "Enabling Nix flakes..."
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        success "Nix flakes enabled"
    fi
else
    info "Installing Nix using Determinate Systems installer..."
    info "This installer includes flakes support and systemd integration"
    
    if ask "Install Nix now?" "y"; then
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        
        # Source nix for the current session
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        
        success "Nix installed successfully"
        
        # Verify nix-daemon is running
        if systemctl is-active --quiet nix-daemon; then
            success "nix-daemon is running"
        else
            warning "nix-daemon is not running. Starting it now..."
            sudo systemctl start nix-daemon
        fi
    else
        warning "Skipping Nix installation"
        info "To install later, run:"
        info "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
        exit 0
    fi
fi

# Verify Nix is working
if command_exists nix; then
    if nix --version &>/dev/null; then
        success "Nix verification successful"
    else
        error "Nix installed but not working correctly"
        info "You may need to start a new shell session"
        exit 1
    fi
fi

section "Debian/Ubuntu Setup Complete"
success "All prerequisites installed"
echo ""
info "Required components:"
echo "  ✓ git"
echo "  ✓ curl"
echo "  ✓ xz-utils"
echo "  ✓ ca-certificates"
echo "  ✓ Nix with flakes support"
echo "  ✓ nix-daemon (systemd service)"
echo ""
warning "IMPORTANT: Close this terminal and open a new one before proceeding"
