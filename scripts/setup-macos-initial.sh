#!/usr/bin/env bash
# macOS initial setup - installs bare minimum for Nix
# Requirements: git, curl, xz (for Nix compression)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

section "macOS Initial Setup"

# Check if we're actually on macOS
if ! is_macos; then
    error "This script is for macOS only"
    exit 1
fi

# Check for internet connection
if ! check_internet; then
    error "Internet connection required for setup"
    exit 1
fi

# Install Xcode Command Line Tools (includes git)
section "Installing Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed"
else
    info "Installing Xcode Command Line Tools (this may take a while)..."
    xcode-select --install
    info "Please complete the installation dialog, then re-run this script"
    exit 0
fi

# Verify git is available
if command_exists git; then
    success "git is available: $(git --version)"
else
    error "git not found after Xcode installation"
    exit 1
fi

# curl is included in macOS by default
if command_exists curl; then
    success "curl is available: $(curl --version | head -n1)"
else
    error "curl not found (should be included in macOS)"
    exit 1
fi

# xz is needed for Nix but not included by default
section "Checking for xz compression tool"
if command_exists xz; then
    success "xz is already installed"
else
    warning "xz not found - Nix will install it during setup"
    info "If Nix installation fails, install Homebrew first:"
    info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    info "Then install xz: brew install xz"
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
    info "This installer includes flakes support by default"
    
    if ask "Install Nix now?" "y"; then
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        
        # Source nix for the current session
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        
        success "Nix installed successfully"
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
        exit 1
    fi
fi

section "macOS Setup Complete"
success "All prerequisites installed"
echo ""
info "Required components:"
echo "  ✓ Xcode Command Line Tools (git)"
echo "  ✓ curl"
echo "  ✓ Nix with flakes support"
echo ""
warning "IMPORTANT: Close this terminal and open a new one before proceeding"
