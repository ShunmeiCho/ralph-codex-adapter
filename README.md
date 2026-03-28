# Ralph for Codex

Codex CLI adapter for the Ralph iterative coding workflow.

It is based on the upstream Ralph workflow from `snarktank/ralph`, but replaces the runner with a Codex-oriented `codex exec` loop.

## What It Does

Ralph's core idea is simple: each implementation pass runs in a fresh AI context, while long-term state lives on disk.

This adapter preserves that model for Codex by using:

- `prd.json` as the task list
- `progress.txt` as append-only iteration memory
- `git` history as durable implementation history
- `codex exec` as the fresh-context runner for each iteration

## Included Files

- `ralph-codex.sh` — non-interactive loop runner using `codex exec`
- `CODEX.md` — per-iteration prompt template for Codex
- `prd.json.example` — example Ralph task file

## Prerequisites

- A working `codex` CLI installation
- Valid Codex authentication on the machine
- `jq` installed
- A git repository for the project you want Ralph to work on
- A `prd.json` file in Ralph format

## Installation

Option 1: call the script directly

```bash
chmod +x ralph-codex.sh
./ralph-codex.sh --help
```

Option 2: put it on your `PATH`

```bash
chmod +x ralph-codex.sh
ln -s "$(pwd)/ralph-codex.sh" ~/.local/bin/ralph-codex
```

## Quick Start

1. Create a PRD markdown file for your feature.
2. Convert it into `prd.json` using your Ralph-compatible PRD workflow.
3. Put `prd.json` in the project directory you want the loop to operate on.
4. Run a dry run first.
5. Start the loop.

```bash
ralph-codex --state-dir /path/to/project --dry-run 3
ralph-codex --state-dir /path/to/project 10
```

If you are already in the target project directory:

```bash
cp prd.json.example ./prd.json
ralph-codex 10
```

## Usage

```bash
ralph-codex 10
```

Or point it at a specific state directory:

```bash
ralph-codex --state-dir /path/to/project 10
```

Useful flags:

- `--profile strict` to use a Codex config profile
- `--model gpt-5.4` to force a model
- `--skip-git-repo-check` to allow non-standard working layouts
- `--dangerous` to bypass approvals and sandboxing when you have an external sandbox and know what you are doing

## State Files

The runner expects these files in the state directory:

- `prd.json`
- `progress.txt` (created automatically if missing)

It also creates:

- `.ralph/.last-branch`
- `.ralph/archive/...`
- `.ralph/last-message.txt`

## Iteration Flow

For each loop iteration, the runner:

1. Starts a fresh `codex exec` process
2. Feeds it the Codex-specific Ralph prompt from `CODEX.md`
3. Lets Codex pick the highest-priority unfinished story
4. Expects Codex to implement one story, run checks, commit, update `prd.json`, and append to `progress.txt`
5. Detects completion if the final message contains `<promise>COMPLETE</promise>`

## Example `prd.json`

See [prd.json.example](./prd.json.example) for a minimal valid example.

## Notes and Limitations

- This runner uses `codex exec`, so each iteration starts with a fresh Codex instance.
- Completion is detected by the final message containing `<promise>COMPLETE</promise>`.
- By default it uses `workspace-write` sandboxing.
- You need a working `codex` CLI installation and authentication on the machine where you run it.
- This repository adapts the Ralph loop only. It does not bundle the full upstream Ralph repo.
- End-to-end execution still depends on your local Codex environment, network access, and repository-specific checks.

## Relationship to Upstream Ralph

- Upstream project: `snarktank/ralph`
- Upstream runner supports Amp and Claude Code
- This repository replaces only the loop runner and prompt template so the workflow can target Codex

## License

MIT. See [LICENSE](./LICENSE).
