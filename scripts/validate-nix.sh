#!/usr/bin/env bash
# Nix System Validation Script
# Run this to verify your Nix setup is working correctly

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/lib/utils.sh"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions specific to validation
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_failure() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

check_command() {
    local cmd=$1
    local display_name=${2:-$cmd}
    
    if command -v "$cmd" &> /dev/null; then
        local version
        version=$(command "$cmd" --version 2>&1 | head -1 || echo "unknown")
        print_success "$display_name: $version"
        return 0
    else
        print_failure "$display_name not found"
        return 1
    fi
}

# Start validation
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Nix System Validation Script        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# System Information
print_header "System Information"
echo "Platform: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Home: $HOME"

# Detect platform type
PLATFORM="unknown"
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "OS: $NAME $VERSION"
    if [[ "$NAME" == "NixOS" ]]; then
        PLATFORM="nixos"
        echo "NixOS Version: $(nixos-version 2>/dev/null || echo 'N/A')"
    elif grep -q Microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
        echo "Platform: WSL2"
    else
        PLATFORM="linux"
    fi
elif [[ "$(uname -s)" == "Darwin" ]]; then
    PLATFORM="macos"
    echo "macOS Version: $(sw_vers -productVersion)"
fi

# Nix Installation
print_header "Nix Installation"

