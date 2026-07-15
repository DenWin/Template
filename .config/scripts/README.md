# Linting & testing scripts

The shared work bodies that `pre-commit` **and** CI invoke — one copy, run both
places. This is the "same script, both places" contract: the custom checks that
have no native pre-commit backend live here as pwsh scripts, wired in
[`.pre-commit-config.yaml`](../../.pre-commit-config.yaml) as `repo: local`
hooks. See [`/AGENTS.md`](../../AGENTS.md) for the overall architecture.

## Contract

Every script is `#Requires -Version 7.0` and:

- **Fails fast** with an actionable hint if a dependency (module, gem) is
  missing — it never self-installs. Bootstrapping is explicit (see below).
- **No-ops cleanly** (exit 0) when handed nothing to check — "not present" is a
  valid result, not a failure.
- Takes the file list pre-commit passes (or a lane), so local and CI behave
  identically.

## Naming

Approved PowerShell Verb-Noun. The verb encodes the role:

- **`Test-*`** *verifies* (lint → pass/fail): `Test-PowerShellScript`, `Test-AsciiDoc`.
- **`Invoke-*`** *executes* (runs a suite): `Invoke-TestLane`.

| Script                          | Role                               | Runs                     |
| ------------------------------- | ---------------------------------- | ------------------------ |
| `Initialize-DevEnvironment.ps1` | one-time local setup               | manually, once per clone |
| `Test-PowerShellScript.ps1`     | PSScriptAnalyzer over passed files | commit + CI              |
| `Test-AsciiDoc.ps1`             | asciidoctor syntax validation      | commit + CI              |
| `Invoke-TestLane.ps1`           | Pester by `-Lane`                  | commit / push / CI       |

## Test lanes

Lanes are execution **cadences**, not test types. A test opts into a lane via a
Pester **`-Tag`** (`Fast` / `Standard` / `Thorough`), assigned by measured
cost/risk — *not* by a unit/integration label.

| Lane     | Tag        | Git stage    | When                    |
| -------- | ---------- | ------------ | ----------------------- |
| Fast     | `Fast`     | `pre-commit` | every commit (live)     |
| Standard | `Standard` | `pre-push`   | every push (dormant)    |
| Thorough | `Thorough` | manual / CI  | merge/release (dormant) |

`Invoke-TestLane.ps1 -Lane <lane>` runs the tagged `*.Tests.ps1` and no-ops when
there are none. Standard/thorough hooks ship **commented-in-place** in the
pre-commit config — uncomment when you have tests for them.

Keep the fast (commit) lane genuinely fast, or contributors reach for
`--no-verify`. The floor is pwsh + Pester warm-up (~1-3s), not your assertions.

## Onboarding

Run once after cloning:

```pwsh
pwsh -NoProfile -File .config/scripts/Initialize-DevEnvironment.ps1
```

Installs pre-commit's git hooks and the pwsh modules the local hooks need
(PSScriptAnalyzer, Pester). Idempotent. `-UpdateHooks` also runs
`pre-commit autoupdate`. Activation is **not** automatic on clone — git won't run
setup from a fresh clone, by design.

> **Windows: don't run elevated.** If VS Code / your terminal runs *as admin*,
> new temp dirs are owned by `BUILTIN\Administrators` and Git for Windows can't
> `git init` in them — pre-commit fails to fetch hooks (`cannot mkdir …: File
> exists`). Run non-elevated; the bootstrap warns you if it detects admin.
