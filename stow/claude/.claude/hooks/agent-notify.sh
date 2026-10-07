#!/usr/bin/env bash
# Agent notifications for cmux (works over plain ssh and inside tmux).
#
# Claude Code: registered as Stop/Notification hook (JSON payload on stdin).
# Codex:       `notify = [...]` in config.toml (JSON payload as $1).
#
# Delivery order:
#   1. `cmux notify` when the cmux CLI is reachable (local or via `cmux ssh` relay)
#   2. OSC 777 escape written to the terminal; wrapped in tmux DCS passthrough
#      when inside tmux (needs `allow-passthrough all` in .tmux.conf)
#
# Never fails: always exits 0 so the agent is never blocked.

exec 2>/dev/null

payload="${1:-}"
if [[ -z "$payload" && ! -t 0 ]]; then
    payload="$(cat)"
fi
command -v jq >/dev/null 2>&1 || exit 0

field() { jq -r "$1 // empty" <<<"$payload"; }

title="" body=""
case "$(field '.hook_event_name // .type')" in
    Stop)
        title="Claude Code"
        body="Done: $(basename "$(field '.cwd')")"
        ;;
    Notification)
        title="Claude Code"
        body="$(field '.message')"
        [[ -z "$body" ]] && body="Needs your attention"
        ;;
    agent-turn-complete)
        title="Codex"
        body="$(field '."last-assistant-message"')"
        [[ -z "$body" ]] && body="Turn complete"
        ;;
    *)
        exit 0
        ;;
esac

# Prefix with tmux session name so the cmux sidebar says where to look
if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]]; then
    session="$(tmux display-message -p -t "$TMUX_PANE" '#S')"
    [[ -n "$session" ]] && title="$title [$session]"
fi

# OSC fields: single line, no ';' or control chars, bounded length
sanitize() { printf '%s' "${1//;/,}" | tr '\n\t' '  ' | tr -d '\000-\037\177' | cut -c1-200; }
title="$(sanitize "$title")"
body="$(sanitize "$body")"

# 1. cmux CLI (only works when a cmux socket/relay is present)
if command -v cmux >/dev/null 2>&1; then
    if cmux notify --title "$title" --body "$body" >/dev/null 2>&1; then
        exit 0
    fi
fi

# 2. OSC 777 to the terminal
osc=$'\e]777;notify;'"$title;$body"$'\a'

if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]]; then
    tty="$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')"
    # DCS passthrough: ESC P tmux; <payload with ESC doubled> ESC \
    seq=$'\ePtmux;'"${osc//$'\e'/$'\e\e'}"$'\e\\'
else
    tty="/dev/tty"
    [[ -w "$tty" ]] || tty="${SSH_TTY:-}"
    seq="$osc"
fi

[[ -n "$tty" && -w "$tty" ]] && printf '%s' "$seq" >"$tty"
exit 0
