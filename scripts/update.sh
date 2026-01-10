#!/usr/bin/env bash
#
# Update system packages and dotfiles
#

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib/utils.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       System & Package Update         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

info "Dotfiles directory: $DOTFILES_DIR"
cd "$DOTFILES_DIR"

# Parse arguments
UPDATE_DOTFILES=true
UPDATE_PACKAGES=true
PULL_CHANGES=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-dotfiles)
            UPDATE_DOTFILES=false
            shift
            ;;
        --no-packages)
            UPDATE_PACKAGES=false
            shift
            ;;
        --no-pull)
            PULL_CHANGES=false
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-dotfiles    Don't update dotfiles from git"
            echo "  --no-packages    Don't update system packages"
            echo "  --no-pull        Don't pull latest changes from git"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                       # Update everything"
            echo "  $0 --no-dotfiles        # Only update system packages"
            echo "  $0 --no-packages        # Only update dotfiles"
            echo ""
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Update dotfiles from git
if [ "$UPDATE_DOTFILES" = true ] && [ "$PULL_CHANGES" = true ]; then
    section "Updating Dotfiles from Git"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        warning "Not in a git repository, skipping git pull"
    else
        # Check for uncommitted changes
        if [[ -n $(git status -s) ]]; then
            warning "You have uncommitted changes:"
            git status -s
            echo ""
            if ! ask "Stash changes and pull?"; then
                warning "Skipping git pull"
            else
                git stash
                if git pull; then
                    info "Restoring stashed changes..."
                    if git stash pop; then
                        success "Changes restored successfully"
                    else
                        warning "Could not auto-restore changes. Run 'git stash pop' manually"
                        warning "You may need to resolve conflicts"
                    fi
                else
                    warning "Pull failed. Your changes are still stashed"
                    info "Run 'git stash pop' to restore your changes"
                fi
            fi
        else
            info "Pulling latest changes..."
            git pull
            success "Dotfiles updated from git"
        fi
    fi
fi

# Update system packages
if [ "$UPDATE_PACKAGES" = true ]; then
    section "Updating System Packages"
    
    if is_macos; then
        if command_exists brew; then
            info "Updating Homebrew..."
            brew update
            
            info "Upgrading Homebrew packages..."
            brew upgrade
            
            info "Cleaning up..."
            brew cleanup
            
            success "Homebrew packages updated"
        else
            warning "Homebrew not installed, skipping package updates"
        fi
    elif is_linux; then
        # Detect Linux package manager
        if command_exists apt-get; then
            info "Updating apt package list..."
            sudo apt-get update
            
            info "Upgrading packages..."
            sudo apt-get upgrade -y
            
            info "Removing unused packages..."
            sudo apt-get autoremove -y
            
            success "apt packages updated"
        elif command_exists dnf; then
            info "Updating dnf packages..."
            sudo dnf upgrade -y
            
            success "dnf packages updated"
        elif command_exists pacman; then
            info "Updating pacman packages..."
            sudo pacman -Syu --noconfirm
            
            success "pacman packages updated"
        else
            warning "No recognized package manager found, skipping system updates"
        fi
    else
        warning "Unknown OS, skipping system package updates"
    fi
fi

# Restow all packages to pick up any changes
if [ "$UPDATE_DOTFILES" = true ]; then
    section "Restowing Dotfiles"
    
    if [ -f "$DOTFILES_DIR/stow-all.sh" ]; then
        info "Running stow-all.sh to apply any changes..."
        bash "$DOTFILES_DIR/stow-all.sh"
        success "Dotfiles restowed"
    else
        warning "stow-all.sh not found, skipping restow"
    fi
fi

section "Update Complete!"
echo ""
success "System is up to date"
echo ""
info "Next steps:"
echo "  1. Restart your shell: exec zsh"
echo "  2. Run health check: ./scripts/health-check.sh"
echo ""
