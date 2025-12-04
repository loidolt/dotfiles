#!/usr/bin/env bash
# Health check script for dotfiles installation
# Run this to diagnose issues with your dotfiles setup

# Don't exit on errors - we want to run all checks
set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
info() { echo -e "${BLUE}i${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}!${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }
section() { echo ""; echo -e "${CYAN}===${NC} ${MAGENTA}$*${NC}"; echo ""; }

# OS detection
is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }
is_linux() { [[ "$OSTYPE" == "linux-gnu"* ]]; }

detect_os() {
    if is_macos; then
        echo "macOS"
    elif is_linux; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "Linux ($NAME)"
        else
            echo "Linux"
        fi
    else
        echo "Unknown"
    fi
}

command_exists() { command -v "$1" &>/dev/null; }

# Track overall status
ISSUES_FOUND=0
WARNINGS_FOUND=0

check_pass() {
    success "$1"
}

check_fail() {
    error "$1"
    ((ISSUES_FOUND++))
}

check_warn() {
    warning "$1"
    ((WARNINGS_FOUND++))
}

section "System Information"
info "Host: $(hostname)"
info "OS: $(detect_os)"
info "User: $(whoami)"
info "Shell: $SHELL"

# Source nix if available (needed for non-login shells)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

section "Nix Installation"

# Check nix is installed
if command_exists nix; then
    check_pass "Nix is installed: $(nix --version)"
else
    check_fail "Nix is not installed"
    echo "  Install with: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
fi

# Check nix-daemon is running (Linux only)
if is_linux; then
    if systemctl is-active --quiet nix-daemon 2>/dev/null; then
        check_pass "nix-daemon is running"
    else
        check_fail "nix-daemon is not running"
        echo "  Fix with: sudo systemctl start nix-daemon"
    fi
fi

# Check trusted-users (Linux only)
if is_linux && [ -f /etc/nix/nix.conf ]; then
    if grep -q "trusted-users.*$(whoami)" /etc/nix/nix.conf 2>/dev/null; then
        check_pass "User is trusted in nix.conf"
    else
        check_warn "User is not a trusted user (cachix won't work)"
        echo "  Fix with: echo 'trusted-users = root $(whoami)' | sudo tee -a /etc/nix/nix.conf && sudo systemctl restart nix-daemon"
    fi
fi

section "Home Manager"

# Check home-manager is available
if bash -l -c 'command -v home-manager' &>/dev/null; then
    check_pass "home-manager is available"
else
    check_fail "home-manager is not in PATH"
fi

# Check home-manager generation exists
if [ -L "$HOME/.nix-profile" ]; then
    check_pass "Nix profile exists: $(readlink "$HOME/.nix-profile")"
else
    check_fail "Nix profile symlink missing"
fi

section "PATH Configuration"

# Check if nix-profile/bin is in PATH
if echo "$PATH" | grep -q ".nix-profile/bin"; then
    check_pass "~/.nix-profile/bin is in PATH"
else
    check_warn "~/.nix-profile/bin is NOT in PATH"
    echo "  This may indicate zsh isn't sourcing nix-daemon.sh"
    echo "  Try: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# Check local bin directories
if echo "$PATH" | grep -q ".local/bin"; then
    check_pass "~/.local/bin is in PATH"
else
    check_warn "~/.local/bin is NOT in PATH"
fi

if echo "$PATH" | grep -q ".opencode/bin"; then
    check_pass "~/.opencode/bin is in PATH"
else
    check_warn "~/.opencode/bin is NOT in PATH"
fi

section "Shell Configuration"

# Check zsh config files
for file in .zshenv .zshrc; do
    if [ -L "$HOME/$file" ] || [ -f "$HOME/$file" ]; then
        check_pass "$file exists"
    else
        check_fail "$file is missing"
    fi
done

# Check if .zprofile exists (needed for nix PATH on Linux)
if is_linux; then
    if [ -L "$HOME/.zprofile" ] || [ -f "$HOME/.zprofile" ]; then
        check_pass ".zprofile exists"
    else
        check_warn ".zprofile is missing (may need hm switch)"
    fi
fi

section "External Tools (not managed by nix)"

# Check opencode
if command_exists opencode; then
    check_pass "opencode is installed: $(which opencode)"
elif [ -x "$HOME/.opencode/bin/opencode" ]; then
    check_warn "opencode exists but not in PATH"
else
    check_warn "opencode is not installed"
    echo "  Install with: curl -fsSL https://opencode.ai/install | bash"
fi

# Check claude CLI
if command_exists claude; then
    check_pass "claude CLI is installed: $(which claude)"
elif [ -x "$HOME/.local/bin/claude" ]; then
    check_warn "claude exists but not in PATH"
else
    check_warn "claude CLI is not installed"
    echo "  Install with: curl -fsSL https://claude.ai/install | bash"
fi

section "Key Nix-Managed Tools"

# Check essential tools from nix profile
for tool in nvim git tmux fzf eza bat starship zoxide; do
    if bash -l -c "command -v $tool" &>/dev/null; then
        check_pass "$tool is available"
    else
        check_fail "$tool is NOT available (run hm to fix)"
    fi
done

section "Summary"

echo ""
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    success "All checks passed! Your dotfiles setup is healthy."
elif [ $ISSUES_FOUND -eq 0 ]; then
    warning "Found $WARNINGS_FOUND warning(s), but no critical issues."
else
    error "Found $ISSUES_FOUND critical issue(s) and $WARNINGS_FOUND warning(s)."
    echo ""
    info "Common fixes:"
    echo "  1. Run 'hm' to apply home-manager configuration"
    echo "  2. Start a new terminal session after changes"
    echo "  3. Run installers for external tools (opencode, claude)"
fi

exit $ISSUES_FOUND
