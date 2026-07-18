# Technical Review of the TDD Foundation

Date: 2026-07-13
Reviewed file: `tools/tdd/notNededAnymore/testing-methodologies-foundation.adoc`

## Executive Assessment

The document presents a strong, largely internally consistent **classicist TDD position**. Its core claims about short feedback loops, refactoring, the limited meaning of coverage, BDD collaboration, and complementary testing techniques are fundamentally sound. However, it is not yet a neutral “foundation”: definitions, rules of experience, and author preferences are repeatedly presented as universally applicable rules. Some claims are factually incorrect or too absolute; the most significant problems concern BDD/ATDD, the meaning of “Red,” test levels, mocks, and permanently red acceptance tests.

## High-Priority Corrections

### 1. “Red” is not universally limited to assertion failures

The sections *What Counts as Red?* and the AI rule “Red means assertion failure, not compilation failure” present a disputed preference as a definition. Robert C. Martin’s second “Law of TDD” explicitly treats a test that fails **or fails to compile** as a sufficient Red state. Martin also distinguishes the second-by-second Three Laws nano-cycle from the minute-by-minute Red–Green–Refactor cycle. The document may choose assertion-only Red as its own stricter operating rule, but it must label it accordingly and must not claim that compile-time Red is not TDD.

Source: [Robert C. Martin, *The Cycles of TDD*](https://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)

### 2. BDD is now more than “TDD with different vocabulary”

Historically, BDD emerged from Dan North’s difficulties teaching TDD; the original questions included where to start, what to test, how much to test at once, and how to name tests. North’s origin account does not support the claim that BDD was created specifically because TDD was equated with unit testing or because of coverage chasing. Current BDD practice includes Discovery, Formulation, and Automation, together with collaboratively developed shared domain understanding. Therefore, “BDD is therefore not a separate practice from TDD” and “a scenario written by one person ... is structurally indistinguishable from a well-named TDD test” are too reductive.

Sources: [Dan North, *Introducing BDD*](https://dannorth.net/blog/introducing-bdd/), [Dan North, *BDD is like TDD if...*](https://dannorth.net/blog/bdd-is-like-tdd-if/), [Cucumber, *Behaviour-Driven Development*](https://cucumber.io/docs/bdd/), [Agile Alliance, *BDD*](https://agilealliance.org/glossary/bdd/)

### 3. BDD and ATDD overlap but are not simply synonymous

“ATDD is, in practice, the same activity as BDD” erases a useful distinction. ATDD refers to acceptance tests created collaboratively **before implementation** from customer, development, and testing perspectives. BDD synthesizes and extends practices from TDD and ATDD through outside-in thinking, business value, shared language, and application across several abstraction levels. Some communities use the terms interchangeably; that supports describing “strong overlap,” not identity.

Sources: [Agile Alliance, *ATDD*](https://agilealliance.org/glossary/atdd/), [Agile Alliance, *BDD*](https://agilealliance.org/glossary/bdd/)

### 4. The document contradicts itself about TDD and test levels

Early on, it correctly states that TDD is a workflow that can drive unit, integration, acceptance, and E2E tests. Later, it states that “TDD's primary domain is unit-level testing,” says TDD/BDD do not answer whether the integrated system works, and equates TDD with the unit level and BDD with the acceptance level in the comparison table. These are different models. The common definition usually describes TDD as tightly interwoven programming, **unit testing**, and refactoring; outside-in and acceptance-test-driven variants also exist. Recommendation: declare the chosen conceptual framework instead of equating a method with a level.

Sources: [Martin Fowler, *Test-Driven Development*](https://martinfowler.com/bliki/TestDrivenDevelopment.html), [Agile Alliance, *TDD*](https://agilealliance.org/glossary/tdd/), [Cucumber, *BDD – Automation*](https://cucumber.io/docs/bdd/)

### 5. Permanently red acceptance tests do not belong in a normally evaluated CI suite

The recommendation to add unfinished acceptance tests “red from day one” to a slow suite in which red tests are expected destroys that suite’s signal. An intentionally red test may serve as a local target or an explicitly quarantined/pending test; when run, a CI suite should be reliably green or technically distinguish a known pending state. Feature branches, tags, or disabled pending scenarios are more appropriate. Likewise, “days or weeks” as a normal Red–Green cycle is not a general TDD rule and weakens the rapid feedback emphasized by primary descriptions.

Sources: [Martin Fowler, *Test-Driven Development*](https://martinfowler.com/bliki/TestDrivenDevelopment.html), [Cucumber, *Automation*](https://cucumber.io/docs/bdd/)

### 6. Mock tests do not prove a real external effect

“If the interaction is the thing the user cares about (a payment was actually charged, an email was actually sent), use a mock” is inaccurately worded. A mock can prove that the code sent the expected request to a controlled abstraction; it specifically does **not** prove that the payment provider made the charge or the email was delivered. That requires contract, integration, sandbox, or E2E verification. In addition, a mock in Meszaros’ taxonomy is not simply “a spy with pre-programmed expectations,” but a double used for behavior verification; spies and mocks are related but distinct patterns.

Sources: [Martin Fowler, *Mocks Aren't Stubs*](https://martinfowler.com/articles/mocksArentStubs.html), [Gerard Meszaros, *xUnit Test Patterns*](https://xunitpatterns.com/), [Pact, *What is contract testing?*](https://docs.pact.io/)

### 7. Interface changes can be refactorings

The rule “Any change to that [external] interface would belong in a new red step” is too absolute. An interface change is a refactoring when all controlled callers are changed with it and the system’s observable behavior is preserved. This is considerably riskier for published APIs, but it is not excluded by definition.

Source: [Martin Fowler, *Is Changing Interfaces Refactoring?*](https://martinfowler.com/bliki/IsChangingInterfacesRefactoring.html)

### 8. Coverage is neither the goal nor merely a worthless by-product

The criticism of percentage chasing is correct: high line coverage guarantees neither strong oracles nor relevant cases. However, “do not propose coverage percentage targets” and the portrayal of coverage as merely a by-product are too absolute. Coverage is a useful **gap and risk signal**; low coverage reveals unexecuted areas, and meaningful thresholds depend on criticality, change frequency, expected lifetime, and domain. The claim that TDD produces high coverage “by definition” applies only to the path currently driven by a test; refactoring can introduce new branches, and a project may use TDD only partially. In safety-critical or regulated contexts, structural coverage objectives may also be normatively required.

Source: [Google Testing Blog, *Code Coverage Best Practices*](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)

There is also a minor error in the example: a test without an explicit assertion does fail if `calculate_total` raises an exception. It implicitly verifies “does not throw,” but not the return value.

The AI rule that generally rejects tests without assertions or tests that only verify the absence of exceptions is also too absolute: “this operation does not throw for valid inputs” can itself be the required observable contract. The correct rule is that every test needs an effective oracle for **the behavior it claims to verify**.

## Clarifications for Complementary Methods

- **Mutation Testing:** The basic description is correct. “A much more honest quality measure” and direct comparisons between arbitrary mutation scores are too strong: score and cost depend on mutation operators, equivalent mutants, timeout/error classification, and the code under analysis. Even Stryker cannot reliably eliminate equivalent mutants automatically; 100% is not a meaningful universal target. Sources: [Stryker, *Equivalent mutants*](https://stryker-mutator.io/docs/mutation-testing-elements/equivalent-mutants/), [Stryker, *Mutant states and metrics*](https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/).

- **Property-based Testing:** The definition and typical use cases are correct. “Do not suggest for ... UI” and the exclusion of glue code are acceptable heuristics but not prohibitions: stateful models can verify event sequences, protocols, and UI states. PBT does not replace examples; generator and oracle quality remain decisive. Source: [Claessen/Hughes, *QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs*](https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf).

- **Contract Testing:** The Pact description is correct for consumer-driven contract testing, but that is not the only form of contract testing. “At every inter-service boundary” is too absolute; the technique is especially valuable for independently deployed consumer/provider teams and systems with many integrations. Contract tests verify message compatibility, not the provider’s business correctness. Source: [Pact, *Introduction*](https://docs.pact.io/).

- **Approval, Golden Master, Characterization, Snapshot:** These techniques overlap but are not stable synonyms. “Approval” describes a human-approved oracle/baseline workflow; “characterization” describes the purpose of preserving current legacy behavior; “snapshot” usually describes the stored comparison form. An approval test can verify new behavior, and a characterization test can use ordinary assertions. Sources: [ApprovalTests, *ApprovalTesting concept*](https://approvaltestscpp.readthedocs.io/en/latest/generated_docs/ApprovalTestingConcept.html), [Jest, *Snapshot Testing*](https://jestjs.io/docs/snapshot-testing).

- **Testing Pyramid/Trophy:** Cohn popularized the pyramid; it is a cost heuristic, not a universal test-level standard. The claim that “each level is about an order of magnitude slower and more fragile” is unsupported and should be removed or clearly labeled a local rule of thumb. Dodds’ Trophy argues for ROI and tests that resemble real use, especially in the JavaScript/UI context; “integration tests should numerically outnumber unit tests” is one possible interpretation, not a general definition. Sources: [Martin Fowler, *Test Pyramid*](https://martinfowler.com/bliki/TestPyramid.html), [Kent C. Dodds, *The Testing Trophy and Testing Classifications*](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications).

- **Given–When–Then:** The context/event/outcome description is correct. “Exactly one `When`; split when it contains `and`” is a useful readability rule, but neither Gherkin syntax nor a universal BDD definition. Cucumber permits multiple steps and keyword sequences. Source: [Cucumber, *Gherkin Reference*](https://cucumber.io/docs/gherkin/reference/).

- **Test Levels:** “Unit / Integration / E2E / Smoke” is useful but incomplete, and definitions vary between organizations. ISO/IEC/IEEE 29119 distinguishes test processes, test levels, and test types and includes system, acceptance, performance, usability, and reliability testing. Source: [ISO/IEC/IEEE 29119 series overview](https://committee.iso.org/sites/jtc1sc7/home/projects/flagship-standards/isoiecieee-29119-series.html).

## Empirical Evidence

The cautious core claim “do not sell it as empirically proven” is correct. It should not, however, slide into “the evidence supports no benefit”:

- Four industrial case studies at Microsoft/IBM reported 40–90% lower pre-release defect density with a subjectively assessed 15–35% increase in initial development time. This is positive but observational and confounded evidence, not a general causal proof. Source: [Nagappan et al., 2008, IBM Research](https://research.ibm.com/publications/realizing-quality-improvement-through-test-driven-development-results-and-experiences-of-four-industrial-teams).
- A process dissection found that small, steady steps and test granularity may explain outcomes better than test-first ordering alone. Source: [Fucci et al., *A Dissection of the TDD Process*](https://arxiv.org/abs/1611.05994).
- A larger family of experiments with TDD novices found slightly higher quality under iterative test-last than under TDD and points to training and study-duration effects. Source: [Santos et al., *A Family of Experiments on TDD*](https://arxiv.org/abs/2011.11942).

A defensible formulation is: **The empirical results are mixed and strongly dependent on context, skill, and operationalization. There are positive and negative findings; neither side justifies universal productivity or quality promises.** The “mechanistic” benefits are also plausible mechanisms, not guaranteed outcomes: a test written first can cement a poor interface, and a test safety net makes refactoring less risky, not automatically safe.

## Missing or Underrepresented Perspectives

A foundation should at least mention and clearly distinguish:

1. **Inside-out vs. outside-in TDD** and **classicist/sociable vs. mockist/solitary TDD**. The document mentions London/classicist styles, but partly characterizes the London style inconsistently (“never mock what you own; mock only external dependencies” is not the same as “mock all interesting collaborators”). Source: [Fowler, *Mocks Aren't Stubs*](https://martinfowler.com/articles/mocksArentStubs.html).
2. **Specification by Example and Example Mapping** as collaborative requirements practices; BDD is not merely a test-writing style.
3. **Exploratory Testing and human/oracle questions**. Automated checks answer only explicitly encoded expectations; learning, unexpected risks, usability, and visual quality require human exploration.
4. **Risk-based Testing:** Neither “every function” nor “every transformation” is the right unit. Priority follows impact, probability, change frequency, complexity, and observability. Data transformations are often good candidates, but they are not a definitional TDD boundary.
5. **Non-functional quality attributes:** Security, performance, reliability/resilience, accessibility, compatibility, data quality, and observability require their own test designs and do not fit neatly into Unit/Integration/E2E.
6. **Static and formal techniques:** Type checking, linting, reviews, static analysis, model checking, and formal verification complement dynamic tests; the “foundation” focuses almost entirely on executable examples.
7. **Regulated/safety-critical development:** Coverage can be a required structural criterion in such contexts; “never use coverage targets” is therefore unsuitable as a universal AI rule.
8. **Test maintenance and economics:** Behavior-focused tests can also break under legitimate requirement changes and create maintenance costs. “Tests should not break when implementation changes” applies only when the observed interface and semantics remain unchanged.
9. **Fuzzing, metamorphic, and statistical testing:** TDD is not limited to fully deterministic logic. Randomness and concurrency can be tested through controlled seeds/seams and properties; ML/LLM behavior requires datasets, distributions, thresholds, and repeated evaluations rather than isolated deterministic assertions.
10. **Flaky-test management:** Quarantine, reproducibility, ownership, and repair budgets are missing even though unstable tests substantially damage the feedback signal, especially at integration/E2E levels.

## Claims That Can Be Retained

- The commonly accepted core of TDD is a small test/code/refactoring cycle; refactoring is essential. [Fowler](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- Test-first directs attention to the interface early; self-testing code and interface feedback are both important benefit mechanisms. [Fowler](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- High line coverage guarantees neither relevant paths nor effective assertions; coverage should be used contextually as a signal. [Google Testing Blog](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)
- BDD is not synonymous with Cucumber/Gherkin; collaboration and concrete examples are central. [Cucumber](https://cucumber.io/docs/bdd/)
- The pyramid and trophy are context-dependent heuristics, not competing laws of nature. [Fowler](https://martinfowler.com/articles/2021-test-shapes.html)
- Mockist and classicist TDD have real, documented trade-offs; a deliberate choice is better than unmarked mixing. [Fowler](https://martinfowler.com/articles/mocksArentStubs.html)

## Implications for the AI-Condensed Version

The AI rules should use four labels:

- **Definition:** A broadly accepted core that is non-negotiable within the term.
- **Default:** A preferred working method that may be overridden by stronger contextual signals.
- **Heuristic:** A diagnostic prompt that helps choose an action but is not a compliance rule.
- **Project Decision:** For example, assertion-only Red, classicist default, coverage gates, real database vs. fake, or testing pyramid vs. trophy.

Absolute terms such as “never,” “always,” “at every boundary,” and “does not apply” should remain only when they protect technical correctness or safety. Most current absolutes are valuable defaults, not universal facts.

## Propagation Status

The second iteration applies the research through a claim-to-deliverable matrix in `traceability.md`. The important changes are no longer confined to this report:

- disputed claims about Red are labeled as conventions rather than definitions;
- BDD, ATDD, Specification by Example, and double-loop TDD remain overlapping but distinct;
- acceptance examples cannot silently keep an evaluated CI suite red;
- refactoring is governed by observable behavior, not an absolute ban on interface changes;
- mocks verify requested interactions, while real effects require broader evidence;
- coverage is retained as a diagnostic and possible regulatory objective, not a quality verdict;
- classicist and London/mockist schools are defined consistently;
- companion techniques and non-functional qualities are selected from their assurance question;
- AI rules are labeled Definition, Default, Heuristic, or Project decision.

The human chapters cite primary or authoritative sources near historical and empirical claims. The self-contained skill stores its operating reference under `develop-with-tdd/references/`.

## Public Skill Survey

The separate `external-skill-survey.md` compares public TDD, testing-strategy, contract-testing, and E2E skills through their source repositories and skills.sh entries.

No surveyed skill supplied a stronger general TDD foundation. The useful additions were practical: contrastive examples, mutation-sensitive data, factories, provider-state contract lifecycle, E2E diagnostics, flake ownership, and gate placement.

The local skill adopts those ideas through conditional references. It rejects fixed pyramid ratios, universal mocking rules, mandatory coverage or mutation targets, one-assertion rigidity, and framework-specific recipes in the core workflow.

## Targeted Follow-up: Feedback, Beginners, Criticism, Greenfield, and Legacy Work

Date: 2026-07-14
Scope: the current `human/01`–`07` chapters and all earlier findings in this file.

The foundation is already strong on all five topics. It needs two concrete additions and three small emphases, not another broad chapter.

| Topic                   | Finding and disposition                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Fast feedback**       | **Emphasize the mechanism.** Fast feedback is produced by one small item in flight, a prompt relevant test run, a trustworthy result, and a design signal while the decision is still cheap—not by “unit” scope or mocking alone. Beck describes seconds-scale logic and design feedback; a study of 39 professionals found fine-grained, uniform steps positively associated with quality and productivity, while test-first sequencing had no important influence. Keep “seconds” as an aspiration, not a fixed SLA, and retain the current rule that the narrowest *relevant* boundary wins. Sources: [Beck, *TDD is Kanban for Code*](https://newsletter.kentbeck.com/p/tdd-is-kanban-for-code); [Fucci et al., *A Dissection of the TDD Process*](https://doi.org/10.1109/TSE.2016.2616877).                                                                                                                                                                 |
| **Beginner practice**   | **Add a short guided practice box.** Make the test list explicit: list behavioral variants, turn exactly one item into a concrete runnable test, complete its cycle, then revise and choose again. This fills a real gap between the current compact loop and worked examples without concretizing a whole speculative suite. A controlled experiment with 48 graduate novices found better functional quality with finer-grained task descriptions; a much smaller expert/novice comparison found experts used shorter, less variable cycles. These studies justify scaffolding and coaching, not a productivity promise. Sources: [Beck, *Canon TDD*](https://newsletter.kentbeck.com/p/canon-tdd); [Karac, Turhan, and Juristo, novice task-granularity experiment](https://doi.org/10.1109/TSE.2019.2920377); [Müller and Höfer, expert/novice process study](https://ps.ipd.kit.edu/downloads/za_2007_effect_experience_test_driven_development.pdf).        |
| **Skeptical criticism** | **Cross-link and sharpen; do not add another debate chapter.** State once that TDD is neither a professionalism test nor inseparable from mock-heavy unit isolation. DHH’s primary objection is to test-first fundamentalism and isolation-driven indirection, while still endorsing automated regression testing; Beck likewise says there is no “gold star” for canonical conformance. Chapters 3 and 4 already answer the substantive issues by separating workflow, scope, and classicist/mockist choices. Sources: [DHH, *TDD is dead. Long live testing.*](https://dhh.dk/2014/tdd-is-dead-long-live-testing.html); [Beck, *Canon TDD*](https://newsletter.kentbeck.com/p/canon-tdd).                                                                                                                                                                                                                                                                       |
| **Greenfield work**     | **Keep the walking skeleton; add one limiting sentence.** It is a provisional end-to-end architecture probe, used to validate a broad-brush structure before focused inner cycles, not permission for comprehensive up-front architecture. The current health-path example and first stakeholder slice are otherwise sufficient. Source: [Freeman and Pryce, *Growing Object-Oriented Software, Guided by Tests*, Chapter 10](https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/ch10.html).                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **Legacy adjustment**   | **Correct the apparent ordering constraint.** Characterization and seams are already covered well, but the current numbered sequence can imply that a characterization test must always precede a seam. Sometimes a dependency prevents any test from running. Permit the smallest behavior-preserving dependency break needed to create a test point, then characterize only the behavior around the intended change, add the failing new-behavior test, and resume normal cycles. Feathers explicitly describes dependency-breaking refactorings performed without tests *in the service of putting tests in place*, and his seam chapter explains using just enough substitution to get code under test. Sources: [Feathers, *Working Effectively with Legacy Code* sample](https://www.informit.com/content/images/9780131177055/samplepages/0131177052.pdf); [Feathers, *The Seam Model*](https://www.informit.com/articles/article.aspx?p=359417&seqNum=2). |

**Scope boundary:** Do not add rigid cycle-time limits, test-count or coverage targets, a universal unit-first/mocking rule, or causal promises from short cycles. Also exclude a kata catalog, general learning theory, IDE/framework tutorials, a full CI/CD or architecture course, and Feathers’ complete dependency-breaking catalog. Broader integration, contract, E2E, operational, and non-functional testing already has enough context in Chapter 3; expanding it further here would dilute a curriculum whose distinctive subject is the TDD feedback workflow.
