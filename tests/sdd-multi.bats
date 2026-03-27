#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- function existence ---

@test "sdd-multi: function exists" {
    run type -t sdd-multi
    assert_success
    assert_output "function"
}

# --- no tmux environment ---

@test "sdd-multi: fails outside tmux" {
    unset TMUX
    run sdd-multi file.md
    assert_failure
    assert_output --partial "tmux session"
}

# --- no arguments ---

@test "sdd-multi: shows usage when no arguments" {
    export TMUX="/tmp/tmux-test/default,12345,0"
    run sdd-multi
    assert_failure
    assert_output --partial "Usage: sdd-multi"
}

# --- file not found ---

@test "sdd-multi: fails when file does not exist" {
    export TMUX="/tmp/tmux-test/default,12345,0"
    run sdd-multi "$TEST_TEMP_DIR/nonexistent.md"
    assert_failure
    assert_output --partial "not found"
}

# --- checks all files before opening panes ---

@test "sdd-multi: checks all files exist before opening" {
    export TMUX="/tmp/tmux-test/default,12345,0"
    echo "# Real" > "$TEST_TEMP_DIR/real.md"

    run sdd-multi "$TEST_TEMP_DIR/real.md" "$TEST_TEMP_DIR/missing.md"
    assert_failure
    assert_output --partial "missing.md"
    assert_output --partial "not found"
}

# --- multiple valid files (without actual tmux) ---

@test "sdd-multi: accepts multiple existing files (mock tmux)" {
    export TMUX="/tmp/tmux-test/default,12345,0"
    echo "# File A" > "$TEST_TEMP_DIR/a.md"
    echo "# File B" > "$TEST_TEMP_DIR/b.md"

    # Mock tmux commands since we're not in a real tmux session
    function tmux() { echo "tmux $*"; }
    export -f tmux

    run sdd-multi "$TEST_TEMP_DIR/a.md" "$TEST_TEMP_DIR/b.md"
    assert_success
    assert_output --partial "tmux split-window"
    assert_output --partial "tmux select-layout tiled"
}
