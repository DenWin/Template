# Claude Code

This repo's tooling architecture, conventions, and retrofit guide live in
[AGENTS.md](AGENTS.md) — read it first (imported below in full); it also
defines the TDD workflow and where the bundled skill lives.

@AGENTS.md

## Model delegation (Claude Code)

Reserve the lead model (Fable/Opus) for reasoning-heavy work: architecture,
debugging, code review, and anything touching `.pre-commit-config.yaml`
semantics or policy rules. Delegate the following **named task types** to
cheaper models via the Task tool instead of doing them inline:

- **Git commits** → `committer` subagent (haiku, defined in
  `.claude/agents/committer.md`). The lead model writes the commit message
  and passes it plus the explicit file list in the delegation prompt; the
  subagent only stages and commits.
- **PR descriptions / `gh pr create`** → general-purpose subagent,
  `model: sonnet`. Must fill every section of
  `.github/pull_request_template.md`, including Evidence.
- **Log, CI-output, and test-failure scans** → Explore or general-purpose
  subagent, `model: haiku`. Return conclusions, not dumps.
- **Boilerplate** (README stubs, config skeletons, test scaffolds) →
  general-purpose subagent, `model: sonnet`.
- **Web recon / research summaries** → general-purpose subagent,
  `model: haiku` (sonnet when synthesis across sources is needed).
- **Lint/test runs and triage** (`pre-commit run --all-files`, test
  suites) → general-purpose subagent, `model: haiku`. Report failures
  verbatim; fix nothing.
- **`gh` chores** (file issues, set labels, post comments) →
  general-purpose subagent, `model: haiku`, executing lead-authored text.
- **Doc drafts** (AsciiDoc/README skeletons from a lead-provided outline)
  → general-purpose subagent, `model: sonnet`.
- **Codebase recon** ("where is X handled?") → Explore subagent,
  `model: haiku`.
- **Dependency/changelog scans** → general-purpose subagent,
  `model: haiku`.

In every case the lead model authors, the delegate executes: pass finished
text, outlines, or file lists in the delegation prompt — never delegate the
judgment itself. Delegate only these named task types — not by a vague
"this looks simple" judgment. Never delegate cross-file refactors or edits
to hook/policy configuration.

### Creating a new delegate mid-task

When a delegable pattern emerges that the list above doesn't cover:

1. **One-off** → no file. Spawn a general-purpose or Explore subagent with
   the `model:` parameter and a tight, self-contained prompt. Works
   immediately in any session.
2. **Recurring** → write `.claude/agents/<name>.md` (frontmatter: `name`,
   `description`, `tools`, `model`; body follows the lead-authors,
   delegate-executes pattern) and add its task type to the list above.
   Claude Code hot-reloads agent files within seconds, so it is invocable
   from the next delegation — no restart.
3. **Fallback — restart required** only if `.claude/agents/` did not exist
   at session start (first agent in a fresh repo) or the session runs with
   `--disable-slash-commands`: write the agent file anyway, write a
   handoff (decisions made, open items, next step), then stop and tell the
   user to start a new session and send "continue".
