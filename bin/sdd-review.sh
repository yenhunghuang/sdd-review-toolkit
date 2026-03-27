#!/usr/bin/env bash
# SDD Review Toolkit - Interactive Markdown Browser (US-1)

sdd-review() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        echo "Usage: sdd-review [directory]"
        echo "  Interactive .md browser with fzf preview + glow rendering."
        echo "  ENTER: fullscreen | Ctrl+E: VS Code | Ctrl+Y: copy path"
        return 0
    fi

    local dir="${1:-.}"

    _sdd_check_dep fzf "Install: brew install fzf / apt install fzf" || return 1

    if [[ ! -d "$dir" ]]; then
        echo "sdd-review: directory '$dir' not found." >&2
        return 1
    fi
    dir="$(cd "$dir" && pwd)"

    local md_files
    md_files=$(find "$dir" -type f -name '*.md' \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/test_helper/bats-*/*' \
        -not -path '*/.venv/*' \
        -not -path '*/vendor/*' \
        2>/dev/null | sort)

    if [[ -z "$md_files" ]]; then
        echo "sdd-review: no .md files found in '$dir'." >&2
        return 1
    fi

    local helpers="${_SDD_TOOLKIT_DIR}/_sdd-helpers.sh"

    local selected
    selected=$(echo "$md_files" | fzf \
        --preview "bash -c '. \"$helpers\" && _sdd_glow_render \"\$1\"' _ {}" \
        --preview-window 'right:60%:wrap' \
        --bind "ctrl-e:execute-silent(code {})" \
        --bind "ctrl-y:execute-silent(bash -c '. \"$helpers\" && printf \"%s\" \"\$1\" | _sdd_clipboard' _ {})" \
        --bind "ctrl-/:toggle-preview" \
        --bind "ctrl-p:execute(tmux display-popup -w 80% -h 80% \"glow -p {}\" 2>/dev/null || glow -p {})" \
        --header 'ENTER: view | Ctrl+E: VS Code | Ctrl+Y: copy | Ctrl+/: toggle | Ctrl+P: popup')

    if [[ -n "$selected" ]]; then
        _sdd_glow_render "$selected"
    fi
}
