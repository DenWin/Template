# Glossary

This glossary defines terms as used in this documentation. Communities use some terms differently, especially “unit,” “mock,” “acceptance test,” and “contract test.”

## Acceptance test

A test of a stakeholder-visible capability against agreed examples or criteria. It may cross several technical components without exercising a production deployment.

## Approval test

A test that captures complex output, asks a person to review it, then compares later output with the approved baseline.

## ATDD

**Acceptance Test-Driven Development.** A collaborative practice in which acceptance examples are clarified before implementation and used to guide development.

## BDD

**Behavior-Driven Development.** Practices emphasizing behavior in domain language, outside-in discovery, concrete examples, and collaboration. Gherkin is optional.

## Behavior

An outcome a caller can observe under stated conditions. Behavior concerns what a system does at a chosen boundary rather than how its internals are arranged.

## Characterization test

A test that records what existing code currently does so it can be changed more safely. It does not imply that every captured behavior is desirable.

## Classicist TDD

A style that runs real owned collaborators together and uses doubles mainly at slow, nondeterministic, or external boundaries. Also called Detroit-style or sociable TDD.

## Component test

A test of a deployable or cohesive subsystem through its supported boundary, usually with external systems replaced or controlled. Its scope is broader than one focused rule.

## Composition root

The application startup location where concrete dependencies are constructed and connected. Keeping construction there can leave behavior code easier to control and observe.

## Consumer-driven contract test

A contract-testing workflow in which consumers publish the interactions they rely on and providers verify those interactions against their implementation.

## Continuous integration

The practice of integrating changes frequently and verifying the combined state automatically. It extends local feedback into feedback about the shared codebase.

## Contract

An agreement about observable inputs, outputs, errors, or interactions at a boundary. A contract may be published between systems or internal to one codebase.

## Contract test

A test of compatibility at a boundary between independently changing parties. Consumer-driven contract testing is one form; schema and protocol conformance are others.

## Coverage

A structural measure reporting which statements, branches, conditions, or paths executed. It does not show by itself that results were asserted or requirements were complete.

## Double-loop TDD

A development pattern in which an outer acceptance example gives a capability its destination while faster inner Red–Green–Refactor cycles develop the required parts.

## Dummy

A test double passed to satisfy an interface but not used by the behavior under test.

## E2E test

An **end-to-end test** that observes a deployed or fully assembled path. It can reveal wiring and configuration failures but is usually slower and harder to diagnose.

## Executable example

A concrete input, action, and expected outcome represented so a tool can evaluate it repeatedly. A TDD test begins as an executable example of desired behavior.

## Fake

A working implementation used in testing that takes shortcuts unsuitable for production, such as an in-memory repository with simplified semantics.

## Fake It

A TDD strategy that uses a narrow result when the general implementation is unclear. Later examples can require generalization; refactoring may only change structure.

## Fast feedback lane

The smallest project-defined checks used during Red, Green, and refactoring. Membership depends on measured feedback value, not on a test-level label.

## Feedback lane

A project-defined group of checks selected by cost, reliability, environment, and risk. This documentation uses fast/local, standard/change-validation, and thorough/system-validation lanes.

## Feedback time

The time from making a change to receiving a trustworthy diagnosis that can guide the next decision. It includes execution, setup, queuing, and investigation.

## Flaky test

A test that can pass and fail against the same relevant code because of uncontrolled state, timing, environment, concurrency, infrastructure, or nondeterminism.

## Focused test

A test at a narrow coherent behavior boundary, usually selected for diagnostic feedback. It may involve several functions or classes and is not guaranteed to be fast.

## Gherkin

A structured scenario language commonly using `Feature`, `Scenario`, `Given`, `When`, and `Then`. Using Gherkin does not by itself constitute BDD.

## Given–When–Then

A way to structure an example as relevant starting conditions, one triggering event, and observable outcomes.

## Golden master

A reviewed output retained as the comparison baseline for an approval or characterization test.

## Green

The phase in which production code is changed until the current example and relevant existing tests pass for the intended reason.

## Green integrity

