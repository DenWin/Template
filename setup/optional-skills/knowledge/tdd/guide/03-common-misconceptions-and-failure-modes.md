# Common misconceptions and failure modes

TDD can disappoint because it was misapplied, because its evidence did not match the risk, or because it was a poor fit for the work.

Those explanations are not interchangeable. Calling every criticism a misunderstanding makes TDD unfalsifiable. Calling every failed adoption proof against TDD ignores how the practice was used.

This chapter first diagnoses common misuse. It then separates those failure modes from serious objections that remain even when TDD is practised competently.

Each diagnostic uses the same questions:

- What is the misconception?
- What symptom appears in the work?
- Why does it weaken feedback or design?
- How can the team recover?
- Where is the deeper explanation?

## Mistaking a by-product for the goal

### “TDD means testing every method”

**Misconception:** Each function, method, or class must receive its own test.

**Symptom:** The suite mirrors the code inventory. Trivial accessors receive tests while important cross-component behavior remains uncertain.

**Why it fails:** Program structure does not determine testing value. Structure-coupled tests add maintenance cost and break during harmless refactoring.

**Recovery:** Start from behavior and risk. Add focused evidence when it clarifies a contract, distinguishes important cases, improves diagnosis, or enables safe change.

**Read next:** “Start from behavior, not code inventory” and “What deserves a focused test” in [Practising TDD deliberately](02-practising-tdd.md).

### “Coverage is the objective”

**Misconception:** A high coverage percentage demonstrates test quality or successful TDD.

**Symptom:** Tests execute lines without discriminating assertions. Teams avoid valuable refactoring or write low-value tests to protect a target.

**Why it fails:** Coverage measures execution, not correctness of the oracle, fault detection, or importance of the behavior.

**Recovery:** Use coverage to find unexamined code, then ask which risk matters and what evidence could detect a meaningful error. Do not treat the percentage as the product.

**Read next:** “Why coverage is not the goal” in [Why test-driven development exists](01-why-tdd.md).

### “Test-first automatically produces good tests”

**Misconception:** Writing an assertion before production code makes the resulting test valuable.

**Symptom:** A test is fast and test-first but checks an irrelevant detail, copies production reasoning, or cannot detect a plausible defect.

**Why it fails:** Timing creates an opportunity for design feedback. Relevance, independence, sensitivity, stability, and fidelity determine the quality of the evidence.

**Recovery:** Review the behavior, risk, boundary, and oracle. Confirm that an important wrong implementation would fail.

**Read next:** “Derive the expected result independently” and “What makes a retained test useful” in [Practising TDD deliberately](02-practising-tdd.md).

## Breaking the meaning of Red

### “The change is obvious, so Red can be skipped”

**Misconception:** A developer or AI can reason that the test would have failed without executing it.

**Symptom:** Test and implementation appear together, followed only by a passing run. Nobody knows whether the test was ever sensitive to the missing behavior.

**Why it fails:** The test may use the wrong setup, miss the production path, contain a tautology, or assert a result the system already produced.

**Recovery:** Run the new or revised test against the unchanged behavior. Require a reproducible failure caused by the intended rule before implementation.

**Read next:** “Observe a meaningful Red” in [Practising TDD deliberately](02-practising-tdd.md).

### “Any failure counts as Red”

**Misconception:** A compilation error, broken fixture, missing import, or unavailable service proves the behavioral example.

**Symptom:** Production code changes while the test has not yet reached the behavior it claims to describe.

**Why it fails:** The failure proves only that the execution path is broken. It does not show that the oracle distinguishes the current behavior from the intended behavior.

**Recovery:** Repair the test route with the smallest necessary structure. Restore the known baseline, then rerun until the expected behavioral failure is visible.

**Read next:** “If the test fails for the wrong reason” in [Practising TDD deliberately](02-practising-tdd.md).

### “An existing suite failure can serve as the new Red”

**Misconception:** Any Red result in the repository is enough to begin the production change.

