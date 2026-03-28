# Ralph Agent Instructions for Codex

You are Codex running non-interactively on a software project.

## Your Task

1. Read `prd.json` in the current working directory.
2. Read `progress.txt` and check the `Codebase Patterns` section first.
3. Check the target branch from `prd.json.branchName`. If needed, create or switch to it from the repository's mainline branch.
4. Pick the highest-priority user story where `passes: false`.
5. Implement that single user story only.
6. Run the project's relevant quality checks such as typecheck, lint, and tests.
7. Update nearby `AGENTS.md` files only if you discover reusable knowledge that future work should preserve.
8. If checks pass, commit all changes with message: `feat: [Story ID] - [Story Title]`.
9. Update `prd.json` to set `passes: true` for the completed story.
10. Append your progress to `progress.txt`.

## Progress Report Format

Append to `progress.txt` and never replace previous entries:

```markdown
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- Quality checks run and results
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

If you discover a reusable pattern, consolidate it near the top of `progress.txt` under:

```markdown
## Codebase Patterns
- Example: Use X for Y
- Example: Update Z whenever W changes
```

Only add patterns that are general and reusable.

## AGENTS.md Updates

Before committing, check whether any edited directories have an `AGENTS.md` file that should capture reusable knowledge:

- Module-specific API conventions
- Required companion changes in nearby files
- Testing expectations for that area
- Configuration gotchas

Do not add story-specific details or temporary debugging notes.

## Quality Requirements

- Do not commit broken code.
- Keep changes focused on one story.
- Follow existing code patterns.
- If a UI story changes frontend behavior, verify it in a browser when browser tooling is available.

## Failure Handling

- If you hit a blocker, record it in `progress.txt`.
- Do not mark `passes: true` unless implementation and checks really pass.
- If blocked, end without the completion marker so the next iteration can continue.

## Stop Condition

After completing one story, check whether all stories in `prd.json` now have `passes: true`.

If all stories are complete, your final line must be:

```text
<promise>COMPLETE</promise>
```

If there are still unfinished stories, end normally without that marker.

## Important

- Work on exactly one story per iteration.
- Read `progress.txt` before making decisions.
- Use Context7 or project docs if library or API details are needed.
