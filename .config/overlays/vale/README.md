# Vale overlay (opt-in prose linting)

Vale is **not** part of the base template. It lints *prose* (spelling, word
choice, style) in Markdown and AsciiDoc — a different layer from markdownlint
(structure) and asciidoctor (syntax). It is opinionated and noisy by default,
so it lives here as an inert overlay you enable only where prose quality
matters (published docs, a handbook).

Nothing in this folder runs until you activate it.

## Activate

1. **Install Vale** — <https://vale.sh/docs/vale-cli/installation/>
2. **Fetch styles** (downloads the `Packages` from `vale.ini`):

   ```pwsh
   vale sync --config .config/overlays/vale/vale.ini
   ```

3. **Wire the hook** — paste the block from [`precommit-hook.yaml`](precommit-hook.yaml)
   into the `repos:` list of [`/.pre-commit-config.yaml`](../../../.pre-commit-config.yaml),
   then `pre-commit autoupdate` to pin `rev`.

## Tune

- `vale.ini` — alert level, style packages, per-format `BasedOnStyles`.
- `styles/config/vocabularies/Base/accept.txt` — terms Vale should not flag
  (product names, jargon). One term (or regex) per line.

## Why an overlay, not a placeholder

A half-configured Vale *errors* (missing `StylesPath`/packages). Keeping it
inert-but-complete means it never breaks a repo that ignores it, yet activation
is ~3 steps. Same pattern applies to any "might-not-need-it" tool.
