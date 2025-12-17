#!/usr/bin/env bash
# Dotfiles installer using GNU Stow
# Simple, reliable, debuggable

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warning() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

# Get script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES_DIR/stow"
HOST_DIR="$DOTFILES_DIR/hosts/$(hostname)"

info "Dotfiles installation starting..."
info "Dotfiles directory: $DOTFILES_DIR"

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

OS=$(detect_os)
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
    
    # Find all packages (directories in stow/)
    for package in */; do
        package=${package%/}  # Remove trailing slash
        
        info "Installing $package..."
        
        # Backup conflicts before stowing
        # This prevents stow from failing on existing files
        while IFS= read -r file; do
            backup_existing "$file"
        done < <(stow -n -v "$package" 2>&1 | grep "existing target is" | sed 's/.*existing target is neither a link nor a directory: //' || true)
        
        # Now stow the package
        if stow -v "$package" 2>&1 | grep -v "BUG in find_stowed_path"; then
            success "$package configured"
        else
            error "Failed to stow $package"
        fi
    done
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
        
        # Source host-specific shell config if it exists
        if [[ -f "$HOST_DIR/host.sh" ]]; then
            # Add source line to .zshrc if not already there
            local source_line="[ -f \"$HOST_DIR/host.sh\" ] && source \"$HOST_DIR/host.sh\""
            if [[ -f "$HOME/.zshrc" ]] && ! grep -q "host.sh" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "# Host-specific configuration" >> "$HOME/.zshrc"
                echo "$source_line" >> "$HOME/.zshrc"
                success "Host-specific shell config linked"
            fi
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
