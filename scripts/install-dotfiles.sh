#!/usr/bin/env bash
# Install dotfiles using Home Manager
# Run this after setup-*-initial.sh has completed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib/utils.sh"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Dotfiles Installation            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verify Nix is installed
section "Verifying Prerequisites"

if ! command_exists nix; then
    error "Nix is not installed!"
    error "Please run the initial setup script first:"
    error "  bash $SCRIPT_DIR/initial-setup.sh"
    exit 1
fi

success "Nix is installed: $(nix --version)"

# Check if nix-daemon is running (Linux only)
if is_linux; then
    if systemctl is-active --quiet nix-daemon 2>/dev/null; then
        success "nix-daemon is running"
    else
        error "nix-daemon is not running!"
        info "Start it with:"
        echo "  sudo systemctl start nix-daemon"
        echo "  sudo systemctl enable nix-daemon"
        exit 1
    fi
    
    # Check if user is in nix-users group
    if groups | grep -q nix-users; then
        success "User is in nix-users group"
    else
        error "User is NOT in nix-users group!"
        info "Fix this with:"
        echo "  sudo usermod -aG nix-users $(whoami)"
        echo ""
        warning "After adding yourself to the group, you MUST:"
        echo "  1. Log out completely"
        echo "  2. Log back in"
        echo "  3. Verify with: groups | grep nix-users"
        echo "  4. Run this script again"
        exit 1
    fi
fi

# Verify we're in the dotfiles directory
if [ ! -f "$DOTFILES_DIR/flake.nix" ]; then
    error "Cannot find flake.nix in $DOTFILES_DIR"
    error "Please run this script from the dotfiles repository"
    exit 1
fi

success "Found dotfiles configuration in: $DOTFILES_DIR"

# Check if we're in a git repository
if ! git -C "$DOTFILES_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    warning "Not in a git repository!"
    warning "This is unusual but will continue..."
fi

# Verify internet connection
if ! check_internet; then
    error "Internet connection required for installation"
    exit 1
fi

success "Internet connection verified"

# Detect platform and determine configuration name
section "Detecting Platform"

SYSTEM_TYPE=""
CONFIG_NAME=""

if is_macos; then
    if is_arm; then
        SYSTEM_TYPE="macOS (Apple Silicon)"
        # Check user.nix for username
        if [ -f "$DOTFILES_DIR/user.nix" ]; then
            USERNAME=$(grep 'username = ' "$DOTFILES_DIR/user.nix" | sed 's/.*"\(.*\)".*/\1/')
            CONFIG_NAME="$USERNAME"
        else
            error "Cannot find user.nix configuration file"
            exit 1
        fi
    else
        SYSTEM_TYPE="macOS (Intel)"
        if [ -f "$DOTFILES_DIR/user.nix" ]; then
            USERNAME=$(grep 'username = ' "$DOTFILES_DIR/user.nix" | sed 's/.*"\(.*\)".*/\1/')
            CONFIG_NAME="$USERNAME-x86"
        else
            error "Cannot find user.nix configuration file"
            exit 1
        fi
    fi
elif is_linux; then
    if is_arm; then
        SYSTEM_TYPE="Linux (ARM64)"
        if [ -f "$DOTFILES_DIR/user.nix" ]; then
            USERNAME=$(grep 'username = ' "$DOTFILES_DIR/user.nix" | sed 's/.*"\(.*\)".*/\1/')
            CONFIG_NAME="$USERNAME-arm"
        else
            error "Cannot find user.nix configuration file"
            exit 1
        fi
    else
        SYSTEM_TYPE="Linux (x86_64)"
        if [ -f "$DOTFILES_DIR/user.nix" ]; then
            USERNAME=$(grep 'username = ' "$DOTFILES_DIR/user.nix" | sed 's/.*"\(.*\)".*/\1/')
            CONFIG_NAME="$USERNAME-linux"
        else
            error "Cannot find user.nix configuration file"
            exit 1
        fi
    fi
else
    error "Unsupported platform: $OSTYPE"
    exit 1
fi

info "Platform: $SYSTEM_TYPE"
info "Configuration: $CONFIG_NAME"
info "Username: $USERNAME"

# Check if user.nix needs customization
section "Configuration Check"

if [ -f "$DOTFILES_DIR/user.nix" ]; then
    echo ""
    info "Current user configuration:"
    echo ""
    cat "$DOTFILES_DIR/user.nix"
    echo ""
    
    if ! ask "Is this configuration correct?" "y"; then
        warning "Please edit $DOTFILES_DIR/user.nix before continuing"
        info "Update the following fields:"
        echo "  - username: Your system username"
        echo "  - git.name: Your full name for git commits"
        echo "  - git.email: Your email for git commits"
        echo ""
        info "After editing, run this script again"
        exit 0
    fi
fi

# Prepare for installation
section "Preparing Installation"

cd "$DOTFILES_DIR"

# Check if there are uncommitted changes
if git rev-parse --git-dir > /dev/null 2>&1; then
    if [[ -n $(git status -s) ]]; then
        warning "You have uncommitted changes in the dotfiles repository:"
        git status -s
        echo ""
        if ! ask "Continue with installation?" "y"; then
            info "Installation cancelled"
            exit 0
        fi
    fi
fi

# Show what will be installed
info "The following components will be installed/configured:"
echo "  - ZSH with custom configuration"
echo "  - Starship prompt"
echo "  - Git with your configuration"
echo "  - Neovim with custom setup"
echo "  - Tmux with custom configuration"
echo "  - FZF (fuzzy finder)"
echo "  - Direnv"
echo "  - Various development tools"
echo ""