if command -v nix &> /dev/null; then
    nix_version=$(nix --version)
    print_success "Nix installed: $nix_version"
    
    # Check Nix version
    version_number=$(echo "$nix_version" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if command -v bc &> /dev/null && [[ $(echo "$version_number >= 2.18" | bc -l 2>/dev/null || echo "0") == "1" ]]; then
        print_success "Nix version >= 2.18"
    else
        print_warning "Nix version < 2.18 (recommended: >= 2.18)"
    fi
else
    print_failure "Nix not installed"
    echo ""
    echo "Install Nix:"
    echo "  sh <(curl -L https://nixos.org/nix/install) --daemon"
    exit 1
fi

# Flakes enabled
print_header "Nix Configuration"

if nix flake --version &> /dev/null; then
    print_success "Flakes enabled"
else
    print_failure "Flakes not enabled"
    echo ""
    echo "Enable flakes:"
    echo "  mkdir -p ~/.config/nix"
    echo "  echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
fi

# Check nix.conf
if [[ -f ~/.config/nix/nix.conf ]]; then
    print_success "Nix config exists: ~/.config/nix/nix.conf"
    if grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
        print_success "Flakes enabled in config"
    fi
fi

# Nix store
if [[ -d /nix/store ]]; then
    store_size=$(du -sh /nix/store 2>/dev/null | cut -f1)
    print_success "Nix store exists: $store_size"
else
    print_failure "Nix store not found"
fi

# Core Tools
print_header "Core Tools"

check_command git "Git"
check_command zsh "Zsh"
check_command nvim "Neovim" || check_command vim "Vim"
check_command tmux "Tmux"

# Modern CLI Tools
print_header "Modern CLI Tools"

check_command rg "ripgrep"
check_command fd "fd"
check_command bat "bat"
check_command eza "eza"
check_command zoxide "zoxide"
check_command fzf "fzf"
check_command delta "delta"

# Development Tools
print_header "Development Tools"

check_command node "Node.js"
check_command bun "Bun"
check_command gh "GitHub CLI"

# Shell Configuration
print_header "Shell Configuration"

# Check if running in zsh
if [[ "$SHELL" == *"zsh"* ]]; then
    print_success "Default shell: zsh"
else
    print_warning "Default shell is not zsh: $SHELL"
fi

# Check oh-my-zsh
if [[ -d ~/.oh-my-zsh ]] || command -v omz &> /dev/null; then
    print_success "oh-my-zsh installed"
else
    print_warning "oh-my-zsh not found"
fi

# Check starship
if command -v starship &> /dev/null; then
    print_success "Starship prompt installed"
    
    # Check if starship is in use
    if grep -q "starship" ~/.zshrc 2>/dev/null || [[ -f ~/.config/starship.toml ]]; then
        print_success "Starship configured"
    fi
else
    print_warning "Starship not installed"
fi

# Configurations
print_header "Configuration Files"

# Neovim
if [[ -d ~/.config/nvim ]]; then
    if [[ -L ~/.config/nvim ]]; then
        target=$(readlink ~/.config/nvim)
        print_success "Neovim config (symlink): $target"
    else
        print_success "Neovim config exists"
    fi
else
    print_warning "Neovim config not found"
fi

# Tmux
if [[ -f ~/.tmux.conf ]] || [[ -f ~/.config/tmux/tmux.conf ]]; then
    print_success "Tmux config exists"
else
    print_warning "Tmux config not found"
fi

# OpenCode
if [[ -d ~/.config/opencode ]]; then
    if [[ -L ~/.config/opencode ]]; then
        target=$(readlink ~/.config/opencode)
        print_success "OpenCode config (symlink): $target"
    else
        print_success "OpenCode config exists"
    fi
else
    print_warning "OpenCode config not found"
fi

# Ghostty
if [[ -d ~/.config/ghostty ]]; then
    if [[ -L ~/.config/ghostty ]]; then
        target=$(readlink ~/.config/ghostty)
        print_success "Ghostty config (symlink): $target"
    else
        print_success "Ghostty config exists"
    fi
else
    print_warning "Ghostty config not found"
fi

# Home Manager (if applicable)
print_header "Home Manager"

if command -v home-manager &> /dev/null; then
    print_success "Home Manager installed"
    
    # Check generations
    if home-manager generations &> /dev/null; then
        current_gen=$(home-manager generations | head -1)
        print_success "Current generation: $current_gen"
    fi
else
    print_warning "Home Manager not installed"
fi

# NixOS Specific (if on NixOS)
if [[ "$PLATFORM" == "nixos" ]]; then
    print_header "NixOS Configuration"
    
    if [[ -f /etc/nixos/configuration.nix ]] || [[ -d /etc/nixos ]]; then
        print_success "NixOS configuration exists"
    fi
    
    if command -v nixos-rebuild &> /dev/null; then
        print_success "nixos-rebuild available"
    fi
    
    # Check for desktop environment
    if command -v plasmashell &> /dev/null; then
        print_success "KDE Plasma installed"
    elif command -v gnome-shell &> /dev/null; then
        print_success "GNOME installed"
    fi
    
    # Check Docker
    if systemctl is-active --quiet docker 2>/dev/null; then
        print_success "Docker service running"
    elif command -v docker &> /dev/null; then
        print_warning "Docker installed but service not running"
    fi
fi

# macOS Specific (if on macOS)
if [[ "$PLATFORM" == "macos" ]]; then
    print_header "macOS Configuration"
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew installed"
    else
        print_warning "Homebrew not installed"
    fi
    
    if command -v darwin-rebuild &> /dev/null; then
        print_success "nix-darwin installed"
    else
        print_warning "nix-darwin not installed (optional)"
    fi
fi

# Dotfiles Repository
print_header "Dotfiles Repository"

DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
if [[ -d "$DOTFILES_DIR" ]]; then
    print_success "Dotfiles directory exists: $DOTFILES_DIR"
    
    cd "$DOTFILES_DIR"
    
    if git rev-parse --git-dir &> /dev/null 2>&1; then
        print_success "Dotfiles is a git repository"
        
        current_branch=$(git branch --show-current)
        print_success "Current branch: $current_branch"
        
        if [[ -f flake.nix ]]; then
            print_success "flake.nix exists"
            
            # Try to show flake
            if nix flake show . &> /dev/null; then
                print_success "Flake is valid"
            else
                print_failure "Flake has errors"
            fi
        else
            print_warning "flake.nix not found"
        fi
    else
        print_failure "Dotfiles is not a git repository"
    fi
else
    print_failure "Dotfiles directory not found"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Validation Summary          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Passed:   $PASSED${NC}"
echo -e "${RED}✗ Failed:   $FAILED${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}All checks passed! Your Nix setup looks great!${NC}"
        exit 0
    else
        echo -e "${YELLOW}All critical checks passed, but there are some warnings.${NC}"
        echo "Review the warnings above to ensure everything is configured as expected."
        exit 0
    fi
else
    echo -e "${RED}Some checks failed. Please review the errors above.${NC}"
    exit 1
fi
