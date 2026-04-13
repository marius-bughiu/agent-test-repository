#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd gh; require_cmd jq; require_cmd git
require_gh_auth; require_fork

target="$AGENT_FORK_OWNER/$AGENT_FORK_REPO"
gh api --method PATCH "repos/$target" -f allow_squash_merge=true >/dev/null 2>&1 || true

clone_fork
branch="$(push_pr_branch squash)"

# Add a second commit before opening the PR.
echo second > second.txt
git add second.txt
git commit -q -m "Second commit"
git push -q origin "$branch"

pr_num="$(open_pr_on_fork "$branch" "$(artifact_name pr-squash)")"

subject="$(artifact_name squash-subject)"
gh pr merge --repo "$target" "$pr_num" --squash --delete-branch --subject "$subject" >/dev/null \
    || fail "squash merge failed (fork may disallow squash)"

state="$(gh pr view --repo "$target" "$pr_num" --json state --jq .state)"
assert_eq "$state" "MERGED" "PR state"

# Verify the merge commit on main has the expected subject.
head_subj="$(gh api "repos/$target/commits/main" --jq .commit.message | head -n1)"
assert_eq "$head_subj" "$subject" "squash commit subject"
pass
