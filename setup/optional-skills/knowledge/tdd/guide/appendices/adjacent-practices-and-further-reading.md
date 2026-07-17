# Adjacent practices and further reading

TDD is one feedback workflow, not a complete engineering system. This appendix points to practices that answer nearby questions but are too broad for the core reading path.

Each entry explains its question, connection to TDD, and trigger for deeper study. The links are starting points, not a required curriculum.

## Test doubles and testability

**Question:** How can a test control inputs or observe outcomes when a collaborator is slow, nondeterministic, destructive, or outside the team's control?

**Relationship to TDD:** Dummies, stubs, spies, mocks, and fakes can make a boundary controllable. They do not prove the real external effect, and testability is broader than mockability.

**Investigate when:** Time, randomness, networks, costly infrastructure, or separately governed systems obstruct useful feedback. Also investigate when interaction-heavy tests make safe refactoring difficult.

**Start with:** Gerard Meszaros, [xUnit Test Patterns](https://xunitpatterns.com/); Martin Fowler, [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html).

## TDD schools and working styles

**Question:** Where should design pressure enter, and when should tests use real owned collaborators rather than substitutes?

**Relationship to TDD:** Classicist TDD commonly uses real owned collaborators. Mockist TDD uses interaction expectations to discover roles. Inside-out and outside-in describe another, related axis.

**Investigate when:** A team disagrees about isolation, test boundaries, or whether interfaces discovered through mocks clarify the domain. Judge outcomes, not school labels.

**Start with:** Fowler, [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html).

Also see Freeman and Pryce, [Growing Object-Oriented Software](https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/).

## Test portfolio heuristics

**Question:** How should a project distribute focused, integration, and E2E evidence so feedback remains useful and affordable?

**Relationship to TDD:** The pyramid, trophy, and honeycomb visualize cost or fidelity preferences. They do not determine the correct Red or replace risk analysis.

**Investigate when:** The suite is slow, fragile, duplicative, or blind to important integration risks. Use measurements and unique questions rather than target proportions.

**Start with:** Fowler, [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html); Kent C. Dodds, [The Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications).

## Risk-based testing

**Question:** Which behaviors and conditions deserve the most evidence when time and attention are limited?

**Relationship to TDD:** Risk helps select the next behavior, observation boundary, and verification depth. Neither every function nor every data transformation deserves equal treatment.

**Investigate when:** Impact, failure probability, change frequency, complexity, poor observability, or regulatory exposure varies materially across the system.

**Start with:** ISO/IEC/IEEE 29119-2, [Test processes](https://www.iso.org/standard/79428.html); ISTQB, [Advanced Test Management](https://www.istqb.org/certifications/certified-tester-advanced-level-test-management-ctal-tm-v3-0/).

## Exploratory testing

**Question:** What important behavior or risk has nobody encoded as an expectation yet?

**Relationship to TDD:** Automated examples check known claims repeatedly. Exploration combines learning, test design, and execution to discover surprises, usability problems, and new questions.

**Investigate when:** The domain is unfamiliar, behavior is visual or experiential, incidents reveal unknown risks, or scripted checks pass while confidence remains low.

**Start with:** Cem Kaner and James Bach, [The Nature of Exploratory Testing](https://kaner.com/pdfs/ETatQAI.pdf); James Bach, [Exploratory Testing Explained](https://www.satisfice.com/download/exploratory-testing-explained).

## Property-based testing

**Question:** Does an invariant hold across a generated range of inputs rather than only selected examples?

**Relationship to TDD:** Properties can follow examples or drive a cycle when a trustworthy invariant is known. Generator and oracle quality still determine the evidence.

**Investigate when:** Parsers, transformations, algebraic rules, protocols, or state machines have large input spaces and useful invariants.

**Start with:** Koen Claessen and John Hughes, [QuickCheck](https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf).

## Metamorphic testing

**Question:** When an exact expected output is unavailable, should related executions still have a known relationship?

**Relationship to TDD:** A metamorphic relation can serve as an oracle. It complements concrete examples when calculating one exact answer independently is difficult.

**Investigate when:** Search, simulation, scientific computing, optimization, and ML systems have an oracle problem but support meaningful transformations or relations.

**Start with:** Tsong Yueh Chen et al., [Metamorphic Testing: A Review of Challenges and Opportunities](https://doi.org/10.1145/3143561).

## Model-based testing

**Question:** Do generated action sequences and state transitions agree with an explicit behavioral model?

**Relationship to TDD:** A model supplies an oracle across sequences that individual examples may miss. Creating and maintaining it is a separate design investment.

**Investigate when:** Stateful workflows, protocols, devices, or user interfaces have many valid sequences and transition rules.

**Start with:** Mark Utting, Alexander Pretschner, and Bruno Legeard, [A Taxonomy of Model-Based Testing Approaches](https://doi.org/10.1002/stvr.456).

## Mutation testing

**Question:** Would the retained tests detect selected plausible changes to production code?

**Relationship to TDD:** Mutation probes the suite's ability to discriminate behavior. A mutation score is evidence to interpret, not a universal quality target.

**Investigate when:** Coverage is high but assertions may be weak, critical rules deserve an evidence audit, or a team wants to find untested decision outcomes.

**Start with:** Yue Jia and Mark Harman, [An Analysis and Survey of Mutation Testing](https://doi.org/10.1109/TSE.2010.62); Stryker, [Mutation testing elements](https://stryker-mutator.io/docs/mutation-testing-elements/).

## Approval and snapshot testing

**Question:** How can a team review and retain complex output when many small assertions would hide the meaningful whole?

**Relationship to TDD:** An approved baseline can become an oracle for new or existing behavior. Snapshot storage is a mechanism; deliberate human review gives a change meaning.

**Investigate when:** Reports, rendered output, serialized structures, compiler output, or legacy behavior are costly to express with focused assertions.

**Start with:** ApprovalTests, [Approval Testing](https://approvaltestscpp.readthedocs.io/en/latest/generated_docs/ApprovalTestingConcept.html); Jest, [Snapshot Testing](https://jestjs.io/docs/snapshot-testing).

## Static analysis, type systems, and formal methods

**Question:** Which defects can be rejected or which critical properties can be justified without executing example-based tests?

**Relationship to TDD:** Types and static checks shorten feedback for classes of invalid programs. Model checking and proof can establish properties that sampled executions cannot.

**Investigate when:** Invalid states can be excluded by design, concurrency creates large state spaces, or failure impact justifies stronger assurance than examples provide.

**Start with:** Benjamin Pierce, [Types and Programming Languages resources](https://www.cis.upenn.edu/~bcpierce/tapl/); Leslie Lamport, [The TLA+ Home Page](https://lamport.azurewebsites.net/tla/tla.html).

## Quality attributes

**Question:** Does the system remain acceptable under security, privacy, accessibility, performance, resilience, concurrency, compatibility, and resource constraints?

**Relationship to TDD:** Some attributes can be driven by executable examples. Most also require threat models, workloads, fault injection, audits, specialist tools, or statistical evidence.

**Investigate when:** The attribute affects users, legal duties, safety, cost, service objectives, or architecture. Define measurable quality scenarios rather than calling the concern “non-functional.”

**Start with:** [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/); [W3C WCAG](https://www.w3.org/TR/WCAG22/); Google, [Site Reliability Engineering](https://sre.google/books/).

For privacy engineering, also see NIST, [Privacy Framework](https://www.nist.gov/privacy-framework). Select domain standards with qualified specialists where legal or safety obligations apply.

## Monitoring, observability, and reconciliation

**Question:** What can be learned only from the system operating with real traffic, dependencies, data, and failure modes?

**Relationship to TDD:** Operational feedback detects outcomes pre-release checks cannot reproduce. It complements rather than excuses missing development evidence.

**Investigate when:** Systems are distributed, depend on third parties, degrade gradually, process asynchronous work, or require confirmation of real business outcomes.

**Start with:** Google SRE, [Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/); OpenTelemetry, [Observability primer](https://opentelemetry.io/docs/concepts/observability-primer/).

## ML and LLM evaluation

**Question:** How well does a probabilistic model behave across representative tasks, populations, adversarial inputs, and changing production conditions?

**Relationship to TDD:** Test deterministic preprocessing, schemas, tool calls, and control flow normally. Model quality usually needs datasets, metrics, repeated trials, human judgment, and monitoring.

**Investigate when:** Outputs vary, exact strings are not the real requirement, model or prompt changes shift behavior, or safety and fairness depend on a distribution of outcomes.

**Start with:** NIST, [AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework); NIST, [Generative AI Profile](https://doi.org/10.6028/NIST.AI.600-1).

## Regulatory and safety structural coverage

**Question:** Which prescribed evidence, traceability, independence, and structural coverage objectives apply to this product and assurance level?

**Relationship to TDD:** TDD can contribute executable requirements and regression evidence. It does not replace mandated processes, reviews, traceability, or coverage analysis.

**Investigate when:** Software affects aviation, automotive, medical, rail, industrial, financial, or other regulated and safety-critical domains. Engage assurance specialists early.

**Start with:** FAA, [Advisory Circular 20-115D](https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_20-115D.pdf); ISO, [ISO 26262-6 software development](https://www.iso.org/standard/68388.html).

Do not transfer a coverage target from one standard, assurance level, or jurisdiction to another. Determine the exact governing obligations for the system.

## Continuous integration and delivery

**Question:** Does work remain integrated, deployable, and evaluable as contributions and environments change?

**Relationship to TDD:** CI extends the local feedback loop to the team. Delivery automation tests packaging and deployment paths that focused development checks cannot prove.

**Investigate when:** More than one change stream exists, integration is delayed, releases are risky, or environment drift weakens confidence.

**Start with:** Martin Fowler, [Continuous Integration](https://martinfowler.com/articles/continuousIntegration.html); Jez Humble, [Continuous Delivery](https://continuousdelivery.com/).

## Architecture and walking skeletons

**Question:** Which system boundaries, runtime responsibilities, and delivery paths must work together before local design choices can succeed?

**Relationship to TDD:** Tests provide local design feedback but do not automatically grow a sound system architecture. A walking skeleton probes a provisional end-to-end structure early.

**Investigate when:** Starting a system, crossing trust or deployment boundaries, making irreversible technology choices, or changing system-wide qualities.

**Start with:** Freeman and Pryce, [Walking Skeleton](https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/ch10.html).

Also see Michael Nygard, [Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

Use spikes, prototypes, architecture decision records, and quality scenarios when uncertainty requires them. Keep the probe provisional; it is not permission for comprehensive design up front.

## How to use this appendix

Return to the core TDD loop when the current question is behavior that can be expressed through a trustworthy executable example.

Follow an adjacent practice when it answers a different material question. Combine evidence deliberately, and state what each result does and does not establish.
