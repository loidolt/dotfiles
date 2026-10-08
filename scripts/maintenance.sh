#!/usr/bin/env bash
# Weekly development-machine cleanup
#
# Deletes only things that regenerate on demand (docker build cache and
# unused images, idle VS Code server versions, package-manager caches).
# Anything that could be work - stale node_modules, old Node versions,
# docker volumes - is reported, never removed.
#
# Usage: maintenance.sh [--dry-run]
# Runs weekly via the dotfiles-maintenance.timer user unit (stow/systemd).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Tunables (override via environment)
DOCKER_MAX_AGE="${DOCKER_MAX_AGE:-168h}"         # prune docker objects older than this
VSCODE_KEEP="${VSCODE_KEEP:-2}"                   # newest VS Code server versions to keep
NPM_CACHE_MAX_GB="${NPM_CACHE_MAX_GB:-5}"         # clean npm cache above this size
STALE_DAYS="${STALE_DAYS:-30}"                    # project untouched this long = stale
WORK_DIRS="${WORK_DIRS:-$HOME/Work}"              # colon-separated roots to scan
REPORT_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-maintenance"

mkdir -p "$REPORT_DIR"

run() {
    if $DRY_RUN; then
        info "[dry-run] $*"
    else
        "$@" || warning "Command failed: $*"
    fi
}

size_gb() {
    du -s --block-size=1G "$1" 2>/dev/null | cut -f1
}

# ---------------------------------------------------------------------------
section "Docker"
if command_exists docker && docker info >/dev/null 2>&1; then
    run docker container prune -f --filter "until=$DOCKER_MAX_AGE"
    run docker image prune -a -f --filter "until=$DOCKER_MAX_AGE"
    run docker builder prune -f --filter "until=$DOCKER_MAX_AGE"
    info "Volumes are never pruned automatically:"
    docker system df --format '  {{.Type}}: {{.Size}} ({{.Reclaimable}} reclaimable)' 2>/dev/null || true
else
    info "Docker not available, skipping"
fi

# ---------------------------------------------------------------------------
section "VS Code server"
VSCODE_SERVERS="$HOME/.vscode-server/cli/servers"
if [[ -d "$VSCODE_SERVERS" ]]; then
    kept=0
    # Newest first; keep the N newest plus any version with a live process
    while IFS= read -r dir; do
        name="$(basename "$dir")"
        if pgrep -f "$dir/" >/dev/null 2>&1; then
            info "Keeping $name (running)"
        elif (( kept < VSCODE_KEEP )) && [[ "$name" != *.staging ]]; then
            info "Keeping $name"
            kept=$((kept + 1))
        else
            info "Removing $name"
            run rm -rf -- "$dir"
        fi
    done < <(ls -1dt "$VSCODE_SERVERS"/Stable-* 2>/dev/null)
else
    info "No VS Code server installed, skipping"
fi

# ---------------------------------------------------------------------------
section "Package caches"
NPM_CACACHE="$HOME/.npm/_cacache"
if [[ -d "$NPM_CACACHE" ]]; then
    npm_gb="$(size_gb "$NPM_CACACHE")"
    if (( npm_gb >= NPM_CACHE_MAX_GB )); then
        # Only the content cache; ~/.npm/_npx holds running MCP servers
        info "npm cache is ${npm_gb}G (limit ${NPM_CACHE_MAX_GB}G), clearing"
        run rm -rf -- "$NPM_CACACHE"
    else
        info "npm cache ${npm_gb}G, under limit"
    fi
fi

if command_exists uv; then
    run uv cache prune
fi

# Skip unless a pnpm store exists: with corepack, `pnpm` is a shim that
# downloads pnpm on first use
PNPM_STORE="${PNPM_HOME:-$HOME/.local/share/pnpm}/store"
if command_exists pnpm && [[ -d "$PNPM_STORE" ]]; then
    run pnpm store prune
fi

if command_exists go && [[ -d "$(go env GOCACHE 2>/dev/null)" ]]; then
    gocache="$(go env GOCACHE)"
    if (( $(size_gb "$gocache") >= 2 )); then
        run go clean -cache
    fi
fi

# ---------------------------------------------------------------------------
section "Report: stale node_modules (not deleted)"
report="$REPORT_DIR/stale-node-modules.txt"
: > "$report"
IFS=':' read -ra roots <<< "$WORK_DIRS"
for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r nm; do
        project="$(dirname "$nm")"
        # Stale = nothing outside node_modules/.git touched in STALE_DAYS
        recent="$(command find "$project" -maxdepth 3 \
            \( -name node_modules -o -name .git \) -prune -o \
            -type f -mtime "-$STALE_DAYS" -print -quit 2>/dev/null)"
        if [[ -z "$recent" ]]; then
            printf '%s\t%s\n' "$(du -sh "$nm" 2>/dev/null | cut -f1)" "$nm" >> "$report"
        fi
    done < <(command find "$root" -maxdepth 6 -type d -name node_modules -prune 2>/dev/null)
done
if [[ -s "$report" ]]; then
    sort -rh -o "$report" "$report"
    warning "$(wc -l < "$report") node_modules untouched for ${STALE_DAYS}+ days:"
    head -10 "$report" | sed 's/^/  /'
    info "Full list: $report"
    info "Remove with: cut -f2 \"$report\" | while read -r d; do rm -rf \"\$d\"; done"
else
    success "No stale node_modules"
fi

# ---------------------------------------------------------------------------
section "Report: Node versions (not deleted)"
if [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
    set +eu
    # shellcheck disable=SC1091
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh" --no-use
    default="$(nvm version default 2>/dev/null)"
    set -eu
    for v in "${NVM_DIR:-$HOME/.nvm}"/versions/node/*; do
        ver="$(basename "$v")"
        [[ "$ver" == "$default" ]] && continue
        if pgrep -f "$v/bin/" >/dev/null 2>&1; then
            info "$ver (in use by a running process)"
        else
            warning "$ver unused, remove with: nvm uninstall $ver"
        fi
    done
fi

echo ""
success "Maintenance complete"
