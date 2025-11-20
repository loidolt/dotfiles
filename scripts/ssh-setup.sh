#!/usr/bin/env bash
# GitHub SSH Setup Script
#
# Usage:
#   ./ssh-setup.sh [email@example.com]
#
# This script will:
#   - Generate an ED25519 SSH key for GitHub
#   - Display the public key for you to add to GitHub
#   - Test the connection to GitHub
#   - Configure SSH config for GitHub
#   - Set up automatic SSH agent initialization

set -euo pipefail

readonly EMAIL="${1:-$(git config user.email 2>/dev/null || echo 'user@example.com')}"
readonly KEY_FILE="${HOME}/.ssh/id_ed25519_github"

# Validate email format
if [[ ! "${EMAIL}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Error: Invalid email format: ${EMAIL}"
    echo "Usage: $0 [email@example.com]"
    exit 1
fi

echo "=== GitHub SSH Key Setup ==="
echo

# Generate SSH key if it doesn't exist
if [ ! -f "$KEY_FILE" ]; then
	echo "Generating new SSH key..."
	ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
	echo "✓ Key generated"
else
	echo "✓ SSH key already exists"
fi

echo
echo "=== YOUR PUBLIC KEY (copy this to GitHub) ==="
echo
cat "${KEY_FILE}.pub"
echo
echo "=== Add this key to GitHub: ==="
echo "1. Go to: https://github.com/settings/ssh/new"
echo "2. Paste the key above"
echo "3. Click 'Add SSH key'"
echo
read -p "Press Enter after you've added the key to GitHub..."

# Start SSH agent and add key
echo
echo "Adding key to SSH agent..."
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$KEY_FILE" 2>/dev/null
echo "✓ Key added to agent"

# Test connection
echo
echo "Testing GitHub connection..."
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	echo "✗ Authentication failed. Please check that you added the key correctly."
	echo "  Common issues:"
	echo "  - Key not added to GitHub (https://github.com/settings/keys)"
	echo "  - Firewall blocking SSH on port 22"
	echo "  - SSH agent not running"
	exit 1
fi
echo "✓ Successfully authenticated with GitHub!"

# Configure SSH config
echo
echo "Configuring SSH..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
	cat >>"$HOME/.ssh/config" <<'EOF'

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
EOF
	echo "✓ SSH config updated"
else
	echo "✓ SSH config already has GitHub entry"
fi

# Add to bashrc
echo
echo "Setting up automatic SSH agent..."
if ! grep -q "ssh-agent.*id_ed25519_github" "$HOME/.bashrc" 2>/dev/null; then
	cat >>"$HOME/.bashrc" <<'EOF'

# Start SSH agent and add GitHub key
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519_github 2>/dev/null
fi
EOF
	echo "✓ Added to ~/.bashrc"
	echo "  (Will take effect in new terminal sessions)"
else
	echo "✓ Already configured in ~/.bashrc"
fi

echo
echo "=== Setup Complete! ==="
echo "You can now use: git clone git@github.com:username/repo.git"
