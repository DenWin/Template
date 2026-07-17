# TDD knowledge base

This directory separates a human learning path from the compact instructions an AI agent needs while changing code.

The human chapters are the teaching authority. The `develop-with-tdd` folder is a self-contained execution package; it does not load the human curriculum during development.

## Choose a route

| Reader or need                                           | Start here                                                                               | Continue with                                      |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------- |
| New to TDD                                               | [Why TDD exists](guide/01-why-tdd.md)                                                    | Practise -> misconceptions -> first worked example |
| Ready to try one cycle                                   | [Practising TDD deliberately](guide/02-practising-tdd.md)                                | Greenfield example in Chapter 7                    |
| Skeptical of TDD                                         | [Applying TDD without dogma](guide/06-applying-tdd-without-dogma.md)                     | Research findings and worked examples              |
| Changing legacy code                                     | [Legacy guidance](guide/06-applying-tdd-without-dogma.md#starting-in-legacy-code)        | Legacy worked example                              |
| Choosing focused, integration, contract, or E2E evidence | [Choosing evidence and feedback lanes](guide/04-choosing-evidence-and-feedback-lanes.md) | Decision examples and adjacent practices           |
| Introducing TDD to a team                                | [Team adoption](guide/06-applying-tdd-without-dogma.md#introducing-tdd-to-a-team)        | Feedback lanes and maintenance model               |
| Asking an AI agent to develop through TDD                | [`develop-with-tdd`](../../skills/develop-with-tdd/SKILL.md)                             | Installation notes below                           |
| Asking an AI agent to assess the material                | [Assessment brief](ASSESSMENT_BRIEF.md)                                                  | Guide -> research -> traceability -> skill         |

## Core learning path

These chapters form the main argument and should be read in order by a beginner:

1. [Why test-driven development exists](guide/01-why-tdd.md)
2. [Practising TDD deliberately](guide/02-practising-tdd.md)
3. [Common misconceptions and failure modes](guide/03-common-misconceptions-and-failure-modes.md)
4. [Choosing evidence and feedback lanes](guide/04-choosing-evidence-and-feedback-lanes.md)
5. [BDD and collaborative discovery](guide/05-bdd-and-collaborative-discovery.md)

## Applied guidance

1. [Applying TDD without dogma](guide/06-applying-tdd-without-dogma.md)
2. [Worked examples](guide/07-worked-examples.md)

## Reference and optional material

- [Stack-specific notes](guide/appendices/stack-specific-notes.md)
- [Glossary](guide/appendices/glossary.md)
- [Adjacent practices and further reading](guide/appendices/adjacent-practices-and-further-reading.md)

Optional material helps readers recognize when TDD needs another form of evidence. It is not prerequisite knowledge for attempting the core loop.

## Install the AI skill

The portable skill consists of `../../skills/develop-with-tdd/SKILL.md`, `../../skills/develop-with-tdd/references/`, and optional provider metadata in `../../skills/develop-with-tdd/agents/`.

### Claude Code

Copy the complete `develop-with-tdd` folder to one of:

- project scope: `.claude/skills/develop-with-tdd/`;
- global scope: `~/.claude/skills/develop-with-tdd/`.

The directory name must match the `name` in `SKILL.md`. Invoke it with `/develop-with-tdd` or allow its description to trigger it.

To make TDD the default for behavioral code, add a matching rule to `CLAUDE.md` at the same scope:

> When implementing or correcting behavior in production code, use the `develop-with-tdd` skill to establish Red, reach Green, and refactor under evidence.

Keep throwaway diagnostics and exploratory spikes outside that blanket rule.

### OpenAI

Install the complete folder in the applicable skills directory. The `agents/openai.yaml` file supplies OpenAI UI metadata.

Invoke the skill explicitly with `$develop-with-tdd` or allow model invocation when the environment supports it.

## Analysis and provenance

- [Primary-source research findings](research-findings.md)
- [Claim-to-deliverable traceability](traceability.md)
- [Maintenance model](MAINTENANCE.md)
- [Assessment brief for AI reviewers](ASSESSMENT_BRIEF.md)

Superseded source material may remain in the old working area as provenance. It is not active documentation for this package.
