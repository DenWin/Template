---
name: changelog-entry
description: Add a notable-change entry to a repository's CHANGELOG.md, written for the affected audience. Use when the user wants the changelog updated for a change, or a changelog bootstrapped for a repo that has none.
---

# Changelog entry

Add a **notable**-change entry to a repository's `CHANGELOG.md`, written for
the **audience** it affects. The invariants below are non-negotiable; the
numbered steps are the process.

Read [examples](references/examples.md) for a worked model of the repository
type in front of you — application, library/API, or infrastructure — or for
the bootstrap and negative examples.

## Invariants

Hold these across every run:

- **Evidence, not subjects.** A commit subject says what the author typed; the
  diff says what changed — derive entries from the change itself, not the log.
- **Notable only.** Record what the **audience** would act on. Exclude
  internal refactors, formatting, test-only changes, and dependency churn —
  unless they change behavior, compatibility, security, or operator/developer
  experience.
- **Audience's perspective.** Each entry says what changed, who or what is
  affected when relevant, and why it matters or what to do.
- **Never invent.** No fabricated version, tag, date, release, or claimed
  impact. Unreleased work stays under `Unreleased`. When impact is genuinely
  unknown, ask.
- **Preserve the format.** Match the existing changelog's structure, category
  names, date format, link style, and line endings exactly.

## 1. Inspect

- Read repo guidance that governs docs: `AGENTS.md`, `CLAUDE.md`,
  `CONTRIBUTING*`, any changelog policy in a README.
- Read `CHANGELOG.md` in full — its category scheme, date format, link style,
  and where the newest entries go.
- Gather the change: `git diff`, `git log` for the range, the PR body, the
  linked issue.

Done when you know the repository's changelog convention (or its absence) and
hold the actual changed content.

## 2. Fix the format and target section

- **Convention exists** → follow it; format questions stop here.
- **No convention** → default to
  [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): `## [Unreleased]`
  on top, releases below in reverse chronological order; categories `Added`,
  `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security` (only those that
  apply); ISO dates on released sections only.

Done when the target format and the section to edit are fixed.

## 3. Select and place each notable change

- List candidates from the diff/commits/PR/issue; drop the non-notable.
- Identify the **audience** and write for it: application → end users;
  library/service/API → API consumers; infrastructure → operators; contributor
  tooling → contributors, only when the change materially affects the workflow.
  Technical language fits a developer audience; raw implementation detail never
  does — state the observable effect.
- Assign each entry a category. Make **breaking changes, removals,
  deprecations, migrations, and security fixes** unmistakable: state the break
  and the required action, never folded into a soft "Changed" line.

Done when every surviving candidate has an audience, a category, and a stated
reason it matters.

## 4. Write

- Reverse chronological; `Unreleased` by default.
- One item per change: specific, independently understandable, in the repo's
  format. Name the actual change — "various improvements" and "bug fixes" say
  nothing.
- Rewrite from the change's effect, not from the commit message.
- Before adding, scan for an overlapping entry and update that one instead of
  adding a second.

Done when the entries are in the file, in the repository's format, with no
duplicate covering the same change.

## 5. Show and validate

- Show the entry (or the diff) to the user.
- Run the repo's Markdown validation (this repo:
  `pre-commit run markdownlint-cli2 --files CHANGELOG.md`).
- Ask one focused question only when audience, release target, or user impact
  can't be determined from the repository — otherwise state your default and
  proceed.

Done when the entries are placed, the format is intact, Markdown validates, and
nothing was invented.

## Versioning and history

- No releases yet → everything stays under `Unreleased`.
- On release, use the repo's scheme; if none exists, SemVer for versioned
  packages/artifacts, date-based headings for continuously deployed products.
- Introducing a changelog mid-project: reconstruct history only from verifiable
  commits, tags, releases, and PRs. Never imply a historical version that never
  existed — group verified changes by date, or under a labeled `Pre-release
  development` section.

## Agent logging

Agent actions belong in commits, PRs, and issues — not a changelog. Create or
update `AGENT_CHANGELOG.md` only when repository instructions explicitly require
one.
