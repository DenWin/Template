# Optional tooling overlays

Overlays are the add-when-relevant shelf: deliberately inert tooling and
decision records that do not run until a maintainer activates them. Read an
overlay's own instructions before copying its hook fragment; not every overlay
has the same shape.

| Overlay                                 | State                | What it contains                                      |
| --------------------------------------- | -------------------- | ----------------------------------------------------- |
| [`vale/`](vale/README.md)               | Complete, inert      | Vale config, vocabulary, and a pre-commit fragment    |
| [`semgrep/`](semgrep/README.md)         | Complete, inert      | Local-rule activation and a pre-commit fragment       |
| [`semgrep-pro/`](semgrep-pro/README.md) | Decision record only | Current product/licensing trade-offs; no active rules |

Activation is a repository decision: copy or enable only the mechanisms that
match the target repository's languages and risk. Keeping an overlay complete
but inactive avoids broken placeholder checks while preserving a reviewed path
to adoption.
