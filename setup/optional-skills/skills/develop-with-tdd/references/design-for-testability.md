# Design for testability

Read this reference when behavior is hard to observe or control, or when considering a new interface, wrapper, or test double.

Testability means controlling relevant inputs and observing relevant outcomes. Mockability is one technique, not the design objective.

## Expose outcomes

Prefer a returned result or domain event over requiring tests to inspect logs or private state.

```typescript
// Observable contract
const receipt = checkout(order);
expect(receipt.status).toBe("confirmed");
```

Keep logs as operational evidence unless log content is itself a published contract.

## Control difficult boundaries

Inject time, randomness, network clients, file systems, schedulers, and external services when their real behavior would make the focused test slow, destructive, or nondeterministic.

```typescript
function expiresAt(clock: Clock): Date {
  return addMinutes(clock.now(), 15);
}
```

Pass the smallest capability needed. Avoid exposing an entire framework client when one domain operation is enough.

## Prefer operation-shaped ports

Specific:

```typescript
interface CustomerDirectory {
  findCustomer(id: CustomerId): Promise<Customer>;
  saveCustomer(customer: Customer): Promise<void>;
}
```

Over-general:

```typescript
interface RemoteClient {
  request(operation: string, payload: unknown): Promise<unknown>;
}
```

Operation-shaped ports reveal the contract and return one known shape. A generic dispatcher leaks protocol generality into callers and their doubles.

## Respect the project’s TDD school

In classicist/sociable TDD, let owned deterministic collaborators run together and substitute difficult boundaries.

In London/mockist TDD, define collaborator protocols outside-in and verify messages. Mocking an owned collaborator is expected in that style.

Do not silently mix the schools within one design area. Follow repository evidence or make the migration a project decision.

## Charge every seam rent

An interface, wrapper, or dependency-injection parameter adds concepts and maintenance. Introduce it when it creates a stable ownership boundary, controls a difficult dependency, centralizes policy, or enables meaningful substitution.

Keep direct code when an indirection exists only to satisfy a mock framework. Test-induced design damage is a signal that isolation cost exceeds assurance value.

## Keep deep modules

A useful boundary hides substantial implementation choices behind a small contract. Avoid one-interface-per-class structures that expose the same decomposition in production and tests.

## Verify the boundary itself

A double verifies code on one side of a port. Add contract or integration evidence for the production adapter when compatibility or infrastructure semantics matter.
