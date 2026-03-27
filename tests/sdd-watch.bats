#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- function existence ---

@test "sdd-watch: function exists" {
    run type -t sdd-watch
    assert_success
    assert_output "function"
}

# --- usage / argument validation ---

@test "sdd-watch: no arguments shows usage" {
    run sdd-watch
    assert_failure
    assert_output --partial "Usage: sdd-watch <file.md>"
}

@test "sdd-watch: nonexistent file shows error" {
    run sdd-watch "/tmp/nonexistent_file_$RANDOM.md"
    assert_failure
    assert_output --partial "file not found"
}

# --- inotifywait detection ---

@test "sdd-watch: detects inotifywait availability" {
    local body
    body="$(declare -f sdd-watch)"
    [[ "$body" == *"inotifywait"* ]]
}

@test "sdd-watch: has polling fallback with sleep" {
    local body
    body="$(declare -f sdd-watch)"
    [[ "$body" == *"sleep"* ]]
}

@test "sdd-watch: has trap for clean exit" {
    local body
    body="$(declare -f sdd-watch)"
    [[ "$body" == *"trap"* ]]
}

@test "sdd-watch: fallback shows install suggestion" {
    local body
    body="$(declare -f sdd-watch)"
    [[ "$body" == *"inotify-tools"* ]]
}
