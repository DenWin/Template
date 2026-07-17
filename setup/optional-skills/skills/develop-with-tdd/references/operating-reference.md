# TDD operating reference

Read this reference when explaining, reviewing, or adapting the skill's policy. Ordinary TDD cycles use `SKILL.md` directly.

## Guidance strength

- **Definition:** shared meaning required for correct interpretation.
- **Default:** preferred action unless repository evidence or explicit requirements justify another choice.
- **Heuristic:** diagnostic prompt rather than a compliance rule.
- **Project decision:** choice governed by the repository, team, regulatory context, or user.

Apply explicit requirements and repository-wide conventions before defaults. Ask for a decision only when requirements and repository evidence cannot resolve a material product, compatibility, oracle, observation-boundary, or architecture choice.

## Conceptual boundaries

- **Definition:** TDD interleaves executable behavioral evidence, implementation, and design improvement. Its immediate value is feedback during design; retained tests later provide regression evidence.
- **Definition:** Test-first timing, test level, and execution cadence are separate dimensions. TDD does not imply unit-only tests or one universal suite speed.
- **Definition:** An observation boundary is the interface through which a test supplies inputs and observes outcomes.
- **Definition:** A seam is a place where behavior or a dependency can be varied. A seam may make a boundary controllable, but the terms are not synonyms.
- **Definition:** Testability is the ability to control relevant inputs and observe relevant outcomes. Mockability is one technique, not the objective.
- **Definition:** Coverage records execution. It does not establish oracle strength, requirement completeness, fault detection, or design quality.
- **Definition:** Characterization records current behavior. It does not approve that behavior as correct or desirable.

## Why the cycle gates matter

- **Observed Red** demonstrates that the test can detect the missing or defective behavior. A claimed or inferred Red supplies no evidence of sensitivity.
- **Minimal coherent Green** limits the number of decisions made without feedback. It does not require deliberately poor code.
- **Refactoring under Green** separates structural decisions from behavioral decisions so regressions remain attributable.
- **One closed cycle at a time** keeps failures local and recent enough to diagnose.

These mechanisms reduce uncertainty; they do not make either the implementation or its tests infallible.

## Evidence decisions

- **Default:** Select evidence from the risk and question it must answer, not from source-file, method, test-count, or coverage targets.
- **Default:** Prefer a stable focused boundary for domain rules and transformations when it faithfully exposes the risk.
- **Default:** Use real integration semantics for framework wiring, database behavior, serialization, deployment configuration, and cross-service behavior when substitutes could change the outcome.
- **Default:** Derive oracles independently through domain examples, known literals, properties, trusted references, metamorphic relations, models, or reviewed baselines.
- **Heuristic:** A test that breaks under behavior-preserving restructuring may be observing decomposition rather than behavior.
- **Project decision:** Accessibility, security, performance, resilience, privacy, concurrency, safety, operability, and probabilistic behavior require evidence appropriate to their risk and representative environment.

## Bound the claims

TDD supplies local feedback; it does not replace product discovery, architecture, code review, exploratory testing, static analysis, integration evidence, delivery verification, or production monitoring. Its effect depends on task, practitioner experience, test design, codebase, and comparison baseline.

BDD, ATDD, and Specification by Example may improve the behavior and examples entering the cycle. They complement TDD rather than changing every test into an acceptance scenario.

## Preserve project authority

Treat these as project decisions:

- classicist/sociable versus London/mockist collaboration style;
- published compatibility and migration policy;
- production-like environments and acceptable substitutes;
- required structural coverage or regulatory evidence;
- test tags, lane definitions, CI gates, and release criteria.

Recommend changes when evidence shows a problem; do not silently replace repository-wide policy inside a feature change.
