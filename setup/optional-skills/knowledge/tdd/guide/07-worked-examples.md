# Worked examples

These examples show decisions unfolding over time. The code is illustrative Python, but the sequence applies across stacks.

Each complete example records the baseline, expected behavior, observed Red, coherent Green, refactoring decision, and broader verification.

Terms are defined in the [glossary](appendices/glossary.md).

The example repository uses illustrative lane commands:

```text
fast/local:                 pytest tests/unit -q
standard/change-validation: pytest tests/unit tests/component tests/integration -q
thorough/system-validation: pytest -q
```

Real projects should use their own measured commands and gates.

## Complete example 1: a greenfield delivery quote

A new service has a build and test command but no proven runtime or delivery path.

### Establish the walking skeleton

The team first verifies the known starting state:

```text
$ python -m compileall -q src
$ pytest --version
pytest 9.x
```

The first component example requests `/health` and expects status 200. It initially receives 404, showing that the request reaches the application but the health capability is absent.

The smallest implementation adds the route. The component example passes, and the same request succeeds after deployment to a test environment.

The skeleton now proves build, test, request routing, deployment, and runtime connection. It remains a provisional architecture probe, not evidence for any delivery-quote rule.

The first stakeholder-visible slice is a delivery quote. Orders at or above EUR 50 receive free standard delivery. The price below that threshold is still an open policy question.

### Frame the slice

The team writes a provisional test list:

- EUR 50 receives free delivery;
- determine the price below EUR 50;
- an amount above EUR 50 receives free delivery;
- invalid negative totals are rejected;
- the HTTP endpoint returns the calculated quote.

Only the first item becomes executable. The others remain reminders that may change after each cycle.

The outer HTTP example is recorded as pending while the domain rule is developed through faster inner cycles:

```python
@pytest.mark.skip(reason="delivery quote is in progress")
def test_quote_endpoint_returns_free_delivery_at_threshold(client):
    response = client.post("/quotes", json={"order_total": "50.00"})

    assert response.status_code == 200
    assert response.json() == {"standard_delivery_fee": "0.00"}
```

### Establish the baseline

The health and test-runner checks pass:

```text
$ pytest -q
1 passed, 1 skipped
```

There is no pre-existing failure that could be confused with the new Red.

### First Red

The first focused example states the inclusive threshold:

```python
def test_standard_delivery_is_free_at_fifty_euros():
    assert standard_delivery_fee(Decimal("50.00")) == Decimal("0.00")
```

A missing symbol is only an intermediate Red. After adding the callable surface without the behavior, the test reaches the contract failure:

```text
FAILED: expected Decimal("0.00"), received None
```

The failure is reproducible, attributable to the missing rule, and demonstrates that the assertion can detect its absence.

### First Green

The implementation supports the agreed range and refuses to invent the unresolved price:

```python
def standard_delivery_fee(order_total):
    if order_total >= Decimal("50.00"):
        return Decimal("0.00")
    raise QuotePolicyUndefined()
```

The focused test passes. This implementation is intentionally narrow, but it does not violate or silently invent an established requirement.

### Second Red

The product owner now decides that smaller orders cost EUR 5. The next example makes that newly agreed behavior executable:

```python
def test_standard_delivery_costs_five_euros_below_threshold():
    assert standard_delivery_fee(Decimal("49.99")) == Decimal("5.00")
```

The test fails with `QuotePolicyUndefined`. The new example now justifies behavior below the threshold.

### Second Green

```python
def standard_delivery_fee(order_total):
    if order_total >= Decimal("50.00"):
        return Decimal("0.00")
    return Decimal("5.00")
```

Both examples pass. The code handles only behavior supported by the current examples.

The pending outer example can now include the newly agreed paid-delivery outcome. It is revised while still pending:

```python
@pytest.mark.skip(reason="delivery quote is in progress")
def test_quote_endpoint_returns_standard_delivery_fees(client):
    free = client.post("/quotes", json={"order_total": "50.00"})
    paid = client.post("/quotes", json={"order_total": "12.34"})

    assert free.status_code == paid.status_code == 200
    assert free.json() == {"standard_delivery_fee": "0.00"}
    assert paid.json() == {"standard_delivery_fee": "5.00"}
```

### Review the remaining examples

An example above the threshold passes immediately because the current comparison already supports it. The team confirms that it reaches production code and retains it because the inclusive range is part of the contract.

This is useful regression evidence, but it is not presented as a Red–Green cycle.

The team then agrees that negative totals are invalid:

```python
def test_standard_delivery_rejects_negative_total():
    with pytest.raises(InvalidOrderTotal):
        standard_delivery_fee(Decimal("-0.01"))
```

The test fails because the current implementation returns EUR 5. That observed failure establishes the next Red.

The smallest coherent Green adds the validation guard. All threshold and invalid-input examples pass.

### Refactor while Green

The literals now carry domain meaning, so they are named without changing behavior:

```python
FREE_DELIVERY_THRESHOLD = Decimal("50.00")
STANDARD_DELIVERY_FEE = Decimal("5.00")


def standard_delivery_fee(order_total):
    if order_total < Decimal("0.00"):
        raise InvalidOrderTotal()
    if order_total >= FREE_DELIVERY_THRESHOLD:
        return Decimal("0.00")
    return STANDARD_DELIVERY_FEE
```

