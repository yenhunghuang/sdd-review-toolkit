#!/usr/bin/env bash
# SDD Review Toolkit - SDD Directory Auto-detection (US-2)

sdd-specs() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: sdd-specs [directory]"
        echo "  Auto-detect SDD structure (.specify/specs/ or openspec/) and browse specs."
        echo "  Falls back to current directory if no SDD structure found."
        return 0
    fi

    local dir="${1:-}"

    if [[ -z "$dir" ]]; then
        local sdd_type
        sdd_type="$(_sdd_detect_type)"

        if [[ "$sdd_type" == "unknown" ]]; then
            echo "sdd-specs: no SDD structure detected. Falling back to current directory." >&2
        fi

        dir="$(_sdd_spec_dir)"
    fi

    sdd-review "$dir"
}
