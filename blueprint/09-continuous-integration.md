# 09 — Continuous Integration

CI validates every relevant change automatically.

## Typical pipeline
1. Checkout
2. Resolve dependencies
3. Build
4. Unit tests
5. Integration tests
6. Static analysis / lint
7. Security checks
8. Package
9. Publish test artifacts when useful

## Gate
A change is integrable only when required CI checks pass.

The workflow examples in `.github/workflows/` provide a technology-neutral starting point.