**Symptom:** A pre-existing or unrelated failure is later reported as proof that the new test detected the missing behavior.

**Why it fails:** The change has no attributable baseline. Green may hide the old failure or leave the new behavior untested.

**Recovery:** Record or repair existing failures first. Isolate the new example and observe its own relevant failure.

**Read next:** “Establish a known baseline” in [Practising TDD deliberately](02-practising-tdd.md).

### “A new test that passes immediately is close enough”

**Misconception:** An immediately Green test can be accepted as evidence of a completed Red–Green cycle.

**Symptom:** The team adds production code anyway or retains an assertion without checking whether it can detect a defect.

**Why it fails:** The behavior may already exist, be satisfied accidentally, or never be exercised by the test.

**Recovery:** Inspect setup, action, and oracle. When safe, perturb the relevant behavior to check sensitivity. If the behavior already exists, choose a genuinely missing behavior.

**Read next:** “If the new test passes immediately” in [Practising TDD deliberately](02-practising-tdd.md).

## Turning the cycle into ceremony

### “Write the entire test suite first”

**Misconception:** Test-first means specifying every case before any implementation.

**Symptom:** Many tests fail at once and encode an interface imagined before the first design feedback arrives.

**Why it fails:** Later tests cannot benefit from discoveries made while satisfying earlier examples. Failures also become harder to attribute.

**Recovery:** Keep a provisional test list, select one informative example, and close its cycle before choosing the next.

**Read next:** “Make a provisional test list” in [Practising TDD deliberately](02-practising-tdd.md).

### “One behavior means one assertion”

**Misconception:** Every test may contain only one assertion.

**Symptom:** One coherent outcome is split across tests with duplicated setup, or related facts become difficult to read together.

**Why it fails:** Assertion count is a syntactic metric. The useful boundary is one behavioral decision and one understandable reason for failure.

**Recovery:** Keep assertions together when they describe one outcome. Split a test when it mixes independent rules or failures would be ambiguous.

**Read next:** “Start from behavior, not code inventory” in [Practising TDD deliberately](02-practising-tdd.md).

### “Minimal Green requires deliberately bad code”

**Misconception:** Every example must be satisfied with a hard-coded or knowingly poor implementation.

**Symptom:** Obvious solutions are delayed by ritual, or code violates already-known requirements merely to demonstrate Fake It.

**Why it fails:** The goal is a small, attributable learning step, not artificial incompetence.

**Recovery:** Use Obvious Implementation when the rule is clear. Use Fake It or triangulation when a narrow implementation will expose uncertainty or useful design pressure.

**Read next:** “Make the smallest coherent Green” in [Practising TDD deliberately](02-practising-tdd.md).

### “Refactor may add behavior”

**Misconception:** Any cleanup performed after Green belongs to Refactor, even when observable behavior changes.

**Symptom:** New rules appear without an observed Red, and a failing test during cleanup is dismissed as an expected side effect.

**Why it fails:** The evidence no longer distinguishes structural change from behavioral change.

**Recovery:** Refactor only while observable behavior remains Green. Begin a new cycle when the intended contract changes.

**Read next:** “Refactor only under Green” and “Change an existing contract deliberately” in [Practising TDD deliberately](02-practising-tdd.md).

## Choosing evidence by fashion

Test **scope** describes how much of the system participates. A focused test observes a narrow coherent behavior. An integration test includes real collaborators or infrastructure.

An end-to-end test observes an assembled path from an outside entry point. The next chapter defines these and other evidence labels in more detail.

### “TDD means unit tests”

**Misconception:** Red–Green–Refactor must always operate through an isolated unit test.

**Symptom:** A fast test bypasses the database, framework, contract, or assembly behavior that creates the current risk.

**Why it fails:** TDD determines when feedback enters development. It does not require one fixed test scope.

**Recovery:** Use the narrowest boundary that faithfully answers the current question. A focused, integration, or end-to-end test can be the correct Red.

**Read next:** [Choosing evidence and feedback lanes](04-choosing-evidence-and-feedback-lanes.md).

