#!/usr/bin/env bash
# SDD Review Toolkit - File Watch with Auto-Refresh
# Watches a markdown file and re-renders on change.

sdd-watch() {
    local file="$1"

    if [[ -z "$file" || "$file" == "--help" || "$file" == "-h" ]]; then
        echo "Usage: sdd-watch <file.md>"
        echo "  Watch a markdown file and auto-refresh on change."
        echo "  Uses inotifywait if available, otherwise polls every 1s."
        [[ -z "$file" ]] && return 1 || return 0
    fi

    if [[ ! -f "$file" ]]; then
        echo "sdd-watch: file not found: $file" >&2
        return 1
    fi

    # Resolve to absolute path
    file="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"

    # Clean exit on Ctrl+C
    trap 'echo ""; echo "sdd-watch: stopped."; return 0' INT TERM

    # Initial render
    clear
    _sdd_glow_render "$file"

    if command -v inotifywait &>/dev/null; then
        # Event-driven mode
        inotifywait -m -e modify "$file" 2>/dev/null | while read -r; do
            clear
            _sdd_glow_render "$file"
        done
    else
        # Polling fallback
        echo "sdd-watch: 建議安裝 inotify-tools 以獲得更好的效能" >&2
        local prev_hash
        prev_hash="$(md5sum "$file" 2>/dev/null || cksum "$file")"
        while true; do
            sleep 1
            local curr_hash
            curr_hash="$(md5sum "$file" 2>/dev/null || cksum "$file")"
            if [[ "$curr_hash" != "$prev_hash" ]]; then
                clear
                _sdd_glow_render "$file"
                prev_hash="$curr_hash"
            fi
        done
    fi
}
