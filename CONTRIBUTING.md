# Contributing to the Software Engineering Blueprint

Thank you for contributing. This repository is the **normative definition** of a software engineering lifecycle, so a change here changes the process every adopting project follows. That raises the bar for what a pull request has to demonstrate.

Read [README.md](README.md) first, then [AGENTS.md](AGENTS.md) for the working rules.

## What this repository is

- 14 lifecycle phases in `blueprint/`, each with activities, a required artifact and a quality gate.
- Engineering standards in `standards/` that apply to every change.
- Templates in `templates/` — the required format for any artifact a phase produces.
- `.opencode/` — an **optional adapter**, not a dependency and not a source of truth.

## Order of authority

1. `blueprint/00-principles.md` … `blueprint/14-continuous-improvement.md` — normative.
2. `standards/` — engineering standards that apply to every change here.
3. `templates/` — the required format for any artifact you produce.
4. `.opencode/skills/` and `.opencode/agents/` — an adapter, not a source of truth.

If a skill and a phase document disagree, the phase document wins and the skill is a bug. This applies to the requirements, architecture, development and cicd skills, and to the `blueprint-orchestrator` agent.

## Before you open a pull request

1. **Determine the lifecycle phase** the change belongs to. Do not implement while requirements are ambiguous — ask.
2. **Inspect before assuming.** The default answer is the existing architecture.
3. **Decide whether a phase is skipped.** If one does not apply, say so explicitly. Never skip a phase silently.
4. **Add an ADR** for any significant architectural decision, in `blueprint/architecture/adr/`, following the format of the existing ones. Use the next `adr-NNN-` number.
5. **Update `CHANGELOG.md`** under `## [Unreleased]`, using [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) categories.
6. **Run the validation.** The gate is `.github/workflows/ci.yml`. It checks repository structure, phase documents, templates, standards, ADRs, the OpenCode adapter and every internal markdown link.

```bash
# Everything the CI checks, without waiting for a runner.
npx --yes markdownlint-cli@0.49.1 "**/*.md"
```

## Writing rules

This repository lints itself with `markdownlint-cli` (pinned version in `.github/workflows/ci.yml`, configuration in `.markdownlint.json`). The configuration is deliberate:

- **Long lines are allowed.** Prose stays on one line per paragraph so it reads well in a terminal and in a diff.
- **Headings and lists are not surrounded by blank lines.** The house style is compact. Do not reformat existing documents to satisfy a different style.
- Every file ends with exactly one newline, and every heading starts at level 1.

Use `shall` / `should` / `may` deliberately, following [standards/normative-language.md](standards/normative-language.md). Use the vocabulary in [standards/terms.md](standards/terms.md), and add a term there when you rely on one that is not defined. A quality gate that cannot be falsified is not a gate.

## Commit messages and branches

Follow [standards/git.md](standards/git.md) and [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Note that only `feat` and `fix` are defined by the Conventional Commits specification; the other types this project uses (`chore`, `docs`, `refactor`, `test`, `ci`, `build`) come from the `commitlint` conventional configuration.

## What we will not accept

- Unrelated refactoring bundled into a change. Split it.
- Tests deferred to a follow-up change.
- A pattern, abstraction or base class added without a stated problem behind it.
- A skill or agent that restates a phase instead of routing to it. CI rejects this.
- A change that skips a phase without saying so.

## Reporting problems

Bugs and documentation errors go through the issue templates. Security issues must **not** be filed as a public issue — see [SECURITY.md](SECURITY.md).

## Licence

By contributing you agree that your contribution is licensed under the licence of the part you contributed to. The documentation — `blueprint/`, `templates/`, `standards/`, `examples/`, this file, `README.md` and the ADR records — is under the [Creative Commons Attribution 4.0 International](LICENSE) licence (CC BY 4.0). The code — `scripts/` and `.github/workflows/` — is under the [Apache License 2.0](LICENSE-CODE) licence. See [ADR-012](blueprint/architecture/adr/adr-012-licencia-del-codigo-y-distribucion-de-licencias.md).
