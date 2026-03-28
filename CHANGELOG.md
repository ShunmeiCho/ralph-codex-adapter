# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [0.1.0] - 2026-03-29

### Added

- Initial `ralph-codex.sh` loop runner for Codex CLI
- Codex-specific prompt template in `CODEX.md`
- Minimal `prd.json.example` for bootstrapping tasks
- Project documentation in `README.md`
- `CONTRIBUTING.md` with contribution and validation guidance
- MIT `LICENSE`
- GitHub Actions workflow for `bash -n` and `--dry-run` validation

### Notes

- This is the first public release of the Codex adaptation layer for the upstream Ralph workflow
- The adapter preserves Ralph's `prd.json` and `progress.txt` task-state model while replacing the execution engine with `codex exec`
