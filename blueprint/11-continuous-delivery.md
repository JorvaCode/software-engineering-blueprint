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

## Gate
Promotion requires the defined automated checks and, where required, an explicit approval.
