#!/usr/bin/env bash
# Validation script - Checks that everything is set up correctly

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

section "Validating Setup"

ERRORS=0
WARNINGS=0

# Check function
check() {
    local name="$1"
    local command="$2"
    
    if eval "$command" &>/dev/null; then
        success "$name"
        return 0
    else
        error "$name"
        ((ERRORS++))
        return 1
    fi
}

# Warning function  
check_warn() {
    local name="$1"
    local command="$2"
    
    if eval "$command" &>/dev/null; then
        success "$name"
        return 0
    else
        warning "$name (optional)"
        ((WARNINGS++))
        return 1
    fi
}

info "Checking core tools..."
check "Git" "command -v git"
check "Curl" "command -v curl"
check "Wget" "command -v wget"

echo ""
info "Checking CLI tools..."
check_warn "Ripgrep (rg)" "command -v rg"
check_warn "fd" "command -v fd"
check_warn "bat" "command -v bat"
check_warn "fzf" "command -v fzf"
check_warn "eza" "command -v eza"

echo ""
info "Checking development tools..."
check_warn "Docker" "command -v docker"
check_warn "Node.js" "command -v node"
check_warn "Bun" "command -v bun"
check_warn "mise" "command -v mise"

echo ""
info "Checking editors..."
check_warn "Neovim" "command -v nvim"
check_warn "VS Code" "command -v code"

echo ""
info "Checking dotfiles..."
check "OpenCode config" "[ -d ~/.config/opencode ]"
check "Neovim config" "[ -d ~/.config/nvim ]"

echo ""
info "Checking environment..."
if [ -f ~/.dotfiles_env ]; then
    success "Environment file exists"
    if grep -q "GET_FROM_https" ~/.dotfiles_env; then
        warning "API keys not configured in ~/.dotfiles_env"
        ((WARNINGS++))
    else
        success "API keys appear to be configured"
    fi
else
    error "Environment file missing"
    ((ERRORS++))
fi

echo ""
info "Checking shell configuration..."
if [ -f ~/.zshrc ]; then
    if grep -q ".dotfiles_env" ~/.zshrc; then
        success "Shell sources environment file"
    else
        warning "Shell doesn't source ~/.dotfiles_env"
        ((WARNINGS++))
    fi
else
    warning "~/.zshrc not found"
    ((WARNINGS++))
fi

echo ""
section "Validation Summary"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    success "All checks passed!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    warning "$WARNINGS warnings (optional features not installed)"
    exit 0
else
    error "$ERRORS errors, $WARNINGS warnings"
    echo ""
    info "Run ./bootstrap.sh to fix errors"
    exit 1
fi
