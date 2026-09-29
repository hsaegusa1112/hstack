---
name: commit
description: Commit work in any repo in the GitHub workspace following conventional commits — when the user asks to commit, checkpoint, or land changes. Covers message format, staging discipline, and what never goes in.
---

# Commit

Only when explicitly asked — never auto-commit, and never push unless asked.

## Message format — conventional commits

```text
<type>: <summary>
<blank line>
[optional body — why, not what; wrap at 72]
[optional footers]
```

- **Types**: `feat` `fix` `perf` `revert` change behavior; `docs` `chore` `refactor` `test` `ci` `style` don't.
- **Summary**: imperative mood, lowercase, no trailing period, ≤ 72 chars. This workspace's history uses plain `type: summary` without scope — match the repo you're in (add `(scope)` only if its history already does).
- **Breaking changes**: `!` before the colon (`feat!:`) plus a `BREAKING CHANGE: <explanation>` footer.
- **Body**: explain the _why_, wrap at 72, separate from the summary by a blank line. One logical change per commit — split mixed work into multiple commits.

## Procedure

1. `git status` + `git diff` (+ `git diff --staged`) — read what's actually there before writing the message. The message describes the real diff, not the intent.
2. Stage deliberately — `git add <specific files>`, never a blind `git add -A`.
3. Verify first: run the repo's gate before committing (see the repo's skills — e.g. portal: `npm run lint && npm run format:check && npm run build`). Don't commit a red gate.
4. Commit with a heredoc so the message formats correctly:

```bash
git commit -m "$(cat <<'EOF'
type: summary

Optional body.
EOF
)"
```

5. Confirm with `git log --oneline -3` / `git show --stat HEAD`.

## Never goes in

- Env files, secrets, tokens (`.env*` and friends — even if `git add -f` would allow it).
- Generated/local artifacts (`node_modules`, `.next`, build caches, editor state).
- Harness debris or unrelated files swept in with the change — commit only what the change needs.

## Guardrails

- No `--no-verify`, no `--amend` of pushed commits, no force-push — unless explicitly asked.
- On a worktree branch (`type/slug`), commit freely; the branch is the checkpoint. Main gets commits only via the repo's merge flow (e.g. GitLab MR).
- Agent-created commits end with the `Co-Authored-By: Claude Code <noreply@anthropic.com>` trailer per the harness attribution rule.
