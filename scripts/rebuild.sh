#!/usr/bin/env bash
#
# Smart rebuild script - detects platform and runs appropriate rebuild command
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Detect platform
detect_platform() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            echo "nixos"
        elif grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "darwin"
    else
        echo "unknown"
    fi
}

# Get hostname for configuration selection
get_hostname() {
    if [[ -f /etc/nixos/configuration.nix ]]; then
        # NixOS - use hostname from system
        hostname
    else
        # macOS/other - use username or hostname
        echo "$USER"
    fi
}

PLATFORM=$(detect_platform)
HOSTNAME=$(get_hostname)

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Nix Configuration Rebuild        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

info "Platform: $PLATFORM"
info "Hostname/User: $HOSTNAME"
echo ""

# Change to dotfiles directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

info "Dotfiles directory: $DOTFILES_DIR"
cd "$DOTFILES_DIR"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository!"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    warn "You have uncommitted changes:"
    git status -s
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Rebuild cancelled"
        exit 0
    fi
fi

# Parse arguments
SWITCH=true
BOOT=false
TEST=false
BUILD_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            TEST=true
            shift
            ;;
        --boot)
            BOOT=true
            SWITCH=false
            shift
            ;;
        --build)
            BUILD_ONLY=true
            SWITCH=false
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --test      Test the configuration (NixOS only)"
            echo "  --boot      Set configuration for next boot (NixOS only)"
            echo "  --build     Only build, don't activate"
            echo "  --help      Show this help message"
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

# Platform-specific rebuild
case $PLATFORM in
    "nixos")
        info "Rebuilding NixOS system..."
        
        # Determine configuration name
        if [[ "$HOSTNAME" == "nixos-desktop" ]]; then
            CONFIG="nixos-desktop"
        else
            CONFIG="nixos-desktop"  # default
        fi
        
        REBUILD_CMD="sudo nixos-rebuild"
        
        if [[ "$BUILD_ONLY" == true ]]; then
            REBUILD_CMD="$REBUILD_CMD build"
        elif [[ "$TEST" == true ]]; then
            REBUILD_CMD="$REBUILD_CMD test"
        elif [[ "$BOOT" == true ]]; then
            REBUILD_CMD="$REBUILD_CMD boot"
        else
            REBUILD_CMD="$REBUILD_CMD switch"
        fi
        
        REBUILD_CMD="$REBUILD_CMD --flake .#$CONFIG"
        
        info "Running: $REBUILD_CMD"
        eval "$REBUILD_CMD"
        
        success "NixOS rebuild complete!"
        
        if [[ "$BOOT" == true ]]; then
            info "Configuration will be active on next boot"
        elif [[ "$TEST" == true ]]; then
            info "Test configuration active (will not persist after reboot)"
        fi
        ;;
        
    "darwin")
        # Check if using nix-darwin or standalone Home Manager
        if command -v darwin-rebuild &> /dev/null && [[ -d "$DOTFILES_DIR/hosts/darwin" ]]; then
            info "Rebuilding nix-darwin configuration..."
            
            # Detect architecture
            ARCH=$(uname -m)
            if [[ "$ARCH" == "arm64" ]]; then
                CONFIG="darwin-arm64"
            else
                CONFIG="darwin-x86"
            fi
            
            if [[ "$BUILD_ONLY" == true ]]; then
                REBUILD_CMD="nix build .#darwinConfigurations.$CONFIG.system"
            else
                REBUILD_CMD="darwin-rebuild switch --flake .#$CONFIG"
            fi
            
            info "Running: $REBUILD_CMD"
            eval "$REBUILD_CMD"
            
            success "nix-darwin rebuild complete!"
        else
            info "Rebuilding Home Manager configuration for macOS..."
            
            CONFIG="${HOSTNAME:-chrisloidolt}"
            
            if [[ "$BUILD_ONLY" == true ]]; then
                REBUILD_CMD="nix build .#homeConfigurations.$CONFIG.activationPackage"
            else
                REBUILD_CMD="home-manager switch --flake .#$CONFIG"
            fi
            
            info "Running: $REBUILD_CMD"
            eval "$REBUILD_CMD"
            
            success "Home Manager rebuild complete!"
        fi
        
        if [[ "$SWITCH" == true ]]; then
            info "Close and reopen your terminal to see all changes"
        fi
        ;;
        
    "wsl")
        info "Rebuilding NixOS-WSL system..."
        
        CONFIG="wsl"
        
        REBUILD_CMD="sudo nixos-rebuild"
        
        if [[ "$BUILD_ONLY" == true ]]; then
            REBUILD_CMD="$REBUILD_CMD build"
        else
            REBUILD_CMD="$REBUILD_CMD switch"
        fi
        
        REBUILD_CMD="$REBUILD_CMD --flake .#$CONFIG"
        
        info "Running: $REBUILD_CMD"
        eval "$REBUILD_CMD"
        
        success "NixOS-WSL rebuild complete!"
        ;;
        
    *)
        error "Unknown platform: $PLATFORM"
        error "This script supports: NixOS, macOS (Home Manager), and WSL2"
        exit 1
        ;;
esac

echo ""
info "Rebuild completed successfully!"
echo ""

# Show helpful next steps
echo -e "${BLUE}Next steps:${NC}"
if [[ "$PLATFORM" == "darwin" ]]; then
    echo "  • Restart your terminal to load new configuration"
    echo "  • Run 'home-manager generations' to see previous versions"
elif [[ "$PLATFORM" == "nixos" ]] || [[ "$PLATFORM" == "wsl" ]]; then
    echo "  • Run 'nixos-rebuild list-generations' to see previous versions"
    echo "  • Rollback with: sudo nixos-rebuild switch --rollback"
fi
echo ""
