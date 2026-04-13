#!/usr/bin/env bash
# Cleans up GitHub artifacts and local sandboxes created by the test suite.
#
# Safely removes only resources tagged with the 'agent-test' label or the
# 'agent-test-' prefix, so it cannot accidentally nuke unrelated state.
#
# Usage:
#   scripts/cleanup.sh                 # clean local sandbox + fork artifacts
#   scripts/cleanup.sh --local-only    # only delete local sandbox
#   scripts/cleanup.sh --remote-only   # only delete remote artifacts
#   scripts/cleanup.sh --dry-run       # list what would be deleted

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

LOCAL=1
REMOTE=1
DRY_RUN=0

while [ $# -gt 0 ]; do
    case "$1" in
        --local-only)  REMOTE=0; shift ;;
        --remote-only) LOCAL=0;  shift ;;
        --dry-run)     DRY_RUN=1; shift ;;
        -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) printf 'unknown arg: %s\n' "$1" >&2; exit 1 ;;
    esac
done

do_cmd() {
    if [ "$DRY_RUN" = 1 ]; then
        printf '[dry-run] %s\n' "$*"
    else
        printf '[run]     %s\n' "$*"
        eval "$@"
    fi
}

# ---------------------------------------------------------------------------
# Local: sandbox directories
# ---------------------------------------------------------------------------

if [ "$LOCAL" = 1 ]; then
    printf '== Local cleanup ==\n'
    if [ -d "$AGENT_WORKDIR" ]; then
        for d in "$AGENT_WORKDIR"/sbx-*; do
            [ -e "$d" ] || continue
            do_cmd "rm -rf '$d'"
        done
    fi
    # Ephemeral artifacts in repo root
    for f in "$REPO_ROOT/results.json" "$REPO_ROOT/scorecard.json"; do
        [ -e "$f" ] || continue
        do_cmd "rm -f '$f'"
    done
    printf '\n'
fi

# ---------------------------------------------------------------------------
# Remote: issues, PRs, branches, releases, gists
# ---------------------------------------------------------------------------

if [ "$REMOTE" = 1 ]; then
    printf '== Remote cleanup ==\n'
    if ! command -v gh >/dev/null 2>&1; then
        printf '  gh not installed; skipping remote cleanup\n'
    elif ! gh auth status >/dev/null 2>&1; then
        printf '  gh not authenticated; skipping remote cleanup\n'
    elif [ ! -f "$AGENT_WORKDIR/env.json" ]; then
        printf '  env.json missing; run scripts/setup.sh first\n'
    else
        if ! command -v jq >/dev/null 2>&1; then
            printf '  jq not installed; skipping remote cleanup\n'
        else
            owner="$(jq -r '.fork.owner // empty' "$AGENT_WORKDIR/env.json")"
            repo="$(jq -r '.fork.repo  // empty' "$AGENT_WORKDIR/env.json")"
            if [ -z "$owner" ] || [ -z "$repo" ]; then
                printf '  fork not configured in env.json; skipping remote cleanup\n'
            else
                target="$owner/$repo"
                printf '  target: %s\n' "$target"

                # Close issues matching 'agent-test-*' title or label.
                printf '  -- issues --\n'
                for num in $(gh issue list --repo "$target" --state open --search 'agent-test in:title' --json number --jq '.[].number' 2>/dev/null); do
                    do_cmd "gh issue close --repo '$target' '$num' --comment 'closed by agent-test cleanup'"
                done
                for num in $(gh issue list --repo "$target" --state open --label 'agent-test' --json number --jq '.[].number' 2>/dev/null); do
                    do_cmd "gh issue close --repo '$target' '$num' --comment 'closed by agent-test cleanup'"
                done

                # Close PRs matching 'agent-test-*' title or label.
                printf '  -- PRs --\n'
                for num in $(gh pr list --repo "$target" --state open --search 'agent-test in:title' --json number --jq '.[].number' 2>/dev/null); do
                    do_cmd "gh pr close --repo '$target' '$num' --delete-branch --comment 'closed by agent-test cleanup'"
                done

                # Delete remote branches matching agent-test-*.
                printf '  -- branches --\n'
                for br in $(gh api "repos/$target/branches" --jq '.[].name' 2>/dev/null | grep -E '^agent-test-' || true); do
                    do_cmd "gh api --method DELETE 'repos/$target/git/refs/heads/$br'"
                done

                # Delete releases matching agent-test-*.
                printf '  -- releases --\n'
                for tag in $(gh release list --repo "$target" --limit 200 --json tagName --jq '.[] | .tagName' 2>/dev/null | grep -E '^agent-test-' || true); do
                    do_cmd "gh release delete --repo '$target' '$tag' --cleanup-tag --yes"
                done

                # Delete gists tagged with agent-test in their description.
                printf '  -- gists --\n'
                for gid in $(gh gist list --limit 200 --json id,description --jq '.[] | select(.description | test("agent-test")) | .id' 2>/dev/null || true); do
                    do_cmd "gh gist delete '$gid'"
                done
            fi
        fi
    fi
fi

printf '\nCleanup complete.\n'
