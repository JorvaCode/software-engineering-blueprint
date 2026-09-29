# 01 — Requirements Specification

## Objective
Convert a business or technical need into a clear, testable specification.

## Information items
### Inputs
- **Problem or opportunity** — the trigger, stated as a need rather than a solution.
- **Stakeholders** — who is affected by the change and who decides on it.
- **Constraints** — regulatory, contractual, technical and organisational, each with its source.
- **Existing system context** — what exists today, so the requirement is anchored to reality rather than to assumption.

### Outputs
- **Problem statement** — the need, the affected parties, and why it matters now. Use `templates/requirement.md`.
- **Scope** — what is in scope and, explicitly, what is not.
- **Functional requirements** — numbered `FR-nn`, each independently testable and each stating one behaviour.
- **Non-functional requirements** — numbered `NFR-nn`, each naming the quality attribute it constrains and a threshold where one applies.
- **Acceptance criteria** — at least one per functional requirement, written so a test can fail against them, each naming its verification method.
- **Risks and assumptions** — each assumption stating what breaks if it is false.

## Quality gate
Every functional requirement in `templates/requirement.md` is numbered, testable and feasible, and each has at least one acceptance criterion that names its verification method. A reviewer who did not write the requirement can write the test that decides it, and reaches the same verdict.

## Template
Use `templates/requirement.md`.
