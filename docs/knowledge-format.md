# Knowledge format

## Purpose and status

This repository uses a deliberately reduced, OKF-inspired convention for
documentation in an ordinary software repository. It is not an LLM wiki or a
portable knowledge bundle, and this policy does not claim Open Knowledge Format
(OKF) conformance or an OKF version.

OKF is currently a
[version 0.1 draft](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#open-knowledge-format-okf)
aimed at knowledge that people and agents can author, consume, and exchange.
Treat its upstream specification as the evolving authority; link to it rather
than copying its rules into this repository.

## Local convention

Borrow these useful properties:

- Write human- and agent-readable Markdown or AsciiDoc that remains easy to
  review as a Git diff, reflecting OKF's
  [readability and diffability goals](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#1-motivation).
- Express relationships with explicit standard links (`[label](path)` in
  Markdown; `xref:path[label]` or `link:path[label]` in AsciiDoc) and enough
  surrounding prose to explain the relationship, as in
  [OKF cross-linking](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#5-cross-linking).
- Use `README.md` or `README.adoc` as the index for a documentation directory
  when an index helps readers discover its contents before opening individual
  files. This is the local equivalent of OKF's
  [progressive-disclosure index](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#6-index-files).
- Cite external sources for claims that depend on them, using ordinary links
  near the claim or a compact citations section. OKF likewise treats
  [citations as supporting links](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#8-citations).

AsciiDoc is not an exception to the convention: it follows the same
discoverability, progressive-disclosure, and citation rules as Markdown, using
native AsciiDoc syntax. Use ordinary repository-relative targets such as
`../README.md`, `xref:../guide/README.adoc[]`, or `link:../SKILL.md[]`. Do not
use OKF's leading-slash, bundle-relative link convention.

## Deliberate omissions

Do not add mandatory YAML frontmatter or a required `type`; those are OKF
[concept-document requirements](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#41-frontmatter),
not requirements for this repository. Do not reserve `index.md` or `log.md` or
assign them OKF semantics; upstream defines those names specially for
[bundle indexes and update logs](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#31-reserved-filenames).
Do not describe this repository as an OKF bundle, conformant implementation, or
versioned OKF producer; upstream defines those concepts for
[interoperable bundles](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md#9-conformance).

Reevaluate this policy if a future consumer needs an exchangeable knowledge
catalog. At that point, assess the then-current upstream specification and adopt
its bundle, metadata, reserved-file, conformance, and versioning rules together.
