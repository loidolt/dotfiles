#!/bin/bash
# GitHub SSH Setup Script

set -e

EMAIL="${1:-loidolt@gmail.com}"
KEY_FILE="$HOME/.ssh/id_ed25519_github"

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
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	echo "✓ Successfully authenticated with GitHub!"
else
	echo "✗ Authentication failed. Please check that you added the key correctly."
	exit 1
fi

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
