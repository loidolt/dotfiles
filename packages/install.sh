#!/usr/bin/env bash
# Package installer for dotfiles
# Supports macOS (Homebrew), Debian/Ubuntu (apt), Fedora/RHEL (dnf), Arch (pacman)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warning() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Read packages from file (ignoring comments and empty lines)
read_packages() {
    local file=$1
    if [[ -f "$file" ]]; then
        # Remove comments (anything after #), trim whitespace, and filter empty lines
        grep -v '^#' "$file" | sed 's/#.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^[[:space:]]*$' || true
    fi
}

# Install packages via Homebrew (macOS)
install_brew() {
    local packages=("$@")
    
    if ! command -v brew &> /dev/null; then
        warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add brew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    info "Updating Homebrew..."
    brew update
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            success "$package already installed"
        else
            info "Installing $package..."
            if brew install "$package"; then
                success "$package installed"
            else
                warning "Failed to install $package"
            fi
        fi
    done
}

# Install packages via apt (Debian/Ubuntu)
install_apt() {
    local packages=("$@")
    
    info "Updating package list..."
    sudo apt-get update
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            success "$package already installed"
        else
            info "Installing $package..."
            if sudo apt-get install -y "$package"; then
                success "$package installed"
            else
                warning "Failed to install $package"
            fi
        fi
    done
}

# Install packages via dnf (Fedora/RHEL)
install_dnf() {
    local packages=("$@")
    
    for package in "${packages[@]}"; do
        if dnf list installed "$package" &>/dev/null; then
            success "$package already installed"
        else
            info "Installing $package..."
            if sudo dnf install -y "$package"; then
                success "$package installed"
            else
                warning "Failed to install $package"
            fi
        fi
    done
}

# Install packages via pacman (Arch)
install_pacman() {
    local packages=("$@")
    
    info "Updating package database..."
    sudo pacman -Sy
    
    for package in "${packages[@]}"; do
        if pacman -Q "$package" &>/dev/null; then
            success "$package already installed"
        else
            info "Installing $package..."
            if sudo pacman -S --noconfirm "$package"; then
                success "$package installed"
            else
                warning "Failed to install $package"
            fi
        fi
    done
}

# Main installation
main() {
    local os=$(detect_os)
    local pm=$(detect_package_manager)
    
    info "Detected OS: $os"
    info "Package manager: $pm"
    echo ""
    
    # Read package lists
    local common_packages=()
    local os_packages=()
    
    # Read packages into array (compatible with bash 3.x)
    while IFS= read -r line; do
        [[ -n "$line" ]] && common_packages+=("$line")
    done < <(read_packages "$PACKAGES_DIR/common.txt")
    
    if [[ "$os" == "macos" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && os_packages+=("$line")
        done < <(read_packages "$PACKAGES_DIR/macos.txt")
    elif [[ "$os" == "linux" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && os_packages+=("$line")
        done < <(read_packages "$PACKAGES_DIR/linux.txt")
    fi
    
    # Combine package lists
    local all_packages=("${common_packages[@]}" "${os_packages[@]}")
    
    if [[ ${#all_packages[@]} -eq 0 ]]; then
        warning "No packages to install"
        exit 0
    fi
    
    info "Found ${#all_packages[@]} packages to install"
    echo ""
    
    # Install packages based on package manager
    case "$pm" in
        brew)
            install_brew "${all_packages[@]}"
            ;;
        apt)
            install_apt "${all_packages[@]}"
            ;;
        dnf)
            install_dnf "${all_packages[@]}"
            ;;
        pacman)
            install_pacman "${all_packages[@]}"
            ;;
        *)
            error "Unsupported package manager: $pm"
            error "Please install packages manually from:"
            echo "  - $PACKAGES_DIR/common.txt"
            if [[ "$os" == "macos" ]]; then
                echo "  - $PACKAGES_DIR/macos.txt"
            elif [[ "$os" == "linux" ]]; then
                echo "  - $PACKAGES_DIR/linux.txt"
            fi
            exit 1
            ;;
    esac
    
    echo ""
    success "Package installation complete!"
}

main "$@"
