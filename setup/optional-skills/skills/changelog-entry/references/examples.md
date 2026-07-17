# Changelog entry examples

Worked models for each repository type, a bootstrap example, and negative
examples. All use the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
default; when a repository has its own convention, follow that instead.

The point of every example is the same: translate a raw change into an effect
on the repository's audience.

## Application / product (audience: end users)

Diff: scheduled CSV exports were built with the server's UTC clock; a config
field now carries the account timezone into the export job.

```markdown
## [Unreleased]

### Changed

- Scheduled exports now use the account timezone instead of the server clock,
  so daily reports arrive on the correct calendar day for accounts outside UTC.
```

Why it works: names the observable effect (reports on the right day) and who
is affected (non-UTC accounts). It does not mention the config field or the
job class — implementation the end user never sees.

## Developer library / API (audience: API consumers)

Diff: `parseDate()` gains a required `locale` parameter; calling it with one
argument no longer compiles.

```markdown
## [Unreleased]

### Changed

- **BREAKING:** `parseDate()` now requires a `locale` argument. Calls with a
  single argument no longer type-check. Pass the caller's locale, or
  `Locale.ROOT` to keep the previous behavior.

### Deprecated

- `parseDateLegacy()` is deprecated and will be removed in the next major
  release. Migrate to `parseDate(value, locale)`.
```

Why it works: technical language is correct because the audience is
developers, but the entry states the break and the exact migration action,
not the internal parser refactor that enabled it.

## Infrastructure / deployment (audience: operators)

Diff: Terraform module changes the default RDS instance class and enables
storage autoscaling.

```markdown
## [Unreleased]

### Changed

- Default database instance class raised from `db.t3.medium` to
  `db.r6g.large`. Applying this module to an existing environment triggers a
  replacement — schedule a maintenance window before upgrading.

### Added

- Storage autoscaling on the database (up to 500 GB), removing the manual
  disk-resize runbook step.
```

Why it works: written for whoever runs `terraform apply` — it flags the
destructive replacement and the required action (maintenance window), which a
raw "bump instance class" subject would hide.

## Bootstrap: repo with commits but no releases

A repository that has been developed for months with no tags introduces a
changelog. Reconstruct only from verifiable history and never imply releases
that never happened.

```markdown
# Changelog

Notable changes, following Keep a Changelog. No release has been tagged, so
current work sits under Unreleased and earlier history under Pre-release
development, grouped by commit date.

## [Unreleased]

### Added

- Retry with exponential backoff on the payment webhook handler.

## Pre-release development

No versions, tags, or releases existed before this changelog was introduced.
Entries below are reconstructed from commit and PR history, grouped by date.

### 2026-06-30

#### Added

- Initial REST API for orders and a Postgres-backed persistence layer.
```

Why it works: the audience-facing changes are grouped by verifiable date under
an honestly labeled section; no `1.0.0` heading is invented to make the
history look released.

## Negative examples — do NOT add an entry

These changes are not notable on their own. Skip them unless they change
behavior, compatibility, security, or operator/developer experience.

| Change                                                         | Why it is skipped                                                  |
| -------------------------------------------------------------- | ------------------------------------------------------------------ |
| Renamed a private helper `fetchData` → `loadData`              | No observable effect on any audience.                              |
| Reformatted files with Prettier / ran the linter               | Style only.                                                        |
| Added unit tests for existing behavior                         | No behavior change.                                                |
| Bumped a transitive dev dependency with no API/behavior change | Dependency churn.                                                  |
| "Various improvements and bug fixes"                           | Vague filler — banned outright; name the actual change or drop it. |

A dependency bump *does* earn an entry when it changes behavior, fixes a CVE
(→ `Security`), or alters a supported version — then say which, and why.
