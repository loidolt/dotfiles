#!/usr/bin/env bash
# Health check script for dotfiles installation
# Run this to diagnose issues with your dotfiles setup

# Source utilities for consistent colors and functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Don't exit on errors - we want to run all checks
# Must be set AFTER sourcing utils.sh which sets -e
set +e

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

section "Package Manager"

if is_macos; then
    if command_exists brew; then
        check_pass "Homebrew is installed: $(brew --version | head -n1)"
    else
        check_fail "Homebrew is not installed"
        echo "  Install with: /bin/bash -c '\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
    fi
elif is_linux; then
    if command_exists apt-get; then
        check_pass "apt package manager available"
    elif command_exists dnf; then
        check_pass "dnf package manager available"
    elif command_exists pacman; then
        check_pass "pacman package manager available"
    else
        check_warn "No recognized package manager found"
    fi
fi

section "GNU Stow"

if command_exists stow; then
    check_pass "GNU Stow is installed: $(stow --version | head -n1)"
else
    check_fail "GNU Stow is not installed"
    if is_macos; then
        echo "  Install with: brew install stow"
    else
        echo "  Install with your package manager (apt/dnf/pacman)"
    fi
fi

section "PATH Configuration"

# Check local bin directory
# shellcheck disable=SC2088 # literal ~ in messages is intentional
if echo "$PATH" | grep -q ".local/bin"; then
    check_pass "~/.local/bin is in PATH"
else
    check_warn "~/.local/bin is NOT in PATH"
    echo "  Add to ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Check Homebrew in PATH (macOS)
if is_macos && command_exists brew; then
    if echo "$PATH" | grep -q "homebrew"; then
        check_pass "Homebrew is in PATH"
    else
        check_warn "Homebrew may not be properly configured in PATH"
        echo "  Run: eval \"\$(brew shellenv)\""
    fi
fi

section "Shell Configuration"

# Check zsh config files
for file in .zshrc .zshenv; do
    if [ -L "$HOME/$file" ]; then
        check_pass "$file is symlinked (managed by Stow)"
    elif [ -f "$HOME/$file" ]; then
        check_warn "$file exists but is not a symlink"
        echo "  May need to backup and restow: mv ~/$file ~/$file.backup && cd ~/dotfiles/stow && stow zsh"
    else
        check_fail "$file is missing"
        echo "  Run: cd ~/dotfiles && ./install.sh"
    fi
done

# Check if shell is zsh
if [[ "$SHELL" == *"zsh"* ]]; then
    check_pass "Default shell is zsh"
else
    check_warn "Default shell is not zsh: $SHELL"
    echo "  Change with: chsh -s \$(which zsh)"
fi

section "Stow Packages"

DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
fi

# Helper function to verify symlink points to dotfiles
verify_stow_symlink() {
    local target="$1"
    local pkg="$2"

    if [ -L "$target" ]; then
        local link_target
        link_target=$(readlink "$target")
        if [[ "$link_target" == *"dotfiles/stow/$pkg"* ]]; then
            check_pass "$pkg is correctly stowed"
            return 0
        else
            check_warn "$pkg is symlinked but not to dotfiles repo"
            echo "    Points to: $link_target"
            return 1
        fi
    elif [ -f "$target" ] || [ -d "$target" ]; then
        check_warn "$pkg exists but is not a symlink (not managed by stow)"
        echo "    Consider: mv $target ${target}.backup && cd ~/dotfiles && stow -R $pkg"
        return 1
    else
        check_warn "$pkg is not installed"
        return 1
    fi
}

if [ -d "$DOTFILES_DIR/stow" ]; then
    check_pass "Dotfiles directory found: $DOTFILES_DIR"

    # Check key stow packages with proper symlink verification
    for pkg in git tmux starship zsh; do
        if [ -d "$DOTFILES_DIR/stow/$pkg" ]; then
            case $pkg in
                git)
                    verify_stow_symlink "$HOME/.gitconfig" "$pkg"
                    ;;
                tmux)
                    verify_stow_symlink "$HOME/.tmux.conf" "$pkg"
                    ;;
                starship)
                    verify_stow_symlink "$HOME/.config/starship.toml" "$pkg"
                    ;;
                zsh)
                    verify_stow_symlink "$HOME/.zshrc" "$pkg"
                    ;;
            esac
        fi
    done
else
    check_fail "Dotfiles directory not found at $DOTFILES_DIR"
    echo "  Clone with: git clone https://github.com/loidolt/dotfiles.git ~/dotfiles"
fi

section "Essential Tools"

# Check essential CLI tools
for tool in git tmux fzf eza bat rg fd zoxide starship; do
    if command_exists "$tool"; then
        check_pass "$tool is installed"
    else
        check_warn "$tool is NOT installed"
        echo "  Install via: cd ~/dotfiles && ./packages/install.sh"
    fi
done

section "Terminal Integration (tmux / cmux)"

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    check_pass "TPM installed"
else
    check_warn "TPM not installed (reload tmux config to bootstrap: prefix + r)"
fi

if [ -x "$HOME/.claude/hooks/agent-notify.sh" ]; then
    check_pass "Agent notify hook installed"
    if ! command_exists jq; then
        check_warn "jq missing - agent notifications will be silent"
    fi
else
    check_warn "Agent notify hook missing (run: make stow-all)"
fi