The rule that Green is reached through a valid production change, not by weakening the oracle, skipping the test, swallowing failures, or silently changing the contract.

## Integration test

A test that exercises real collaboration between components or infrastructure, such as application code with the production database engine.

## Mock

A test double with interaction expectations. Terminology varies by framework; this documentation distinguishes mocks from stubs and spies by built-in expectations.

## Mockist TDD

A style that uses interaction expectations to discover collaborator roles from the outside in. Also called London-style or solitary TDD.

## Mutation testing

A technique that changes production code in selected ways and runs the suite to see whether tests detect those changes.

## Observation boundary

The interface through which a test supplies inputs and observes outcomes. It may be a function, component, API, message contract, command, or user interface.

## Obvious Implementation

A TDD strategy that writes the straightforward general implementation directly when the correct change is already clear.

## Oracle

The source of truth used to decide whether an outcome is acceptable. Examples include agreed literals, domain examples, invariants, trusted references, and reviewed baselines.

## Property-based testing

A technique that generates inputs to check general invariants and often shrinks a failure to a simpler counterexample.

## Red

The phase in which an executable example is observed failing because the intended behavior is absent or incorrect.

This documentation treats compile and missing-symbol failures as intermediate Red states. When practical, continue until the behavioral expectation itself fails.

## Red–Green–Refactor

The recurring cycle: demonstrate one missing behavior, make it work, then improve structure without changing the demonstrated behavior.

## Refactor

Change the internal structure of code without intentionally changing observable behavior. An intended contract change is not refactoring.

## Regression

A previously working and still-required behavior that stops working after a change.

## Seam

A place where behavior or a dependency can be varied without editing the code at that point. Seams can make a legacy observation boundary controllable.

## Smoke test

A small test of basic operability after deployment or in a production-like environment. It is intentionally shallow and fast.

## Snapshot test

A baseline comparison that stores serialized or rendered output. It provides useful evidence only when changes are reviewed deliberately.

## Specification by Example

A collaborative practice that discovers and documents requirements through concrete examples, often retaining them as living specifications.

## Standard feedback lane

The project-defined checks used to validate the affected area before handoff or integration. It may contain focused, component, integration, and contract evidence.

## Spy

A test double that supplies behavior and records interactions for later assertions.

## Stub

A test double that returns controlled values or outcomes needed by the code under test.

## Succession problem

The problem of choosing and ordering examples so each provides useful information for the next implementation or design decision.

## TDD

**Test-Driven Development.** A workflow that develops one observable behavior at a time through Red–Green–Refactor cycles.

## Test-after

Writing a test after the relevant production behavior exists. The test may verify and document behavior but did not influence the preceding implementation decision.

## Test double

Any substitute used in place of a real collaborator during a test. Dummies, stubs, spies, mocks, and fakes serve different purposes.

## Test-first

Expressing intended behavior as an executable example before implementing it. Test-first enables early feedback but does not guarantee a useful test.

## Test fidelity

How faithfully a check exercises the semantics relevant to the current risk. Scope and fidelity are related but separate dimensions.

## Test pyramid

A portfolio heuristic favoring many narrow tests, fewer integration tests, and very few E2E tests because feedback cost often increases with scope.

## Test trophy

A portfolio heuristic emphasizing integration tests for applications whose main risks lie in component and framework collaboration.

## Three Amigos

A collaborative example-discovery practice involving product or domain, development, and testing perspectives.

## Thorough feedback lane

The broadest relevant project-defined checks, often including costly or environment-dependent evidence before merge, release, or deployment.

## Triangulation

A TDD strategy that adds a contrasting example when one example does not justify a useful general rule. The contrast creates pressure to generalize.

## Unit test

A test of a coherent unit of behavior at a narrow boundary. It is often fast, but “unit” does not determine cadence or mean exactly one method or class.

## Verschlimmbesserung

A German term for a change intended as an improvement that makes the result worse. Retained regression tests can expose this outcome for covered behavior.

## Walking skeleton

The thinnest end-to-end implementation proving that a new system’s build, test, delivery, and runtime parts connect. It is a provisional architecture probe.
