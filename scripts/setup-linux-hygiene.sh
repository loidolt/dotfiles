#!/usr/bin/env bash
# One-time system hygiene settings for a Linux development machine.
# Idempotent: safe to re-run. Run as your normal user; uses sudo where needed.
#
#   - journald capped at 500M
#   - docker container logs rotated (10M x 3)
#   - unattended-upgrades removes unused kernels/dependencies, apt autoclean weekly
#   - snaps keep 2 revisions
#   - memory guardrail: user@.service (tmux, agents, builds, desktop) throttled
#     at 85% of RAM, so ssh sessions and the system stay responsive
#   - user lingering + weekly dotfiles-maintenance.timer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

if ! is_linux; then
    error "This script is for Linux only"
    exit 1
fi

# Write a root-owned file only when its content changes; returns 1 if unchanged
write_root_file() {
    local path="$1" content="$2"
    if [[ -f "$path" ]] && [[ "$(sudo cat "$path")" == "$content" ]]; then
        return 1
    fi
    sudo mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" | sudo tee "$path" >/dev/null
}

setup_journald() {
    section "journald"
    if write_root_file /etc/systemd/journald.conf.d/50-dotfiles-size.conf \
'[Journal]
SystemMaxUse=500M
SystemKeepFree=2G'; then
        sudo systemctl restart systemd-journald
        sudo journalctl --vacuum-size=500M >/dev/null 2>&1 || true
        success "journald capped at 500M"
    else
        success "journald already capped"
    fi
}

setup_docker_logs() {
    section "Docker logs"
    if ! command_exists docker; then
        info "Docker not installed, skipping"
        return
    fi
    local conf=/etc/docker/daemon.json current merged
    current="$(sudo cat "$conf" 2>/dev/null || echo '{}')"
    merged="$(jq '. + {"log-driver": "json-file", "log-opts": ((.["log-opts"] // {}) + {"max-size": "10m", "max-file": "3"})}' <<<"$current")"
    if write_root_file "$conf" "$merged"; then
        success "Docker log rotation configured (10m x 3)"
        warning "Applies to containers created after the next docker restart or reboot"
    else
        success "Docker log rotation already configured"
    fi
}

setup_apt() {
    section "apt / unattended-upgrades"
    if ! command_exists apt-get; then
        info "Not apt-based, skipping"
        return
    fi
    if write_root_file /etc/apt/apt.conf.d/52dotfiles-hygiene \
'// Managed by dotfiles: scripts/setup-linux-hygiene.sh
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
APT::Periodic::AutocleanInterval "7";'; then
        success "Unused kernels/dependencies removed automatically, apt autoclean weekly"
    else
        success "apt hygiene already configured"
    fi
}

setup_snap() {
    section "Snap"
    if ! command_exists snap; then
        info "Snap not installed, skipping"
        return
    fi
    if [[ "$(snap get system refresh.retain 2>/dev/null)" != "2" ]]; then
        sudo snap set system refresh.retain=2
    fi
    success "Snaps keep 2 revisions"
}

setup_memory_guardrail() {
    section "Memory guardrail"
    local uid
    uid="$(id -u)"
    # user@.service holds tmux, agents, builds and the desktop session;
    # ssh login sessions live outside it, so you can always get back in
    if write_root_file /etc/systemd/system/user@.service.d/50-dotfiles-memory.conf \
'[Service]
MemoryHigh=85%'; then
        sudo systemctl daemon-reload
    fi
    # Apply to the running user manager without restarting it
    sudo systemctl set-property --runtime "user@${uid}.service" MemoryHigh=85%
    success "user@${uid}.service throttled at $(systemctl show "user@${uid}.service" -p MemoryHigh --value | numfmt --to=iec) (85% of RAM)"
}

setup_maintenance_timer() {
    section "Maintenance timer"
    if [[ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != "yes" ]]; then
        sudo loginctl enable-linger "$USER"
    fi
    success "Lingering enabled (user timers run without a login)"

    if [[ ! -f "$HOME/.config/systemd/user/dotfiles-maintenance.timer" ]]; then
        warning "Timer unit not stowed; run: make stow-all"
        return
    fi
    systemctl --user daemon-reload
    systemctl --user enable --now dotfiles-maintenance.timer >/dev/null
    success "dotfiles-maintenance.timer enabled: $(systemctl --user show dotfiles-maintenance.timer -p NextElapseUSecRealtime --value)"
}

main() {
    info "Configuring system hygiene (requires sudo)"
    if ! sudo -n true 2>/dev/null && [[ ! -t 0 ]]; then
        error "sudo needs a password but there is no terminal; run this from an interactive shell"
        exit 1
    fi
    sudo -v
    setup_journald
    setup_docker_logs
    setup_apt
    setup_snap
    setup_memory_guardrail
    setup_maintenance_timer
    echo ""
    success "System hygiene configured"
}

main "$@"
