# Test-level decision examples

Read this reference when choosing between focused, component, integration, contract, acceptance, and E2E evidence.

## Decision table

| Risk or question                                      | Smallest faithful evidence                          | What it does not prove                             |
| ----------------------------------------------------- | --------------------------------------------------- | -------------------------------------------------- |
| Shipping threshold and rounding                       | Focused domain test                                 | Database or UI wiring                              |
| ORM translation, collation, transaction, or migration | Integration test against the relevant engine        | Complete user workflow                             |
| Consumer request/response compatibility               | Consumer-driven contract plus provider verification | Provider business correctness or deployment wiring |
| A component with real owned collaborators             | Component test through its public API               | Cross-service deployment                           |
| A critical deployed user journey                      | E2E test from an outside observer                   | Every business-rule partition                      |
| Parser invariants over large input space              | Property-based focused test                         | Production integrations                            |
| Complex legacy output                                 | Reviewed approval/characterization test             | Whether historical behavior is desirable           |

## Focused example: domain boundary

```python
def test_fifty_euros_qualifies_for_free_shipping():
    assert shipping_price(Decimal("50.00")) == Decimal("0.00")
```

This is the right level when the risk is the inclusive rule. Driving a browser to test `>=` adds cost without adding relevant evidence.

## Integration example: database semantics

```csharp
[Fact]
public async Task UsernamesAreUniqueUsingProductionCollation()
{
    await repository.Add(new User("Alice"));
    var result = () => repository.Add(new User("alice"));
    await result.Should().ThrowAsync<DuplicateUsername>();
}
```

Run this against the production database engine or a disposable instance with the relevant schema and collation. An in-memory collection cannot certify provider translation or constraint behavior.

## Contract example: compatibility

A consumer contract may state:

```json
{
  "request": { "method": "GET", "path": "/users/42" },
  "response": { "status": 200, "body": { "id": 42, "name": "Alice" } }
}
```

Consumer tests create the expectation; provider verification replays it against the provider. This catches incompatible messages without deploying the entire system. It does not prove authorization, persistence, or every provider rule.

Complete consumer-driven testing also needs provider-state setup, contract publication/versioning, and a compatibility check before release. A JSON Schema or OpenAPI check validates shape but is not the same lifecycle.

## E2E example: deployed capability

```typescript
test("customer completes checkout", async ({ page }) => {
  await page.goto("/cart");
  await page.getByRole("button", { name: "Checkout" }).click();
  await expect(
    page.getByRole("heading", { name: "Order confirmed" }),
  ).toBeVisible();
});
```

Use an E2E test for a small number of critical deployed paths. Prefer user-facing roles and outcomes, isolated test data, explicit environment ownership, and failure artifacts such as traces or screenshots.

Keep edge partitions in faster lower-level tests. Do not reproduce the full business-rule matrix through the browser.

E2E is not synonymous with browser testing. An external API, CLI, message, or protocol can be the entry point when that is how the assembled system is used.

## Complementary evidence

A feature may need several non-duplicating checks:

1. focused examples for domain rules;
2. integration tests for infrastructure semantics;
3. contracts for independently deployed boundaries;
4. one E2E path for deployment and wiring;
5. monitoring or reconciliation for effects only production can reveal.

Each check must have a distinct assurance question. Remove a slower test when a cheaper test provides the same evidence and no unique risk remains.
