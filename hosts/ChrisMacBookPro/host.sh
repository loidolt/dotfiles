#!/usr/bin/env bash
# Host-specific configuration for ChrisMacBookPro

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy host-specific SSH config
if [ -f "$SCRIPT_DIR/ssh-config" ]; then
    echo "Installing host-specific SSH config..."
    cp "$SCRIPT_DIR/ssh-config" ~/.ssh/config.local
    chmod 600 ~/.ssh/config.local
fi

# Add any other host-specific setup here
# Example: custom PATH for this host
# export PATH="/custom/path:$PATH"

# Example: host-specific aliases
# alias deploy="ssh myserver 'cd /app && git pull && systemctl restart app'"

# Example: environment variables for this host
# export API_KEY="secret-key-for-this-host"
