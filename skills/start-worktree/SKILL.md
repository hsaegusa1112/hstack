---
name: start-worktree
description: Workspace-wide convention for starting any new work in ~/Documents/GitHub — branch naming, sibling worktree, VSCode workspace. Use at the start of any feature, fix, chore, or docs change in any repo in this workspace.
---

# Start work in the GitHub workspace

## Branch — `type/slug`

Match the repo's existing history: `feat/…`, `fix/…`, `chore/…`, `docs/…`. Commits use the same vocabulary — `type: summary` — and happen only when explicitly asked.

## Worktree — sibling folder, never nested

The VSCode workspace is the multi-root `~/Documents/GitHub` folder and only sees **depth-1** folders, so worktrees live as siblings of the main checkout — never inside `.claude/worktrees/`:

```bash
cd ~/Documents/GitHub/<repo>
git worktree add ../<repo>-<slug> -b <type>/<slug>

# add it to the workspace (code is not on PATH by default)
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --add ~/Documents/GitHub/<repo>-<slug>
```

## Per-worktree setup

Dependencies are NOT shared between worktrees — install in the new one (`npm install`, `mvn …`). Gitignored env files (`.env.local`, …) need copying from the main checkout.

Repo-specific workflows (env, run, verify, landing) live in each repo's own skills — e.g. `ledger-admin-portal`'s `start-feature`.