The focused tests remain Green after the structural change.

### Complete the vertical slice

The pending marker is removed. The outer example now runs and receives 404 because the quote route does not exist.

The route is added as a thin adapter over the tested rule:

```text
$ pytest tests/component/test_quotes_api.py -q
1 passed
```

The contrasting requests confirm parsing, routing, serialization, and results consistent with the domain rule. They do not prove whether the adapter delegates or duplicates that rule.

The outer check does not repeat every threshold and invalid-input partition through HTTP.

Before handoff, the standard command shown above passes. The thorough `pytest -q` lane also passes before merge because the first slice changed delivery wiring.

The next slice can now be selected from what the team learned.

## Complete example 2: correcting an existing defect

An existing percentage parser accepts negative discounts. Its current positive and zero-value tests pass.

### Establish the baseline

```text
$ pytest tests/unit/test_discounts.py -q
6 passed
```

### Establish Red

```python
def test_rejects_negative_percentage():
    with pytest.raises(InvalidDiscountError):
        parse_discount("-10%")
```

The observed result is:

```text
FAILED: did not raise InvalidDiscountError
```

This is the intended Red. A parsing error, missing fixture, or unrelated failure would not demonstrate the defect.

### Reach Green

```python
def parse_discount(text):
    value = parse_percentage(text)
    if value < 0:
        raise InvalidDiscountError("discount must not be negative")
    return value
```

The new test and the neighboring parser tests pass.

### Refactor and verify

Validation already exists in another percentage-based input. Extracting a shared domain validator removes that duplication while all examples remain Green.

The developer runs `pytest tests/unit/test_discounts.py tests/component/pricing -q` as the affected standard lane.

No browser test is added because browser behavior was not part of the defect.

The correction is test-first even though the original parser was not developed through TDD.

## Complete example 3: changing an existing contract

An order may currently be reopened at any time after cancellation. The clarified requirement permits reopening through exactly ten minutes, but not later.

This is an intentional behavior change. Existing tests are specifications to revise, not immutable obstacles.

### Establish the baseline

The existing reopening examples pass. The team confirms the new time limit with the product owner and chooses the public `reopen` operation as the observation boundary.

### Revise retained evidence and establish Red

The former unconditional example is narrowed to the still-supported behavior:

```python
def test_cancelled_order_can_be_reopened_at_exactly_ten_minutes():
    order = cancelled_order(cancelled_at=instant("10:00"))

    order.reopen(now=instant("10:10"))

    assert order.status == OrderStatus.OPEN
```

This example already passes because it describes a subset of existing behavior. It clarifies the retained contract but does not establish Red.

The next example expresses the unsupported restriction:

```python
def test_cancelled_order_cannot_be_reopened_after_ten_minutes():
    order = cancelled_order(cancelled_at=instant("10:00"))

    with pytest.raises(ReopenWindowExpired):
        order.reopen(now=instant("10:10:00.001"))

    assert order.status == OrderStatus.CANCELLED
```

The test fails because no exception is raised. That observed failure establishes Red for the changed contract.

### Reach Green

```python
def reopen(self, now):
    if now - self.cancelled_at > timedelta(minutes=10):
        raise ReopenWindowExpired()
    self.status = OrderStatus.OPEN
```

Both the retained and restricted examples pass.

### Refactor and verify

The ten-minute duration becomes a named policy value. Cancellation behavior unrelated to reopening remains unchanged.

Focused order tests and the standard order-workflow suite pass. Published clients are reviewed because compatibility is part of the observable contract.

This example shows why the runtime instruction must say “add or revise a test,” rather than only “add a test.”

## Complete example 4: entering difficult legacy code

A legacy invoice service constructs a tax client internally. Local tests cannot substitute it, and the real client requires credentials available only in the deployed test environment.

The requested change is to exempt zero-value invoices from the tax request. Existing non-zero invoice behavior must remain stable.

### Establish the best available baseline

The focused local test cannot run because construction reaches the credentialed provider. That limitation is recorded instead of being called Red.

An existing smoke check runs in the credentialed deployed test environment and passes:

```text
$ pytest tests/system/test_invoice_smoke.py -q
1 passed
```

The team will rerun this check immediately after the unprotected dependency break.

### Identify the risk

No useful characterization test can run while construction is hard-wired. The first step is therefore a minimal dependency break, not a fictional Red.

The constructor is changed to accept an optional tax client while preserving the production default:

```python
class InvoiceService:
    def __init__(self, tax_client=None):
        self.tax_client = (
            tax_client if tax_client is not None else RealTaxClient()
        )
```

This edit is mechanical but not protected by a new test. It receives careful review, then the existing system smoke check passes again.

### Characterize behavior to preserve

A deterministic fake now makes current non-zero behavior observable:

