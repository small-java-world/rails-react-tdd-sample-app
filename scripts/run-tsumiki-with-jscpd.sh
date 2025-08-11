#!/usr/bin/env bash
set -euo pipefail

print_usage() {
  cat <<'USAGE'
Usage: run-tsumiki-with-jscpd.sh -c "/kairo-tasks" [options]

Options:
  -c, --command       Slash command to run (e.g., "/kairo-tasks") [required]
  -r, --report        Generate jscpd HTML report
  -T, --skip-template Skip inserting jscpd/how-to + Cursor review templates
  -t, --tasks-file    Target tasks file path (defaults to latest under docs/tasks)
  -o, --open          Open outputs (tasks file, jscpd report) after run
  -h, --help          Show this help
USAGE
}

COMMAND=""
REPORT=0
SKIP_TEMPLATE=0
TASKS_FILE=""
OPEN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--command)
      COMMAND=${2-}
      shift 2 || { echo "Missing value for $1"; exit 1; }
      ;;
    -r|--report)
      REPORT=1; shift ;;
    -T|--skip-template)
      SKIP_TEMPLATE=1; shift ;;
    -t|--tasks-file)
      TASKS_FILE=${2-}
      shift 2 || { echo "Missing value for $1"; exit 1; }
      ;;
    -o|--open)
      OPEN=1; shift ;;
    -h|--help)
      print_usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage; exit 1 ;;
  esac
done

if [[ -z "$COMMAND" ]]; then
  echo "--command is required" >&2
  print_usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[run] Running tsumiki command: $COMMAND"
claude -p "$COMMAND" | cat
echo "[run] tsumiki command finished"

# Insert templates (jscpd section + Cursor review templates)
if [[ $SKIP_TEMPLATE -eq 0 ]]; then
  ADD_PS="$REPO_ROOT/scripts/add-cursor-review-template.ps1"
  if [[ -f "$ADD_PS" ]]; then
    if command -v pwsh >/dev/null 2>&1; then
      if [[ -n "$TASKS_FILE" ]]; then
        pwsh -NoLogo -NoProfile -File "$ADD_PS" -Path "$TASKS_FILE" || true
      else
        pwsh -NoLogo -NoProfile -File "$ADD_PS" || true
      fi
    elif command -v powershell >/dev/null 2>&1; then
      if [[ -n "$TASKS_FILE" ]]; then
        powershell -NoLogo -NoProfile -File "$ADD_PS" -Path "$TASKS_FILE" || true
      else
        powershell -NoLogo -NoProfile -File "$ADD_PS" || true
      fi
    else
      echo "[warn] PowerShell not found; skipping template insertion" >&2
    fi
  else
    echo "[warn] Script not found: $ADD_PS" >&2
  fi
fi

# Run jscpd via frontend npm scripts
FRONTEND_DIR="$REPO_ROOT/frontend"
if [[ -d "$FRONTEND_DIR" ]]; then
  echo "[run] Running jscpd (npm run dup)"
  ( cd "$FRONTEND_DIR" && npm run -s dup ) || true
  if [[ $REPORT -eq 1 ]]; then
    echo "[run] Generating jscpd report (npm run dup:report)"
    ( cd "$FRONTEND_DIR" && npm run -s dup:report ) || true
  fi
else
  echo "[warn] frontend directory not found: $FRONTEND_DIR" >&2
fi

open_path() {
  local p="$1"
  if [[ ! -f "$p" && ! -d "$p" ]]; then return; fi
  if command -v xdg-open >/dev/null 2>&1; then xdg-open "$p" >/dev/null 2>&1 & return; fi
  if command -v open >/dev/null 2>&1; then open "$p" >/dev/null 2>&1 & return; fi
  if command -v cmd >/dev/null 2>&1; then cmd.exe /C start "" "$(cygpath -w "$p" 2>/dev/null || echo "$p")" >/dev/null 2>&1 & return; fi
}

if [[ $OPEN -eq 1 ]]; then
  # Try resolve latest tasks file if not specified
  if [[ -z "$TASKS_FILE" ]]; then
    if compgen -G "$REPO_ROOT/docs/tasks/*-tasks.md" > /dev/null; then
      TASKS_FILE=$(ls -1t "$REPO_ROOT"/docs/tasks/*-tasks.md | head -n1 || true)
    fi
  fi
  if [[ -n "${TASKS_FILE:-}" ]]; then open_path "$TASKS_FILE"; fi
  REPORT_HTML="$REPO_ROOT/reports/jscpd/html/index.html"
  if [[ -f "$REPORT_HTML" ]]; then open_path "$REPORT_HTML"; fi
fi

echo "[run] Done"


