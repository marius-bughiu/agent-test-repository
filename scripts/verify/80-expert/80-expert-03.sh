#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../../lib/common.sh"
trap_sandbox_cleanup

require_cmd git
require_cmd gpg

# Find a usable signing key already in the user's keyring. We do NOT generate
# one, because adding a key to the user's ring is intrusive.
key="$(gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '/^sec/ {print $5; exit}')"
[ -n "$key" ] || skip "no secret GPG key available in the user's keyring"

setup_sandbox

git config user.signingkey "$key"
git config commit.gpgsign true
git config user.email "$(gpg --list-keys --with-colons "$key" 2>/dev/null | awk -F: '/^uid/ {gsub(/.*<|>.*/, "", $10); print $10; exit}')" || true
# fallback if the above produced nothing sensible
[ -n "$(git config user.email)" ] || git config user.email "agent-test@example.invalid"

echo hello > hello.txt
git add hello.txt
if ! git commit -q -m "Signed commit"; then
    skip "GPG signing failed (key may require a passphrase with no agent)"
fi

flag="$(git log -1 --pretty=%G?)"
case "$flag" in
    G|U) : ;;
    *) fail "unexpected %G? flag: '$flag' (expected G or U)" ;;
esac

if ! git verify-commit HEAD >/dev/null 2>&1; then
    fail "git verify-commit HEAD failed"
fi
pass
