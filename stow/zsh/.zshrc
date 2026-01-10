# ZSH Configuration

# Dotfiles location - auto-detect common locations
if [[ -z "$DOTFILES_DIR" ]]; then
    if [[ -d "$HOME/dotfiles" ]]; then
        export DOTFILES_DIR="$HOME/dotfiles"
    elif [[ -d "$HOME/Documents/GitHub/dotfiles" ]]; then
        export DOTFILES_DIR="$HOME/Documents/GitHub/dotfiles"
    else
        export DOTFILES_DIR="$HOME/dotfiles"
    fi
fi

# Path configuration
# Homebrew/Linuxbrew - re-add to PATH here because /etc/profile may reset PATH
# after .zshenv runs (common on Debian/Kali/Ubuntu login shells)
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ~/.local/bin is for user-installed binaries (pip install --user, cargo install, etc.)
export PATH="$HOME/.local/bin:$PATH"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Modern CLI tools
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -lh --icons --git'
    alias la='eza -lah --icons --git'
    alias tree='eza --tree --icons'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Zoxide (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF
if command -v fzf &> /dev/null; then
    # Load key bindings and completion
    source <(fzf --zsh)
    # Load custom FZF config (colors, fd integration) if stowed
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# Direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Aliases
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Git aliases
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias ga='git add'
alias gco='git checkout'
alias gb='git branch'

# Common shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Load secrets (API keys, etc.) - never commit this file
[ -f ~/.secrets.env ] && source ~/.secrets.env

# Load local customizations if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Load host-specific configuration from dotfiles
# Create hosts/$(hostname)/host.sh for machine-specific settings
# Note: hostname may include .local suffix on macOS, so we strip it
_HOSTNAME="${$(hostname)%.local}"
DOTFILES_HOST_DIR="$DOTFILES_DIR/hosts/$_HOSTNAME"
[ -f "$DOTFILES_HOST_DIR/host.sh" ] && source "$DOTFILES_HOST_DIR/host.sh"
unset _HOSTNAME
