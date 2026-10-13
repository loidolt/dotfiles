#!/usr/bin/env bash
# macOS initial setup - installs prerequisites for dotfiles
# Requirements: git, curl (via Xcode CLI Tools)

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

# Rosetta 2 - upgrading to macOS 27 removes it; Docker uses it for amd64 images
if is_arm; then
    section "Rosetta 2"
    if arch -x86_64 /usr/bin/true 2>/dev/null; then
        success "Rosetta 2 is installed"
    else
        warning "Rosetta 2 is not installed (needed for x86_64 apps and fast amd64 containers)"
        echo "  Install with: softwareupdate --install-rosetta"
    fi
fi

section "macOS Setup Complete"
success "All prerequisites installed"
echo ""
info "Required components:"
echo "  ✓ Xcode Command Line Tools (git, curl)"
echo ""
warning "IMPORTANT: Close this terminal and open a new one before proceeding"
