#!/usr/bin/env bash
# One-time setup: checks dependencies, authenticates gh, and writes
# .agent-workdir/env.json with the detected fork owner/name.
#
# Safe to run repeatedly — it overwrites env.json on each run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

printf '=== Agent test harness setup ===\n'
printf 'Repo root: %s\n' "$REPO_ROOT"
printf 'Workdir:   %s\n' "$AGENT_WORKDIR"
printf '\n'

# ---------------------------------------------------------------------------
# Dependency versions
# ---------------------------------------------------------------------------

check_version() {
    local cmd="$1" version_flag="${2:---version}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf '  [--] %-10s not found\n' "$cmd"
        return 1
    fi
    local out rc
    out="$("$cmd" $version_flag 2>&1)"; rc=$?
    # Microsoft Store Python shim writes a "not found" message but exits 0.
    if printf '%s' "$out" | grep -q -i 'Microsoft Store\|was not found; run without arguments'; then
        printf '  [--] %-10s shim only (not a real install)\n' "$cmd"
        return 1
    fi
    if [ "$rc" -ne 0 ] && [ -z "$out" ]; then
        printf '  [--] %-10s exited %d with no output\n' "$cmd" "$rc"
        return 1
    fi
    printf '  [OK] %-10s %s\n' "$cmd" "$(printf '%s' "$out" | head -n1)"
    return 0
}

# Choose the first working python interpreter from a list.
resolve_python() {
    for candidate in python3 python py; do
        if command -v "$candidate" >/dev/null 2>&1; then
            local out
            out="$("$candidate" --version 2>&1)" || continue
            if printf '%s' "$out" | grep -q -i 'Microsoft Store\|was not found'; then
                continue
            fi
            printf '%s' "$candidate"
            return 0
        fi
    done
    return 1
}

missing_required=0
missing_optional=0

printf 'Required:\n'
check_version git  --version || missing_required=$((missing_required+1))
check_version bash --version || missing_required=$((missing_required+1))

printf '\nRecommended (needed for most tiers):\n'
check_version gh --version || missing_optional=$((missing_optional+1))
if py_cmd="$(resolve_python)"; then
    printf '  [OK] %-10s %s (via %s)\n' "python" "$("$py_cmd" --version 2>&1)" "$py_cmd"
else
    printf '  [--] %-10s no working interpreter found\n' "python"
    missing_optional=$((missing_optional+1))
fi
check_version jq --version || missing_optional=$((missing_optional+1))

printf '\nOptional (specific tests only):\n'
check_version gpg        --version || :
if command -v ssh-keygen >/dev/null 2>&1; then
    printf '  [OK] %-10s available\n' "ssh-keygen"
else
    printf '  [--] %-10s not found\n' "ssh-keygen"
fi

if [ "$missing_required" -gt 0 ]; then
    printf '\n[FAIL] %d required dependency missing. Install them and re-run.\n' "$missing_required" >&2
    exit 1
fi
if [ "$missing_optional" -gt 0 ]; then
    printf '\n[warn] %d recommended dependency missing. Some tests will be skipped.\n' "$missing_optional"
fi

# ---------------------------------------------------------------------------
# GitHub auth + fork detection
# ---------------------------------------------------------------------------

fork_owner=""
fork_repo=""
gh_user=""

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh_user="$(gh api user --jq .login 2>/dev/null || echo "")"
    printf '\n[OK] gh authenticated as: %s\n' "${gh_user:-unknown}"
else
    printf '\n[warn] gh not authenticated. GitHub-interaction tests will be skipped.\n'
fi

# Detect fork from the origin remote.
if git -C "$REPO_ROOT" remote get-url origin >/dev/null 2>&1; then
    origin_url="$(git -C "$REPO_ROOT" remote get-url origin)"
    # Match github.com[:/ ]<owner>/<repo>(.git)?
    if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
        fork_owner="${BASH_REMATCH[1]}"
        fork_repo="${BASH_REMATCH[2]}"
        printf '[OK] origin fork detected: %s/%s\n' "$fork_owner" "$fork_repo"
    else
        printf '[warn] could not parse origin URL: %s\n' "$origin_url"
    fi
else
    printf '[warn] no origin remote configured\n'
fi

if [ -n "$gh_user" ] && [ -n "$fork_owner" ] && [ "$gh_user" != "$fork_owner" ]; then
    printf '[warn] authenticated as %s but origin is %s/%s — GitHub tests will act on the origin account.\n' \
        "$gh_user" "$fork_owner" "$fork_repo"
fi

# ---------------------------------------------------------------------------
# Emit env.json
# ---------------------------------------------------------------------------

env_file="$AGENT_WORKDIR/env.json"
{
    printf '{\n'
    printf '  "generated_at": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '  "repo_root": "%s",\n'   "$REPO_ROOT"
    printf '  "workdir": "%s",\n'     "$AGENT_WORKDIR"
    printf '  "gh_user": "%s",\n'     "$gh_user"
    printf '  "fork": {\n'
    printf '    "owner": "%s",\n'     "$fork_owner"
    printf '    "repo": "%s"\n'       "$fork_repo"
    printf '  },\n'
    printf '  "tools": {\n'
    printf '    "git": "%s",\n'      "$(git --version 2>/dev/null | awk '{print $3}')"
    printf '    "gh": "%s",\n'       "$(gh --version 2>/dev/null | head -n1 | awk '{print $3}')"
    printf '    "python": "%s",\n'   "$(if py_cmd="$(resolve_python 2>/dev/null)"; then "$py_cmd" --version 2>&1 | awk '{print $2}'; fi)"
    printf '    "jq": "%s"\n'        "$(jq --version 2>/dev/null | sed 's/^jq-//')"
    printf '  }\n'
    printf '}\n'
} > "$env_file"

printf '\nenv.json written: %s\n' "$env_file"
printf 'Setup complete.\n'
