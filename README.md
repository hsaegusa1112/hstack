# hstack

my personal skills stack, adapted from [pstack](https://github.com/cursor/plugins/tree/master/pstack) (poteto's Cursor plugin, MIT). the infra is the same: a mode skill that routes tasks through playbooks. the playbooks, skills, and extensions are mine.

**the flow:** select `/h-mode`, state the task, and the mode matches it to a playbook, copies the playbook's steps in verbatim as its first todolist items, then routes to the other skills as the steps need them.

## install

```bash
git clone <this-repo> ~/Documents/GitHub/hstack
cd ~/Documents/GitHub/hstack
bash install.sh
```

`install.sh` symlinks every skill in `skills/` into `~/.claude/skills/` and every agent in `agents/` into `~/.claude/agents/`. the repo stays the source of truth; edits here are live immediately. re-run after adding a skill.

## what ships

- **`/h-mode`** — the entry point. non-negotiables, 23 indexed engineering principles, autonomy rules, subagent defaults, reply and comment rules, and the playbook routing table. sticky: stays on across turns until you opt out.
- **playbooks** (in `skills/h-mode/playbooks/`): investigation, bug-fix, feature, refactoring, prototype, plus `opening-a-pr` which every other playbook ends with.
- **principles** (`principle-*`, verbatim from pstack): laziness-protocol, prove-it-works, fix-root-causes, subtract-before-you-add, and friends. one rule each.
- **routed skills**: how, why, architect, unslop, tdd, blast-radius, figure-it-out, show-me-your-work, reflect, technical-writing, no-comments, update-docs, typescript-best-practices.
- **agents**: `h-agent` (the subagent form of h-mode), `comment-sicko` (read-only comment reviewer used by /no-comments).
- **absorbed personal skills**: commit, start-worktree, ledger-e2e, bro.
- **`/agentmap`** — live map of local listeners → worktree/service/health, with collision warnings.

dropped from pstack on purpose: the multi-model panel skills (arena, swarm, interrogate) and `/setup-pstack`'s model-rule layer. models are set per agent in `agents/*.md` frontmatter.

## extend it

**add a playbook:** drop a new `.md` in `skills/h-mode/playbooks/`, then add one line to the routing table in `skills/h-mode/SKILL.md` under `## Playbooks`:

```
- **Name.** One line for when it applies. `playbooks/name.md`.
```

**add a skill:** new directory under `skills/<name>/SKILL.md`, then `bash install.sh`.

**no playbook fits:** `/h-mode` routes to `figure-it-out`, which designs a bespoke playbook for the task. if the design keeps working, promote it to a playbook file.

**pull upstream improvements:** the verbatim dirs (principles, routed skills) can be re-copied from a fresh sparse clone of `cursor/plugins`. the divergence lives in `skills/h-mode/` and this README.

## license

MIT. upstream pstack is by Lauren Tan; the copyright notice is preserved in [LICENSE](./LICENSE).
