# Editor integration

VS Code workspace wiring so the linters that gate commits also surface live in
the editor. See [`/AGENTS.md`](../AGENTS.md) for the overall architecture.

| File              | Purpose                                                 |
| ----------------- | ------------------------------------------------------- |
| `settings.json`   | tooling-only workspace settings, wired to `.config/`    |
| `extensions.json` | recommended extensions matching the commit-time linters |

## `settings.json` — same rules, live

Live markdown linting `extends` the same [`.config/markdownlint.jsonc`](../.config/markdownlint.jsonc)
the commit hook enforces — editor and commit never disagree. File endings and
final newlines honour `.editorconfig` intent for files VS Code creates.

`editor.formatOnSave` stays **off** by design: formatting is a commit concern
here (markdownlint `--fix`, shfmt), and an editor formatter would fight the
linters.

## `extensions.json` — surface the gate early

Recommends one extension per commit-time linter (EditorConfig, markdownlint,
YAML, PowerShell/PSScriptAnalyzer, AsciiDoc, shellcheck, shfmt) so problems
appear while typing, not first at commit. VS Code prompts contributors to
install them on open.

## Conventions

- Keep `settings.json` strictly about wiring linters to `.config/` — no
  personal preferences (theme, fonts). Extend it freely in a project, but keep
  the split.
- `.gitignore` tracks only the shipped files (`settings.json`,
  `extensions.json`, this README) and ignores everything else in `.vscode/`,
  so personal editor state never lands in the repo.
