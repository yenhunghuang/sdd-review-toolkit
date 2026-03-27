#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- _sdd_check_dep ---

@test "_sdd_check_dep: returns 0 for existing command (bash)" {
    run _sdd_check_dep bash
    assert_success
}

@test "_sdd_check_dep: returns 1 for missing command" {
    run _sdd_check_dep nonexistent_command_xyz
    assert_failure
    assert_output --partial "not found"
}

@test "_sdd_check_dep: prints custom install hint" {
    run _sdd_check_dep nonexistent_command_xyz "Run: apt install something"
    assert_failure
    assert_output --partial "Run: apt install something"
}

# --- _sdd_detect_type ---

@test "_sdd_detect_type: detects speckit when .specify/ exists" {
    mkdir -p "$TEST_TEMP_DIR/.specify"
    run _sdd_detect_type "$TEST_TEMP_DIR"
    assert_success
    assert_output "speckit"
}

@test "_sdd_detect_type: detects openspec when openspec/ exists" {
    mkdir -p "$TEST_TEMP_DIR/openspec"
    run _sdd_detect_type "$TEST_TEMP_DIR"
    assert_success
    assert_output "openspec"
}

@test "_sdd_detect_type: speckit takes priority over openspec" {
    mkdir -p "$TEST_TEMP_DIR/.specify" "$TEST_TEMP_DIR/openspec"
    run _sdd_detect_type "$TEST_TEMP_DIR"
    assert_success
    assert_output "speckit"
}

@test "_sdd_detect_type: returns unknown when no SDD dirs" {
    run _sdd_detect_type "$TEST_TEMP_DIR"
    assert_failure
    assert_output "unknown"
}

# --- _sdd_spec_dir ---

@test "_sdd_spec_dir: returns specs/ for speckit" {
    mkdir -p "$TEST_TEMP_DIR/.specify"
    run _sdd_spec_dir "$TEST_TEMP_DIR"
    assert_output "$TEST_TEMP_DIR/specs"
}

@test "_sdd_spec_dir: returns openspec/ for openspec" {
    mkdir -p "$TEST_TEMP_DIR/openspec"
    run _sdd_spec_dir "$TEST_TEMP_DIR"
    assert_output "$TEST_TEMP_DIR/openspec"
}

@test "_sdd_spec_dir: returns root for unknown" {
    run _sdd_spec_dir "$TEST_TEMP_DIR"
    assert_output "$TEST_TEMP_DIR"
}

# --- _sdd_clipboard ---

@test "_sdd_clipboard: function exists" {
    run type -t _sdd_clipboard
    assert_success
    assert_output "function"
}

# --- _sdd_glow_render ---

@test "_sdd_glow_render: renders file content (fallback to cat when glow missing)" {
    echo "# Hello World" > "$TEST_TEMP_DIR/test.md"
    run _sdd_glow_render "$TEST_TEMP_DIR/test.md"
    assert_success
    assert_output --partial "Hello World"
}
