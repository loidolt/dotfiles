#!/usr/bin/env bash
# Setup GitHub SSH key for authentication
#
# Usage: ./scripts/setup-github-ssh.sh [email]
#
# This script will:
#   1. Generate an ED25519 SSH key (if one doesn't exist)
#   2. Start the ssh-agent and add the key
#   3. Copy the public key to clipboard (if possible)
#   4. Open GitHub SSH settings page
#   5. Test the connection

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Configuration
KEY_TYPE="ed25519"
KEY_FILE="$HOME/.ssh/id_${KEY_TYPE}_github"
SSH_CONFIG="$HOME/.ssh/config"

main() {
    section "GitHub SSH Key Setup"

    # Get email for key comment
    local email="${1:-}"
    if [[ -z "$email" ]]; then
        read -p "Enter your GitHub email: " email
    fi

    if [[ -z "$email" ]]; then
        error "Email is required"
        exit 1
    fi

    # Create .ssh directory if it doesn't exist
    if [[ ! -d "$HOME/.ssh" ]]; then
        info "Creating ~/.ssh directory..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    # Check if key already exists
    if [[ -f "$KEY_FILE" ]]; then
        warning "SSH key already exists: $KEY_FILE"
        if ! ask "Do you want to use the existing key?"; then
            if ask "Generate a new key (will overwrite existing)?"; then
                generate_key "$email"
            else
                error "Aborted"
                exit 1
            fi
        fi
    else
        generate_key "$email"
    fi

    # Configure SSH for GitHub
    configure_ssh

    # Start ssh-agent and add key
    setup_agent

    # Copy public key to clipboard
    copy_to_clipboard

    # Show public key
    section "Your Public Key"
    echo ""
    cat "${KEY_FILE}.pub"
    echo ""

    # Open GitHub settings
    if ask "Open GitHub SSH settings in browser?" "y"; then
        open_github_settings
    fi

    # Wait for user to add key
    echo ""
    info "Add the public key to GitHub, then press Enter to test the connection..."
    pause

    # Test connection
    test_connection

    section "Setup Complete"
    success "You can now clone repos with: git clone git@github.com:username/repo.git"
}

generate_key() {
    local email="$1"
    info "Generating new ED25519 SSH key..."
    info "Note: Generating key without passphrase for convenience."
    info "For higher security, consider using a passphrase:"
    info "  ssh-keygen -t $KEY_TYPE -C \"$email\" -f $KEY_FILE"
    
    ssh-keygen -t "$KEY_TYPE" -C "$email" -f "$KEY_FILE" -N ""
    chmod 600 "$KEY_FILE"
    chmod 644 "${KEY_FILE}.pub"
    success "SSH key generated: $KEY_FILE"
}

configure_ssh() {
    info "Configuring SSH for GitHub..."

    # Create config file if it doesn't exist
    if [[ ! -f "$SSH_CONFIG" ]]; then
        touch "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi

    # Check if GitHub config already exists
    if grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
        warning "GitHub SSH config already exists in $SSH_CONFIG"
        return
    fi

    # Add GitHub configuration
    cat >> "$SSH_CONFIG" << EOF

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile $KEY_FILE
    AddKeysToAgent yes
EOF

    # macOS-specific: use keychain
    if is_macos; then
        # Check if UseKeychain is already set for github
        if ! grep -A5 "Host github.com" "$SSH_CONFIG" | grep -q "UseKeychain"; then
            # Add UseKeychain to GitHub block using a more portable approach
            # Create a temporary file with the new content
            local temp_file=$(mktemp)
            awk '
                /^Host github\.com/ { in_github=1 }
                /^Host/ && !/^Host github\.com/ { in_github=0 }
                in_github && /AddKeysToAgent yes/ { 
                    print $0
                    print "    UseKeychain yes"
                    next
                }
                { print $0 }
            ' "$SSH_CONFIG" > "$temp_file"
            mv "$temp_file" "$SSH_CONFIG"
        fi
    fi
    fi

    success "SSH config updated"
}

setup_agent() {
    info "Setting up ssh-agent..."

    # Start ssh-agent if not running
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)" > /dev/null
    fi

    # Add key to agent
    if is_macos; then
        ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE"
    else
        ssh-add "$KEY_FILE"
    fi

    success "Key added to ssh-agent"
    info "Note: The ssh-agent started here is for this session only."
    info "Your shell profile should handle ssh-agent startup for new sessions."
}

copy_to_clipboard() {
    local pub_key
    pub_key=$(cat "${KEY_FILE}.pub")

    if is_macos; then
        echo "$pub_key" | pbcopy
        success "Public key copied to clipboard"
    elif command_exists xclip; then
        echo "$pub_key" | xclip -selection clipboard
        success "Public key copied to clipboard"
    elif command_exists xsel; then
        echo "$pub_key" | xsel --clipboard --input
        success "Public key copied to clipboard"
    elif command_exists wl-copy; then
        echo "$pub_key" | wl-copy
        success "Public key copied to clipboard"
    else
        warning "Could not copy to clipboard (no clipboard tool found)"
        info "Manually copy the public key shown below"
    fi
}

open_github_settings() {
    local url="https://github.com/settings/ssh/new"

    if is_macos; then
        open "$url"
    elif command_exists xdg-open; then
        xdg-open "$url"
    else
        info "Open this URL in your browser: $url"
    fi
}

test_connection() {
    section "Testing GitHub Connection"

    # ssh -T returns exit code 1 even on success, so we check the output
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        success "GitHub authentication successful!"
    else
        warning "Testing connection..."
        ssh -T git@github.com 2>&1 || true
    fi
}

main "$@"
