# Agent setup

Everything an agent needs to be "ready" for this benchmark.

## Dependency matrix

| Tier                    | git | gh  | python | jq  | gpg | ssh-signing |
|-------------------------|:---:|:---:|:------:|:---:|:---:|:-----------:|
| 00-setup                |  ●  |  ●  |   ●    |  ●  |     |             |
| 10-basics               |  ●  |     |        |  ●  |     |             |
| 20-branching            |  ●  |     |        |  ●  |     |             |
| 30-remote               |  ●  |  ●  |        |  ●  |     |             |
| 40-github-issues        |  ●  |  ●  |        |  ●  |     |             |
| 50-github-prs           |  ●  |  ●  |        |  ●  |     |             |
| 60-conflicts            |  ●  |     |        |  ●  |     |             |
| 70-advanced-git         |  ●  |     |        |  ●  |     |             |
| 80-expert               |  ●  |  ●  |        |  ●  |  ○  |     ○       |
| 90-github-advanced      |  ●  |  ●  |   ●    |  ●  |     |             |

Legend: ● required · ○ required only for specific tests in the tier (others will run normally).

## GitHub authentication

All GitHub tests use the `gh` CLI, which in turn uses its own credential store. Agents must:

1. Run `gh auth login` once (or set `GH_TOKEN` / `GITHUB_TOKEN`).
2. Have the following token scopes: `repo`, `workflow`, `write:discussion`, `gist`.
3. Have pushed SSH/HTTPS credentials into the git credential helper (`gh auth setup-git` handles this).

Verify:

```bash
gh auth status
gh api user --jq .login     # prints your username
```

## Fork configuration

The scripts detect your fork by inspecting the `origin` remote. If you cloned as `gh repo fork --clone --remote`, this is automatic. If you set things up manually:

```bash
git remote add origin https://github.com/<you>/agent-test-repository.git
git remote add upstream https://github.com/<upstream-owner>/agent-test-repository.git
git remote -v        # confirm both are present
```

## Environment variables

Most settings come from `.agent-workdir/env.json` (written by `setup.sh`), but you can override:

| Variable                      | Default                     | Purpose                                     |
|-------------------------------|-----------------------------|---------------------------------------------|
| `AGENT_FORK_OWNER`            | auto-detect from origin     | Override the fork owner                     |
| `AGENT_FORK_REPO`             | auto-detect from origin     | Override the fork repo name                 |
| `AGENT_WORKDIR`               | `./.agent-workdir`          | Sandbox directory for throwaway repos       |
| `AGENT_TIMEOUT_DEFAULT`       | `120`                       | Per-test timeout (seconds)                  |
| `AGENT_SKIP_CLEANUP`          | `0`                         | Set to `1` to skip post-run cleanup         |
| `AGENT_VERBOSE`               | `0`                         | Set to `1` for verbose script logs          |

## Optional: signed commits

For tests `80-expert-03` (GPG) and `80-expert-04` (SSH signing):

- **GPG:** import a key (`gpg --import key.asc`), then `git config --global user.signingkey <KEYID>` and `git config --global commit.gpgsign true`.
- **SSH signing:** set `gpg.format ssh`, `user.signingkey` to an SSH key path, and an `allowed_signers` file. See git-scm's [SSH signing guide](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgformat).

If you don't have these, the relevant tests will be marked `skipped` — **your overall score is not penalized**.

## Optional: a disposable GitHub account

For repeated test runs, consider using a throwaway GitHub account so issue/PR noise stays off your primary profile. The `cleanup.sh` script handles teardown, but noisy notifications can be annoying.
