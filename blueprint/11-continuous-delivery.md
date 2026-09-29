# 11 — Continuous Delivery

Continuous Delivery takes a validated artifact through controlled release and deployment stages.

## Typical flow
CI
  -> artifact
  -> registry
  -> environment validation
  -> deployment
  -> smoke tests
  -> promotion

## Environments
Common examples:
- Development
- Test
- Staging
- Production

The exact environments depend on the project.

## Information items
### Inputs
- **Versioned artifact** — the output of `10-packaging.md`, with its identity.
- **Environment inventory** — the environments, their configuration source, and their owners.
- **Promotion criteria** — the checks and approvals each environment requires, declared rather than assumed.

### Outputs
- **Release record** — the artifact version, the identity from packaging, the environments it reached, and the timestamp of each promotion.
- **Promotion result** — the automated checks and the approvals that allowed each promotion, recorded per environment.
- **Rollback plan** — how to return to the previous version, and the evidence that it was rehearsed rather than only written down.

## Quality gate
Each promotion that happened is recorded with the checks and approvals that allowed it, and the rollback plan names a target version that was verified to work. A reviewer who did not take part in the release reaches the same verdict on what shipped and on whether it can be withdrawn.
