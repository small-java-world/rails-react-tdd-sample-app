#!/usr/bin/env bash
set -euo pipefail

# Run official /kairo-tasks then post-process with jscpd and template insertion

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

echo "[kairo-tasks-with-jscpd] Running /kairo-tasks"
claude -p "/kairo-tasks" | cat
echo "[kairo-tasks-with-jscpd] /kairo-tasks finished"

# Run jscpd only (see CLAUDE.md for guidance)
if [ -d "$repo_root/frontend" ]; then
  echo "[kairo-tasks-with-jscpd] Running jscpd (frontend + backend)"
  ( cd "$repo_root/frontend" && npm run -s dup ) || true
  echo "[kairo-tasks-with-jscpd] Generating jscpd HTML report"
  ( cd "$repo_root/frontend" && npm run -s dup:report ) || true
fi

echo "[kairo-tasks-with-jscpd] Done"