### “The narrowest test is always best”

**Misconception:** A focused test is preferable even when it bypasses the component that creates the risk.

**Symptom:** A suite is fast but cannot detect mapping, persistence, framework, configuration, or deployment defects.

**Why it fails:** Raw speed is not useful when the evidence is unfaithful to the question.

**Recovery:** Prefer the shortest trustworthy loop that faithfully exercises the current risk. Use a broader Red when the broader boundary is what can fail.

**Read next:** [Choosing evidence and feedback lanes](04-choosing-evidence-and-feedback-lanes.md).

### “End-to-end tests are always better because they are realistic”

**Misconception:** The broadest available boundary provides the strongest evidence for every question.

**Symptom:** Inner development cycles become slow and failures are hard to localize. Many scenarios repeat the same expensive setup.

**Why it fails:** Broad tests include more collaborating parts, but they may still use unrealistic data or simulated services. Scope, fidelity, speed, and diagnosis are separate qualities.

**Recovery:** Use focused evidence for local rules and broader evidence for assembly, journeys, and deployment risks. Keep only scenarios whose additional scope answers a distinct question.

**Read next:** [Choosing evidence and feedback lanes](04-choosing-evidence-and-feedback-lanes.md).

### “One test level proves the whole feature”

**Misconception:** A focused, integration, or end-to-end test can answer every relevant question about one behavior.

**Symptom:** A team treats a recorded request as proof of an external effect, or repeats every local rule through the browser.

**Why it fails:** Different boundaries expose different failures. One focused interaction does not prove provider acceptance, and one broad journey may diagnose a local rule poorly.

**Recovery:** Map each material risk to the smallest faithful evidence. Remove tests that duplicate another test’s question without adding useful confidence.

**Read next:** [Choosing evidence and feedback lanes](04-choosing-evidence-and-feedback-lanes.md) and the [worked examples](07-worked-examples.md).

## Confusing testability with mockability

A **test double** is a controlled substitute for a collaborator. A **mock** is a double used to set or verify expected interactions.

### “Every collaborator should be mocked”

**Misconception:** TDD requires replacing every dependency with a test double.

**Symptom:** Interfaces exist only for tests, assertions mirror internal call order, and refactoring breaks many tests without changing behavior.

**Why it fails:** Doubles can improve control and diagnosis, but excessive isolation couples tests to imagined implementation structure.

**Recovery:** First look for a stable behavioral boundary. Use a double when control or observation is difficult and the asserted interaction is a meaningful contract.

**Read next:** “Testability rather than mockability” in the [worked examples](07-worked-examples.md).

### “A mock proves the external effect”

**Misconception:** Verifying that code requested a charge, message, or write proves that the real system completed it.

**Symptom:** Focused tests pass while provider contracts, credentials, serialization, settlement, or reconciliation fail.

**Why it fails:** The test proves only the interaction visible at its boundary.

**Recovery:** Keep the focused interaction test when the request matters. Add compatibility, integration, end-to-end, or operational evidence for the external effect and its failure modes.

**Read next:** [Choosing evidence and feedback lanes](04-choosing-evidence-and-feedback-lanes.md).

## Misusing retained tests

### “Tests must never change”

**Misconception:** Changing an existing test is equivalent to weakening it.

**Symptom:** The suite preserves obsolete requirements, or developers work around a test instead of updating an intentional contract change.

**Why it fails:** Retained tests are executable specifications. A specification must change when the intended behavior changes.

**Recovery:** Distinguish an intentional contract change from an accidental regression. Revise the expectation first, observe Red, update production behavior, and preserve unaffected evidence.

**Read next:** “Change an existing contract deliberately” in [Practising TDD deliberately](02-practising-tdd.md).

### “A characterization test proves legacy behavior is correct”

**Misconception:** Recording current output means the output is desired.

**Symptom:** Defects and historical accidents become protected as requirements without review.

**Why it fails:** A characterization test establishes what happens now, not what should happen.

