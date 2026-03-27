#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- function existence ---

@test "sdd-tree: function exists" {
    run type -t sdd-tree
    assert_success
    assert_output "function"
}

# --- basic tree display ---

@test "sdd-tree: displays .md files in directory" {
    mkdir -p "$TEST_TEMP_DIR/docs"
    echo "# Spec" > "$TEST_TEMP_DIR/docs/spec.md"
    echo "# Plan" > "$TEST_TEMP_DIR/docs/plan.md"
    echo "# Not md" > "$TEST_TEMP_DIR/docs/notes.txt"

    run sdd-tree "$TEST_TEMP_DIR"
    assert_success
    assert_output --partial "spec.md"
    assert_output --partial "plan.md"
    refute_output --partial "notes.txt"
}

# --- nested structure ---

@test "sdd-tree: displays nested directory structure" {
    mkdir -p "$TEST_TEMP_DIR/project/openspec/changes"
    echo "# Root" > "$TEST_TEMP_DIR/project/readme.md"
    echo "# Spec" > "$TEST_TEMP_DIR/project/openspec/spec.md"
    echo "# Change" > "$TEST_TEMP_DIR/project/openspec/changes/001.md"

    run sdd-tree "$TEST_TEMP_DIR/project"
    assert_success
    assert_output --partial "readme.md"
    assert_output --partial "spec.md"
    assert_output --partial "001.md"
}

# --- directory argument ---

@test "sdd-tree: accepts directory argument" {
    mkdir -p "$TEST_TEMP_DIR/subdir"
    echo "# Sub" > "$TEST_TEMP_DIR/subdir/doc.md"

    run sdd-tree "$TEST_TEMP_DIR/subdir"
    assert_success
    assert_output --partial "doc.md"
}

# --- invalid directory ---

@test "sdd-tree: fails on non-existent directory" {
    run sdd-tree "$TEST_TEMP_DIR/nonexistent"
    assert_failure
    assert_output --partial "not found"
}

# --- truncation at 50 files ---

@test "sdd-tree: truncates at 50 files" {
    mkdir -p "$TEST_TEMP_DIR/many"
    for i in $(seq 1 55); do
        echo "# File $i" > "$TEST_TEMP_DIR/many/file_$(printf '%03d' "$i").md"
    done

    run sdd-tree "$TEST_TEMP_DIR/many"
    assert_success
    assert_output --partial "more"
}

# --- empty directory ---

@test "sdd-tree: handles directory with no .md files" {
    mkdir -p "$TEST_TEMP_DIR/empty"
    echo "not markdown" > "$TEST_TEMP_DIR/empty/readme.txt"

    run sdd-tree "$TEST_TEMP_DIR/empty"
    assert_success
    # Should at least show the directory name, no crash
}

# --- defaults to current directory ---

@test "sdd-tree: defaults to current directory" {
    cd "$TEST_TEMP_DIR"
    echo "# Here" > readme.md

    run sdd-tree
    assert_success
    assert_output --partial "readme.md"
}
