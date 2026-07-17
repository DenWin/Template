# Applying TDD without dogma

TDD exchanges effort now for earlier design feedback and reusable regression evidence. Whether that exchange is worthwhile depends on the behavior, risk, and cost of obtaining trustworthy feedback.

This chapter examines those limits, then shows how entry into TDD differs for greenfield and legacy work.

## Where TDD tends to earn its cost

TDD has leverage when an executable oracle can express the next behavior, the code is likely to change, and early feedback can still influence its interface or responsibilities.

Typical candidates include business rules, transformations, state machines, validation, parsers, authorization, calculations, and recovery logic.

The case becomes stronger when mistakes are expensive, discovered cases are easy to forget, or debugging through a broader system is slow.

TDD can also help when the final design is unclear but the next concrete behavior is known. The example constrains one decision without pretending to settle the whole architecture.

## Where another mode may be better

TDD supplies less leverage when the immediate goal is learning rather than stable behavior.

Throwaway spikes, diagnostic scripts, visual exploration, and early research may need experiments or human review before an executable contract is useful.

Pure wiring may contain little behavior beyond framework configuration. A mock-heavy focused test may only restate calls, while an integration test can answer the real question directly.

Stable code that is not changing may not justify retrospective tests. Coverage is not a moral debt.

Separate exploration from productionization. Explore cheaply, then preserve the parts that will survive behind explicit contracts and appropriate evidence.

## Serious objections and what survives them

The practical question is not whether TDD is always good. It is which mechanisms help in this context, compared with the way the work would otherwise be performed.

### “The empirical evidence is mixed”

Studies report varied effects on productivity and defects. Results depend on task, experience, cycle discipline, study design, and especially the comparison process.

Do not claim that TDD is proven to make every team faster or every product better.

The narrower claim is mechanistic. Executable examples can clarify outcomes, small batches can localize failures, and retained behavior tests can expose later regressions.

Those mechanisms can be observed during work. Whether they repay their cost remains contextual.

### “TDD cannot design the architecture”

Focused examples can reveal awkward interfaces and misplaced responsibilities. They cannot select a sound system architecture by themselves.

Architecture also needs product discovery, quality-attribute analysis, integration evidence, experiments, and deliberate decisions about boundaries and deployment.

A walking skeleton can probe an initial architecture. Its result remains provisional rather than proof that the larger design is correct.

### “TDD damages design”

Tests can encourage interfaces, dependency injection, indirection, and fragmented responsibilities that the production problem never required.

This happens when design is optimized for isolated mockability instead of useful controllability, observability, and domain boundaries.

Writing a test first does not require mocking every collaborator. Run fast deterministic owned code together and introduce substitution where a real boundary justifies it.

The test should make a production interface easier to use. It should not make every internal function replaceable.

### “Tests can also be wrong”

A passing test proves only that the observed outcome matched its oracle. The requirement, example, test data, boundary, or implementation can still be wrong.

Derive expected results independently, review consequential examples, and use several forms of evidence when one oracle cannot cover the risk.

Delete obsolete tests and revise tests when the intended contract changes. Preserving an incorrect specification is not safety.

### “TDD slows obvious work down”

On an obvious, low-risk, short-lived change, formalizing every small step may cost more than it reveals.

Use Obvious Implementation when the solution is clear. TDD still requires an observed behavioral Red, but it does not require artificial hard-coding or unnecessary triangulation.

The trade is effort now for possible savings in misunderstanding, debugging, regression detection, and future change. Reduce the ceremony when those benefits are unlikely.

### “Strict micro-cycles do not fit every change”

Schema migrations, distributed protocols, and cross-cutting changes may need a coherent slice before any useful test can execute.

Keep one behavioral decision in flight, but let the smallest coherent step match the system. “Small” is a feedback property, not a fixed line count or time limit.

### “Tests calcify the code”

A suite coupled to private methods, call order, framework details, or storage structure makes harmless refactoring expensive.

That suite is a liability whether its tests were written before or after the implementation.

Behavior-focused tests reduce this problem but do not remove maintenance cost. Intended behavior changes still require test changes.

### “TDD does not fit my domain”

Some domains lack stable exact outcomes. Aesthetic judgment, model quality, emergent behavior, and exploratory analysis may require review, experiments, datasets, or monitoring.

Scope TDD to parts with useful executable oracles. These may be examples, invariants, statistical thresholds, or controlled properties rather than exact outputs.

An ML system may use ordinary tests for schemas and transformations while model quality uses dataset evaluation and production monitoring.

The claim is never “test-drive everything.”

### “TDD gets credit for ordinary engineering practices”

Test-first timing, small batches, automation, regression tests, and refactoring are separable mechanisms. Teams can use some without adopting canonical TDD.

TDD packages them into a disciplined feedback sequence. Its value should be judged against the actual alternative, not against an imaginary process with no checking or design thought.

## Starting a new project

Begin with a **walking skeleton**: the thinnest end-to-end slice that proves the build, test runner, delivery path, and runtime can work together.

The first behavior may be a service answering a health request. This removes delivery uncertainty before application logic accumulates.

Treat the skeleton as a provisional architecture probe. It demonstrates connection and deployability, not business correctness or long-term architectural fitness.

Then choose one thin stakeholder-visible capability. An outer acceptance example can give it a destination; focused inner cycles develop the rules and interfaces needed to reach it.

