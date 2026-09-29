#!/usr/bin/env bash
# Link hstack skills and agents into Claude Code's user dirs.
# Idempotent: re-runs only refresh the symlinks. The repo stays the source of truth.
set -euo pipefail
cd "$(dirname "$0")"

SKILLS_DIR="${HOME}/.claude/skills"
AGENTS_DIR="${HOME}/.claude/agents"

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

for skill_dir in skills/*/; do
  name="$(basename "$skill_dir")"
  ln -sfn "${PWD}/${skill_dir%/}" "${SKILLS_DIR}/${name}"
  echo "linked ${SKILLS_DIR}/${name}"
done

for agent_file in agents/*.md; do
  name="$(basename "$agent_file")"
  ln -sfn "${PWD}/${agent_file}" "${AGENTS_DIR}/${name}"
  echo "linked ${AGENTS_DIR}/${name}"
done
