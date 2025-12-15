#!/usr/bin/env bash
# Linux initial setup - installs bare minimum for Nix (all distributions)
# Supports: Debian/Ubuntu, Fedora/RHEL, Arch Linux
# Requirements: git, curl, xz, ca-certificates

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
        XZ_PACKAGE="xz-utils"
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
        XZ_PACKAGE="xz"
        CA_PACKAGE="ca-certificates"
        CA_CHECK_CMD="rpm -q ca-certificates"
        ;;
    arch)
        PKG_MGR="pacman"
        PKG_CHECK_CMD="pacman -Qi"
        PKG_UPDATE_CMD="pacman -Sy"
        PKG_INSTALL_CMD="pacman -S --noconfirm"
        XZ_PACKAGE="xz"
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
if ! command_exists git || ! command_exists curl || ! command_exists xz; then
    NEED_SUDO=true
fi

if $NEED_SUDO && ! command_exists sudo; then
    error "sudo is not installed. Please run as root or install sudo first:"
    error "  su -c '$PKG_MGR install -y sudo'"
    exit 1
fi

# Install prerequisites
section "Installing Prerequisites"
info "Required packages: git, curl, $XZ_PACKAGE, $CA_PACKAGE"

PACKAGES_TO_INSTALL=()

if ! command_exists git; then
    PACKAGES_TO_INSTALL+=("git")
fi

if ! command_exists curl; then
    PACKAGES_TO_INSTALL+=("curl")
fi

if ! command_exists xz; then
    PACKAGES_TO_INSTALL+=("$XZ_PACKAGE")
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
            sudo systemctl enable nix-daemon

            if systemctl is-active --quiet nix-daemon; then
                success "nix-daemon started successfully"
            else
                error "Failed to start nix-daemon"
                info "You may need to start it manually:"
                info "  sudo systemctl start nix-daemon"
                info "  sudo systemctl enable nix-daemon"
            fi
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

# Distribution-specific post-installation checks
section "Post-Installation Checks"

# Check if user is in nix-users group
if groups | grep -q nix-users; then
    success "User is in nix-users group"
else
    warning "User is NOT in nix-users group!"
    info "Adding user to nix-users group..."

    if sudo usermod -aG nix-users "$(whoami)"; then
        success "User added to nix-users group"
        warning "You MUST log out and log back in for group changes to take effect"
    else
        error "Failed to add user to nix-users group"
        info "Manually add yourself:"
        info "  sudo usermod -aG nix-users $(whoami)"
    fi
fi

# SELinux considerations (Fedora/RHEL)
if [ "$DISTRO_FAMILY" = "fedora" ] && command_exists getenforce; then
    if [ "$(getenforce)" != "Disabled" ]; then
        section "SELinux Notice"
        warning "SELinux is enabled on this system"
        info "The Determinate Systems Nix installer handles SELinux automatically"
        info "If you encounter issues, check: sudo ausearch -m avc -ts recent"
    fi
fi

# Arch-specific notes
if [ "$DISTRO_FAMILY" = "arch" ]; then
    section "Arch Linux Notes"
    info "  - Nix is also available in the AUR, but we use the official installer"
    info "  - The nix-daemon runs as a systemd service"
    info "  - You can manage the service with: systemctl status nix-daemon"
fi

# Final daemon check
if ! systemctl is-active --quiet nix-daemon; then
    warning "nix-daemon is still not running"
    info "Start it with: sudo systemctl start nix-daemon && sudo systemctl enable nix-daemon"
fi

section "Linux Setup Complete"
success "All prerequisites installed for ${DISTRO_NAME}"
echo ""
info "Required components:"
echo "  ✓ git"
echo "  ✓ curl"
echo "  ✓ $XZ_PACKAGE"
echo "  ✓ $CA_PACKAGE"
echo "  ✓ Nix with flakes support"
echo "  ✓ nix-daemon (systemd service)"
echo ""
warning "IMPORTANT NEXT STEPS:"
echo "  1. Close this terminal COMPLETELY"
echo "  2. Open a NEW terminal (this ensures group membership takes effect)"
echo "  3. Verify with: groups | grep nix-users"
echo "  4. Then run: cd ~/dotfiles && ./scripts/install-dotfiles.sh"
echo ""
