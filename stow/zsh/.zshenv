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

# Linux X11 DISPLAY - auto-detect if not set (needed for GUI apps like Chrome)
if [[ "$(uname)" == "Linux" && -z "$DISPLAY" && -d "/tmp/.X11-unix" ]]; then
    # Find available X socket and set DISPLAY
    for sock in /tmp/.X11-unix/X*; do
        if [[ -e "$sock" ]]; then
            display_num="${sock##*/tmp/.X11-unix/X}"
            export DISPLAY=":${display_num}"
            break
        fi
    done
fi
