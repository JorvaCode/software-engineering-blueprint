# 08 — Security and Quality

Security and quality checks are part of the delivery pipeline.

## Typical controls
- Dependency vulnerability scanning
- Secret detection
- Static analysis
- Formatting/linting
- License checks where required
- Container image scanning where applicable
- SAST/DAST where appropriate
- Architecture or dependency rule checks where the project can enforce them

## Principle
Controls should be proportional to project risk and should provide actionable feedback.
Where the project can automate part of `standards/code-design.md` — static analysis, dependency
rules, complexity or duplication thresholds — it should; the rest stays in code review.
