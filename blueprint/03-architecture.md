# 03 — Architecture

Define the structural solution and its boundaries.

## Consider
- System boundaries
- Components and responsibilities
- Dependencies
- APIs and contracts
- Data ownership
- Integration patterns
- Security boundaries
- Scalability and availability
- Observability
- Deployment model

## Information items
### Inputs
- **Requirements and constraints** — the outputs of `01-requirements.md` and the analysis record, including the non-functional requirements that carry thresholds.
- **Existing system context** — the current architecture the change has to fit into.

### Outputs
- **Architecture description** — the structural solution: system boundaries, components and their responsibilities, dependencies, APIs and contracts, data ownership, security boundaries, and the deployment model. Each element states the requirement or constraint that makes it necessary, so that a component with no stated reason is visible as such.
- **Architecture decision records** — every decision that is significant, as defined in `standards/terms.md`, using `templates/adr.md`.

## Architecture decision records
A decision that is significant, as defined in `standards/terms.md`, shall be captured using `templates/adr.md`. Recording a decision that is not significant is permitted, and is not a defect.

## Quality gate
The architecture description names every component and the requirement or constraint that makes it necessary, and every significant decision is recorded as an ADR whose Status is `Accepted` or `Superseded`. A reviewer who did not participate in the change reaches the same verdict from the description and the ADR set alone.
