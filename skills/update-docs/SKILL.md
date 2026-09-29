---
name: update-docs
description: "Update README, docs, changelogs, and config comments after a behavior change so docs never drift. Use after a feature, fix, refactor with a visible interface, or config change, before opening a PR, or when asked to update docs."
disable-model-invocation: true
---

# Update docs

Docs drift is silent. Every behavior change leaves a doc surface stale unless someone checks. This skill is that check.

## When

Run after completing a feature, fix, interface-changing refactor, config change, or new repo. Run before Opening a PR. Skip for pure internal cleanup with no observable surface change, and record one line saying why.

## Steps

1. Inventory the doc surfaces the change touches. Top-level and subpackage READMEs, `docs/`, CHANGELOG, config file comments (`values.yaml`, `.env.example`, Makefile help text), and AGENTS.md or CLAUDE.md when agent-facing behavior changed. Grep for the symbols the change renamed, removed, or rebehaved, and read every doc hit.
2. Diff what each surface claims against what the code now does. The code is the source of truth, not the old docs. A claim that is now wrong gets corrected. A claim that is now incomplete gets the smallest addition that closes the gap.
3. Write per the **technical-writing** skill, then apply **unslop**. Prefer editing an existing sentence over adding a new one. Match the surrounding doc's structure before introducing a new section.
4. Prove the docs are true. Re-read each edited claim next to the code and check every name, flag, path, and default value against the real artifact. A wrong path in docs is worse than a missing one.
5. Report the surfaces updated, the claims corrected, and the surfaces checked with no change needed.

**Reply:** files updated, what drifted, what was checked and clean.
