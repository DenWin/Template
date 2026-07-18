# TDD documentation and skill assessment brief

Use this brief when asking an AI agent to review the TDD knowledge base and the
`develop-with-tdd` skill.

The goal is not a generic writing review. The goal is to determine whether the
guide teaches the intended TDD practice clearly, and whether the skill applies
that practice reliably while changing code.

## Review targets

Assess these targets in this order:

1. `knowledge/tdd/guide/`
2. `knowledge/tdd/research-findings.md`
3. `knowledge/tdd/traceability.md`
4. `skills/develop-with-tdd/`

Treat the guide as the human teaching authority.

Treat the skill as an execution artifact that should operationalize the same
doctrine without needing to load the full guide at runtime.

## Intended audience

The human guide must work for:

- beginners who do not yet know why TDD exists;
- practitioners who have used tests but may not have used TDD deliberately;
- skeptics who associate TDD with dogma, slow tests, brittle mocks, or coverage
  theater;
- developers working in both greenfield and legacy code.

Do not assess the guide as if every reader already understands test levels,
mocks, characterization tests, BDD, CI, or refactoring constraints.

## Core doctrine to preserve

The material should teach TDD as a fast-feedback design discipline, not as a
coverage ritual.

The central rule is:

> Prefer the shortest trustworthy feedback loop that faithfully exercises the
> current risk.

The review should preserve these ideas:

- coverage is a by-product and diagnostic signal, not the primary goal;
- the first value of TDD is thinking about desired behavior before
  implementation;
- a TDD cycle clarifies a contract, produces a small design decision, and leaves
  executable regression evidence behind;
- feedback speed includes relevance, fidelity, repeatability, diagnostic value,
  and decision timing, not only runtime;
- test level and execution cadence are related but independent;
- a slower faithful test can be better than a fast irrelevant test;
- BDD, ATDD, and Specification by Example are related practices, not simple
  replacements or synonyms for TDD;
- legacy work may need characterization, minimal behavior-preserving seams, and
  smaller entry strategies before normal TDD becomes possible.

## Required review questions

Answer these questions with concrete file or section references:

1. Does the guide have a clear learning journey from "why TDD" to "how to
   practise it" to "how to adapt it without dogma"?
2. Are important terms introduced before the text relies on them?
3. Does the guide explain why Red matters, including why an AI agent must not
   infer that a test would fail?
4. Does the guide distinguish Red, Green, Refactor, characterization, pure
   refactoring, exploration, and intentional contract changes?
5. Does it explain feedback lanes clearly enough for a team to choose fast,
   standard, and thorough suites?
6. Does it cover focused, integration, contract, acceptance, and E2E evidence
   without implying one universal test pyramid?
7. Does it address common misconceptions and failure modes without turning into
   a defensive rant?
8. Does it help both greenfield and legacy development?
9. Does the skill preserve the same invariants as the guide?
10. Are any examples misleading, incomplete, over-fitted, or too abstract for a
    beginner?

## Skill-specific checks

When reviewing `skills/develop-with-tdd/`, check whether it instructs an AI
agent to:

- establish a known baseline before attributing failures;
- choose the shortest trustworthy evidence for the current risk;
- write or revise evidence before implementing new or corrected behavior;
- run and observe a meaningful Red instead of assuming Red;
- distinguish harness, compile, environment, and behavior failures;
- reach Green without weakening the test or changing the agreed contract;
- refactor only under passing evidence;
- report what was run, what was omitted, and what uncertainty remains;
- use nonstandard branches honestly, such as characterization-first legacy work,
  pure refactor, exploration without an oracle, or intentional contract change.

Also check whether references are loaded conditionally. The skill should stay
compact by default and use deeper references only when the task needs them.

## Output format for an AI reviewer

Use this structure:

1. Findings by severity
2. Missing or underdeveloped angles
3. Skill and guide synchronization issues
4. Suggested concrete edits
5. Residual risks or open questions

For each finding, include:

- location;
- why it matters;
- suggested correction.

Avoid vague praise. A clean assessment should still mention residual risks,
scope limits, and the strongest remaining objections.

## Non-goals

Do not require the guide to become a complete testing textbook.

Do not add every adjacent practice into the core learning path. Security,
accessibility, performance, compliance, observability, mutation testing, and
formal methods belong in adjacent or appendix material unless they directly
change the TDD practice being taught.

Do not optimize the skill for maximum coverage. Optimize it for trustworthy,
timely evidence while preserving the Red-Green-Refactor discipline.
