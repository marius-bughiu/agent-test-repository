#!/usr/bin/env bash
# Run a single test by id and append a JSON line describing the result.
#
# Usage:
#   scripts/run_test.sh <test-id>                      # appends to results.json
#   scripts/run_test.sh <test-id> --output out.json    # custom results path
#   scripts/run_test.sh <test-id> --timeout 60         # override timeout
#
# Exit codes:
#   0  test passed
#   1  test failed
#   2  test skipped (counts as success for the runner, just a different status)
#   3  test errored
#   4  bad invocation

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TEST_ID=""
OUTPUT="$REPO_ROOT/results.json"
TIMEOUT="${AGENT_TIMEOUT_DEFAULT:-120}"
APPEND=1

while [ $# -gt 0 ]; do
    case "$1" in
        --output) OUTPUT="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --no-append) APPEND=0; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            printf 'unknown flag: %s\n' "$1" >&2; exit 4 ;;
        *)
            if [ -z "$TEST_ID" ]; then TEST_ID="$1"; else printf 'unexpected arg: %s\n' "$1" >&2; exit 4; fi
            shift
            ;;
    esac
done

if [ -z "$TEST_ID" ]; then
    printf 'error: test id required\n' >&2
    exit 4
fi

# Parse test id: <tier>-<NN>  where tier may itself contain dashes, e.g. 10-basics-01.
# We split on the trailing -NN.
if ! [[ "$TEST_ID" =~ ^([0-9]{2}-[a-z0-9-]+)-([0-9]{2})$ ]]; then
    printf 'error: malformed test id: %s (expected NN-name-NN)\n' "$TEST_ID" >&2
    exit 4
fi
TIER="${BASH_REMATCH[1]}"
VERIFY="$REPO_ROOT/scripts/verify/$TIER/${TEST_ID}.sh"

if [ ! -x "$VERIFY" ] && [ ! -f "$VERIFY" ]; then
    printf 'error: no verify script at %s\n' "$VERIFY" >&2
    exit 4
fi

# ---------------------------------------------------------------------------
# Run the verify script with a timeout (using bash's builtin wait + a bg pid).
# We avoid GNU `timeout` because Git Bash on Windows doesn't always ship it.
# ---------------------------------------------------------------------------

run_with_timeout() {
    local timeout_s="$1"; shift
    local tmp_stdout tmp_stderr rc
    tmp_stdout="$(mktemp)"
    tmp_stderr="$(mktemp)"

    (
        # shellcheck disable=SC2068
        TEST_ID="$TEST_ID" REPO_ROOT="$REPO_ROOT" bash "$@" >"$tmp_stdout" 2>"$tmp_stderr"
    ) &
    local pid=$!

    local waited=0
    while kill -0 "$pid" 2>/dev/null; do
        if [ "$waited" -ge "$timeout_s" ]; then
            kill -9 "$pid" 2>/dev/null || true
            echo "TIMEOUT after ${timeout_s}s" >>"$tmp_stderr"
            rc=124
            break
        fi
        sleep 1
        waited=$((waited + 1))
    done
    wait "$pid" 2>/dev/null
    rc="${rc:-$?}"

    RUN_STDOUT="$(cat "$tmp_stdout")"
    RUN_STDERR="$(cat "$tmp_stderr")"
    RUN_DURATION="$waited"
    rm -f "$tmp_stdout" "$tmp_stderr"
    return "$rc"
}

start_epoch=$(date +%s 2>/dev/null || echo 0)
run_with_timeout "$TIMEOUT" "$VERIFY"
rc=$?
end_epoch=$(date +%s 2>/dev/null || echo 0)
duration=$((end_epoch - start_epoch))
[ "$duration" -lt 0 ] && duration=0

case "$rc" in
    0)   status="passed";  message=""; exit_rc=0 ;;
    1)   status="failed";  message="$(tail -c 500 <<<"$RUN_STDERR" | tr '\n' ' ')"; exit_rc=1 ;;
    2)   status="skipped"; message="$(tail -c 500 <<<"$RUN_STDERR" | tr '\n' ' ')"; exit_rc=2 ;;
    124) status="failed";  message="timeout after ${TIMEOUT}s"; exit_rc=1 ;;
    *)   status="errored"; message="$(tail -c 500 <<<"$RUN_STDERR" | tr '\n' ' ')"; exit_rc=3 ;;
esac

# ---------------------------------------------------------------------------
# Emit JSON line. We write a single line per test; the outer runner
# assembles them into the final results.json shape.
# ---------------------------------------------------------------------------

json_escape() {
    # minimal JSON escape: backslash, quote, control chars
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

line=$(printf '{"id":"%s","status":"%s","duration_seconds":%s,"message":"%s"}' \
    "$TEST_ID" "$status" "$duration" "$(json_escape "$message")")

if [ "$APPEND" = "1" ]; then
    # Append to a temp file that run_tests.sh will assemble into the final JSON.
    tmp_results="$REPO_ROOT/.agent-workdir/results.ndjson"
    mkdir -p "$(dirname "$tmp_results")"
    printf '%s\n' "$line" >> "$tmp_results"
fi

printf '%s\n' "$line"

# Emit the captured verify-script output for interactive runs.
if [ "${AGENT_VERBOSE:-0}" = "1" ] && [ -n "$RUN_STDERR" ]; then
    printf '%s\n' "--- stderr ---" >&2
    printf '%s\n' "$RUN_STDERR" >&2
fi

exit "$exit_rc"
