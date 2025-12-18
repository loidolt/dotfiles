# ZSH Configuration

# Dotfiles location (override in ~/.zshrc.local if needed)
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Documents/GitHub/dotfiles}"

# Path configuration
# ~/.local/bin is for user-installed binaries (pip install --user, cargo install, etc.)
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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
    source <(fzf --zsh)
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    fi
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

# Load local customizations if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Load host-specific configuration from dotfiles
# Create hosts/$(hostname)/host.sh for machine-specific settings
# Note: hostname may include .local suffix on macOS, so we strip it
_HOSTNAME="${$(hostname)%.local}"
DOTFILES_HOST_DIR="${DOTFILES_DIR:-$HOME/Documents/GitHub/dotfiles}/hosts/$_HOSTNAME"
[ -f "$DOTFILES_HOST_DIR/host.sh" ] && source "$DOTFILES_HOST_DIR/host.sh"
unset _HOSTNAME
