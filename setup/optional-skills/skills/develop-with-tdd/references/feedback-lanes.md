# Feedback lanes

Read this reference when selecting suite cadence, when feedback is too slow, or when the repository has no useful test grouping.

Tests retained after TDD become part of the project's verification portfolio; they are not a separate species of “TDD tests.” Test level and execution cadence are independent: a focused test may be slow, and an integration test may be fast.

## The three lanes

| Lane                           | Decision it supports                                        | Typical contents                                                                                                                                                          |
| ------------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Fast/local**                 | Is the current small edit moving in the intended direction? | The new or revised test, relevant focused tests, and fast deterministic neighboring tests                                                                                 |
| **Standard/change validation** | Is the affected area safe enough to hand off?               | Changed modules or components, relevant integrations and contracts, plus repository-required static checks                                                                |
| **Thorough/system validation** | Is the system safe enough for a risky transition?           | The full relevant portfolio, critical E2E paths, representative environments, and specialized security, performance, resilience, compatibility, or statistical evaluation |

Use repository names and commands when they already express these decisions. The lane names describe intent; they do not require three literal scripts.

## Cadence through a change

1. **Before Red:** run the smallest relevant baseline.
2. **At Red:** run the new or revised test through the smallest faithful command.
3. **At Green:** run that test and relevant fast/local neighbors.
4. **During refactoring:** rerun fast/local evidence after each meaningful structural edit.
5. **Before handoff:** run standard/change-validation evidence.
6. **Before merge, deployment, release, or another risky transition:** run thorough/system evidence when repository policy or risk requires it.

A slower integration or E2E test is the correct Red when only that boundary can detect the risk. Shorten setup and diagnostics where possible; do not substitute a fast test that answers a different question.

## Classify from evidence

Classify tests using:

- measured execution time rather than assumed test-level speed;
- reliability and state isolation;
- environment and service requirements;
- diagnostic quality;
- the risk uniquely covered;
- the decision or gate the result supports.

Avoid universal duration thresholds. Re-measure periodically because suites and infrastructure change.

## Establish or change lanes

When useful lanes do not exist:

1. inventory existing commands, tags, projects, and CI jobs;
2. measure representative execution times and flaky behavior;
3. map unique risks to the smallest faithful commands;
4. propose groupings that preserve required evidence and improve feedback;
5. treat new tags, scripts, and CI gate changes as project decisions with team ownership.

Do not silently redefine required gates while implementing a feature. The skill may recommend a lane design; apply repository-wide gate changes only when the task or user authorizes them.

## Report the signal

Name the commands and lanes actually run, their results, broader lanes omitted, and the uncertainty each omission leaves. A Green fast/local lane is not a claim that the standard or thorough lane would pass.
