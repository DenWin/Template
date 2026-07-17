# Why test-driven development exists

This chapter assumes that you can read a small automated test. It does not assume that you have practised test-driven development or agree that it is useful.

## TDD in one minute

Test-driven development (TDD) is a way to develop one observable behavior at a time.

A behavior is a response that matters to a caller or user. Before implementing it, the developer expresses the intended response as an executable example and runs that example.

For new behavior or a defect correction, the example must show that the current system does not yet satisfy the intended behavior. This observed, relevant failure is **Red**.

The developer then changes the production code until the example passes. This is **Green**. While the evidence remains Green, the developer may improve the structure without changing behavior. This is **Refactor**.

Together, these steps form **Red–Green–Refactor**.

The immediate value is feedback while requirements and design decisions are still cheap to change. The retained examples later provide evidence against regressions.

TDD is therefore both a development workflow and a way to produce tests. Having automated tests does not mean that the code was developed through TDD.

## TDD strengthens a familiar way of working

Many developers already work iteratively: write a small part of the code, run the application, inspect the result, and continue when it appears to work.

That is a useful feedback loop. TDD does not replace the instinct to check work. It makes the loop explicit, repeatable, and available before implementation settles the answer.

An informal loop often starts with code and checks it through a broad manual or end-to-end path. That evidence may be realistic, but it can be slow to repeat and hard to diagnose.

The result may also disappear when the developer moves on. Unless the scenario is recorded, later changes depend on someone remembering and repeating it.

TDD strengthens this loop in three ways:

- state the expected behavior before implementing it;
- use the shortest trustworthy feedback loop that faithfully exercises the current risk;
- retain the example so it can be rerun after later changes.

Each new behavior is checked alongside previously recorded behavior. This reduces the chance that an attempted improvement silently damages something that already worked.

German has a useful word for that outcome: **Verschlimmbesserung**—an attempted improvement that makes something worse.

Tests can expose such regressions only when they describe the affected behavior with a useful expectation. Incorrectly specified, unstable, or untested behavior can still regress.

## The problem begins before code is written

Most software changes sound simple: add a rule, correct a defect, or alter an existing behavior.

The first risk is not syntax. It is building the wrong outcome, overlooking an important case, or damaging behavior that should remain unchanged.

Consider the request “orders of €50 or more receive free shipping.” Before code is written, several questions appear:

- Does exactly €50 qualify?
- Is the threshold applied before or after discounts?
- Do taxes or shipping fees contribute?
- What happens in another currency?

Code can answer these questions accidentally. The first implementation may silently choose one interpretation. Tests derived from that code may then repeat the same assumptions.

TDD asks for a concrete expected outcome first. This does not guarantee the right requirement, but it makes the current interpretation visible and reviewable before implementation hides it.

## What TDD tries to improve

TDD aims to shorten several costly delays:

- the delay before an ambiguous requirement becomes visible;
- the delay before an incorrect implementation is detected;
- the delay before an awkward interface is experienced;
- the delay before a later change reveals a regression.

It does this through several modest mechanisms:

- **Requirement clarity:** an example makes an expected outcome concrete.
- **Interface feedback:** using an interface before implementing it exposes awkward inputs, outputs, and responsibilities.
- **Localized feedback:** small changes make a new failure easier to attribute.
- **Incremental design:** each example can challenge the current design before more structure accumulates.
- **Change safety:** retained examples can reveal regressions during later modification and refactoring.
- **External memory:** the suite records cases that would otherwise depend on developer memory.

These are mechanisms, not guaranteed project outcomes. Their value depends on the problem, the examples, the chosen test boundary, and the discipline of the developer.

## Why test-first and test-after provide different feedback

A test written after implementation can still verify behavior, document a contract, and detect later regressions.

It cannot influence design decisions already made. Existing code also anchors attention: the test may demonstrate what the implementation does instead of challenging what it should do.

That is the relevant difference between **test-first** and **test-after**. It concerns when feedback becomes available, not whether one test is automatically good and the other bad.

Test-first can still produce a weak test. It may assert private details or derive the expected result from the same flawed reasoning used in production.

Test timing creates an opportunity for design feedback. Test quality determines whether that opportunity is used well. Chapter 2 develops the criteria for trustworthy evidence.

## Fast feedback means more than a fast test

TDD is built around fast feedback, but test runtime is only one part of feedback speed.

The governing rule is:

> Prefer the shortest trustworthy feedback loop that faithfully exercises the current risk.

A useful loop is quick enough to guide the next decision, relevant to the behavior, repeatable, and diagnostic when it fails.

A millisecond test that bypasses the database cannot answer a question about database semantics. A slower test through the real database may be the correct Red when its semantics are the risk.

Start as narrowly as the risk permits, not as narrowly as the test framework permits. Broader evidence can then answer broader questions without forcing every inner cycle through the whole system.

