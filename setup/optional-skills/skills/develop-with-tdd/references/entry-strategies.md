# TDD entry strategies

Read only the branch that matches the work. Return to the core Red-Green-Refactor workflow when the branch establishes a testable behavioral decision.

## Greenfield work

1. Inspect repository conventions and establish the smallest test harness needed for the first behavior.
2. If the principal uncertainty is deployment or cross-component wiring, build a walking skeleton: one minimal path through the intended architecture and delivery mechanism.
3. Treat that skeleton as a provisional architecture probe, not proof of business correctness.
4. Select one stakeholder-visible slice and drive its inner behavior through normal cycles.
5. Use an outer acceptance example only when it clarifies the slice. Keep unfinished outer evidence branch-local or explicitly outside required gates until the feature is expected to pass.

Do not design the complete test portfolio or architecture before the first useful slice.

## Defect correction

1. Establish the existing relevant baseline.
2. Reproduce the reported symptom at the narrowest boundary that still exercises the suspected risk.
3. Confirm that the failure is attributable to the defect rather than the fixture or environment.
4. Make the correction, run the reproducer, and run neighboring regression evidence.

If the symptom cannot be reproduced, gather stronger diagnostics or clarify the report before making a speculative production change.

## Intentional contract change

1. Identify which existing expectations describe the old contract and which behavior remains unaffected.
2. Revise an obsolete expectation or add a new one to express the requested contract.
3. Observe Red against the old production behavior.
4. Implement the new contract, preserve unaffected behavior, and update other public contract artifacts when required.

Changing a test is correct when the agreed behavior changed. Weakening a test to accommodate an unintended implementation change is not.

## Untested or fragile legacy code

1. Identify the exact change risk and behavior that must remain stable.
2. If no useful test can run, introduce the smallest behavior-preserving seam needed to control inputs or observe outcomes. Verify that preparatory edit with the best existing evidence and review available.
3. Add characterization evidence for behavior that must be preserved. Expect it to begin Green when it records current behavior.
4. Treat characterization as a record, not approval. Resolve whether questionable user-visible behavior is preserved or corrected.
5. Establish Red for the new or corrected behavior, then follow the normal cycle.

Create only the seam required for the next safe change; avoid a preparatory redesign of the legacy area.

## Pure refactoring

1. Establish a Green baseline at the governing observation boundary.
2. Change structure without intentionally changing behavior or compatibility.
3. Run relevant fast/local evidence after each meaningful edit and broader evidence before handoff as risk requires.

No new Red is required because no new behavior is being requested. If behavior must change, stop and frame a normal cycle.

## Disposable exploration

Use a time-boxed spike when the interface, feasibility, or expected behavior is not yet understood well enough to form a useful oracle. Keep the spike disposable. After learning:

- discard it and drive the chosen behavior through TDD; or
- explicitly characterize retained behavior before treating the code as maintained production code.

Do not present exploratory execution as Red-Green-Refactor evidence.

## No useful executable oracle

Use the strongest suitable alternative evidence when correctness cannot be expressed as a stable executable oracle. Examples include reviewed qualitative judgment, representative statistical evaluation, exploratory testing, formal analysis, production monitoring, or reconciliation.

Report why TDD does not govern that part of the change, which evidence replaces it, and what uncertainty remains. Continue to use TDD for deterministic surrounding code where useful.

## Test passes immediately

Determine which condition applies before changing production code:

- **Behavior already exists:** confirm the example exercises production code and retain it only if it adds durable regression value.
- **Insensitive oracle or data:** choose inputs and assertions that distinguish plausible wrong behavior.
- **Wrong path or boundary:** trace execution and move the observation boundary to the risk.
- **Duplicate evidence:** remove or consolidate it if it adds no information.

When uncertainty remains, demonstrate sensitivity with a controlled mutation or alternate failing input, then restore the probe. If the requested behavior already exists, report that finding rather than manufacture a production change or an artificial Red.
