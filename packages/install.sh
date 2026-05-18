#!/usr/bin/env bash
# Package installer for dotfiles
# Supports macOS (Homebrew), Debian/Ubuntu (apt), Fedora/RHEL (dnf), Arch (pacman)

set -euo pipefail

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$PACKAGES_DIR")"

# Source shared utilities
source "$DOTFILES_DIR/scripts/lib/utils.sh"

# Detect package manager
detect_package_manager() {
    if command_exists brew; then
        echo "brew"
    elif command_exists apt-get; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Pre-flight checks before installation
preflight_checks() {
    local pm="$1"
    local errors=0

    info "Running pre-flight checks..."

    # Check internet connectivity for package managers that need it
    if ! check_internet true; then
        error "No internet connection. Package installation requires network access."
        ((errors++))
    else
        success "Internet connectivity OK"
    fi

    # Check sudo access for Linux package managers
    if [[ "$pm" != "brew" ]] && is_linux; then
        if ! sudo -n true 2>/dev/null; then
            info "Sudo access required for package installation"
            # Prompt for password now rather than mid-install
            if ! sudo true; then
                error "Failed to obtain sudo access"
                ((errors++))
            else
                success "Sudo access OK"
            fi
        else
            success "Sudo access OK"
        fi
    fi

    if [[ $errors -gt 0 ]]; then
        error "Pre-flight checks failed. Please fix the issues above and try again."
        exit 1
    fi

    echo ""
}

# Read packages from file (ignoring comments and empty lines)
read_packages() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    # Remove comments (anything after #), trim whitespace, and filter empty lines
    grep -v '^#' "$file" | sed 's/#.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^[[:space:]]*$' | \
    while read -r pkg; do
        # Basic validation: allow --cask prefix, alphanumeric, dash, underscore, @, /
        if [[ "$pkg" =~ ^(--cask[[:space:]]+)?[a-zA-Z0-9@/_-]+$ ]]; then
            echo "$pkg"
        else
            warning "Skipping invalid package name: $pkg" >&2
        fi
    done
}

# Install packages via Homebrew (macOS)
install_brew() {
    local packages=("$@")
    
    if ! command_exists brew; then
        warning "Homebrew not found. Installing..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            error "Homebrew installation failed"
            return 1
        fi
        
        # Add brew to PATH
        setup_homebrew_path || true

        # Verify installation
        if ! command_exists brew; then
            error "Homebrew installed but not found in PATH"
            return 1
        fi
        
        success "Homebrew installed successfully"
    fi
    
    info "Updating Homebrew..."
    brew update
    
    for package in "${packages[@]}"; do
        local pkg_name="$package"
        local is_cask=false
        local install_cmd="brew install"
        local check_cmd="brew list"
        
        # Handle --cask prefix
        if [[ "$package" == "--cask "* ]]; then
            pkg_name="${package#--cask }"
            is_cask=true
            install_cmd="brew install --cask"
            check_cmd="brew list --cask"
        fi
        
        if $check_cmd "$pkg_name" &>/dev/null; then
            success "$pkg_name already installed"
        else
            if $is_cask; then
                info "Installing $pkg_name (cask)..."
            else
                info "Installing $pkg_name..."
            fi
            if $install_cmd "$pkg_name"; then
                success "$pkg_name installed"
            else
                warning "Failed to install $pkg_name"
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
        # Use dpkg-query for reliable package status check
        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
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

# Install uv (Python package manager) - not available via apt/dnf/pacman
install_uv() {
    if command_exists uv; then
        success "uv already installed"
        return 0
    fi
    
    info "Installing uv (Python package manager)..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        success "uv installed"
        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
    else
        warning "Failed to install uv"
        return 1
    fi
}

# Install devpod CLI (not available via package managers on Linux)
install_devpod() {
    if command_exists devpod; then
        success "devpod already installed"
    else
        info "Installing devpod CLI..."
        local arch=$(uname -m)
        local devpod_arch="amd64"
        if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
            devpod_arch="arm64"
        fi
        
        if curl -L -o /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-${devpod_arch}" && \
           sudo install -c -m 0755 /tmp/devpod /usr/local/bin && \
           rm -f /tmp/devpod; then
            success "devpod installed"
        else
            warning "Failed to install devpod"
            return 1
        fi
    fi
    
    # Configure docker provider as default
    configure_devpod_provider
}

# Configure devpod docker provider
configure_devpod_provider() {
    if ! command_exists devpod; then
        return 0
    fi
    
    # Check if docker provider exists (strip ANSI codes and handle table formatting)
    if ! devpod provider list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -q "docker"; then
        info "Adding devpod docker provider..."
        if devpod provider add docker; then
            success "docker provider added"
        else
            warning "Failed to add docker provider"
            return 1
        fi
    else
        success "docker provider already exists"
    fi
    
    # Set docker as default provider
    info "Setting docker as default devpod provider..."
    if devpod provider use docker; then
        success "docker set as default provider"
    else
        warning "Failed to set docker as default provider"
    fi
}

# Configure npm to install globals into ~/.npm-global without sudo
# Idempotent: only writes config if not already pointing at the user prefix
ensure_user_npm_prefix() {
    local user_prefix="$HOME/.npm-global"
    local current_prefix
    current_prefix=$(npm config get prefix 2>/dev/null || echo "")

    if [[ "$current_prefix" != "$user_prefix" ]]; then
        mkdir -p "$user_prefix"
        npm config set prefix "$user_prefix"
        info "Set npm global prefix to $user_prefix"
    fi

    # Ensure prefix bin is in PATH for this script's child commands
    case ":$PATH:" in
        *":$user_prefix/bin:"*) ;;
        *) export PATH="$user_prefix/bin:$PATH" ;;
    esac
}

