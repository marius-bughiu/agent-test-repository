#!/usr/bin/env bash
# Run a batch of tests and write results.json.
#
# Usage:
#   scripts/run_tests.sh                           # all tiers
#   scripts/run_tests.sh --tier 10-basics          # single tier (repeatable)
#   scripts/run_tests.sh --tier 10-basics --tier 20-branching
#   scripts/run_tests.sh --only 50-github-prs-03   # single test (repeatable)
#   scripts/run_tests.sh --skip-fork               # skip tests that require a fork
#   scripts/run_tests.sh --dry-run                 # list test ids without running
#   scripts/run_tests.sh --output custom.json      # custom results path

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OUTPUT="$REPO_ROOT/results.json"
DRY_RUN=0
SKIP_FORK=0
TIERS=()
ONLY=()

while [ $# -gt 0 ]; do
    case "$1" in
        --tier)      TIERS+=("$2"); shift 2 ;;
        --only)      ONLY+=("$2"); shift 2 ;;
        --skip-fork) SKIP_FORK=1; shift ;;
        --dry-run)   DRY_RUN=1; shift ;;
        --output)    OUTPUT="$2"; shift 2 ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) printf 'unknown arg: %s\n' "$1" >&2; exit 4 ;;
    esac
done

# ---------------------------------------------------------------------------
# Discover test ids from the rubric
# ---------------------------------------------------------------------------

rubric="$REPO_ROOT/scoring/rubric.json"
if [ ! -f "$rubric" ]; then
    printf 'error: rubric missing: %s\n' "$rubric" >&2
    exit 1
fi

declare -a ALL_IDS
declare -A TIER_OF

# Parse rubric.json with jq if available, else a plain-bash fallback.
if command -v jq >/dev/null 2>&1; then
    while IFS=$'\t' read -r id tier; do
        ALL_IDS+=("$id")
        TIER_OF["$id"]="$tier"
    done < <(jq -r '.tests | to_entries[] | "\(.key)\t\(.value.tier)"' "$rubric")
else
    # Fallback: grep for "id": { "tier": "tier" ... } patterns.
    # This is brittle; installing jq is strongly recommended.
    while IFS= read -r line; do
        if [[ "$line" =~ \"([0-9]{2}-[a-z0-9-]+-[0-9]{2})\"[[:space:]]*:.*\"tier\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            ALL_IDS+=("${BASH_REMATCH[1]}")
            TIER_OF["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
        fi
    done < "$rubric"
fi

# Stable ordering by id.
IFS=$'\n' ALL_IDS=($(printf '%s\n' "${ALL_IDS[@]}" | sort)); unset IFS

# ---------------------------------------------------------------------------
# Filter by --tier and --only
# ---------------------------------------------------------------------------

SELECTED=()
for id in "${ALL_IDS[@]}"; do
    if [ "${#ONLY[@]}" -gt 0 ]; then
        matched=0
        for o in "${ONLY[@]}"; do
            if [ "$o" = "$id" ]; then matched=1; break; fi
        done
        [ "$matched" = 1 ] || continue
    fi
    if [ "${#TIERS[@]}" -gt 0 ]; then
        matched=0
        for t in "${TIERS[@]}"; do
            if [ "$t" = "${TIER_OF[$id]}" ]; then matched=1; break; fi
        done
        [ "$matched" = 1 ] || continue
    fi
    SELECTED+=("$id")
done

if [ "${#SELECTED[@]}" -eq 0 ]; then
    printf 'no tests selected\n' >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Dry run: just print what would be executed
# ---------------------------------------------------------------------------

if [ "$DRY_RUN" = 1 ]; then
    for id in "${SELECTED[@]}"; do
        printf '%s\t%s\n' "$id" "${TIER_OF[$id]}"
    done
    exit 0
fi

# ---------------------------------------------------------------------------
# Run each test via run_test.sh, collecting NDJSON lines
# ---------------------------------------------------------------------------

workdir="$REPO_ROOT/.agent-workdir"
mkdir -p "$workdir"
ndjson="$workdir/results.ndjson"
: > "$ndjson"

started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

passed=0; failed=0; skipped=0; errored=0
for id in "${SELECTED[@]}"; do
    printf '[%s] running...\n' "$id"
    if [ "$SKIP_FORK" = 1 ] && grep -q 'fork_required: true' "$REPO_ROOT/tests/${TIER_OF[$id]}/${id}.md" 2>/dev/null; then
        printf '{"id":"%s","status":"skipped","duration_seconds":0,"message":"fork_required and --skip-fork specified"}\n' "$id" >> "$ndjson"
        skipped=$((skipped+1))
        continue
    fi
    "$SCRIPT_DIR/run_test.sh" "$id" --no-append >> "$ndjson"
    rc=$?
    case "$rc" in
        0) passed=$((passed+1)) ;;
        1) failed=$((failed+1)) ;;
        2) skipped=$((skipped+1)) ;;
        *) errored=$((errored+1)) ;;
    esac
done

finished_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# ---------------------------------------------------------------------------
# Assemble final results.json
# ---------------------------------------------------------------------------

agent_name="${AGENT_NAME:-unknown-agent}"
agent_version="${AGENT_VERSION:-}"
agent_model="${AGENT_MODEL:-}"
agent_operator="${AGENT_OPERATOR:-$(git config user.name 2>/dev/null || echo unknown)}"

os_name="$({ uname -sr 2>/dev/null || echo "$OSTYPE"; } | head -n1)"
git_v="$(git --version 2>/dev/null | awk '{print $3}')"
gh_v="$(gh --version 2>/dev/null | head -n1 | awk '{print $3}')"
py_v="$({ python3 --version || python --version; } 2>&1 | awk '{print $2}')"

{
    printf '{\n'
    printf '  "schema_version": "1.0.0",\n'
    printf '  "agent": {\n'
    printf '    "name": "%s",\n' "$agent_name"
    printf '    "version": "%s",\n' "$agent_version"
    printf '    "model": "%s",\n' "$agent_model"
    printf '    "operator": "%s"\n' "$agent_operator"
    printf '  },\n'
    printf '  "environment": {\n'
    printf '    "os": "%s",\n' "$os_name"
    printf '    "shell": "%s",\n' "${BASH_VERSION:-unknown}"
    printf '    "git_version": "%s",\n' "$git_v"
    printf '    "gh_version": "%s",\n' "$gh_v"
    printf '    "python_version": "%s"\n' "$py_v"
    printf '  },\n'
    printf '  "started_at": "%s",\n' "$started_at"
    printf '  "finished_at": "%s",\n' "$finished_at"
    printf '  "results": [\n'
    # join NDJSON lines with commas
    first=1
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        if [ "$first" = 1 ]; then first=0; else printf ',\n'; fi
        printf '    %s' "$line"
    done < "$ndjson"
    printf '\n  ]\n'
    printf '}\n'
} > "$OUTPUT"

printf '\n=== Summary ===\n'
printf '  passed:  %d\n' "$passed"
printf '  failed:  %d\n' "$failed"
printf '  skipped: %d\n' "$skipped"
printf '  errored: %d\n' "$errored"
printf 'Results: %s\n' "$OUTPUT"

# Exit 0 if nothing errored and nothing failed; otherwise non-zero.
if [ "$failed" -gt 0 ] || [ "$errored" -gt 0 ]; then
    exit 1
fi
