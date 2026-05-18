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
        CA_PACKAGE="ca-certificates"
        ca_installed() { dpkg -l ca-certificates &>/dev/null; }
        pkg_update() { apt-get update; }
        pkg_install() { apt-get install -y "$@"; }
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
        CA_PACKAGE="ca-certificates"
        ca_installed() { rpm -q ca-certificates &>/dev/null; }
        pkg_update() { "$PKG_MGR" check-update || true; }  # Returns non-zero if updates available
        pkg_install() { "$PKG_MGR" install -y "$@"; }
        ;;
    arch)
        PKG_MGR="pacman"
        CA_PACKAGE="ca-certificates-utils"
        ca_installed() { pacman -Qi ca-certificates-utils &>/dev/null; }
        pkg_update() { pacman -Sy; }
        pkg_install() { pacman -S --noconfirm "$@"; }
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
if ! ca_installed; then
    PACKAGES_TO_INSTALL+=("$CA_PACKAGE")
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    info "Installing: ${PACKAGES_TO_INSTALL[*]}"

    if is_sudo; then
        pkg_update
        pkg_install "${PACKAGES_TO_INSTALL[@]}"
    else
        sudo -E bash -c "$(declare -f pkg_update pkg_install); PKG_MGR='$PKG_MGR' pkg_update"
        sudo -E bash -c "$(declare -f pkg_update pkg_install); PKG_MGR='$PKG_MGR' pkg_install \"\$@\"" _ "${PACKAGES_TO_INSTALL[@]}"
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
