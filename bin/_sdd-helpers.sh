#!/usr/bin/env bash
# SDD Review Toolkit - Shared Helpers
# Internal functions prefixed with _sdd_ — not meant for direct user invocation.

# Check if a command exists; print install hint if missing.
# Usage: _sdd_check_dep <command> [install_hint]
# Returns: 0 if found, 1 if missing
_sdd_check_dep() {
    local cmd="$1"
    local hint="${2:-"Please install $cmd"}"
    if ! command -v "$cmd" &>/dev/null; then
        echo "sdd: '$cmd' not found. $hint" >&2
        return 1
    fi
    return 0
}

# Detect SDD project type from directory structure.
# Usage: _sdd_detect_type [project_root]
# Outputs: "speckit", "openspec", or "unknown"
# Returns: 0 if detected, 1 if unknown
_sdd_detect_type() {
    local root="${1:-.}"

    if [[ -d "$root/.specify" ]]; then
        echo "speckit"
        return 0
    elif [[ -d "$root/openspec" ]]; then
        echo "openspec"
        return 0
    fi
    echo "unknown"
    return 1
}

# Get the SDD spec directory path for the detected project type.
# Usage: _sdd_spec_dir [project_root]
# Outputs: directory path (specs/, openspec/, or project_root as fallback)
_sdd_spec_dir() {
    local root="${1:-.}"
    local sdd_type
    sdd_type="$(_sdd_detect_type "$root")"

    case "$sdd_type" in
        speckit)  echo "$root/specs" ;;
        openspec) echo "$root/openspec" ;;
        *)        echo "$root" ;;
    esac
}

# Cross-platform clipboard write.
# Usage: echo "text" | _sdd_clipboard
# Returns: 0 on success, 1 if no clipboard tool found
_sdd_clipboard() {
    if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        clip.exe
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --input
    else
        echo "sdd: no clipboard tool found. Install xclip or xsel." >&2
        return 1
    fi
}

# Render a markdown file with glow, with fallback to cat.
# Usage: _sdd_glow_render <file> [width]
_sdd_glow_render() {
    local file="$1"
    local width="${2:-$(tput cols 2>/dev/null || echo 80)}"

    if command -v glow &>/dev/null; then
        glow -w "$width" "$file"
    else
        cat "$file"
    fi
}
