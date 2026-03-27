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

@test "tmux config: prefix + L binds sdd-last" {
    run grep 'bind-key L' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-last"
}

@test "tmux config: prefix + P binds sdd-peek" {
    run grep 'bind-key P' "$TMUX_CONF"
    assert_success
    assert_output --partial "sdd-peek"
}

@test "tmux config: prefix + E opens VS Code" {
    run grep 'bind-key E' "$TMUX_CONF"
    assert_success
    assert_output --partial "code"
}

# --- all use split-window (except E) ---

@test "tmux config: all review keys use split-window" {
    for key in R S D W T L P; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "split-window"
    done
}

# --- pane direction and size ---

@test "tmux config: all splits are horizontal right 55%" {
    for key in R S D W T L P; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "split-window -h -l 55%"
    done
}

# --- working directory ---

@test "tmux config: splits inherit pane_current_path" {
    for key in R S D W T L P; do
        run grep "bind-key $key" "$TMUX_CONF"
        assert_output --partial "pane_current_path"
    done
}

# --- bash -ic for function availability ---

@test "tmux config: uses bash -ic for interactive shell" {
    run grep -c 'bash -ic' "$TMUX_CONF"
    assert_success
    [[ "${output}" -ge 7 ]]
}
