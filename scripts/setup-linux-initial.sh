#!/usr/bin/env bash
# Linux initial setup - installs prerequisites for dotfiles
# Supports: Debian/Ubuntu, Fedora/RHEL, Arch Linux
# Requirements: git, curl, ca-certificates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Check if we're on Linux
if ! is_linux; then
    error "This script is for Linux only"
    exit 1
fi

# Detect distribution family
DISTRO_FAMILY=$(detect_distro_family)

# Get distribution name for display
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NAME="${PRETTY_NAME:-$ID}"
fi

section "Linux Initial Setup - ${DISTRO_NAME:-Unknown}"

# Check for internet connection
if ! check_internet; then
    error "Internet connection required for setup"
    exit 1
fi

# Distribution-specific configuration
case "$DISTRO_FAMILY" in
    debian)
        PKG_MGR="apt-get"
        PKG_CHECK_CMD="dpkg -l"
        PKG_UPDATE_CMD="apt-get update"
        PKG_INSTALL_CMD="apt-get install -y"
        CA_PACKAGE="ca-certificates"
        CA_CHECK_CMD="dpkg -l ca-certificates"
        ;;
    fedora)
        # Detect dnf vs yum
        if command_exists dnf; then
            PKG_MGR="dnf"
        elif command_exists yum; then
            PKG_MGR="yum"
        else
            error "Neither dnf nor yum found on Fedora-based system"
            exit 1
        fi
        PKG_CHECK_CMD="rpm -q"
        PKG_UPDATE_CMD="$PKG_MGR check-update || true"  # Returns non-zero if updates available
        PKG_INSTALL_CMD="$PKG_MGR install -y"
        CA_PACKAGE="ca-certificates"
        CA_CHECK_CMD="rpm -q ca-certificates"
        ;;
    arch)
        PKG_MGR="pacman"
        PKG_CHECK_CMD="pacman -Qi"
        PKG_UPDATE_CMD="pacman -Sy"
        PKG_INSTALL_CMD="pacman -S --noconfirm"
        CA_PACKAGE="ca-certificates-utils"
        CA_CHECK_CMD="pacman -Qi ca-certificates-utils"
        ;;
    *)
        error "Unsupported distribution family: ${DISTRO_FAMILY}"
        error "Supported distributions: Debian, Ubuntu, Fedora, RHEL, CentOS, Arch"
        exit 1
        ;;
esac

info "Detected package manager: $PKG_MGR"

# Check if we need sudo
NEED_SUDO=false
if ! command_exists git || ! command_exists curl; then
    NEED_SUDO=true
fi

if $NEED_SUDO && ! command_exists sudo; then
    error "sudo is not installed. Please run as root or install sudo first:"
    error "  su -c '$PKG_MGR install -y sudo'"
    exit 1
fi

# Install prerequisites
section "Installing Prerequisites"
info "Required packages: git, curl, $CA_PACKAGE"

PACKAGES_TO_INSTALL=()

if ! command_exists git; then
    PACKAGES_TO_INSTALL+=("git")
fi

if ! command_exists curl; then
    PACKAGES_TO_INSTALL+=("curl")
fi

# Always ensure ca-certificates is installed (needed for HTTPS)
if ! eval "$CA_CHECK_CMD" &>/dev/null; then
    PACKAGES_TO_INSTALL+=("$CA_PACKAGE")
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    info "Installing: ${PACKAGES_TO_INSTALL[*]}"

    if is_sudo; then
        # Update package database
        eval "$PKG_UPDATE_CMD"
        eval "$PKG_INSTALL_CMD ${PACKAGES_TO_INSTALL[*]}"
    else
        # Update package database
        sudo bash -c "$PKG_UPDATE_CMD"
        sudo bash -c "$PKG_INSTALL_CMD ${PACKAGES_TO_INSTALL[*]}"
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

section "Linux Setup Complete"
success "All prerequisites installed for ${DISTRO_NAME}"
echo ""
info "Required components:"
echo "  ✓ git"
echo "  ✓ curl"
echo "  ✓ $CA_PACKAGE"
echo ""
warning "IMPORTANT: Close this terminal and open a new one before proceeding"
