#!/usr/bin/env bash
# Reap orphaned dev-tool processes
#
# Coding sessions (terminals, tmux panes, Claude/Codex agents, VS Code)
# start dev servers, test workers and type checkers. When a session dies
# without stopping them they are reparented to init and hold their memory
# until reboot. This finds those orphans and terminates them with their
# children.
#
# A process is reaped only when ALL of these hold:
#   - owned by the current user
#   - its parent is PID 1 (or the user's systemd manager, outside a .service)
#   - its command line matches REAP_PATTERN and not REAP_EXCLUDE
#   - it is older than REAP_MIN_AGE, or REAP_MIN_AGE_DELETED when its
#     working directory has been deleted (e.g. a removed git worktree)
#   - its session leader is gone (a live shell means it was disowned on
#     purpose); skipped for deleted working directories
#
# Usage: reap-orphans.sh [--dry-run]
# Runs hourly via the dotfiles-reaper.timer user unit (stow/systemd).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Tunables (override via environment)
REAP_PATTERN="${REAP_PATTERN:-wrangler|workerd|miniflare|esbuild --service|vitest|jest-worker|node_modules/(\.bin/)?(vite|nodemon|svelte-check|tsserver|astro|next|storybook)|tsc .*(--watch|-w )|tsx watch|playwright}"
REAP_EXCLUDE="${REAP_EXCLUDE:-}"                          # regex of commands to never reap
REAP_MIN_AGE="${REAP_MIN_AGE:-10800}"                     # seconds (3h)
REAP_MIN_AGE_DELETED="${REAP_MIN_AGE_DELETED:-600}"       # seconds (10m) when cwd deleted
REPORT_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-maintenance"
LOG="$REPORT_DIR/reaper.log"

if ! is_linux; then
    info "Orphan reaping relies on /proc; Linux only, skipping"
    exit 0
fi

mkdir -p "$REPORT_DIR"
uid="$(id -u)"
self=$$
user_mgr="$(systemctl --user show -p MainPID --value 2>/dev/null || true)"
[[ "$user_mgr" =~ ^[1-9][0-9]*$ ]] || user_mgr=""

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG"
}

human_age() {
    local s=$1
    if (( s >= 86400 )); then echo "$((s / 86400))d"
    elif (( s >= 3600 )); then echo "$((s / 3600))h"
    else echo "$((s / 60))m"; fi
}

# All descendants of a PID, depth first
descendants() {
    local child
    for child in $(pgrep -P "$1" 2>/dev/null); do
        echo "$child"
        descendants "$child"
    done
}

# Resident + swapped memory of a process in KiB
mem_kb() {
    awk '/^VmRSS|^VmSwap/ {s += $2} END {print s + 0}' "/proc/$1/status" 2>/dev/null || echo 0
}

is_orphan() {
    local pid=$1 ppid=$2
    [[ "$ppid" == 1 ]] && return 0
    # Subreaper case: user systemd adopts orphans of processes in scopes;
    # its own services are legitimately parented to it
    if [[ -n "$user_mgr" && "$ppid" == "$user_mgr" ]]; then
        ! grep -q '\.service$' "/proc/$pid/cgroup" 2>/dev/null
        return
    fi
    return 1
}

section "Orphaned dev processes"

reaped=0
freed_kb=0
skipped=0
all_killed=()

while read -r pid ppid sid age args; do
    [[ "$pid" == "$self" ]] && continue
    is_orphan "$pid" "$ppid" || continue
    grep -Eq -- "$REAP_PATTERN" <<< "$args" || continue
    if [[ -n "$REAP_EXCLUDE" ]] && grep -Eq -- "$REAP_EXCLUDE" <<< "$args"; then
        continue
    fi

    cwd="$(readlink "/proc/$pid/cwd" 2>/dev/null || true)"
    deleted=false
    [[ "$cwd" == *" (deleted)" ]] && deleted=true

    if $deleted; then
        (( age >= REAP_MIN_AGE_DELETED )) || continue
    else
        (( age >= REAP_MIN_AGE )) || continue
        # Live session leader = shell or tmux pane still exists; the user
        # backgrounded this on purpose
        if [[ "$sid" != "$pid" && -d "/proc/$sid" ]]; then
            info "Keeping $pid: session $sid still alive ($(ps -o comm= -p "$sid"))"
            skipped=$((skipped + 1))
            continue
        fi
    fi

    tree=("$pid")
    mapfile -t -O 1 tree < <(descendants "$pid")
    kb=0
    for p in "${tree[@]}"; do kb=$((kb + $(mem_kb "$p"))); done

    summary="$pid ($(human_age "$age"), ${#tree[@]} procs, $((kb / 1024))M) ${cwd/#$HOME/\~}: ${args:0:100}"
    if $DRY_RUN; then
        info "[dry-run] would reap $summary"
    else
        info "Reaping $summary"
        log "reap $summary"
        kill -TERM "${tree[@]}" 2>/dev/null || true
    fi
    reaped=$((reaped + 1))
    freed_kb=$((freed_kb + kb))
    all_killed+=("${tree[@]}")
done < <(ps -u "$uid" -o pid=,ppid=,sid=,etimes=,args=)

# Escalate anything that ignored SIGTERM
if ! $DRY_RUN && (( ${#all_killed[@]} > 0 )); then
    sleep 5
    for p in "${all_killed[@]}"; do
        if kill -0 "$p" 2>/dev/null; then
            warning "PID $p ignored SIGTERM, sending SIGKILL"
            log "sigkill $p"
            kill -KILL "$p" 2>/dev/null || true
        fi
    done
fi

if (( reaped > 0 )); then
    verb="Reaped"; $DRY_RUN && verb="Would reap"
    success "$verb $reaped orphan(s), ~$((freed_kb / 1024))M RAM+swap"
else
    success "No orphaned dev processes"
fi
(( skipped > 0 )) && info "$skipped orphan(s) kept because their session is alive"

# Keep the log bounded
if [[ -f "$LOG" ]] && (( $(wc -l < "$LOG") > 2000 )); then
    tail -n 1000 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi
exit 0
