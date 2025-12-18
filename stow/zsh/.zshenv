# ZSH Environment - sourced for ALL zsh invocations (scripts, interactive, login)
# Keep this minimal - only essential PATH setup

# Linuxbrew (Linux) - needed early for all shell types
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    # Set TERMINFO for Linuxbrew's ncurses (needed for tmux, etc.)
    if [[ -d "/home/linuxbrew/.linuxbrew/share/terminfo" ]]; then
        export TERMINFO="/home/linuxbrew/.linuxbrew/share/terminfo"
    fi
    # Ensure TERM is set for interactive sessions (fallback for SSH)
    if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
        export TERM="xterm-256color"
    fi
fi

# Homebrew (macOS) - needed early for all shell types  
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
