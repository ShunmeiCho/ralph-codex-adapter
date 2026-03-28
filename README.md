# Ralph for Codex

This package adapts the Ralph iteration loop for Codex CLI.

It is based on the upstream Ralph workflow from `snarktank/ralph`, but replaces the runner with a Codex-oriented `codex exec` loop.

## Files

- `ralph-codex.sh` — non-interactive loop runner using `codex exec`
- `CODEX.md` — per-iteration prompt template for Codex
- `prd.json.example` — example Ralph task file

## Usage

Run from a project directory containing `prd.json`:

```bash
ralph-codex 10
```

Or point it at a specific state directory:

```bash
ralph-codex --state-dir /path/to/project 10
```

## State Files

The runner expects these files in the state directory:

- `prd.json`
- `progress.txt` (created automatically if missing)

It also creates:

- `.ralph/.last-branch`
- `.ralph/archive/...`
- `.ralph/last-message.txt`

## Notes

- This runner uses `codex exec`, so each iteration starts with a fresh Codex instance.
- Completion is detected by the final message containing `<promise>COMPLETE</promise>`.
- By default it uses `workspace-write` sandboxing.
- You need a working `codex` CLI installation and authentication on the machine where you run it.