**Recovery:** Name the behavior being preserved and why. Review suspicious output with a domain owner, then establish Red for any intentional correction.

**Read next:** The legacy sequence in [Applying TDD without dogma](06-applying-tdd-without-dogma.md) and the [worked examples](07-worked-examples.md).

### “A flaky test can be rerun until Green”

**Misconception:** A passing rerun is adequate verification.

**Symptom:** Failures are ignored when a later execution happens to pass. The suite’s colors no longer carry a stable meaning.

**Why it fails:** An unexplained result cannot be attributed to code behavior. It may hide shared state, races, time, infrastructure faults, or a weak oracle.

**Recovery:** Treat flakiness as a defect. Reproduce and remove its cause, or exclude the test from required gates while clearly reporting the lost evidence.

**Read next:** “Keep results trustworthy” in [Practising TDD deliberately](02-practising-tdd.md).

## Asking TDD to solve a different problem

### “TDD replaces requirement discovery”

**Misconception:** Writing examples eliminates the need to understand users, goals, constraints, and competing interpretations.

**Symptom:** Precise tests encode the wrong behavior, and passing software still fails the user’s need.

**Why it fails:** TDD checks an expressed expectation. It cannot decide whether that expectation is valuable or complete.

**Recovery:** Use collaborative examples, product discovery, domain expertise, and review to choose behavior. Use TDD to develop the agreed behavior in small, observable steps.

**Read next:** [Behavior-driven development (BDD) and collaborative discovery](05-bdd-and-collaborative-discovery.md).

### “TDD grows the whole architecture automatically”

**Misconception:** Local test-first decisions remove the need for architectural reasoning, experiments, integration, and operational feedback.

**Symptom:** Local units are easy to test, but the assembled system has poor boundaries, delivery risks, or quality-attribute failures.

**Why it fails:** A TDD cycle provides local design feedback at its observation boundary. It does not by itself compare system-level options or validate operation at scale.

**Recovery:** Combine small cycles with a thin runnable system slice, disposable experiments, deliberate architecture, broader evidence, and production feedback.

**Read next:** [Applying TDD without dogma](06-applying-tdd-without-dogma.md) and the [adjacent-practices appendix](appendices/adjacent-practices-and-further-reading.md).

### “Every valuable outcome has an exact oracle”

**Misconception:** Every quality can be reduced to one deterministic expected value.

**Symptom:** Subjective, statistical, emergent, or operational qualities receive misleading assertions because the workflow expects Red–Green.

**Why it fails:** Some questions require ranges, properties, expert review, experiments, monitoring, or repeated evaluation.

**Recovery:** Apply exact example-based TDD to deterministic subproblems. Use the form of evidence appropriate to the remaining uncertainty.

**Read next:** “No useful executable oracle” in [Practising TDD deliberately](02-practising-tdd.md) and the [adjacent-practices appendix](appendices/adjacent-practices-and-further-reading.md).

## Serious objections are not misconceptions

The following concerns can remain valid even when no failure mode above is present. They should be evaluated against a concrete alternative, not dismissed as resistance to discipline.

They include:

- the cycle and retained suite may cost more than the feedback repays;
- isolation-heavy tests can damage production design;
- strict micro-cycles may fit schema, distributed, or cross-cutting changes poorly;
- empirical results vary by task, team, experience, and comparison process;
- local design feedback cannot choose or validate the whole system architecture.

These are evaluation questions, not errors to “recover” from. [Applying TDD without dogma](06-applying-tdd-without-dogma.md) examines their evidence, trade-offs, and adaptations.

## A recovery sequence

When a TDD effort feels slow or unhelpful:

1. State the behavior and current risk again.
2. Check whether the oracle is independent and meaningful.
3. Confirm that Red was observed for the expected reason.
4. Check whether the boundary faithfully exercises the risk.
5. Remove structural coupling and unnecessary setup.
6. Restore trustworthy Green before starting another behavior.
7. Choose different evidence when TDD is not the right mechanism.

The goal is not ritual compliance. It is early, trustworthy information that improves the next development decision.
