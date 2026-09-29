# 07 — Code Review

Review changes against requirements, architecture, maintainability, security and tests.

## Review checklist
- Requirement satisfied?
- Design consistent with architecture?
- Clear and maintainable?
- Design quality per `standards/code-design.md`?
- Any pattern or abstraction without a stated problem, evidence and scope?
- Error handling appropriate?
- Tests adequate?
- Security concerns addressed?
- Performance concerns addressed?
- No unnecessary scope?

The reviewer does not require patterns to be added. A pattern without the justification
defined in `standards/code-design.md` is a finding; the absence of a pattern is not.

## Quality gate
Required reviewers approve the change and all automated checks pass.
