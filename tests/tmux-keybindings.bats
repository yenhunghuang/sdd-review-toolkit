#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    TMUX_CONF="$BATS_TEST_DIRNAME/../tmux/.tmux-sdd.conf"
}

teardown() {
    _common_teardown
}

# --- file existence ---

@test "tmux config: .tmux-sdd.conf exists" {
    [[ -f "$TMUX_CONF" ]]
}

# --- bind-key entries ---

@test "tmux config: prefix + R binds sdd-review" {
    run grep 'bind-key R' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-review"
}

@test "tmux config: prefix + S binds sdd-specs" {
    run grep 'bind-key S' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-specs"
}

@test "tmux config: prefix + D binds sdd-diff" {
    run grep 'bind-key D' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-diff"
}

@test "tmux config: prefix + W binds sdd-watch with prompt" {
    run grep 'bind-key W' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-watch"
    assert_output --partial "read"
}

@test "tmux config: prefix + T binds sdd-tree" {
    run grep 'bind-key T' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-tree"
}

@test "tmux config: prefix + E opens VS Code" {
    run grep 'bind-key E' "$TMUX_CONF"
    assert_success
    assert_output --partial "code ."
}

# --- split directions ---

@test "tmux config: R/S/D use horizontal split" {
    for key in R S D; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "split-window -h"
    done
}

@test "tmux config: W/T use vertical split" {
    for key in W T; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "split-window -v"
    done
}

# --- pane sizes ---

@test "tmux config: R/S/D split at 55%" {
    for key in R S D; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "-p 55"
    done
}

@test "tmux config: W splits at 40%" {
    run grep 'bind-key W' "$TMUX_CONF"
    assert_output --partial "-p 40"
}

@test "tmux config: T splits at 30%" {
    run grep 'bind-key T' "$TMUX_CONF"
    assert_output --partial "-p 30"
}

# --- bash -ic for function availability ---

@test "tmux config: uses bash -ic for interactive shell" {
    run grep -c 'bash -ic' "$TMUX_CONF"
    assert_success
    # R, S, D, W, T = 5 bindings using bash -ic
    [[ "${output}" -ge 5 ]]
}
