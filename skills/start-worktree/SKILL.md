---
name: start-worktree
description: Workspace-wide convention for starting any new work in ~/Documents/GitHub — branch naming, sibling worktree, VSCode workspace. Use at the start of any feature, fix, chore, or docs change in any repo in this workspace.
---

# Start work in the GitHub workspace

## Branch — `type/slug`

Match the repo's existing history: `feat/…`, `fix/…`, `chore/…`, `docs/…`. Commits use the same vocabulary — `type: summary` — and happen freely on the worktree branch unless the human states otherwise.

## Worktree — sibling folder, never nested

The VSCode workspace is the multi-root `~/Documents/GitHub` folder and only sees **depth-1** folders, so worktrees live as siblings of the main checkout — never inside `.claude/worktrees/`:

```bash
cd ~/Documents/GitHub/<repo>
git worktree add ../<repo>-<slug> -b <type>/<slug>
```

Do NOT `code --add` the new worktree to the workspace — the GitHub folder is already the workspace root, so the sibling appears in the Explorer automatically. Adding it as a root too makes it show up twice. (Remove existing duplicates with right-click → Remove Folder from Workspace; files stay on disk.)

## Per-worktree setup

Dependencies are NOT shared between worktrees — install in the new one (`npm install`, `mvn …`). Gitignored env files (`.env.local`, …) need copying from the main checkout.

Repo-specific workflows (env, run, verify, landing) live in each repo's own skills — e.g. `ledger-admin-portal`'s `start-feature`.
