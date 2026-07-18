# Stack-specific notes

These examples cover stacks used in the surrounding project. They are not an exhaustive framework catalog.

General TDD principles remain stable while framework details change. Follow repository conventions first, then use these notes when a runtime affects test behavior or design.

Read the core chapters before treating stack mechanics as instructions. A framework does not decide which behavior matters or which evidence answers its risk.

## PowerShell and Pester

- PowerShell’s success stream can turn an expected scalar into an array. Assert exact type and value when output shape is part of the contract.
- Set strict error behavior in test setup so unexpected non-terminating errors cannot masquerade as useful output.
- Pester mocks replace commands within scope and retain call history. Prefer an owned boundary when cmdlet mocking would couple behavior tests to command decomposition.
- Keep modules with business logic distinct from one-off diagnostic scripts.

See the official [Pester Mock command](https://pester.dev/docs/commands/Mock) reference.

## Python and pytest

- Match the existing framework. Pytest is a common default for new Python work, not a universal mandate.
- Use plain assertions and independently derived expected values.
- Default mutable fixtures to function scope. Broader fixture scope requires explicit reset or immutability.
- Patch where a name is looked up. Prefer an owned boundary when patching a third-party client would expose incidental protocol details.
- Use properties for parsers, serializers, round trips, and transformations with large input spaces.
- Test async code with the project’s async plugin and async-aware doubles.

See the official [pytest fixture](https://docs.pytest.org/en/stable/how-to/fixtures.html) and [monkeypatch](https://docs.pytest.org/en/stable/how-to/monkeypatch.html) guides.

## SQL and database-backed code

- Use the production engine when dialect, query translation, transactions, constraints, migrations, locking, or concurrency participate in the risk.
- A fake database is appropriate only when its semantic differences cannot affect the behavior under test.
- Isolate each test’s data through rollback, schema or database isolation, or deterministic cleanup.
- Treat migrations as executable compatibility paths. Test clean installation and representative upgrades.
- Separate correctness tests from performance experiments. Performance needs representative data and a controlled environment.

Microsoft’s [EF Core testing strategy](https://learn.microsoft.com/en-us/ef/core/testing/choosing-a-testing-strategy) describes SQLite, in-memory-provider, and query differences.

Testcontainers provides [database testing guides](https://testcontainers.com/guides/getting-started-with-testcontainers-for-dotnet/) for disposable real engines.

## C# and .NET

- Follow the repository’s xUnit, NUnit, or MSTest convention and its assertion library.
- Await asynchronous operations. Blocking with `.Result` or `.Wait()` changes failure and deadlock behavior.
- Use `WebApplicationFactory` when the ASP.NET Core request pipeline is the relevant observation boundary.
- Treat EF Core’s InMemory provider and SQLite as fakes with different semantics, not proof of production-database behavior.
- Inject `TimeProvider` or another clock at time-sensitive boundaries.
- Set culture explicitly where formatting or parsing behavior depends on it.

See Microsoft’s [ASP.NET Core integration-test guidance](https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests) and [EF Core testing overview](https://learn.microsoft.com/en-us/ef/core/testing/).

## Why these notes remain an appendix

Stack guidance is human reference, not a hard-coded skill policy. The skill inspects the repository because framework versions and project conventions change faster than the core cycle.
