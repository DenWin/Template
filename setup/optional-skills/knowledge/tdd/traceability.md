# Claim-to-deliverable traceability

This matrix connects material claims from the original draft and later reviews to their evidence, human explanation, and runtime instruction.

“Research verdict” summarizes the relevant finding in `research-findings.md`. Human and skill destinations must remain aligned when a claim changes.

| Claim or decision                                                        | Research verdict                                                                         | Human destination              | AI/skill destination                    |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | ------------------------------ | --------------------------------------- |
| TDD is primarily a design-feedback discipline                            | Defensible thesis, not a universal definition                                            | `human/01-why-tdd.md`          | `SKILL.md`; operating reference         |
| Prefer the shortest trustworthy loop faithful to the current risk        | Retain; speed includes relevance, reliability, diagnosis, and decision timing            | Human 01, 02, and 04           | Cycle invariants; feedback lanes        |
| Establish a known baseline                                               | Retain as an attribution requirement                                                     | Human 01 and 02                | Cycle invariants; step 1                |
| New or corrected behavior requires an observed Red                       | Retain as the local operating default; confidence is not evidence                        | Human 01–03 and 07             | Cycle invariants; step 3                |
| Compile or harness failures are not automatically behavioral Red         | Continue to the intended contract failure when practical                                 | Human 01–03                    | Step 3; test-design examples            |
| Green must preserve evidence sensitivity and the agreed contract         | Retain as Green integrity                                                                | Human 02–03 and 07             | Cycle invariants; step 4                |
| Refactoring preserves behavior and runs under Green                      | Retain; intentional behavior change starts another cycle                                 | Human 01–03 and 07             | Cycle invariants; step 5                |
| Coverage is not the goal                                                 | Retain with diagnostic and regulatory nuance                                             | Human 01 and 06                | Operating reference                     |
| BDD arose partly from TDD teaching difficulties                          | Retain; reject a single-cause coverage story                                             | Human 05                       | Operating reference                     |
| BDD is merely renamed TDD                                                | Reject as reductive                                                                      | Human 05                       | Operating reference                     |
| BDD, ATDD, and Specification by Example are synonyms                     | Reject; preserve overlap and different emphases                                          | Human 05                       | Operating reference                     |
| Test-first and test-after provide identical design feedback              | Reject; post-hoc tests can still provide durable regression evidence                     | Human 01 and 03                | Test-design examples                    |
| Every transforming function needs a test                                 | Retain only as a candidate heuristic                                                     | Human 02, 03, and 06           | Operating reference                     |
| Fake It may be generalized during refactoring                            | Reject when new inputs gain behavior; later examples justify generalization              | Human 02, 03, and 07           | Step 4; operating reference             |
| Published and internal interfaces have identical refactoring constraints | Reject; use the governing observation boundary and compatibility contract                | Human 02 and 03                | Step 5; operating reference             |
| An unfinished outer example may remain Red in required CI                | Reject; keep it pending, branch-local, or outside required gates                         | Human 04–06                    | Entry strategies                        |
| A test without an explicit assertion has no value                        | Replace with an effective-oracle rule                                                    | Human 02 and appendix          | Test-design examples                    |
| Mutation score measures complete test quality                            | Treat as a fault-sensitivity proxy with limitations                                      | Human 01, 06, and appendix     | Operating reference                     |
| Contract tests prove provider correctness                                | Narrow to exercised compatibility                                                        | Human 04, 07, and glossary     | Test-level examples; broader operations |
| Mocks prove payment or delivery occurred                                 | Reject; mocks prove the visible requested interaction                                    | Human 03, 04, 07, and appendix | Test-design examples                    |
| London TDD mocks only external code                                      | Reject; it commonly mocks owned collaborators                                            | Adjacent-practices appendix    | Design-for-testability                  |
| A test pyramid prescribes universal counts                               | Replace with architecture, risk, and unique evidence questions                           | Human 04 and appendix          | Test-level examples                     |
| SQLite is a safe universal database substitute                           | Reject; decide from semantic fidelity                                                    | Stack appendix and Human 07    | Test-level examples                     |
| Tests are the only assurance mechanism                                   | Reject; include complementary evidence                                                   | Human 04–06 and appendix       | Operating reference                     |
| TDD applies only to deterministic systems                                | Replace with the useful-executable-oracle criterion                                      | Human 02, 03, 06, and appendix | Entry strategies                        |
| TDD is empirically proven superior                                       | Reject universal causal guarantees                                                       | Human 01, 03, and 06           | Operating reference                     |
| One test level should prove the whole feature                            | Reject; assign each boundary a distinct assurance question                               | Human 03, 04, and 07           | Test-level examples                     |
| Mockability is the design objective                                      | Reject; optimize controllability and observability while charging seams for indirection  | Human 03, 07, and appendix     | Design-for-testability                  |
| Greenfield TDD begins with a complete up-front test design               | Reject; use a provisional walking skeleton and one thin slice                            | Human 06 and 07                | Entry strategies                        |
| Legacy characterization must always precede a seam                       | Reject; a minimal behavior-preserving seam may be needed before any test can run         | Human 06 and 07                | Entry strategies                        |
| Characterization test Green is equivalent to a TDD Red                   | Reject; characterization records current behavior before the new-behavior cycle          | Human 03, 06, and 07           | Entry strategies                        |
| Test level determines execution cadence                                  | Reject; classify lanes from measured cost, reliability, environment, diagnosis, and risk | Human 04 and 07                | Feedback lanes                          |
| Fast, standard, and thorough lanes need universal durations              | Reject; use project-specific budgets and repository commands                             | Human 04                       | Feedback lanes                          |
| A fast irrelevant test is preferable to a slow faithful test             | Reject                                                                                   | Human 01, 03, 04, and 07       | Cycle invariants; feedback lanes        |
| Unrun checks may be implied by a Green result                            | Reject; report commands, omitted lanes, and remaining uncertainty                        | Human 02, 04, and 07           | Cycle invariants; step 7                |

## Audit rule

When a material claim changes, update its research verdict first, then every destination in that row.

The change is complete only when human explanations, skill behavior, conditional references, examples, glossary terms, and this matrix agree.
