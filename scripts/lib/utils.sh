#!/usr/bin/env bash
# Utility functions for dotfiles scripts

set -euo pipefail

# Debug mode (set via DEBUG=1 environment variable)
DEBUG="${DEBUG:-0}"

# Enable debug output
debug() {
    if [[ "${DEBUG}" == "1" ]]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $*" >&2
    fi
}

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*"
}

section() {
    echo ""
    echo -e "${CYAN}===${NC} ${MAGENTA}$*${NC}"
    echo ""
}

# OS detection
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

is_arm() {
    [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]
}

detect_os() {
    if is_macos; then
        if is_arm; then
            echo "macOS (ARM64)"
        else
            echo "macOS (Intel)"
        fi
    elif is_linux; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "Linux ($NAME)"
        else
            echo "Linux (Unknown)"
        fi
    else
        echo "Unknown OS"
    fi
}

# Detect distribution family (debian, fedora, arch, or unknown)
detect_distro_family() {
    if ! is_linux; then
        echo "unknown"
        return 1
    fi
    
    # Check for os-release file (modern standard)
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        
        # Check ID_LIKE first (includes parent distros)
        if [ -n "${ID_LIKE:-}" ]; then
            # ID_LIKE can be space-separated list, check each one
            for like_id in $ID_LIKE; do
                case "$like_id" in
                    debian|ubuntu)
                        echo "debian"
                        return 0
                        ;;
                    fedora|rhel|centos)
                        echo "fedora"
                        return 0
                        ;;
                    arch|archlinux)
                        echo "arch"
                        return 0
                        ;;
                esac
            done
        fi
        
        # If ID_LIKE didn't match, check ID directly
        case "${ID:-}" in
            debian|ubuntu|linuxmint|pop|kali|parrot|mx|deepin|zorin|elementary|raspbian|devuan)
                echo "debian"
                return 0
                ;;
            fedora|rhel|centos|rocky|almalinux|oracle|scientific|cloudlinux|eurolinux)
                echo "fedora"
                return 0
                ;;
            arch|manjaro|endeavouros|garuda|artix|arcolinux|blackarch)
                echo "arch"
                return 0
                ;;
        esac
    fi
    
    # Fallback: check for package manager binaries
    if command_exists apt-get || command_exists dpkg; then
        echo "debian"
        return 0
    elif command_exists dnf || command_exists yum; then
        echo "fedora"
        return 0
    elif command_exists pacman; then
        echo "arch"
        return 0
    fi
    
    # Could not detect
    echo "unknown"
    return 1
}

# Check if system is Debian-based
is_debian_based() {
    [[ "$(detect_distro_family)" == "debian" ]]
}

# Check if system is Fedora/RHEL-based
is_fedora_based() {
    [[ "$(detect_distro_family)" == "fedora" ]]
}

# Check if system is Arch-based
is_arch_based() {
    [[ "$(detect_distro_family)" == "arch" ]]
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if running with sudo
is_sudo() {
    [ "$EUID" -eq 0 ]
}

# Get the actual user (even when run with sudo)
get_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$(whoami)"
    fi
}

# Get the actual user's home directory
get_home() {
    if [ -n "$SUDO_USER" ]; then
        eval echo "~$SUDO_USER"
    else
        echo "$HOME"
    fi
}

# Ask yes/no question
ask() {
    # shellcheck disable=SC2162
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [[ "$default" == "y" ]]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Check internet connection
check_internet() {
    local silent="${1:-false}"
    # Try multiple DNS servers for better reliability
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null || ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
        return 0
    else
        [[ "$silent" != "true" ]] && error "No internet connection detected"
        return 1
    fi
}

# Wait for user to press Enter
pause() {
    read -p "Press Enter to continue..."
}

# Export functions so they're available in subshells
export -f debug info success warning error section
export -f is_macos is_linux is_arm detect_os
export -f detect_distro_family is_debian_based is_fedora_based is_arch_based
export -f command_exists is_sudo get_user get_home
export -f ask check_internet pause