# Install codex (OpenAI Codex CLI) - not available via apt/dnf/pacman
install_codex() {
    if command_exists codex; then
        success "codex already installed"
        return 0
    fi

    if ! command_exists npm; then
        warning "npm not found, cannot install codex"
        return 1
    fi

    ensure_user_npm_prefix

    info "Installing codex (OpenAI Codex CLI)..."
    if npm install -g @openai/codex; then
        success "codex installed"
    else
        warning "Failed to install codex"
        return 1
    fi
}

# Install gemini-cli (Google Gemini CLI) - not available via apt/dnf/pacman
install_gemini_cli() {
    if command_exists gemini; then
        success "gemini-cli already installed"
        return 0
    fi

    if ! command_exists npm; then
        warning "npm not found, cannot install gemini-cli"
        return 1
    fi

    ensure_user_npm_prefix

    info "Installing gemini-cli (Google Gemini CLI)..."
    if npm install -g @google/gemini-cli; then
        success "gemini-cli installed"
    else
        warning "Failed to install gemini-cli"
        return 1
    fi
}

# Install Chromium browser for Playwright MCP server
# The @playwright/mcp package bundles a specific Playwright version that requires matching browser binaries
install_playwright_browsers() {
    if ! command_exists npx; then
        warning "npx not found, skipping Playwright MCP browser installation"
        return 0
    fi

    if ! command_exists npm; then
        warning "npm not found, skipping Playwright MCP browser installation"
        return 0
    fi

    info "Installing Chromium browser for Playwright MCP..."

    # Get the Playwright version that @playwright/mcp depends on
    local pw_version_raw
    pw_version_raw=$(npm show @playwright/mcp dependencies.playwright 2>/dev/null | tr -d '"' || echo "")

    local pw_version="latest"

    if [[ -n "$pw_version_raw" ]]; then
        # Extract clean version number, handling semver ranges like ^1.40.0, >=1.50.0, ~1.40.0
        # Remove leading ^, ~, >=, >, <=, <, = and any trailing modifiers
        local clean_version
        clean_version=$(echo "$pw_version_raw" | sed -E 's/^[\^~><=]+//' | sed -E 's/[[:space:]].*//')

        # Validate it looks like a semver version (e.g., 1.40.0, 1.40.0-beta.1)
        if [[ "$clean_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
            pw_version="$clean_version"
            info "Detected Playwright version: $pw_version (from: $pw_version_raw)"
        else
            warning "Could not parse Playwright version '$pw_version_raw', using 'latest'"
        fi
    else
        warning "Could not determine Playwright version for @playwright/mcp, using 'latest'"
    fi

    info "Using Playwright version: $pw_version"
    
    # Determine the correct Playwright browser cache location based on OS
    # macOS: ~/Library/Caches/ms-playwright
    # Linux: ~/.cache/ms-playwright
    local playwright_cache
    if is_macos; then
        playwright_cache="$HOME/Library/Caches/ms-playwright"
    else
        playwright_cache="$HOME/.cache/ms-playwright"
    fi
    
    # Install chromium to the standard Playwright browser cache location
    # This ensures @playwright/mcp can find the browsers at runtime
    if PLAYWRIGHT_BROWSERS_PATH="$playwright_cache" npx -y "playwright@$pw_version" install chromium 2>&1; then
        success "Chromium browser installed for Playwright MCP"
    else
        warning "Failed to install Chromium browser for Playwright MCP"
        return 1
    fi
    
    # Also cache the MCP package itself
    if npx -y @playwright/mcp@latest --help &>/dev/null; then
        success "Playwright MCP package cached"
    fi
}

# Main installation
main() {
    local os=$(get_os_type)
    local pm=$(detect_package_manager)

    info "Detected OS: $os"
    info "Package manager: $pm"
    echo ""

    # Run pre-flight checks before proceeding
    preflight_checks "$pm"

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
        # Use different package list depending on package manager
        if [[ "$pm" == "brew" ]]; then
            # Linuxbrew - use linux-brew.txt
            while IFS= read -r line; do
                [[ -n "$line" ]] && os_packages+=("$line")
            done < <(read_packages "$PACKAGES_DIR/linux-brew.txt")
        else
            # Native package managers (apt, dnf, pacman) - use linux.txt
            while IFS= read -r line; do
                [[ -n "$line" ]] && os_packages+=("$line")
            done < <(read_packages "$PACKAGES_DIR/linux.txt")
        fi
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
                echo "  - $PACKAGES_DIR/linux.txt (for apt/dnf/pacman)"
                echo "  - $PACKAGES_DIR/linux-brew.txt (for Linuxbrew)"
            fi
            exit 1
            ;;
    esac
    
    # Install tools that require special installation on Linux
    if [[ "$os" == "linux" ]]; then
        echo ""
        info "Installing additional Linux tools..."
        # Install tools via curl/npm when not using Homebrew (not in apt/dnf/pacman repos)
        if [[ "$pm" != "brew" ]]; then
            install_uv
            install_codex
            install_gemini_cli
        fi
        install_devpod
        install_playwright_browsers
    fi
    
    # Configure devpod provider on macOS (devpod installed via Homebrew)
    if [[ "$os" == "macos" ]] && command_exists devpod; then
        echo ""
        info "Configuring devpod..."
        configure_devpod_provider
    fi
    
    # Install Playwright browsers (for MCP server)
    if [[ "$os" == "macos" ]]; then
        echo ""
        info "Installing Playwright browsers..."
        install_playwright_browsers
    fi
    
    echo ""
    success "Package installation complete!"
}

main "$@"
