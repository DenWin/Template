# Maintenance model

The knowledge base has three authorities with different jobs:

1. **Evidence authority:** `research-findings.md` owns sourced historical, empirical, and definitional findings.
2. **Teaching authority:** `human/**/*.md` owns explanations, progression, examples, and reader-facing trade-offs.
3. **Execution authority:** `develop-with-tdd/SKILL.md` and its bundled reference own agent behavior.

`analysis.md` records editorial judgments. `traceability.md` connects the authorities; it does not duplicate their full content. The original AsciiDoc draft remains provenance, not an active authority.

## Change procedure

1. Record new source evidence or a corrected interpretation in `research-findings.md`.
2. Update the affected row in `traceability.md`.
3. Update human explanation where reader understanding changes.
4. Update the skill only where runtime agent behavior changes.
5. Forward-test every changed skill branch with a task that does not reveal the intended answer.
6. Validate local links, skill metadata, language, feedback-lane commands, and matrix destinations.

Record forward-test scenarios and results in `skill-evaluation.md`. Replace hypothetical scenarios with runnable fixtures when a future change depends on stack-specific execution rather than decision quality.

Keep user-facing installation and learning guidance in the top-level `README.md`. The installable skill contains only `SKILL.md`, provider metadata, and runtime resources.

## Scope rule

Include a perspective when it materially changes at least one of:

- what behavior or risk is tested;
- where the observation boundary belongs or whether a seam is needed;
- which oracle or test double is appropriate;
- how quickly and reliably feedback arrives;
- which feedback lane should run during the cycle or before a risky transition;
- whether another assurance technique is better;
- legal, regulatory, safety, or operational obligations.

Record deliberately excluded detail in the relevant human chapter. Do not add a method merely to make the catalogue exhaustive.

Place a topic in the adjacent-practices appendix when it helps a reader recognize TDD’s boundary but does not change the ordinary Red–Green–Refactor procedure.

## Duplication rule

Repeat a short core principle only when an audience must act without loading another artifact. Keep evidence in research, explanations in human chapters, and imperatives in the skill. Link instead of copying examples or source discussions into the skill.
