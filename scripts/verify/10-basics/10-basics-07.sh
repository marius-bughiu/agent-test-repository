#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
setup_sandbox

printf 'DB_PASSWORD=abc\n' > secret.env
printf 'secret.env\n' > .gitignore
git add .gitignore
git commit -q -m "Ignore secrets"

# secret.env must not appear in status
status_out="$(git status --porcelain)"
case "$status_out" in
    *secret.env*) fail "secret.env appears in git status: $status_out" ;;
esac

git check-ignore secret.env >/dev/null || fail "git check-ignore did not match secret.env"

git ls-files --error-unmatch .gitignore >/dev/null || fail ".gitignore is not tracked"
pass
