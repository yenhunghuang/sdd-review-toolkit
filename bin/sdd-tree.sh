#!/usr/bin/env bash
# SDD Review Toolkit - sdd-tree
# Display SDD document structure as a tree.

sdd-tree() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: sdd-tree [directory]"
        echo "  Display SDD document structure as a tree (only .md files)."
        echo "  Truncates at 50 files."
        return 0
    fi

    local dir="${1:-.}"
    local max_files=50

    if [[ ! -d "$dir" ]]; then
        echo "sdd-tree: directory '$dir' not found." >&2
        return 1
    fi

    if command -v tree &>/dev/null; then
        # Use tree command
        local output
        output="$(tree "$dir" -P '*.md' --prune --noreport 2>/dev/null)"
        local count
        count="$(echo "$output" | grep -c '\.md$' || true)"

        if (( count > max_files )); then
            echo "$output" | head -n "$((max_files + 1))"
            echo "... and $((count - max_files)) more files"
        else
            echo "$output"
        fi
    else
        # Fallback: find + format
        local files
        files="$(find "$dir" -name '*.md' 2>/dev/null | sort)"

        if [[ -z "$files" ]]; then
            echo "$dir"
            return 0
        fi

        local count
        count="$(echo "$files" | wc -l)"
        local display_files="$files"

        if (( count > max_files )); then
            display_files="$(echo "$files" | head -n "$max_files")"
        fi

        echo "$dir"
        echo "$display_files" | while IFS= read -r filepath; do
            # Strip the base dir prefix
            local rel="${filepath#"$dir"/}"
            [[ "$rel" == "$filepath" ]] && rel="${filepath#./}"
            # Calculate depth
            local depth
            depth="$(echo "$rel" | tr -cd '/' | wc -c)"
            local indent=""
            local i
            for (( i = 0; i < depth; i++ )); do
                indent="${indent}|   "
            done
            local name
            name="$(basename "$rel")"
            echo "${indent}|-- ${name}"
        done

        if (( count > max_files )); then
            echo "... and $((count - max_files)) more files"
        fi
    fi
}
