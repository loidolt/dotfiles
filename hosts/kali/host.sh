#!/usr/bin/env bash
# Host-specific configuration for kali (Kali GNU/Linux Rolling)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy host-specific SSH config if it exists
if [ -f "$SCRIPT_DIR/ssh-config" ]; then
    cp "$SCRIPT_DIR/ssh-config" ~/.ssh/config.local
    chmod 600 ~/.ssh/config.local
fi

# Add Homebrew to PATH (Linux)
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Add any host-specific configuration below
