# ZSH Environment - sourced for ALL zsh invocations (scripts, interactive, login)
# Keep this minimal - only essential PATH setup

# Linuxbrew (Linux) - needed early for all shell types
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Homebrew (macOS) - needed early for all shell types  
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
