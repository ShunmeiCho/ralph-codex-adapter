# Contributing

Thanks for contributing to `ralph-codex-adapter`.

This repository is intentionally small. The goal is to keep the Codex adaptation easy to understand, easy to test, and close in spirit to the upstream Ralph workflow.

## Scope

Good contributions include:

- Improving `ralph-codex.sh`
- Tightening the Codex prompt in `CODEX.md`
- Improving documentation and examples
- Making state handling safer or more predictable
- Adding small compatibility improvements for Codex CLI behavior

Please avoid turning this repository into a full fork of upstream Ralph unless the change is directly needed for Codex support.

## Development Setup

Prerequisites:

- `bash`
- `jq`
- `git`
- `codex` CLI installed and authenticated

Clone the repo and run:

```bash
bash -n ralph-codex.sh
./ralph-codex.sh --help
mkdir -p /tmp/ralph-codex-dev
cp prd.json.example /tmp/ralph-codex-dev/prd.json
./ralph-codex.sh --state-dir /tmp/ralph-codex-dev --dry-run 2
```

## Repository Structure

- `ralph-codex.sh` — loop runner
- `CODEX.md` — Codex iteration prompt
- `prd.json.example` — minimal example state file
- `README.md` — usage and project overview

## Contribution Guidelines

Keep changes:

- Focused
- Backward-compatible where practical
- Easy to review
- Consistent with the existing shell style

Prefer:

- Small functions
- Explicit flags over hidden behavior
- Conservative defaults
- Clear logging

## Validation Expectations

Before opening a PR, at minimum:

```bash
bash -n ralph-codex.sh
./ralph-codex.sh --help
./ralph-codex.sh --state-dir /tmp/ralph-codex-dev --dry-run 2
```

If you change iteration behavior, include a short note in the PR describing:

- What changed
- Why it changed
- How you validated it
- Any limitations you could not fully test

## Commits and Pull Requests

Use clear commit messages. Conventional commit style is preferred:

- `feat:`
- `fix:`
- `docs:`
- `refactor:`
- `test:`

PRs should include:

- A short summary
- The motivation
- Validation steps
- Any known limitations or follow-up work

## Relationship to Upstream

This repository is derived from the ideas and workflow of `snarktank/ralph`, but it is not intended to replace the upstream project.

When possible:

- Keep task-state concepts compatible with upstream Ralph
- Keep the Codex-specific changes isolated to the runner and prompt
- Document intentional divergences clearly
