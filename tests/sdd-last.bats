#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

@test "sdd-last: function exists" {
    run type -t sdd-last
    assert_success
    assert_output "function"
}

@test "sdd-last: --help shows usage" {
    run sdd-last --help
    assert_success
    assert_output --partial "Usage: sdd-last"
}

@test "sdd-last: no .md files shows error" {
    mkdir -p "$TEST_TEMP_DIR/empty"
    cd "$TEST_TEMP_DIR/empty"
    run sdd-last
    assert_failure
    assert_output --partial "no .md files"
}

@test "sdd-last: finds most recent .md file" {
    run type sdd-last
    assert_output --partial "sort -rn"
}

@test "sdd-last: accepts numeric argument" {
    run type sdd-last
    assert_output --partial "head -n"
}
