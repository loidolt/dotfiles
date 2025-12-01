#!/usr/bin/env bash
# Convert GitHub HTTPS remotes to SSH
#
# Usage: 
#   ./scripts/git-https-to-ssh.sh              # Convert current repo
#   ./scripts/git-https-to-ssh.sh /path/to/repo # Convert specific repo
#   ./scripts/git-https-to-ssh.sh --scan ~/projects  # Scan directory for repos to convert
#
# This script will:
#   1. Find GitHub HTTPS remotes in a git repository
#   2. Convert them to SSH format (git@github.com:user/repo.git)

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

convert_repo() {
    local repo_path="${1:-.}"
    
    # Check if it's a git repo
    if ! git -C "$repo_path" rev-parse --git-dir &>/dev/null; then
        error "Not a git repository: $repo_path"
        return 1
    fi

    local repo_name
    repo_name=$(basename "$(cd "$repo_path" && pwd)")
    local converted=0

    # Get all remotes
    while IFS= read -r line; do
        local remote_name url
        remote_name=$(echo "$line" | awk '{print $1}')
        url=$(echo "$line" | awk '{print $2}')

        # Check if it's a GitHub HTTPS URL
        if [[ "$url" =~ ^https://github\.com/(.+)/(.+?)(\.git)?$ ]]; then
            local user="${BASH_REMATCH[1]}"
            local repo="${BASH_REMATCH[2]}"
            local ssh_url="git@github.com:${user}/${repo}.git"

            info "[$repo_name] Converting remote '$remote_name'"
            echo "    HTTPS: $url"
            echo "    SSH:   $ssh_url"

            git -C "$repo_path" remote set-url "$remote_name" "$ssh_url"
            success "[$repo_name] Remote '$remote_name' converted to SSH"
            converted=1
        fi
    done < <(git -C "$repo_path" remote -v | grep "(push)")

    if [[ $converted -eq 0 ]]; then
        info "[$repo_name] No GitHub HTTPS remotes found"
    fi

    return 0
}

scan_directory() {
    local scan_path="$1"
    local found=0

    info "Scanning for git repositories in: $scan_path"
    echo ""

    # Find all .git directories
    while IFS= read -r git_dir; do
        local repo_path
        repo_path=$(dirname "$git_dir")
        
        # Check if any remote is GitHub HTTPS
        if git -C "$repo_path" remote -v 2>/dev/null | grep -q "https://github.com"; then
            found=1
            convert_repo "$repo_path"
            echo ""
        fi
    done < <(find "$scan_path" -name ".git" -type d 2>/dev/null)

    if [[ $found -eq 0 ]]; then
        info "No repositories with GitHub HTTPS remotes found"
    fi
}

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [PATH]

Convert GitHub HTTPS remotes to SSH format.

Options:
    -s, --scan DIR    Scan directory recursively for git repos to convert
    -h, --help        Show this help message

Examples:
    $(basename "$0")                    # Convert current repository
    $(basename "$0") /path/to/repo      # Convert specific repository
    $(basename "$0") --scan ~/projects  # Scan and convert all repos in directory
EOF
}

main() {
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -s|--scan)
            if [[ -z "${2:-}" ]]; then
                error "Missing directory path for --scan"
                show_usage
                exit 1
            fi
            scan_directory "$2"
            ;;
        *)
            section "Convert GitHub HTTPS to SSH"
            convert_repo "${1:-.}"
            echo ""
            info "Test with: git fetch"
            ;;
    esac
}

main "$@"
