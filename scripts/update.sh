#!/usr/bin/env bash
#
# Update Nix flake inputs and rebuild
#

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib/utils.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Nix Flake Update & Rebuild       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

info "Dotfiles directory: $DOTFILES_DIR"
cd "$DOTFILES_DIR"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository!"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    warning "You have uncommitted changes:"
    git status -s
    echo ""
    warning "It's recommended to commit changes before updating"
    if ! ask "Continue anyway?"; then
        info "Update cancelled"
        exit 0
    fi
fi

# Parse arguments
UPDATE_SPECIFIC=""
REBUILD=true
COMMIT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            UPDATE_SPECIFIC="$2"
            shift 2
            ;;
        --no-rebuild)
            REBUILD=false
            shift
            ;;
        --commit)
            COMMIT=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --input NAME     Update only specific input (e.g., nixpkgs, home-manager)"
            echo "  --no-rebuild     Update flake.lock but don't rebuild"
            echo "  --commit         Automatically commit the updated flake.lock"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Update all inputs and rebuild"
            echo "  $0 --input nixpkgs          # Update only nixpkgs"
            echo "  $0 --no-rebuild             # Update but don't rebuild yet"
            echo "  $0 --commit                 # Update, rebuild, and commit changes"
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

# Show current flake info
info "Current flake inputs:"
echo ""
nix flake metadata 2>/dev/null | grep -A 20 "Inputs:" || true
echo ""

# Update flake inputs
if [[ -n "$UPDATE_SPECIFIC" ]]; then
    info "Updating specific input: $UPDATE_SPECIFIC"
    nix flake lock --update-input "$UPDATE_SPECIFIC"
else
    info "Updating all flake inputs..."
    nix flake update
fi

success "Flake inputs updated!"
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
