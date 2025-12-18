#!/usr/bin/env bash
# Dotfiles installer using GNU Stow
# Simple, reliable, debuggable

set -euo pipefail

# Get script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"

# Determine host directory (try full hostname first, then short hostname without domain)
HOSTNAME_FULL="$(hostname)"
HOSTNAME_SHORT="${HOSTNAME_FULL%%.*}"
if [[ -d "$DOTFILES_DIR/hosts/$HOSTNAME_FULL" ]]; then
    HOST_DIR="$DOTFILES_DIR/hosts/$HOSTNAME_FULL"
elif [[ -d "$DOTFILES_DIR/hosts/$HOSTNAME_SHORT" ]]; then
    HOST_DIR="$DOTFILES_DIR/hosts/$HOSTNAME_SHORT"
else
    HOST_DIR="$DOTFILES_DIR/hosts/$HOSTNAME_SHORT"
fi

# Source shared utilities
source "$DOTFILES_DIR/scripts/lib/utils.sh"

info "Dotfiles installation starting..."
info "Dotfiles directory: $DOTFILES_DIR"

# Detect OS (wrapper for utils.sh functions)
get_os_type() {
    if is_macos; then
        echo "macos"
    elif is_linux; then
        echo "linux"
    else
        echo "unknown"
    fi
}

OS=$(get_os_type)
info "Detected OS: $OS"

# Check prerequisites
check_prerequisites() {
    local missing=()
    
    # Add Homebrew to PATH if it exists but isn't loaded (macOS)
    if [[ "$OS" == "macos" ]] && [[ ! -x "$(command -v brew)" ]]; then
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v stow &> /dev/null; then
        missing+=("stow")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required tools: ${missing[*]}"
        info "Installing prerequisites..."
        
        if [[ "$OS" == "macos" ]]; then
            if ! command -v brew &> /dev/null; then
                error "Homebrew not installed. Install it first:"
                echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
                exit 1
            fi
            brew install stow git
        elif [[ "$OS" == "linux" ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y stow git
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y stow git
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm stow git
            else
                error "Unsupported package manager. Install stow and git manually."
                exit 1
            fi
        else
            error "Unsupported OS. Install stow and git manually."
            exit 1
        fi
        success "Prerequisites installed"
    else
        success "Prerequisites satisfied: git, stow"
    fi
}

# Install packages
install_packages() {
    info "Installing packages..."
    
    if [[ ! -d "$DOTFILES_DIR/packages" ]]; then
        warning "No packages directory found, skipping package installation"
        return
    fi
    
    if [[ -f "$DOTFILES_DIR/packages/install.sh" ]]; then
        bash "$DOTFILES_DIR/packages/install.sh"
    else
        warning "No package installer found, skipping"
    fi
}

# Backup existing files
backup_existing() {
    local file=$1
    if [[ -f "$HOME/$file" ]] || [[ -d "$HOME/$file" ]]; then
        if [[ ! -L "$HOME/$file" ]]; then
            local backup="$HOME/$file.backup-$(date +%Y%m%d-%H%M%S)"
            warning "Backing up existing $file to ${backup##*/}"
            mv "$HOME/$file" "$backup"
        fi
    fi
}

# Stow packages
stow_packages() {
    info "Symlinking configuration files..."
    
    if [[ ! -d "$STOW_DIR" ]]; then
        error "Stow directory not found: $STOW_DIR"
        exit 1
    fi
    
    cd "$STOW_DIR"
    
    local failed_packages=()
    
    # Find all packages (directories in stow/)
    for package in */; do
        package=${package%/}  # Remove trailing slash
        
        info "Installing $package..."
        
        # Dry-run to detect conflicts
        local stow_output
        stow_output=$(stow -n -v -t "$HOME" "$package" 2>&1) || true
        
        # Backup conflicts before stowing
        echo "$stow_output" | grep "existing target is neither a link nor a directory" | \
            sed 's/.*existing target is neither a link nor a directory: //' | \
            while IFS= read -r file; do
                [[ -n "$file" ]] && backup_existing "$file"
            done
        
        # Now stow the package (use -R for restow to handle already-stowed packages)
        if stow -R -v -t "$HOME" "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
            success "$package configured"
        else
            # Check if it actually failed or just had no output
            if stow -n -t "$HOME" "$package" 2>&1 | grep -q "ERROR\|CONFLICT"; then
                error "Failed to stow $package"
                failed_packages+=("$package")
            else
                success "$package configured"
            fi
        fi
    done
    
    # Report any failures
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo ""
        warning "Some packages failed to stow: ${failed_packages[*]}"
        warning "Try manually fixing conflicts and re-running ./stow-all.sh"
    fi
}

# Apply host-specific overrides
apply_host_overrides() {
    if [[ -d "$HOST_DIR" ]]; then
        info "Applying host-specific overrides for $(hostname)..."
        
        # Copy any host-specific files
        if [[ -d "$HOST_DIR/files" ]]; then
            cp -r "$HOST_DIR/files/." "$HOME/"
            success "Host-specific files applied"
        fi
        
        # Run host.sh to apply host-specific configuration
        if [[ -f "$HOST_DIR/host.sh" ]]; then
            info "Running host-specific setup script..."
            bash "$HOST_DIR/host.sh"
            success "Host-specific setup complete"
        fi
    else
        info "No host-specific overrides found for $(hostname)"
        info "Create them at: $HOST_DIR"
    fi
}

# Post-install tasks
post_install() {
    info "Running post-install tasks..."
    
    # Set ZSH as default shell if available
    if command -v zsh &> /dev/null; then
        if [[ "$SHELL" != *"zsh"* ]]; then
            info "Setting ZSH as default shell..."
            if ! grep -q "$(which zsh)" /etc/shells; then
                echo "$(which zsh)" | sudo tee -a /etc/shells > /dev/null
            fi
            chsh -s "$(which zsh)"
            success "Default shell set to ZSH"
            warning "Please log out and back in for shell change to take effect"
        fi
    fi
    
    # Install Neovim plugins if nvim is available
    if command -v nvim &> /dev/null; then
        info "Neovim will install plugins on first launch"
    fi
    
    success "Installation complete!"
    echo ""
    info "Next steps:"
    echo "  1. Restart your shell or run: exec zsh"
    echo "  2. Run 'nvim' to let plugins install"
    echo "  3. Enjoy your dotfiles!"
    echo ""
    info "Host-specific config: $HOST_DIR"
}

# Main installation flow
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║     Dotfiles Installation (Stow)     ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    check_prerequisites
    install_packages
    stow_packages
    apply_host_overrides
    post_install
}

main "$@"
