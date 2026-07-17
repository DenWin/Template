# Test-design examples

Read this reference when writing or reviewing a test, choosing an oracle, or deciding whether an assertion is coupled to structure.

## Contents

- [Behavior versus decomposition](#behavior-versus-decomposition)
- [Independent oracle versus tautology](#independent-oracle-versus-tautology)
- [Relevant Red versus harness failure](#relevant-red-versus-harness-failure)
- [Public observation versus back-door inspection](#public-observation-versus-back-door-inspection)
- [Requested effect versus real effect](#requested-effect-versus-real-effect)
- [Meaningful completion versus empty execution](#meaningful-completion-versus-empty-execution)
- [Test-first versus durable test-after](#test-first-versus-durable-test-after)
- [Discriminating test data](#discriminating-test-data)
- [Factories with meaningful defaults](#factories-with-meaningful-defaults)

## Behavior versus decomposition

Structure-coupled:

```typescript
test("checkout calls calculateTax then saveOrder", async () => {
  await checkout(cart);
  expect(calculateTax).toHaveBeenCalledBefore(saveOrder);
});
```

Behavior-coupled:

```typescript
test("checkout confirms an order with the calculated total", async () => {
  const result = await checkout(cartWithItems(10, 5));
  expect(result).toEqual({ status: "confirmed", total: 15 });
});
```

Use the second form in classicist code when callers care about the result. The first form can be valid in deliberate London/mockist code when collaborator protocol and ordering are the behavior being designed.

## Independent oracle versus tautology

Tautological:

```typescript
const expected = items.reduce((sum, item) => sum + item.price, 0);
expect(calculateTotal(items)).toBe(expected);
```

Independent:

```typescript
expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
```

The first test repeats the production algorithm. Prefer a worked domain example, known literal, property, trusted reference, or reviewed baseline.

## Relevant Red versus harness failure

A useful Red reaches the intended observation boundary and fails because the behavior is absent or wrong. For example:

```text
Expected shipping price: 0.00
Received shipping price: 4.99
```

This failure demonstrates that the example can distinguish the current behavior from the requested rule.

These failures do not yet establish that signal:

```text
ModuleNotFoundError: test fixture package is missing
Connection refused before the request reached the service
SyntaxError in the test file
```

Repair the test path and run again. A missing type, symbol, or endpoint can be a relevant Red when introducing that public contract is the framed behavior; otherwise continue until the behavioral expectation itself fails.

Observe the output rather than predicting it. If the test is already Green, investigate whether the behavior exists, the test misses production code, or its data and oracle cannot distinguish a plausible fault.

## Public observation versus back-door inspection

Usually coupled to storage:

```typescript
await registerUser({ email: "a@example.com" });
expect(
  await db.query("select * from users where email = ?", ["a@example.com"]),
).toHaveLength(1);
```

Observed through the caller contract:

```typescript
const user = await registerUser({ email: "a@example.com" });
expect(await getUser(user.id)).toMatchObject({ email: "a@example.com" });
```

Direct database observation is correct when the database artifact is the contract—for example a migration, reporting table, or downstream integration. Choose from the risk, not a blanket ban.

## Requested effect versus real effect

```typescript
await placeOrder(order);
expect(paymentGateway.charge).toHaveBeenCalledWith(order.total);
```

This proves that the application requested a charge through its boundary. It does not prove settlement. Add provider contract, sandbox integration, reconciliation, or operational evidence when the real effect matters.

## Meaningful completion versus empty execution

Weak unless non-throwing is the contract:

```python
def test_import_runs():
    import_records(valid_rows)
```

Meaningful when successful completion is the behavior:

```python
def test_empty_batch_is_accepted():
    import_records([])  # any exception fails the test
```

An explicit assertion is not mandatory; an effective oracle is. Name the non-throwing contract so the test cannot masquerade as stronger verification.

## Test-first versus durable test-after

A black-box test written after implementation can still be durable specification and regression evidence. It did not provide design feedback during the original implementation. Evaluate timing and coupling separately.

## Discriminating test data

Weak examples can let plausible faults survive:

```python
assert multiply_price(10, 1) == 10
```

The multiplier identity cannot distinguish multiplication from returning the original price. Use a value such as `3` when the rule must demonstrate scaling, then add boundary values that distinguish relevant alternatives.

Ask which plausible implementation mistake each example would detect. Mutation tooling can support this reasoning, but it is not required in every cycle.

## Factories with meaningful defaults

Use a factory when repeated setup obscures behavior:

```typescript
const order = orderFactory({ status: "cancelled" });
expect(() => ship(order)).toThrow(InvalidTransition);
```

Defaults should form a valid, recognizable domain object. Override only fields relevant to the behavior. Random or unrealistic defaults make failures difficult to interpret.