if ! ask "Proceed with installation?" "y"; then
    info "Installation cancelled"
    exit 0
fi

# Run Home Manager installation
section "Installing with Home Manager"

info "This may take several minutes on the first run..."
info "Nix will download and build all required packages"
echo ""

# Determine if home-manager is already installed
if command_exists home-manager; then
    info "Using existing home-manager installation"
    HM_CMD="home-manager"
else
    info "First-time installation - using nix run home-manager/master"
    HM_CMD="nix run home-manager/master --"
fi

# Check if there are existing dotfiles to backup
EXISTING_FILES=()
if [ -f "$HOME/.zshrc" ]; then EXISTING_FILES+=(".zshrc"); fi
if [ -f "$HOME/.zprofile" ]; then EXISTING_FILES+=(".zprofile"); fi
if [ -f "$HOME/.config/nix/nix.conf" ]; then EXISTING_FILES+=(".config/nix/nix.conf"); fi

if [ ${#EXISTING_FILES[@]} -gt 0 ]; then
    warning "Existing dotfiles will be backed up with .backup extension:"
    for file in "${EXISTING_FILES[@]}"; do
        echo "  - $HOME/$file"
    done
    echo ""
fi

# Note: --impure allows reading gitignored files like ssh-hosts.nix
#       -b backup creates .backup files for conflicts
if $HM_CMD switch --flake "$DOTFILES_DIR#${CONFIG_NAME}" --impure -b backup; then
    success "Home Manager installation completed!"
    
    if [ ${#EXISTING_FILES[@]} -gt 0 ]; then
        echo ""
        info "Backup files created (you can delete these later):"
        for file in "${EXISTING_FILES[@]}"; do
            if [ -f "$HOME/${file}.backup" ]; then
                echo "  - $HOME/${file}.backup"
            fi
        done
    fi
else
    error "Home Manager installation failed!"
    echo ""
    info "Common issues:"
    echo "  - Check that your username matches system username"
    echo "  - Ensure Nix daemon is running: systemctl status nix-daemon"
    echo "  - Verify flake is valid: nix flake check $DOTFILES_DIR"
    echo "  - Try restarting your shell and running again"
    echo ""
    exit 1
fi

# Post-installation checks
section "Post-Installation Verification"

# Check if commands are available
VERIFICATION_FAILED=false

if command_exists zsh; then
    success "ZSH is available: $(zsh --version)"
else
    error "ZSH not found"
    VERIFICATION_FAILED=true
fi

if command_exists nvim; then
    success "Neovim is available: $(nvim --version | head -n1)"
else
    error "Neovim not found"
    VERIFICATION_FAILED=true
fi

if command_exists tmux; then
    success "Tmux is available: $(tmux -V)"
else
    error "Tmux not found"
    VERIFICATION_FAILED=true
fi

if command_exists fzf; then
    success "FZF is available: $(fzf --version)"
else
    error "FZF not found"
    VERIFICATION_FAILED=true
fi

if $VERIFICATION_FAILED; then
    warning "Some components failed verification"
    warning "You may need to restart your shell"
fi

# Shell setup
section "Shell Configuration"

# Check current shell
CURRENT_SHELL=$(basename "$SHELL")
info "Current shell: $CURRENT_SHELL"

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo ""
    warning "Your default shell is not ZSH"
    info "To change your default shell to ZSH, run:"
    
    if is_macos; then
        echo "  chsh -s $(which zsh)"
    else
        echo "  chsh -s $(which zsh)"
        info "Note: On some systems you may need to add ZSH to /etc/shells first:"
        echo "  echo \$(which zsh) | sudo tee -a /etc/shells"
    fi
    echo ""
    
    if ask "Would you like to change your shell to ZSH now?" "n"; then
        if is_macos; then
            chsh -s "$(which zsh)"
            success "Default shell changed to ZSH"
        else
            # Check if zsh is in /etc/shells
            if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
                info "Adding ZSH to /etc/shells..."
                echo "$(which zsh)" | sudo tee -a /etc/shells
            fi
            chsh -s "$(which zsh)"
            success "Default shell changed to ZSH"
        fi
    fi
else
    success "ZSH is already your default shell"
fi

# Installation complete
section "Installation Complete!"

echo ""
success "Your dotfiles have been installed successfully!"
echo ""
info "Important next steps:"
echo ""

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "  1. CLOSE THIS TERMINAL and open a new one"
    echo "     (Or start a new ZSH session with: zsh)"
else
    echo "  1. Restart your shell to load the new configuration:"
    echo "     source ~/.zshrc"
fi

echo "  2. Verify everything works:"
echo "     bash $SCRIPT_DIR/health-check.sh"
echo "  3. Customize your configuration in:"
echo "     $DOTFILES_DIR/user.nix"
echo ""

info "Useful commands:"
echo "  hm          - Rebuild home-manager configuration"
echo "  update-flake - Update Nix flake inputs"
echo ""

info "Configuration locations:"
echo "  - Home Manager: $DOTFILES_DIR/home/"
echo "  - Neovim: $DOTFILES_DIR/configs/neovim/"
echo "  - ZSH: $DOTFILES_DIR/home/programs/zsh.nix"
echo "  - Tmux: $DOTFILES_DIR/home/programs/tmux.nix"
echo ""

if git rev-parse --git-dir > /dev/null 2>&1; then
    info "Git repository:"
    echo "  - To update dotfiles: git pull && hm"
    echo "  - To commit changes: git add . && git commit && git push"
    echo ""
fi

echo -e "${GREEN}Enjoy your new development environment!${NC}"
echo ""
