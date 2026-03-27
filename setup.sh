#!/usr/bin/env bash
# SDD Review Toolkit - Idempotent Installer
# Usage: bash setup.sh
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TOOLKIT_DIR/bin"
TMUX_CONF="$TOOLKIT_DIR/tmux/.tmux-sdd.conf"
SOURCE_LINE="source \"$BIN_DIR/sdd-functions.sh\""
TMUX_SOURCE_LINE="source-file \"$TMUX_CONF\""

info()  { echo "  [INFO] $*"; }
ok()    { echo "  [OK]   $*"; }
warn()  { echo "  [WARN] $*"; }
skip()  { echo "  [SKIP] $*"; }

echo "=== SDD Review Toolkit Setup ==="
echo ""

# --- Check dependencies ---
echo "Checking dependencies..."

missing_required=0

check_dep() {
    local cmd="$1" hint="$2" required="${3:-true}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd found"
        return 0
    elif [[ "$required" == "true" ]]; then
        warn "$cmd NOT found (required). Install: $hint"
        missing_required=1
        return 1
    else
        info "$cmd not found (optional). Install: $hint"
        return 0
    fi
}

check_dep glow "sudo apt install glow / brew install glow" true || true
check_dep fzf "sudo apt install fzf / brew install fzf" true || true
check_dep inotifywait "sudo apt install inotify-tools" false
check_dep tree "sudo apt install tree" false
check_dep bat "sudo apt install bat" false

if (( missing_required )); then
    echo ""
    warn "Required dependencies missing. Install them and re-run setup."
    exit 1
fi

echo ""

# --- Add source line to shell rc files ---
echo "Configuring shell..."

add_source_line() {
    local rc_file="$1"
    if [[ ! -f "$rc_file" ]]; then
        skip "$rc_file does not exist"
        return
    fi
    if grep -qF "sdd-functions.sh" "$rc_file" 2>/dev/null; then
        skip "$rc_file already configured"
    else
        printf '\n# SDD Review Toolkit\n%s\n' "$SOURCE_LINE" >> "$rc_file"
        ok "Added source line to $rc_file"
    fi
}

add_source_line "$HOME/.bashrc"
[[ -f "$HOME/.zshrc" ]] && add_source_line "$HOME/.zshrc"

echo ""

# --- Add tmux source-file ---
echo "Configuring tmux..."

TMUX_USER_CONF="$HOME/.tmux.conf"
if [[ -f "$TMUX_USER_CONF" ]] && grep -qF ".tmux-sdd.conf" "$TMUX_USER_CONF" 2>/dev/null; then
    skip ".tmux.conf already configured"
else
    printf '\n# SDD Review Toolkit keybindings\n%s\n' "$TMUX_SOURCE_LINE" >> "$TMUX_USER_CONF"
    ok "Added source-file to $TMUX_USER_CONF"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. source ~/.bashrc    (or restart terminal)"
echo "  2. tmux source-file ~/.tmux.conf   (if using tmux)"
echo "  3. Try: sdd-review"
echo ""
