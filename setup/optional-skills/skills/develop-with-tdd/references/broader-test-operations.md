# Broader-test operations

Read this reference when adding or maintaining component, integration, contract, acceptance, E2E, smoke, or scheduled tests.

Broader tests earn their cost only when their environment and diagnostics preserve a trustworthy signal.

## Choose fidelity from the risk

- Use the production engine when provider semantics are the behavior under test.
- Use realistic protocol adapters when serialization or compatibility is the risk.
- Use a fake when its differences cannot affect the asserted behavior.
- Record which production properties the environment intentionally does not represent.

“More real” is not automatically better. Fidelity is valuable only along dimensions that can change the outcome.

## Own state

- Give each test deterministic setup and cleanup.
- Prefer unique data, transactional rollback, disposable resources, or isolated namespaces.
- Keep tests independent of execution order.
- Parallelize only when state ownership supports it; serial execution can conceal missing isolation.

## Produce failure evidence

A remote failure should include enough evidence to diagnose without rerunning blindly:

- assertion and relevant domain inputs;
- application and dependency logs scoped to the test;
- request/response or message correlation identifiers;
- browser trace, screenshot, and console/network errors for UI paths;
- environment and version metadata when compatibility matters.

Capture sensitive data safely and retain artifacts for an explicit period.

## Handle flakiness as a defect

Confirm a suspected flake through repetition or controlled reproduction. Classify its source: shared state, timing, environment, nondeterminism, infrastructure, or an unstable oracle.

Quarantine only to restore suite signal. Record owner, reason, issue, expiry, and repair path. A quarantined test without ownership is a silently deleted test.

Track flaky-test rate and repair time. Do not normalize rerunning until green as verification.

## Operate consumer-driven contracts

A complete contract lifecycle includes:

1. consumer interaction generation from behavior the consumer actually uses;
2. explicit provider states that arrange required preconditions;
3. provider verification against the real provider interface;
4. contract publication and version association;
5. compatibility checks before release or deployment.

Schema conformance and consumer-driven contracts answer different questions. A schema validates allowed shape; a consumer contract verifies that an exercised interaction remains supported.

Neither proves the provider’s full business correctness or deployed network path.

## Keep E2E narrow

E2E means an external path across the assembled system. Its entry point may be a browser, API, CLI, message, or protocol.

Keep critical paths and unique deployment risks at E2E. Move domain partitions to cheaper focused tests and infrastructure edge cases to integration tests.
