#!/usr/bin/env bash
# Host-specific configuration for epa-cloidoltlw (Pop!_OS workstation)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy host-specific SSH config if it exists
if [ -f "$SCRIPT_DIR/ssh-config" ]; then
    echo "Installing host-specific SSH config..."
    cp "$SCRIPT_DIR/ssh-config" ~/.ssh/config.local
    chmod 600 ~/.ssh/config.local
fi

# Add Homebrew to PATH (Linux)
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Add any other host-specific setup here
