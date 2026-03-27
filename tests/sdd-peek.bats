#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

@test "sdd-peek: function exists" {
    run type -t sdd-peek
    assert_success
    assert_output "function"
}

@test "sdd-peek: shows usage when no arguments" {
    run sdd-peek
    assert_failure
    assert_output --partial "Usage: sdd-peek"
}

@test "sdd-peek: --help shows usage" {
    run sdd-peek --help
    assert_success
    assert_output --partial "Usage: sdd-peek"
}

@test "sdd-peek: fails when file does not exist" {
    run sdd-peek nonexistent.md
    assert_failure
    assert_output --partial "not found"
}

@test "sdd-peek: uses glow pager" {
    run type sdd-peek
    assert_output --partial "glow -p"
}
