#!/usr/bin/env bash
# SDD Review Toolkit - Preview most recently modified .md

sdd-last() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: sdd-last [N]"
        echo "  Preview the most recently modified .md file."
        echo "  N > 1: show fzf picker with N most recent files."
        return 0
    fi

    local n="${1:-1}"
    local dir="."

    local files
    files=$(find "$dir" -type f -name '*.md' \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/test_helper/bats-*/*' \
        -not -path '*/.venv/*' \
        -not -path '*/vendor/*' \
        -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n "$n" | cut -d' ' -f2-)

    if [[ -z "$files" ]]; then
        echo "sdd-last: no .md files found." >&2
        return 1
    fi

    local count
    count=$(echo "$files" | wc -l)

    if (( count == 1 )); then
        sdd-peek "$files"
    else
        local helpers="${_SDD_TOOLKIT_DIR}/_sdd-helpers.sh"
        local selected
        selected=$(echo "$files" | fzf \
            --preview "bash -c '. \"$helpers\" && _sdd_glow_render \"\$1\"' _ {}" \
            --preview-window 'right:60%:wrap' \
            --header "Most recent $n .md files")
        [[ -n "$selected" ]] && sdd-peek "$selected"
    fi
}
