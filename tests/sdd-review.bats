#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- Helper: mock fzf ---

# Creates a mock fzf in TEST_TEMP_DIR/bin.
#   "capture"       — saves stdin to MOCK_FZF_CAPTURE, exits 130 (ESC)
#   "select-first"  — outputs the first line of stdin (simulates ENTER)
_create_mock_fzf() {
    local mode="$1"
    mkdir -p "$TEST_TEMP_DIR/bin"
    case "$mode" in
        capture)
            cat > "$TEST_TEMP_DIR/bin/fzf" << 'EOF'
#!/usr/bin/env bash
cat > "${MOCK_FZF_CAPTURE:-/dev/null}"
exit 130
EOF
            ;;
        select-first)
            cat > "$TEST_TEMP_DIR/bin/fzf" << 'EOF'
#!/usr/bin/env bash
head -1
EOF
            ;;
    esac
    chmod +x "$TEST_TEMP_DIR/bin/fzf"
}

# --- Tests ---

@test "sdd-review: function exists" {
    run type -t sdd-review
    assert_success
    assert_output "function"
}

@test "sdd-review: fails when fzf is not available" {
    mkdir -p "$TEST_TEMP_DIR/empty_bin"
    PATH="$TEST_TEMP_DIR/empty_bin" run sdd-review
    assert_failure
    assert_output --partial "fzf"
    assert_output --partial "not found"
}

@test "sdd-review: shows message when no .md files found" {
    _create_mock_fzf capture
    mkdir -p "$TEST_TEMP_DIR/empty_dir"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-review "$TEST_TEMP_DIR/empty_dir"
    assert_failure
    assert_output --partial "no .md files"
}

@test "sdd-review: fails with nonexistent directory" {
    _create_mock_fzf capture
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-review "/nonexistent/path/xyz"
    assert_failure
    assert_output --partial "not found"
}

@test "sdd-review: finds .md files recursively" {
    mkdir -p "$TEST_TEMP_DIR/project/sub/deep"
    echo "# Root" > "$TEST_TEMP_DIR/project/root.md"
    echo "# Deep" > "$TEST_TEMP_DIR/project/sub/deep/nested.md"
    echo "not md" > "$TEST_TEMP_DIR/project/readme.txt"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-review "$TEST_TEMP_DIR/project"

    # Verify fzf received the right file list
    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "root.md"
    assert_output --partial "nested.md"
    refute_output --partial "readme.txt"
}

@test "sdd-review: ENTER renders selected file with glow fallback" {
    mkdir -p "$TEST_TEMP_DIR/docs"
    echo "# Hello Glow" > "$TEST_TEMP_DIR/docs/hello.md"

    _create_mock_fzf select-first
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-review "$TEST_TEMP_DIR/docs"
    assert_success
    assert_output --partial "Hello Glow"
}

@test "sdd-review: defaults to current directory" {
    mkdir -p "$TEST_TEMP_DIR/workdir"
    echo "# CWD File" > "$TEST_TEMP_DIR/workdir/readme.md"

    _create_mock_fzf select-first
    cd "$TEST_TEMP_DIR/workdir"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-review
    assert_success
    assert_output --partial "CWD File"
}