Do not design a complete acceptance suite in advance. Let one completed slice teach the team about vocabulary, architecture, infrastructure, and feedback cost.

Keep required gates trustworthy. An unfinished outer example may remain pending, branch-local, or excluded from required gates until it represents behavior expected to pass.

The greenfield sequence is therefore:

1. establish the smallest runnable build, test, and delivery skeleton;
2. select one stakeholder-visible capability;
3. frame one concrete behavior and its oracle;
4. drive its inner behavior through observed Red–Green–Refactor cycles;
5. verify the assembled slice with the appropriate outer evidence;
6. use what was learned to select the next slice.

Chapter 7 follows this sequence in a complete example.

## Starting in legacy code

Legacy code may not permit a clean Red–Green–Refactor cycle immediately. Hard-wired dependencies and unknown behavior can prevent safe observation.

Begin with the risk of the intended change, not a blanket coverage campaign.

When possible, characterize behavior that must remain stable before restructuring. A characterization test records current behavior; it does not declare that behavior desirable.

Sometimes no useful test can run until a dependency is broken. In that case, introduce the smallest behavior-preserving seam needed to gain control or observation.

That preparatory edit is risky because it lacks a test. Keep it mechanical, review it carefully, and obtain the best available external evidence before proceeding.

The legacy sequence is:

1. identify the intended change and the behavior at risk;
2. observe the current system through the best available boundary;
3. introduce a minimal seam first when no test can otherwise run;
4. characterize only behavior that must remain stable;
5. establish an observed Red for the new or corrected behavior;
6. make the smallest coherent Green change;
7. refactor under the improved evidence.

Questionable existing behavior needs domain review before it becomes a long-term specification. Approval testing can help capture complex output for that review.

Adoption is incremental. Each touched area should leave behind clearer boundaries and more useful evidence than it had before.

## Coverage without coverage theatre

Coverage can reveal code the suite never executes. It cannot establish requirement completeness, oracle strength, or fault detection by itself.

Use it to ask questions:

- Why is this changed branch unexercised?
- Is the code unreachable, low risk, or missing an example?
- Did configuration omit part of the suite?
- Does a regulatory objective require structural evidence?

Avoid using a percentage as an individual performance goal. Once rewards depend on the number, weak assertions and low-value tests become rational responses.

Regulated or safety-critical work may require structural coverage objectives. Meet them while preserving the distinction between executed structure and demonstrated correctness.

Mutation testing can reveal assertions that miss selected faults. Inspect meaningful survivors instead of replacing one gamed score with another.

## Signals worth discussing

No single metric represents test quality or engineering confidence.

Useful observations include:

- time from a change to a trustworthy diagnosis;
- flaky-test rate and time spent investigating noise;
- escaped-defect themes and recurrence;
- change-failure and recovery patterns;
- mutation survivors in critical logic;
- maintenance cost of important suites;
- ease of changing a business rule without unrelated breakage.

Use these signals to investigate the system, not to rank individual developers.

## Test-suite health

A retained suite is part of the production feedback system and requires maintenance.

Treat flaky tests as defects. Classify shared state, timing, nondeterminism, environment, infrastructure, and oracle failures.

Temporary quarantine needs an owner, reason, issue, and repair path. Permanent quarantine is deletion with extra noise.

Broader tests should retain diagnostic artifacts. Without logs, identifiers, traces, or screenshots, realism often produces only expensive uncertainty.

Delete redundant tests when cheaper evidence answers the same question. Rewrite tests that resist legitimate refactoring. Update examples when intended behavior changes.

## Introducing TDD to a team

Adoption needs practice and feedback, not only a policy.

Start with a bounded pilot where behavior has a useful oracle and the cost of regression is visible. Pair or review early cycles so the team can discuss Red quality, boundaries, and test coupling.

Retrospectives should examine whether the loop reduced uncertainty and how much maintenance it created. Adjust the practice rather than enforcing ritual.

A practical team policy is:

- state the behavior and relevant risk before implementation;
- observe Red for new or corrected behavior with an executable oracle;
- select the shortest trustworthy feedback loop faithful to that risk;
- use broader evidence for infrastructure, compatibility, and deployed behavior;
- introduce doubles and seams only when control or observation justifies them;
- treat coverage and mutation results as prompts for investigation;
- maintain fast, standard, and thorough feedback lanes;
- reconsider tests whose maintenance cost exceeds the evidence they provide.

## Sources and further reading

- David Heinemeier Hansson, [TDD is dead. Long live testing.](https://dhh.dk/2014/tdd-is-dead-long-live-testing.html)
- Kent Beck, [Canon TDD](https://newsletter.kentbeck.com/p/canon-tdd)
- Michael Feathers, *Working Effectively with Legacy Code*
- Michael Feathers, [The Seam Model](https://www.informit.com/articles/article.aspx?p=359417&seqNum=2)
- Martin Fowler, [Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
- Freeman and Pryce, [Growing Object-Oriented Software, Guided by Tests](https://www.oreilly.com/library/view/growing-object-oriented-software/9780321574442/)
- Rafique and Mišić, [The Effects of Test-Driven Development on External Quality and Productivity](https://doi.org/10.1109/TSE.2012.28)
- Munir et al., [Considering rigor and relevance when evaluating test driven development](https://doi.org/10.1016/j.infsof.2014.01.001)
