#!/usr/bin/env bash
# Shared bash helpers for verify scripts and runners.
#
# Source this file at the top of every verify script:
#     SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#     . "${REPO_ROOT:-$SCRIPT_DIR/../../..}/scripts/lib/common.sh"
#
# Exit codes (verify scripts):
#   0  passed
#   1  failed
#   2  skipped (missing dep / unconfigured env; reported via skip())
#   3  errored (unexpected failure; reported via die())
#
# Verify scripts MUST call exactly one of: pass, fail, skip, die.

set -o pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

if [ -z "${REPO_ROOT:-}" ]; then
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

: "${AGENT_WORKDIR:=$REPO_ROOT/.agent-workdir}"
: "${AGENT_TIMEOUT_DEFAULT:=120}"
: "${AGENT_VERBOSE:=0}"
: "${AGENT_SKIP_CLEANUP:=0}"

export REPO_ROOT AGENT_WORKDIR AGENT_TIMEOUT_DEFAULT AGENT_VERBOSE AGENT_SKIP_CLEANUP

mkdir -p "$AGENT_WORKDIR"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

log() {
    if [ "$AGENT_VERBOSE" = "1" ]; then
        printf '[%s] %s\n' "${TEST_ID:-?}" "$*" >&2
    fi
}

info() {
    printf '[%s] %s\n' "${TEST_ID:-?}" "$*" >&2
}

# ---------------------------------------------------------------------------
# Result primitives — exactly one of these should be called per verify script
# ---------------------------------------------------------------------------

pass() {
    exit 0
}

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

skip() {
    printf 'SKIP: %s\n' "$*" >&2
    exit 2
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 3
}

# ---------------------------------------------------------------------------
# Dep checks
# ---------------------------------------------------------------------------

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        skip "required command not found on PATH: $cmd"
    fi
}

require_gh_auth() {
    require_cmd gh
    if ! gh auth status >/dev/null 2>&1; then
        skip "gh is not authenticated (run: gh auth login)"
    fi
}

require_fork() {
    if [ ! -f "$AGENT_WORKDIR/env.json" ]; then
        skip "fork not configured — run scripts/setup.sh first"
    fi
    if ! command -v jq >/dev/null 2>&1; then
        skip "jq is required to read fork config"
    fi
    local owner repo
    owner=$(jq -r '.fork.owner // empty' "$AGENT_WORKDIR/env.json")
    repo=$(jq -r '.fork.repo // empty' "$AGENT_WORKDIR/env.json")
    if [ -z "$owner" ] || [ -z "$repo" ]; then
        skip "fork owner/repo not detected in env.json"
    fi
    export AGENT_FORK_OWNER="${AGENT_FORK_OWNER:-$owner}"
    export AGENT_FORK_REPO="${AGENT_FORK_REPO:-$repo}"
}

# ---------------------------------------------------------------------------
# Sandbox management
# ---------------------------------------------------------------------------

# Create a fresh, empty throwaway git repo and cd into it.
# Usage: setup_sandbox        # uses $TEST_ID as folder name
#        setup_sandbox mylabel
setup_sandbox() {
    local label="${1:-${TEST_ID:-sandbox}}"
    local dir="$AGENT_WORKDIR/sbx-$label-$$"
    rm -rf "$dir"
    mkdir -p "$dir"
    cd "$dir" || die "could not cd into sandbox: $dir"
    git init -q -b main
    git config user.email "agent-test@example.invalid"
    git config user.name  "Agent Test"
    git config commit.gpgsign false
    git config tag.gpgsign false
    export SANDBOX_DIR="$dir"
    log "sandbox at $dir"
}

cleanup_sandbox() {
    if [ "$AGENT_SKIP_CLEANUP" = "1" ]; then
        return 0
    fi
    if [ -n "${SANDBOX_DIR:-}" ] && [ -d "$SANDBOX_DIR" ]; then
        cd "$REPO_ROOT" 2>/dev/null || true
        rm -rf "$SANDBOX_DIR"
    fi
    if [ -n "${BARE_REMOTE_DIR:-}" ] && [ -d "$BARE_REMOTE_DIR" ]; then
        rm -rf "$BARE_REMOTE_DIR"
    fi
    if [ -n "${SECOND_CLONE_DIR:-}" ] && [ -d "$SECOND_CLONE_DIR" ]; then
        rm -rf "$SECOND_CLONE_DIR"
    fi
}

# Create a bare git repo and register it as 'origin' on the current sandbox.
# Call after setup_sandbox. Sets BARE_REMOTE_DIR.
setup_bare_remote() {
    local label="${1:-${TEST_ID:-sandbox}}"
    BARE_REMOTE_DIR="$AGENT_WORKDIR/bare-$label-$$"
    rm -rf "$BARE_REMOTE_DIR"
    git init -q --bare -b main "$BARE_REMOTE_DIR"
    git remote add origin "$BARE_REMOTE_DIR"
    export BARE_REMOTE_DIR
    log "bare remote at $BARE_REMOTE_DIR"
}

# Create a second clone of the bare remote (simulates another developer).
# Sets SECOND_CLONE_DIR. Caller must cd back when done.
setup_second_clone() {
    [ -n "${BARE_REMOTE_DIR:-}" ] || die "setup_second_clone requires setup_bare_remote first"
    SECOND_CLONE_DIR="$AGENT_WORKDIR/clone2-${TEST_ID:-sandbox}-$$"
    rm -rf "$SECOND_CLONE_DIR"
    git clone -q "$BARE_REMOTE_DIR" "$SECOND_CLONE_DIR"
    (
        cd "$SECOND_CLONE_DIR"
        git config user.email "agent-test-clone@example.invalid"
        git config user.name  "Agent Test Clone"
        git config commit.gpgsign false
    )
    export SECOND_CLONE_DIR
}

# Auto-register sandbox cleanup (called on any exit).
trap_sandbox_cleanup() {
    trap 'cleanup_sandbox' EXIT
}

# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

assert_eq() {
    local actual="$1" expected="$2" label="${3:-value}"
    if [ "$actual" != "$expected" ]; then
        fail "$label mismatch — expected '$expected' got '$actual'"
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" label="${3:-output}"
    case "$haystack" in
        *"$needle"*) : ;;
        *) fail "$label did not contain '$needle'" ;;
    esac
}

assert_file_exists() {
    local path="$1"
    [ -f "$path" ] || fail "expected file to exist: $path"
}

assert_file_contents() {
    local path="$1" expected="$2"
    assert_file_exists "$path"
    local actual
    actual="$(cat "$path")"
    assert_eq "$actual" "$expected" "contents of $path"
}

assert_clean_tree() {
    if [ -n "$(git status --porcelain)" ]; then
        fail "working tree is not clean: $(git status --porcelain | tr '\n' ';' )"
    fi
}

assert_head_message() {
    local expected="$1"
    local actual
    actual="$(git log -1 --pretty=%s)"
    assert_eq "$actual" "$expected" "HEAD commit subject"
}

# ---------------------------------------------------------------------------
# Unique naming for artifacts created on GitHub
# ---------------------------------------------------------------------------

# Returns a suffix unique per run, so parallel agents don't collide.
run_suffix() {
    if [ -n "${AGENT_RUN_ID:-}" ]; then
        printf '%s' "$AGENT_RUN_ID"
    else
        printf '%s-%s' "$(date -u +%Y%m%d-%H%M%S)" "$$"
    fi
}

# Prefix every GitHub artifact with 'agent-test-' so cleanup.sh can find them.
artifact_name() {
    local base="$1"
    printf 'agent-test-%s-%s' "$base" "$(run_suffix)"
}
