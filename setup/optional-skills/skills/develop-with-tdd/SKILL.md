---
name: develop-with-tdd
description: Develop and safely change code using trustworthy TDD feedback. Use when implementing behavior test-first, reproducing a defect before fixing it, evolving greenfield or legacy code, protecting a pure refactor with existing tests, or when another implementation workflow needs a red-green-refactor loop.
---

# Develop with TDD

Work on one observable behavior at a time. Choose the shortest trustworthy feedback loop that faithfully exercises the current risk. A slower faithful test outranks a fast test that cannot detect that risk.

Follow repository conventions for stacks, test commands, tags, and gates. Load a reference only when its condition applies:

- For greenfield, defect, intentional contract change, legacy, pure-refactor, exploration, no-oracle, or immediately-passing-test work, read [entry strategies](references/entry-strategies.md).
- When an oracle, observation boundary, assertion, or test-data choice is uncertain, read [test-design examples](references/test-design-examples.md).
- When risk crosses a component, process, database, service, or deployed-system boundary, read [test-level examples](references/test-level-examples.md).
- When behavior is difficult to control or observe, or an interface, wrapper, or double is being considered, read [design for testability](references/design-for-testability.md).
- When suite cadence is unclear, feedback is too slow, or the repository lacks useful test lanes, read [feedback lanes](references/feedback-lanes.md).
- When creating or repairing environment-dependent, flaky, contract, integration, acceptance, or E2E tests, read [broader-test operations](references/broader-test-operations.md).
- When explaining, reviewing, or adapting this skill's policy, read [the operating reference](references/operating-reference.md).

## Cycle invariants

- **Faithful feedback:** Select evidence by risk, not by test count, coverage, or a preferred test level.
- **Known baseline:** Run relevant existing evidence first, or record why it cannot run and which failures already exist.
- **Explicit frame:** State one behavior, its risk, observation boundary, and an independently derived oracle before implementation.
- **Observed Red:** For new or corrected behavior, run the new or revised test and observe a relevant, reproducible failure attributable to that behavior. Never infer Red from confidence or inspection.
- **Green integrity:** Make the framed evidence pass by changing production behavior while preserving the test's sensitivity and the intended contract.
- **Behavior/refactor separation:** Add behavior under Red; change structure under Green while preserving observable behavior.
- **Trustworthy signal:** Diagnose flaky, environmental, or unexplained results before treating them as Red or Green.
- **Closed cycle:** Return to Green before starting the next behavioral decision.
- **Honest completion:** Claim only checks actually run; name omitted checks, unavailable environments, and remaining uncertainty.

Characterization, pure refactoring, exploration, and work without an executable oracle use the explicit branches in [entry strategies](references/entry-strategies.md); they do not manufacture a Red.

## 1. Orient and establish the baseline

- Inspect requirements, public interfaces, nearby production code, existing tests, and repository test instructions.
- Classify the work. Load [entry strategies](references/entry-strategies.md) when it is not a straightforward new behavior in an already-tested area.
- Identify the smallest relevant existing test command and the broader commands expected before handoff.
- Run the smallest relevant baseline when possible. Record pre-existing failures and environmental limitations.

Complete this step when the work type and repository conventions are known, and the baseline state or its absence is explicit.

## 2. Frame one behavior

- State the behavior in caller or domain language.
- Identify the failure risk the evidence must detect.
- Choose the narrowest stable observation boundary that reproduces that risk faithfully.
- Derive the expected result independently through a concrete example, property, model, trusted reference, or reviewed baseline.
- Choose the test level from the risk rather than the code's decomposition.

Recover choices from requirements and repository evidence. Ask the user before settling a material ambiguity in product behavior, compatibility, oracle, observation boundary, or architecture that those sources cannot resolve.

Complete this step when the behavior, risk, boundary, oracle, and test level are explicit.

## 3. Establish Red

- Add or revise one test that contributes new behavioral information. Revise an existing expectation when the requested contract intentionally changes.
- Make the test runnable, then execute the smallest faithful command.
- Trace the failure to the framed behavior. Treat unrelated compilation, fixture, setup, and environment failures as test-path problems; repair that path before claiming Red. A missing compile-time contract is Red only when that contract is the behavior under development.
- Reproduce the failure when nondeterminism or shared state could explain it.
- If the test passes immediately, follow the immediately-passing-test branch in [entry strategies](references/entry-strategies.md) before touching production code.

Complete this step only after observing a relevant, reproducible, attributable Red for the expected reason.

## 4. Reach Green

- Make the smallest coherent production change that satisfies the example.
- Use an obvious implementation when the rule is clear. Use Fake It or Triangulation when examples have not yet revealed the general rule.
- Preserve assertion strength, test execution, error propagation, and the agreed contract.
- Run the formerly failing test, then relevant fast/local neighboring tests.

Complete this step when the same evidence is Green for the intended reason, nearby fast feedback is Green, and no unrelated behavior was added.

## 5. Refactor while Green

- Improve names, duplication, responsibilities, and boundaries justified by behavior already known.
- Preserve observable behavior at the governing boundary; treat a behavior or compatibility change as a new cycle.
- Run relevant fast/local tests after each meaningful structural change.

Complete this step when the structure is clear enough for the current behavior and all relevant fast/local evidence remains Green.

## 6. Continue one behavior at a time

- Select the next smallest example that adds information.
- Complete its Red, Green, and refactor stages before selecting another.
- Stop adding examples when the requested behavior is covered and additional cases would not change confidence or design.

Complete this step when every requested behavior has appropriate evidence and every started cycle is closed at Green.

## 7. Verify and report

- Run repository-required formatting and static checks.
- Run the standard/change-validation lane before handoff. Run the thorough/system-validation lane when repository policy, risk, or the next transition requires it.
- Inspect the diff for implementation-coupled assertions, speculative code, weakened evidence, and accidental contract changes.
- Report behavior covered, exact commands and lanes run, results, checks not run, and remaining uncertainty.

Complete the skill only when requested behavior is implemented, all required checks pass, every claimed result was observed, and residual risk is explicit.