```python
def test_non_zero_invoice_requests_current_tax_amount():
    taxes = RecordingTaxClient(amount=Decimal("2.00"))
    service = InvoiceService(tax_client=taxes)

    invoice = service.create_invoice(subtotal=Decimal("10.00"))

    assert invoice.total == Decimal("12.00")
    assert taxes.requested_subtotals == [Decimal("10.00")]
```

The characterization test passes. It records the behavior at risk; it is not the Red for the requested change.

### Establish Red for the change

```python
def test_zero_value_invoice_does_not_request_tax():
    taxes = RecordingTaxClient(amount=Decimal("0.00"))
    service = InvoiceService(tax_client=taxes)

    invoice = service.create_invoice(subtotal=Decimal("0.00"))

    assert invoice.subtotal == Decimal("0.00")
    assert invoice.tax == Decimal("0.00")
    assert invoice.total == Decimal("0.00")
    assert taxes.requested_subtotals == []
```

The test fails because the fake records a request for `Decimal("0.00")`.

### Reach Green

The coherent early return still creates the required invoice:

```python
def create_invoice(self, subtotal):
    if subtotal == Decimal("0.00"):
        return Invoice(subtotal=subtotal, tax=Decimal("0.00"))

    tax = self.tax_client.calculate(subtotal)
    return Invoice(subtotal=subtotal, tax=tax)
```

The outcome assertions prevent an implementation that merely skips all work. The interaction assertion proves that zero-value invoices avoid the external request.

### Refactor and verify

Only then is tax-request construction extracted into a small private operation. Public invoice behavior remains unchanged while the tests stay Green.

The developer runs `pytest tests/unit/invoicing tests/contract/tax_provider -q`. The fake proves what the service requested; the contract check covers provider compatibility, not real settlement.

## Complete example 5: when integration evidence is the correct Red

A SQL Server application requires usernames to be unique under its production collation. An in-memory collection cannot supply that oracle.

The test uses a disposable SQL Server instance with production-relevant schema and collation.

### Establish the baseline

The existing registration integration tests pass against the disposable engine:

```text
$ pytest tests/integration/test_registration_sqlserver.py -q
4 passed
```

### Establish Red

```python
def test_username_constraint_uses_production_collation(sql_user_repository):
    sql_user_repository.insert(username="Alice")

    with pytest.raises(UsernameConstraintViolation):
        sql_user_repository.insert(username="alice")

    assert sql_user_repository.count_matching("alice") == 1
```

Both inserts succeed and the count becomes two. The new test is the only failure, and it observes the database constraint and persisted state rather than only an application return value.

### Reach Green

A production-relevant unique index is added. A separate application integration example verifies translation of that constraint violation into the duplicate-user result.

The new example and neighboring SQL Server tests pass.

### Refactor and verify

The constraint-to-domain translation is extracted behind one named mapping operation while the integration suite remains Green.

The developer runs:

```text
$ pytest tests/unit/registration tests/integration/test_registration_sqlserver.py -q
18 passed
```

The migration test also verifies clean installation and upgrade from the previous schema. A focused test may support diagnosis, but it cannot replace the database evidence.

This slower test is the correct Red because only it faithfully exercises the risk. Runtime speed is not allowed to select an irrelevant boundary.

## Compact decision examples

The remaining examples illustrate choices rather than complete development sequences.

### Requesting an external effect

A focused test can prove that checkout requested a charge:

```python
payment_gateway.charge.assert_called_once_with(order.total)
```

It does not prove settlement. Provider contracts, sandbox integration, and operational reconciliation answer different questions.

### Consumer-driven contract evidence

A consumer records the requests and responses it relies on. Provider verification replays those interactions against the provider build.

This detects exercised incompatibility without proving authorization, database behavior, unrelated endpoints, or production configuration.

Use it when independently changing consumers and providers need compatibility feedback before release.

### E2E evidence for a deployed path

One checkout E2E test can cover routing, browser behavior, deployed configuration, and service wiring.

Keep discount, tax, and validation partitions in faster tests. Capture traces, scoped logs, and screenshots so a broad failure remains diagnosable.

### Controlled nondeterminism

A retry policy with jitter can accept a seeded random source and expose bounds:

```python
delay = retry_delay(attempt=3, random_source=seeded_random)
assert minimum <= delay <= maximum
```

Distribution quality still needs repeated statistical evaluation. One exact example is not a sufficient oracle.

### Test-after evidence

A black-box test written after implementation can still provide useful specification and regression evidence.

It did not supply design feedback during the original implementation. Test timing and test quality are separate judgments.

### Testability rather than mockability

Code that constructs a payment SDK, reads the system clock, and returns nothing is hard to control and observe.

Move SDK construction to the application’s startup wiring, often called the composition root. Inject the clock and payment capability, and expose a caller-relevant outcome.

Keep deterministic owned helpers together when that gives clearer behavior tests. The number of interfaces or mocks is not a quality measure.

## What the examples demonstrate

The examples differ in scope, setup, and speed, but keep the same evidence discipline:

- know the starting state;
- choose a faithful boundary and independent oracle;
- observe meaningful Red for new or corrected behavior;
- reach Green without weakening the evidence;
- refactor only while behavior remains Green;
- run broader evidence according to risk;
- report what remains unverified.
