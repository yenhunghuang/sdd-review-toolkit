#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- Helper: mock fzf ---

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

@test "sdd-specs: function exists" {
    run type -t sdd-specs
    assert_success
    assert_output "function"
}

@test "sdd-specs: detects speckit and uses specs/ directory" {
    mkdir -p "$TEST_TEMP_DIR/project/.specify"
    mkdir -p "$TEST_TEMP_DIR/project/specs"
    echo "# Spec Doc" > "$TEST_TEMP_DIR/project/specs/feature.md"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    cd "$TEST_TEMP_DIR/project"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-specs

    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "specs/feature.md"
}

@test "sdd-specs: detects openspec and uses openspec/ directory" {
    mkdir -p "$TEST_TEMP_DIR/project/openspec"
    echo "# OpenSpec Doc" > "$TEST_TEMP_DIR/project/openspec/change.md"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    cd "$TEST_TEMP_DIR/project"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-specs

    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "openspec/change.md"
}

@test "sdd-specs: falls back to current directory with warning" {
    mkdir -p "$TEST_TEMP_DIR/project"
    echo "# Readme" > "$TEST_TEMP_DIR/project/readme.md"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    cd "$TEST_TEMP_DIR/project"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-specs

    assert_output --partial "no SDD structure detected"
    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "readme.md"
}

@test "sdd-specs: uses explicit directory argument" {
    mkdir -p "$TEST_TEMP_DIR/custom-dir"
    echo "# Custom Doc" > "$TEST_TEMP_DIR/custom-dir/doc.md"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-specs "$TEST_TEMP_DIR/custom-dir"

    refute_output --partial "no SDD structure"
    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "custom-dir/doc.md"
}

@test "sdd-specs: speckit takes priority when both .specify and openspec exist" {
    mkdir -p "$TEST_TEMP_DIR/project/.specify"
    mkdir -p "$TEST_TEMP_DIR/project/specs"
    mkdir -p "$TEST_TEMP_DIR/project/openspec"
    echo "# From Specs" > "$TEST_TEMP_DIR/project/specs/spec.md"
    echo "# From OpenSpec" > "$TEST_TEMP_DIR/project/openspec/open.md"

    _create_mock_fzf capture
    export MOCK_FZF_CAPTURE="$TEST_TEMP_DIR/fzf_input.txt"
    cd "$TEST_TEMP_DIR/project"
    PATH="$TEST_TEMP_DIR/bin:$PATH" run sdd-specs

    assert [ -f "$TEST_TEMP_DIR/fzf_input.txt" ]
    run cat "$TEST_TEMP_DIR/fzf_input.txt"
    assert_output --partial "specs/spec.md"
    refute_output --partial "openspec/open.md"
}
