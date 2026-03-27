#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    _common_teardown
}

# --- function existence ---

@test "sdd-approve: function exists" {
    run type -t sdd-approve
    assert_success
    assert_output "function"
}

# --- no arguments ---

@test "sdd-approve: shows usage when no arguments" {
    run sdd-approve
    assert_failure
    assert_output --partial "Usage: sdd-approve"
}

# --- file not found ---

@test "sdd-approve: fails when file does not exist" {
    run sdd-approve "$TEST_TEMP_DIR/nonexistent.md"
    assert_failure
    assert_output --partial "not found"
}

# --- approve pending sign-off ---

@test "sdd-approve: replaces pending marker with approved" {
    cat > "$TEST_TEMP_DIR/spec.md" << 'EOF'
# Spec

## Sign-off
⬜ 待確認
EOF

    run sdd-approve "$TEST_TEMP_DIR/spec.md"
    assert_success
    assert_output --partial "approved successfully"

    # Verify file was updated
    run cat "$TEST_TEMP_DIR/spec.md"
    assert_output --partial "✅ 已確認"
    refute_output --partial "⬜"
}

# --- approve includes date ---

@test "sdd-approve: includes current date in approval" {
    cat > "$TEST_TEMP_DIR/spec.md" << 'EOF'
⬜ 待確認
EOF

    run sdd-approve "$TEST_TEMP_DIR/spec.md"
    assert_success

    local today
    today="$(date +%Y-%m-%d)"
    run cat "$TEST_TEMP_DIR/spec.md"
    assert_output --partial "$today"
}

# --- already approved ---

@test "sdd-approve: reports already approved" {
    cat > "$TEST_TEMP_DIR/spec.md" << 'EOF'
# Spec

## Sign-off
✅ 已確認 (2026-01-01)
EOF

    run sdd-approve "$TEST_TEMP_DIR/spec.md"
    assert_success
    assert_output --partial "already approved"
}

# --- no sign-off block ---

@test "sdd-approve: reports no sign-off block" {
    cat > "$TEST_TEMP_DIR/spec.md" << 'EOF'
# Spec

Just regular content, no sign-off markers.
EOF

    run sdd-approve "$TEST_TEMP_DIR/spec.md"
    assert_success
    assert_output --partial "no sign-off block"
}

# --- multiple pending markers ---

@test "sdd-approve: replaces all pending markers" {
    cat > "$TEST_TEMP_DIR/spec.md" << 'EOF'
## Reviews
⬜ PM Review
⬜ Tech Review
EOF

    run sdd-approve "$TEST_TEMP_DIR/spec.md"
    assert_success

    run grep -c '✅' "$TEST_TEMP_DIR/spec.md"
    assert_output "2"

    run grep -c '⬜' "$TEST_TEMP_DIR/spec.md" || true
    assert_output "0"
}
