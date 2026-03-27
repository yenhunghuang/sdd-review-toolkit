#!/usr/bin/env bash
# SDD Review Toolkit - sdd-diff
# Browse recently changed .md files with fzf preview.

sdd-diff() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: sdd-diff [N]"
        echo "  Browse recently changed .md files (default: last 5 commits)."
        echo "  Falls back to files modified in last 24h if not in a git repo."
        return 0
    fi

    local n="${1:-5}"
    local files=""

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Git environment: diff + untracked
        local diff_files untracked_files
        diff_files="$(git diff --name-only HEAD~"$n" -- '*.md' 2>/dev/null)"
        untracked_files="$(git ls-files --others --exclude-standard -- '*.md' 2>/dev/null)"
        files="$(printf '%s\n%s' "$diff_files" "$untracked_files" | sort -u | sed '/^$/d')"
    else
        # Non-git: recently modified
        files="$(find . -name '*.md' -mtime -1 2>/dev/null | sort | sed '/^$/d')"
    fi

    if [[ -z "$files" ]]; then
        echo "sdd-diff: no recently changed .md files found."
        return 0
    fi

    _sdd_check_dep fzf "Install: https://github.com/junegunn/fzf" || return 1
    echo "$files" | fzf --preview '_sdd_glow_render {}' --preview-window=right:60%
}
