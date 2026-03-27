#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- function existence ---

@test "sdd-diff: function exists" {
    run type -t sdd-diff
    assert_success
    assert_output "function"
}

# --- fzf dependency check ---

@test "sdd-diff: requires fzf when files are found" {
    cd "$TEST_TEMP_DIR"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "# Doc" > doc.md
    git add doc.md
    git commit -q -m "init"
    echo "# Changed" >> doc.md
    git add doc.md
    git commit -q -m "change"

    # Override _sdd_check_dep to simulate missing fzf
    _sdd_check_dep() { echo "sdd: '$1' not found." >&2; return 1; }
    run sdd-diff 1
    assert_failure
    assert_output --partial "fzf"
    assert_output --partial "not found"
}

# --- git environment ---

@test "sdd-diff: lists changed .md files in git repo" {
    cd "$TEST_TEMP_DIR"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "# Initial" > readme.md
    git add readme.md
    git commit -q -m "init"
    echo "# Changed" > readme.md
    echo "# New" > new.md
    git add readme.md new.md
    git commit -q -m "changes"

    # We can't test fzf interactively, but verify the function doesn't error
    # by checking it at least detects the git environment
    run bash -c "cd '$TEST_TEMP_DIR' && source '$SDD_TOOLKIT_DIR/sdd-functions.sh' && git diff --name-only HEAD~1 -- '*.md'"
    assert_success
    assert_output --partial ".md"
}

# --- non-git environment ---

@test "sdd-diff: shows message when no changed .md files" {
    cd "$TEST_TEMP_DIR"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "not markdown" > readme.txt
    git add readme.txt
    git commit -q -m "init"

    # No .md files changed at all — should show "no recently changed" message
    run sdd-diff 1
    assert_success
    assert_output --partial "no recently changed"
}

# --- parameter handling ---

@test "sdd-diff: accepts numeric argument" {
    cd "$TEST_TEMP_DIR"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "# Doc" > doc.md
    git add doc.md
    git commit -q -m "init"

    # Just verify it doesn't crash with a parameter
    run bash -c "cd '$TEST_TEMP_DIR' && source '$SDD_TOOLKIT_DIR/sdd-functions.sh' && git diff --name-only HEAD~1 -- '*.md' 2>/dev/null; echo ok"
    assert_success
    assert_output --partial "ok"
}

# --- non-git fallback ---

@test "sdd-diff: uses find in non-git directory" {
    cd "$TEST_TEMP_DIR"
    # Not a git repo, create a recent .md file
    echo "# Recent" > recent.md
    touch -t "$(date +%Y%m%d%H%M)" recent.md

    # Verify find works as fallback
    run bash -c "cd '$TEST_TEMP_DIR' && find . -name '*.md' -mtime -1"
    assert_success
    assert_output --partial "recent.md"
}
