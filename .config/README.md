# Configuration

Tool configuration for the repo, kept out of root. See [`/AGENTS.md`](../AGENTS.md)
for the overall architecture; the mechanisms documented elsewhere:

- Linting & testing scripts → [`scripts/README.md`](scripts/README.md)
- CI workflows → [`../.github/README.md`](../.github/README.md)
- Editor integration → [`../.vscode/README.md`](../.vscode/README.md)
- Opt-in tooling → [`overlays/README.md`](overlays/README.md)

## Why configs live here

To keep root lean. Only files a tool *forces* to root stay there:
`.pre-commit-config.yaml`, `.editorconfig`, `.gitattributes`, `.gitignore`,
`.claudeignore`. Everything else is pointed at explicitly (e.g. yamllint runs
with `-c .config/yamllint.yaml`).

## The config files

| File                            | Consumed by                         | Notes                                    |
| ------------------------------- | ----------------------------------- | ---------------------------------------- |
| `yamllint.yaml`                 | yamllint hook (`-c`)                | migrated from root `.yamllint`           |
| `markdownlint.jsonc`            | CLI **and** editor (`extends`)      | the shared markdown rules                |
| `markdownlint-cli2.jsonc`       | markdownlint-cli2 hook (`--config`) | CLI wrapper: custom table rule + `--fix` |
| `PSScriptAnalyzerSettings.psd1` | `Test-PowerShellScript.ps1`         | severity gate + rule tuning              |

### Markdown: rules vs formatting

The markdown rules are factored into `markdownlint.jsonc` so both the CLI config
*and* [`../.vscode/settings.json`](../.vscode/settings.json) `extends` them —
editor and commit stay in agreement.

- **Emphasis stays asterisk** (`MD049`/`MD050`). The table formatter only
  touches tables, never emphasis.
- **Tables auto-align** via `markdownlint-rule-table-format` on `--fix`
  (`MD060: aligned`). Parser-based, so tables inside code fences are left alone.
  It's a single-maintainer third-party rule — worth watching its upkeep.

### PowerShell

`PSScriptAnalyzerSettings.psd1` gates on `Warning` + `Error`. Suppress specific
noisy rules via `ExcludeRules` rather than dropping a whole severity.
