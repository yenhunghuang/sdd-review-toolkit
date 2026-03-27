#!/usr/bin/env bash
# SDD Review Toolkit - sdd-multi
# Open multiple .md files in tmux panes for simultaneous review.

sdd-multi() {
    if [[ -z "$TMUX" ]]; then
        echo "sdd-multi: must be run inside a tmux session." >&2
        return 1
    fi

    if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: sdd-multi <file1.md> [file2.md] ..."
        echo "  Open multiple .md files in tmux panes for simultaneous review."
        echo "  Requires tmux."
        [[ $# -eq 0 ]] && return 1 || return 0
    fi

    # Check all files exist first
    local file
    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "sdd-multi: file '$file' not found." >&2
            return 1
        fi
    done

    # Open each file in a new pane
    for file in "$@"; do
        tmux split-window "_sdd_glow_render '$file'; read -r"
    done

    tmux select-layout tiled
}
