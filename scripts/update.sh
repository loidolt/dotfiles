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
                git pull
                info "Run 'git stash pop' to restore your changes"
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

# Show what changed
info "Changes to flake.lock:"
echo ""
git diff flake.lock | head -50 || true
echo ""

# Rebuild if requested
if [[ "$REBUILD" == true ]]; then
    info "Rebuilding with updated inputs..."
    echo ""
    
    # Use same configuration approach as zsh.nix (just username)
    # This matches the flake.nix which uses builtins.currentSystem for auto-detection
    CONFIG="${USER}"
    
    # Note: --impure allows reading gitignored files like ssh-hosts.nix
    home-manager switch --flake "$DOTFILES_DIR#${CONFIG}" --impure
else
    info "Skipping rebuild (run 'hm' manually to apply changes)"
fi

# Commit if requested
if [[ "$COMMIT" == true ]]; then
    echo ""
    info "Committing flake.lock changes..."
    
    if [[ -n $(git diff --cached flake.lock) ]] || [[ -n $(git diff flake.lock) ]]; then
        git add flake.lock
        
        # Create commit message
        if [[ -n "$UPDATE_SPECIFIC" ]]; then
            COMMIT_MSG="Update $UPDATE_SPECIFIC input"
        else
            COMMIT_MSG="Update all flake inputs"
        fi
        
        git commit -m "$COMMIT_MSG"
        success "Changes committed!"
        
        info "Don't forget to push: git push"
    else
        info "No changes to commit"
    fi
fi

echo ""
success "Update process complete!"
echo ""

# Show helpful information
echo -e "${BLUE}What was updated:${NC}"
if [[ -n "$UPDATE_SPECIFIC" ]]; then
    echo "  - $UPDATE_SPECIFIC input"
else
    echo "  - All flake inputs (nixpkgs, home-manager, etc.)"
fi
echo ""

if [[ "$REBUILD" == false ]]; then
    echo -e "${YELLOW}Note:${NC} Changes are not yet active"
    echo "  Run 'hm' to apply updates"
    echo ""
fi

echo -e "${BLUE}Next steps:${NC}"
echo "  - Test your system to ensure everything works"
echo "  - If issues occur, rollback with previous generation"
if [[ "$COMMIT" == false ]]; then
    echo "  - Commit flake.lock: git add flake.lock && git commit -m 'Update flake inputs'"
fi
echo "  - Push changes: git push"
echo ""
