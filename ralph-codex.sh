#!/usr/bin/env bash
# Ralph loop runner for Codex CLI
# Usage: ralph-codex.sh [options] [max_iterations]

set -euo pipefail

CODEX_BIN="${CODEX_BIN:-codex}"
SANDBOX_MODE="workspace-write"
MAX_ITERATIONS=10
MODEL=""
PROFILE=""
STATE_DIR="${PWD}"
PROMPT_FILE=""
SLEEP_SECONDS=2
DRY_RUN=0
SKIP_GIT_REPO_CHECK=0
DANGEROUS=0

usage() {
  cat <<'EOF'
Usage: ralph-codex.sh [options] [max_iterations]

Options:
  --state-dir DIR        Directory containing prd.json and progress.txt (default: current directory)
  --prompt-file FILE     Prompt template to feed into codex exec
  --sandbox MODE         Codex sandbox mode (default: workspace-write)
  --model MODEL          Override Codex model
  --profile PROFILE      Use a Codex config profile
  --codex-bin PATH       Path to codex executable
  --sleep SECONDS        Delay between iterations (default: 2)
  --skip-git-repo-check  Pass through to codex exec
  --dangerous            Use --dangerously-bypass-approvals-and-sandbox
  --dry-run              Print resolved configuration and exit
  -h, --help             Show this help

Examples:
  ralph-codex.sh 10
  ralph-codex.sh --state-dir /repo/path --profile strict 5
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --state-dir)
      STATE_DIR="$2"
      shift 2
      ;;
    --prompt-file)
      PROMPT_FILE="$2"
      shift 2
      ;;
    --sandbox)
      SANDBOX_MODE="$2"
      shift 2
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --codex-bin)
      CODEX_BIN="$2"
      shift 2
      ;;
    --sleep)
      SLEEP_SECONDS="$2"
      shift 2
      ;;
    --skip-git-repo-check)
      SKIP_GIT_REPO_CHECK=1
      shift
      ;;
    --dangerous)
      DANGEROUS=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
        shift
      else
        echo "Error: unknown argument '$1'" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$(cd "$STATE_DIR" && pwd)"
PROMPT_FILE="${PROMPT_FILE:-$SCRIPT_DIR/CODEX.md}"
PRD_FILE="$STATE_DIR/prd.json"
PROGRESS_FILE="$STATE_DIR/progress.txt"
RALPH_DIR="$STATE_DIR/.ralph"
ARCHIVE_DIR="$RALPH_DIR/archive"
LAST_BRANCH_FILE="$RALPH_DIR/.last-branch"
LAST_MESSAGE_FILE="$RALPH_DIR/last-message.txt"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

require_cmd "$CODEX_BIN"
require_cmd jq

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

if [[ ! -f "$PRD_FILE" ]]; then
  echo "Error: missing $PRD_FILE" >&2
  exit 1
fi

mkdir -p "$RALPH_DIR" "$ARCHIVE_DIR"

if [[ "$DRY_RUN" -eq 1 ]]; then
  cat <<EOF
ralph-codex.sh dry run
  CODEX_BIN=$CODEX_BIN
  STATE_DIR=$STATE_DIR
  PROMPT_FILE=$PROMPT_FILE
  PRD_FILE=$PRD_FILE
  PROGRESS_FILE=$PROGRESS_FILE
  SANDBOX_MODE=$SANDBOX_MODE
  MODEL=${MODEL:-<default>}
  PROFILE=${PROFILE:-<default>}
  MAX_ITERATIONS=$MAX_ITERATIONS
  SKIP_GIT_REPO_CHECK=$SKIP_GIT_REPO_CHECK
  DANGEROUS=$DANGEROUS
EOF
  exit 0
fi

archive_previous_run_if_needed() {
  if [[ -f "$PRD_FILE" && -f "$LAST_BRANCH_FILE" ]]; then
    local current_branch last_branch date folder_name archive_folder
    current_branch="$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || true)"
    last_branch="$(cat "$LAST_BRANCH_FILE" 2>/dev/null || true)"

    if [[ -n "$current_branch" && -n "$last_branch" && "$current_branch" != "$last_branch" ]]; then
      date="$(date +%Y-%m-%d)"
      folder_name="${last_branch#ralph/}"
      archive_folder="$ARCHIVE_DIR/$date-$folder_name"

      echo "Archiving previous run: $last_branch"
      mkdir -p "$archive_folder"
      [[ -f "$PRD_FILE" ]] && cp "$PRD_FILE" "$archive_folder/"
      [[ -f "$PROGRESS_FILE" ]] && cp "$PROGRESS_FILE" "$archive_folder/"
      echo "Archived to: $archive_folder"

      {
        echo "# Ralph Progress Log"
        echo "Started: $(date)"
        echo "---"
      } > "$PROGRESS_FILE"
    fi
  fi
}

track_current_branch() {
  local current_branch
  current_branch="$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || true)"
  if [[ -n "$current_branch" ]]; then
    printf '%s\n' "$current_branch" > "$LAST_BRANCH_FILE"
  fi
}

init_progress_file_if_missing() {
  if [[ ! -f "$PROGRESS_FILE" ]]; then
    {
      echo "# Ralph Progress Log"
      echo "Started: $(date)"
      echo "---"
    } > "$PROGRESS_FILE"
  fi
}

run_iteration() {
  local iteration="$1"
  local -a cmd
  local output last_message

  cmd=("$CODEX_BIN" exec "--cd" "$STATE_DIR" "--sandbox" "$SANDBOX_MODE" "--output-last-message" "$LAST_MESSAGE_FILE")

  if [[ -n "$MODEL" ]]; then
    cmd+=("--model" "$MODEL")
  fi
  if [[ -n "$PROFILE" ]]; then
    cmd+=("--profile" "$PROFILE")
  fi
  if [[ "$SKIP_GIT_REPO_CHECK" -eq 1 ]]; then
    cmd+=("--skip-git-repo-check")
  fi
  if [[ "$DANGEROUS" -eq 1 ]]; then
    cmd+=("--dangerously-bypass-approvals-and-sandbox")
  fi

  echo
  echo "==============================================================="
  echo "  Ralph Iteration $iteration of $MAX_ITERATIONS (codex)"
  echo "==============================================================="

  rm -f "$LAST_MESSAGE_FILE"
  output="$("${cmd[@]}" < "$PROMPT_FILE" 2>&1 | tee /dev/stderr)" || true
  last_message="$(cat "$LAST_MESSAGE_FILE" 2>/dev/null || true)"

  if [[ "$last_message" == *"<promise>COMPLETE</promise>"* ]] || [[ "$output" == *"<promise>COMPLETE</promise>"* ]]; then
    echo
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $iteration of $MAX_ITERATIONS"
    return 0
  fi

  echo "Iteration $iteration complete. Continuing..."
  return 1
}

archive_previous_run_if_needed
track_current_branch
init_progress_file_if_missing

echo "Starting Ralph for Codex - Max iterations: $MAX_ITERATIONS"
echo "State directory: $STATE_DIR"

for i in $(seq 1 "$MAX_ITERATIONS"); do
  if run_iteration "$i"; then
    exit 0
  fi
  sleep "$SLEEP_SECONDS"
done

echo
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