if is_linux; then
    section "Machine Hygiene"

    # /tmp in RAM fills swap; it should be on disk
    if [ "$(findmnt -n -o FSTYPE /tmp 2>/dev/null)" = "tmpfs" ]; then
        if [ "$(systemctl is-enabled tmp.mount 2>/dev/null)" = "masked" ]; then
            check_warn "/tmp is tmpfs until next reboot (tmp.mount masked)"
        else
            check_warn "/tmp is tmpfs (RAM-backed); move to disk: sudo systemctl mask tmp.mount"
        fi
    else
        check_pass "/tmp is on disk"
    fi

    swap_total=$(awk '/SwapTotal/{print $2}' /proc/meminfo)
    swap_free=$(awk '/SwapFree/{print $2}' /proc/meminfo)
    if [ "$swap_total" -gt 0 ]; then
        swap_pct=$(( (swap_total - swap_free) * 100 / swap_total ))
        if [ "$swap_pct" -ge 80 ]; then
            check_warn "Swap ${swap_pct}% used"
        else
            check_pass "Swap ${swap_pct}% used"
        fi
    fi

    journal_mb=$(du -sm /var/log/journal 2>/dev/null | cut -f1)
    if [ "${journal_mb:-0}" -gt 1024 ]; then
        check_warn "journald uses ${journal_mb}M (run: make setup-hygiene)"
    else
        check_pass "journald uses ${journal_mb:-0}M"
    fi

    if [ -d "$HOME/.npm/_cacache" ]; then
        npm_gb=$(du -s --block-size=1G "$HOME/.npm/_cacache" 2>/dev/null | cut -f1)
        if [ "$npm_gb" -ge 5 ]; then
            check_warn "npm cache ${npm_gb}G (run: make maintain)"
        else
            check_pass "npm cache ${npm_gb}G"
        fi
    fi

    # Same policy as maintenance.sh: running versions plus the newest 2 are kept
    vscode_idle=0
    for d in "$HOME"/.vscode-server/cli/servers/Stable-*; do
        [ -d "$d" ] || continue
        pgrep -f "$d/" >/dev/null 2>&1 || vscode_idle=$((vscode_idle + 1))
    done
    if [ "$vscode_idle" -gt 2 ]; then
        check_warn "$vscode_idle idle VS Code server versions (run: make maintain)"
    fi

    if systemctl --user is-enabled dotfiles-maintenance.timer >/dev/null 2>&1; then
        check_pass "Weekly maintenance timer enabled"
    else
        check_warn "Maintenance timer not enabled (run: make setup-hygiene)"
    fi

    if [ "$(systemctl show "user@$(id -u).service" -p MemoryHigh --value 2>/dev/null)" = "infinity" ]; then
        check_warn "No memory guardrail on user session (run: make setup-hygiene)"
    else
        check_pass "Memory guardrail active on user session"
    fi
fi

section "Optional Tools"

# Check optional tools
for tool in lazygit lazydocker lazysql gh delta jq yq; do
    if command_exists "$tool"; then
        check_pass "$tool is installed"
    else
        check_warn "$tool is NOT installed (optional)"
    fi
done

section "MCP Servers"

# Check Node.js/npx for MCP servers
if command_exists npx; then
    check_pass "npx is installed: $(npx --version 2>/dev/null || echo 'version unknown')"
else
    check_warn "npx is NOT installed (required for MCP servers like Playwright)"
    echo "  Install Node.js via: brew install node (macOS) or apt install nodejs npm (Linux)"
fi

# Check Docker for MCP servers that require it
if command_exists docker; then
    if docker info &>/dev/null 2>&1; then
        check_pass "Docker is installed and running"

        # Check for sequentialthinking image
        if docker images mcp/sequentialthinking --format '{{.Repository}}' 2>/dev/null | grep -q "mcp/sequentialthinking"; then
            check_pass "Docker image mcp/sequentialthinking is available"
        else
            check_warn "Docker image mcp/sequentialthinking is NOT installed"
            echo "  Pull with: docker pull mcp/sequentialthinking"
        fi
    else
        check_warn "Docker is installed but not running"
        echo "  Start Docker daemon to use containerized MCP servers"
    fi
else
    check_warn "Docker is NOT installed (required for some MCP servers)"
    echo "  Install Docker: https://docs.docker.com/get-docker/"
fi

# Check Playwright browser installation
# macOS uses ~/Library/Caches/ms-playwright, Linux uses ~/.cache/ms-playwright
if is_macos; then
    PLAYWRIGHT_CACHE="$HOME/Library/Caches/ms-playwright"
else
    PLAYWRIGHT_CACHE="$HOME/.cache/ms-playwright"
fi

if [ -d "$PLAYWRIGHT_CACHE" ]; then
    CHROMIUM_COUNT=$(find "$PLAYWRIGHT_CACHE" -maxdepth 1 -type d -name "chromium*" 2>/dev/null | wc -l)
    if [ "$CHROMIUM_COUNT" -gt 0 ]; then
        check_pass "Playwright Chromium browsers installed ($CHROMIUM_COUNT version(s))"
    else
        check_warn "Playwright browsers NOT installed"
        echo "  Install with: npx playwright install chromium"
    fi
else
    check_warn "Playwright browsers NOT installed"
    echo "  Install with: npx playwright install chromium"
fi

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
    echo "  1. Run: cd ~/dotfiles && ./install.sh"
    echo "  2. Run: cd ~/dotfiles && ./packages/install.sh"
    echo "  3. Restart your shell: exec zsh"
fi

exit $ISSUES_FOUND
