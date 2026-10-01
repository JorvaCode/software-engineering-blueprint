# Software Engineering Blueprint

A tool-agnostic, reusable blueprint for professional software delivery, from requirements specification through Continuous Integration (CI), Continuous Delivery (CD), deployment and observability. It defines the full engineering lifecycle — the phases, the artifacts each phase must produce, and the quality gates that apply — while leaving the concrete language, framework, IDE, cloud, registry and deployment platform to each adopting project.

## Goals

- IDE-agnostic: IntelliJ IDEA, Visual Studio, VS Code, etc.
- Language-agnostic at the process level.
- Tool-agnostic where possible.
- Reusable across projects and teams.
- Compatible with AI-assisted development.
- Ready to integrate with GitHub and GitHub Actions.
- OpenCode integration is provided as an adapter, not as a dependency.

## Lifecycle

1. Requirements
2. Analysis
3. Architecture
4. Technical Design
5. Implementation
6. Testing
7. Code Review
8. Security & Quality
9. Continuous Integration
10. Packaging / Containerization
11. Continuous Delivery
12. Deployment
13. Observability
14. Feedback & Continuous Improvement

## Core principle

The blueprint defines **what must happen, what artifacts are expected, and what quality gates apply**. Individual projects choose their language, IDE, framework, cloud, registry and deployment platform.

## Normative language

Normative text states its strength deliberately. `shall` is an obligation, `should` is a recommendation that needs a recorded reason to deviate, `may` is a genuine option, and `prefer` is not modality at all. The vocabulary is defined in [standards/terms.md](standards/terms.md) and the rules in [standards/normative-language.md](standards/normative-language.md), which also derive from RFC 2119 and RFC 8174.

A quality gate is a check, not a sentiment. Every gate names the artifact inspected, the criterion it must meet, and the evidence a third party uses to reach the same verdict. See [ADR-008](blueprint/architecture/adr/adr-008-terminologia-y-modalidad-normativa.md).

## What a phase produces

Each phase in `blueprint/01` … `blueprint/14` declares an `## Information items` section with its `### Inputs` and its `### Outputs`, and every output states the content it shall hold rather than only what it is called. Naming an artifact is not specifying it: `02-analysis` used to ask for "an analysis decision", which told a reader what to call the thing and nothing about what to put in it.

[standards/information-items.md](standards/information-items.md) holds the rules: what makes a declared content list sufficient, when an item is retained, and how it is versioned. It follows **ISO/IEC/IEEE 15289:2019**, and it records one thing it does not do — the phases are checkable against themselves, but not yet against each other, so a change to a requirement has no enforced link to the design and tests that implement it. See [ADR-009](blueprint/architecture/adr/adr-009-information-items-por-fase.md).

Phase `00` is excluded from this requirement. It states principles rather than running a process, which is the same distinction ISO/IEC/IEEE 12207 makes.

## Architecture description

The architecture phase names the **stakeholders** and the **concerns** they hold before it describes any structure, because a structure is designed to satisfy concerns and a concern with no stakeholder has nobody to resolve it for. Where a single description does not serve every concern, it is split into **views**, each taken from one **viewpoint**, with the **correspondence** between them and the **rationale** declared.

Every concern that carries a threshold in the requirements phase gets a **quality attribute scenario** with six parts — source, stimulus, environment, artifact, response, response measure. The response measure is what makes the scenario falsifiable: without it the scenario restates a concern that the requirements phase already gave a number to, and that number never reaches the structural decision.

The vocabulary is defined in [standards/terms.md](standards/terms.md) from **ISO/IEC/IEEE 42010:2022**, in a narrow scope that is stated rather than implied. A single view is valid and splitting is not a goal; the same rule as principle 10 applies. Full ATAM is deliberately out of scope — it presupposes a workshop for changes far larger than most of the ones this blueprint is used for. See [ADR-010](blueprint/architecture/adr/adr-010-vistas-y-escenarios-de-atributo-de-calidad.md).

## Design quality

Design quality is checked, not assumed. `standards/code-design.md` treats SOLID and Clean Code as diagnostics that only produce a finding when they name a concrete problem, and admits a design pattern only when the design states the problem it solves, the evidence, the cost of the simpler alternative and the scope of application. Code that uses no pattern is never a defect. See [ADR-006](blueprint/architecture/adr/adr-006-calidad-diseno-codigo-solid-clean-code-patrones.md).

## Repository structure

- `blueprint/` — normative lifecycle definition.
- `templates/` — reusable project artifacts.
- `standards/` — engineering standards, including the vocabulary, the normative language and the information items.
- `AGENTS.md` — working rules for AI assistants in this repository.
- `CONTRIBUTING.md` — working rules for human contributors, and the order of authority.
- `SECURITY.md` — how to report a vulnerability privately.
- `CODE_OF_CONDUCT.md` — expectations for participants.
- `.opencode/skills/` — optional OpenCode adapter (routers to `blueprint/`).
- `.opencode/agents/` — optional OpenCode subagent for autonomous blueprint passes.
- `.github/workflows/` — example CI workflow and reusable workflow.
- `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` — contribution workflow.
- `examples/` — examples for adopting the blueprint.

The blueprint is IDE-agnostic: it can be used from IntelliJ IDEA, Visual Studio, VS Code or any other IDE. It is also technology-agnostic at the process level — each project chooses its own language, framework, cloud, registry and deployment platform.

The OpenCode integration is optional and automatically discoverable. OpenCode is an adapter, not a dependency: the blueprint works perfectly without it.

Two kinds of OpenCode component are provided:

- **Skills** (`.opencode/skills/<name>/SKILL.md`) — routers used interactively. They point at the normative phase documents in `blueprint/` and never restate them. Use the `blueprint` skill for guided, conversational work, or a phase skill (`blueprint-requirements`, `blueprint-architecture`, `blueprint-development`, `blueprint-cicd`) for a single phase.
- **Agent** (`.opencode/agents/blueprint-orchestrator.md`) — a subagent for autonomous passes with no interactive user: readiness audits, per-phase gap reports, and creating missing blueprint artifacts. It does not modify application code.

See [ADR-005](blueprint/architecture/adr/adr-005-skill-agente-adaptor-opencode.md) for the rationale behind the split.

There is deliberately **no custom primary agent**. `scripts/blueprint-init.ps1` and `scripts/blueprint-init.sh` install `.opencode/agents/` and `.opencode/skills/` into every adopting project, so a primary agent would appear in the agent cycle of every consumer — the adapter would impose a default on teams that only asked for guidance. Interactive work uses the built-in primary agent plus the `blueprint` skill. See [AGENTS.md](AGENTS.md) for the working rules in this repository.

GitHub Actions workflows belong in `.github/workflows/`.

## Validating

The validation gate lives in [`scripts/validate-blueprint.sh`](scripts/validate-blueprint.sh), not inline in a workflow. It runs in this repository's CI and it runs locally with no Actions involved:

```bash
bash scripts/validate-blueprint.sh
```

One implementation, two callers. A gate copied into two workflows is a gate that will eventually disagree with itself, and the copy nobody looks at is the one that goes stale.

The [reusable workflow](.github/workflows/reusable-blueprint-validation.yml) offered to consumers is deliberately **not** a third caller, and cannot be: it validates a *consuming* repository, `scripts/` is never installed into one, and most of this gate checks facts that only exist here (ADRs, governance, `VERSION`, this repository's own prose links). So the reusable workflow carries its own small structural floor — installed directories, all fifteen phase documents, information items declared, adoption manifest versioned — and `scripts/validate-blueprint.sh` asserts that the reusable workflow does not pretend to be this gate.

The installers are covered by their own suites, `scripts/test-installers.sh` and `scripts/test-installers.ps1`, which run both installers against a real temporary destination. An installer that is never run is not tested, and reading one does not reveal that its output cannot be captured.

## Version

The installed blueprint version is declared in the [`VERSION`](VERSION) file at the root. It carries the version this working tree produces, including a `-dev` suffix while the [CHANGELOG.md](CHANGELOG.md) has work under `[Unreleased]`.

Each installer writes `.blueprint-install.json` into the destination, recording the version that was installed, when, by which installer, and which entries were actually applied — an entry skipped because it already existed is not recorded, because it was not applied. A project can therefore answer "which blueprint is this" without searching. It cannot answer "has it been modified since" from the manifest: there is no content hash, by design, so that a consumer's local edits do not look like corruption. The installer never overwrites an existing manifest, because a hand-edited one may be more accurate than the one it would write.

There is no content hash in the manifest. `sha256sum` is not POSIX — macOS calls it `shasum` — and the installers promise not to need anything external. The version is the identifier, and it is the one the project controls. See [ADR-011](blueprint/architecture/adr/adr-011-distribucion-versionada-y-manifiesto.md).

## Installation

Install the blueprint into an existing project with the provided installers. The destination directory is created if it does not exist, and existing content is never overwritten without warning.

Windows:

```powershell
.\scripts\blueprint-init.ps1 C:\proyectos\mi-app
```

Linux/macOS:

```bash
./scripts/blueprint-init.sh /home/user/proyectos/mi-app
```

The installers copy an **allowlist** of entries, not directory trees: `blueprint/`, `templates/`, `standards/`, and `.opencode/agents/` and `.opencode/skills/` when the adapter is present. Nothing else is copied, ever — no build manifests, no lockfiles, no `node_modules`. The list is the executable definition of what the blueprint is; adding an entry to it is a distribution decision and needs an ADR.

## Quick start

Copy the relevant directories into a project or keep this repository as a centralized blueprint repository.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The gate is `.github/workflows/ci.yml`; it validates repository structure, phase documents, templates, standards, ADRs, the OpenCode adapter, every internal Markdown link, and the prose itself via `markdownlint-cli`.

Reporting and conduct go through GitHub's private channels, so neither needs a mailbox that a maintainer would have to remember to watch. See [SECURITY.md](SECURITY.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). There is no `CODEOWNERS` file: with a single maintainer there is no second account to name, and an entry that matches no account is ignored by GitHub without a warning, which would look like review enforcement while enforcing nothing. The file returns as a one-line addition when there is someone else to name. See [ADR-007](blueprint/architecture/adr/adr-007-licencia-y-gobernanza-del-repositorio.md).

## License

This work is licensed in two parts, because it contains two kinds of work.

- **Documentation** — `blueprint/`, `templates/`, `standards/`, `examples/`, this README, `CONTRIBUTING.md` and the ADR records — under the [Creative Commons Attribution 4.0 International](LICENSE) licence (CC BY 4.0). You may share and adapt it, including commercially, provided you give appropriate credit, link the licence and indicate changes.
- **Code** — the installers under `scripts/` and the workflow definitions under `.github/workflows/` — under the [Apache License 2.0](LICENSE-CODE).

The split is not a preference. Creative Commons recommends against applying a CC licence to software, because it carries no terms about distributing source code, addresses patent rights only by exclusion, and is not compatible with the major software licences. Its own FAQ says so: <https://creativecommons.org/faq/>. See [ADR-012](blueprint/architecture/adr/adr-012-licencia-del-codigo-y-distribucion-de-licencias.md).

Both installers copy `LICENSE` and `LICENSE-CODE` into the destination, unless the destination already has a `LICENSE` of its own, which is never overwritten. The two licences are also recorded in `.blueprint-install.json`, so a project can answer what the installed content is under without searching.
