#!/usr/bin/env bash
# Common test setup for all bats test files.

_common_setup() {
    load "$BATS_TEST_DIRNAME/test_helper/bats-support/load"
    load "$BATS_TEST_DIRNAME/test_helper/bats-assert/load"

    # Unset guard so we can re-source in each test
    unset _SDD_REVIEW_LOADED

    # Source our functions
    SDD_TOOLKIT_DIR="$(cd "$BATS_TEST_DIRNAME/../bin" && pwd)"
    source "$SDD_TOOLKIT_DIR/sdd-functions.sh"

    # Create temp directory for test fixtures
    TEST_TEMP_DIR="$(mktemp -d)"
}

_common_teardown() {
    [[ -d "${TEST_TEMP_DIR:-}" ]] && rm -rf "$TEST_TEMP_DIR"
}
