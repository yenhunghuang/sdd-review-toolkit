#!/usr/bin/env bash
# SDD Review Toolkit - Quick Preview with glow pager

sdd-peek() {
    if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: sdd-peek <file.md>"
        echo "  Quick preview with glow pager. Press q to close."
        [[ $# -eq 0 ]] && return 1 || return 0
    fi

    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "sdd-peek: file '$file' not found." >&2
        return 1
    fi

    # Resolve to absolute path
    file="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"

    glow -p "$file" 2>/dev/null || _sdd_glow_render "$file"
}
