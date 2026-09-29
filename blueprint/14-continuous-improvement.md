# 14 — Feedback and Continuous Improvement

The lifecycle is a feedback loop.

Production and development feedback should influence future requirements, architecture and implementation.

## Sources
- Incidents
- Metrics
- User feedback
- Retrospectives
- Technical debt
- Security findings
- Performance findings

## Loop

Requirement -> Design -> Build -> Test -> Deliver -> Operate -> Learn -> Improve

## Information items
### Inputs
- **Operational feedback** — incidents, metrics, user feedback, retrospectives, technical debt, security findings and performance findings, each from a named source.
- **Previous improvement actions** — what was already changed, so the same finding is not raised twice.

### Outputs
- **Improvement items** — each stating the artifact it changes, an owner, and a link back to the feedback that produced it. A finding with no owner is a wish, not an improvement item.
- **Lifecycle changes** — the phase documents, standards, templates or ADRs this feedback changes, or an explicit record that no change is needed and why.
- **Closure record** — what was changed and what evidence the change took effect, so the loop visibly closes.

## Quality gate
Every improvement item has an owner and names the artifact it changes, and every closure record states the evidence that the change took effect. A reviewer can trace each item back to the feedback that raised it, and each change back to an item, and reaches the same verdict on whether the loop closed.
