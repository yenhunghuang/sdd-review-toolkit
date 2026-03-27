#!/usr/bin/env bash
# SDD Review Toolkit - sdd-approve
# Update sign-off markers in SDD documents.

sdd-approve() {
    if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: sdd-approve <file.md>"
        echo "  Update sign-off markers in SDD documents."
        [[ $# -eq 0 ]] && return 1 || return 0
    fi

    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "sdd-approve: file '$file' not found." >&2
        return 1
    fi

    if grep -q '⬜' "$file"; then
        sed -i "s/⬜.*/✅ 已確認 ($(date +%Y-%m-%d))/" "$file"
        echo "sdd-approve: '$file' approved successfully."
        return 0
    elif grep -q '✅' "$file"; then
        echo "sdd-approve: '$file' is already approved."
        return 0
    else
        echo "sdd-approve: '$file' has no sign-off block."
        return 0
    fi
}