The chapter on choosing evidence and feedback lanes develops this trade-off.

## What TDD does not promise

TDD does not prove that requirements are correct or complete. A precise example of the wrong requirement is still wrong.

It does not automatically create good design or a sound architecture. Tests coupled to imagined internals can encourage unnecessary interfaces, dependency injection, and brittle simulations.

It does not eliminate integration, deployment, security, usability, or operational failures. A focused test can prove a rule without proving that the assembled system works.

It is not guaranteed to make every team faster or reduce every defect rate. Research reports mixed results across different settings.

The defensible claim is narrower: TDD changes when certain questions are asked and how quickly some mistakes become visible.

Whether that feedback is worth its cost must be judged for the code and risk at hand. The chapter on applying TDD without dogma examines evidence, objections, and limits.

## One observed cycle

Suppose the agreed rule is: an order qualifies for free shipping when its discounted subtotal is at least €50.

### Establish a known baseline

Run the relevant existing tests first. If they pass, a later failure can be attributed to the new example. If they do not, record the existing failures before changing anything.

### Red: demonstrate one missing behavior

The first example defines one boundary case:

```python
def test_fifty_euros_qualifies_for_free_shipping():
    order = Order(discounted_subtotal=Decimal("50.00"))

    assert order.qualifies_for_free_shipping() is True
```

Run the test. Do not infer that it would fail, even when the change seems obvious.

The useful Red is a reproducible failure caused by the missing shipping rule. A broken fixture, wrong import, or unrelated failure does not establish that the example detects the intended problem.

If a missing method prevents the assertion from running, add only enough structure to reach the behavior. Then rerun and observe the expected behavioral failure.

This requirement applies equally to human and AI developers. Neither confidence nor generated reasoning is evidence that the test can fail.

### Green: satisfy the demonstrated behavior

Make the example pass with the smallest coherent production change:

```python
class Order:
    def __init__(self, discounted_subtotal):
        self.discounted_subtotal = discounted_subtotal

    def qualifies_for_free_shipping(self):
        return self.discounted_subtotal >= Decimal("50.00")
```

Run the same test and observe Green. Do not obtain Green by weakening the assertion, skipping the test, swallowing the failure, or silently changing the requested contract.

“Smallest” does not mean deliberately poor code. It means avoiding unrelated features, speculative abstractions, and cases that no current example or clear requirement demands.

### Refactor: improve structure without changing behavior

With the test passing, inspect production and test code. Improve names, remove duplication, or clarify responsibilities while rerunning the relevant tests.

Perhaps the threshold deserves a named policy. Perhaps no refactoring is justified yet. Refactor is an opportunity to improve structure, not a demand to invent an abstraction.

An intentional behavior change is not refactoring. It begins another cycle with a new or revised expectation.

### Continue with an informative example

A useful next example might show that €49.99 does not qualify. It examines the other side of the boundary instead of repeating the same fact with another large value.

Another example could clarify whether discounts apply before the threshold. Each example should resolve uncertainty or put useful pressure on the current design.

Finish this cycle at Green before starting the next behavior. That keeps failures attributable to a small, recent change.

## Why coverage is not the goal

Coverage reports which code a suite executed. It does not show that expectations were correct, assertions were meaningful, or important faults would be detected.

A test can execute every line without checking a result. High coverage and low confidence can therefore coexist.

Coverage remains useful as a diagnostic. An uncovered branch may reveal a missed case, and a sudden drop may reveal a configuration error.

The distortion begins when a percentage becomes the objective. People optimize for the visible number while harder questions about risk and fault detection receive less attention.

TDD often produces coverage because each new behavior is exercised by its example. Coverage is a by-product of the feedback loop, not its purpose.

Mutation testing can probe whether tests detect selected changes, but its score is also evidence to interpret rather than a universal target.

## What the retained tests become

During development, an example helps make one decision. Afterward, the retained test may serve three related purposes:

- **Specification:** it records behavior the system is expected to preserve.
- **Verification:** it supplies evidence that the current implementation satisfies that behavior.
- **Regression detection:** it warns when a later change violates the recorded behavior.

Design feedback is different because it occurs while an interface or responsibility is still being formed. The same test may contribute to all these jobs at different times.

The next chapter turns this first cycle into a deliberate practice and explains how to choose behavior, evidence, expected results, and useful next examples.

## Sources and further reading

- Kent Beck, [TDD is Kanban for Code](https://newsletter.kentbeck.com/p/tdd-is-kanban-for-code)
- Martin Fowler, [Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
- Rafique and Mišić, [The Effects of Test-Driven Development on External Quality and Productivity](https://doi.org/10.1109/TSE.2012.28)
- Munir et al., [Considering rigor and relevance when evaluating test driven development](https://doi.org/10.1016/j.infsof.2014.01.001)
