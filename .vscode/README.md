# Editor integration

VS Code workspace settings that keep the editor in sync with the same rules
`pre-commit` enforces at commit time. See [`/AGENTS.md`](../AGENTS.md) for the
overall architecture.

## The files

| File              | Purpose                                                                                                                                                                                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `settings.json`   | Wires live linting to `.config/` sources (e.g. `markdownlint.config` `extends` [`.config/markdownlint.jsonc`](../.config/markdownlint.jsonc)) so editor and commit agree. Deliberately tooling-only — no personal prefs (theme, fonts). |
| `extensions.json` | Recommended extensions so the linters that run at commit also surface live in the editor. VS Code prompts contributors to install these on open.                                                                                        |

## Why settings.json is tracked but scoped

`.gitignore` keeps the rest of `.vscode/` ignored (so personal workspace state
doesn't leak into commits) while explicitly tracking `settings.json` and
`extensions.json`. Keep that split: personal preferences go in the user's own
VS Code profile, not here.
