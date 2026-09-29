## What this change does

<!-- One or two sentences. Link the issue it closes, if any. -->

Closes #

## Lifecycle phase

<!-- Which of the 14 phases does this belong to? If a phase is skipped, say so
     explicitly. A silent skip is not accepted. -->

- [ ] Requirements
- [ ] Analysis
- [ ] Architecture
- [ ] Technical design
- [ ] Implementation
- [ ] Testing
- [ ] Code review
- [ ] Security and quality
- [ ] Continuous integration
- [ ] Packaging
- [ ] Continuous delivery
- [ ] Deployment
- [ ] Observability
- [ ] Continuous improvement
- [ ] No phase applies — this is repository governance, not a lifecycle change

## Checklist

- [ ] `CHANGELOG.md` updated under `## [Unreleased]`.
- [ ] A new ADR was added under `blueprint/architecture/adr/` if this is a significant architectural decision.
- [ ] The skills and agents in `.opencode/` were updated **only** to route to the change, never to restate it.
- [ ] Any new quality gate can be falsified — it names the artifact, the criterion and the evidence.
- [ ] No unrelated refactoring is included.
- [ ] Tests, or an explicit verification step, were added in the same change — never deferred.
- [ ] `npx --yes markdownlint-cli@0.49.1 "**/*.md"` passes.
- [ ] `.github/workflows/ci.yml` passes.

## Normative text

- [ ] Any change to `blueprint/` or `standards/` states the modality deliberately: `shall` for an obligation, `should` for a recommendation with a stated reason to deviate, `may` for an option. See [standards/normative-language.md](../standards/normative-language.md) and [standards/terms.md](../standards/terms.md).

## Review notes

<!-- Anything a reviewer should check first. Call out the riskiest part of the
     change rather than making them find it. -->
