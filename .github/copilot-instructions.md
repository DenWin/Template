# Copilot repository instructions

These instructions apply to both Copilot CLI and GitHub Copilot.

## Lead vs delegate contract

The lead/default Copilot agent owns requirements, architecture, debugging,
review conclusions, and any changes to hook/policy configuration. Delegates
execute bounded tasks only.

### Named delegation categories

- **Git commits** → `committer` custom agent (`.github/agents/committer.md`).
  The lead provides the exact commit message and exact file list.
- **Read-only reconnaissance** (for example, "where is X handled?") → use a
  read-only subagent approach (built-in `explore` or equivalent).
- **Independent lint/test lanes** → use one command-focused subagent per lane
  when the lanes can run independently.
- **Boilerplate drafts** (README/config/test scaffolds) → delegate drafting;
  the lead verifies and finalizes.
- **Research summaries** (docs/web/repo research) → delegate collection and
  summarization; the lead owns synthesis decisions.
- **Mechanical GitHub chores** (issues, labels, comments) → delegate execution
  of lead-authored text only; do not delegate scope/readiness decisions.

Do not delegate cross-file refactors or final merge/readiness judgment.

## Model selection policy across Copilot surfaces

Repository custom agents do **not** pin a `model` field right now. They inherit
the caller's/default model so behavior is consistent between Copilot CLI and
GitHub Copilot without assuming feature parity.

If a future custom agent pins a model:

1. Validate explicit model support in both Copilot CLI and GitHub Copilot.
2. Document the approved fallback behavior in this file and `.github/README.md`.
3. On model unavailability, fail fast with a visible error and choose the
   documented fallback explicitly — never rely on silent escalation.
