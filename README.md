# Software Engineering Blueprint v1.0.0

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
- `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/CODEOWNERS` — contribution workflow.
- `examples/` — examples for adopting the blueprint.

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

## Quick start

Copy the relevant directories into a project or keep this repository as a centralized blueprint repository.

The blueprint is IDE-agnostic: it can be used from IntelliJ IDEA, Visual Studio, VS Code or any other IDE. It is also technology-agnostic at the process level — each project chooses its own language, framework, cloud, registry and deployment platform.

The OpenCode integration is optional and automatically discoverable. OpenCode is an adapter, not a dependency: the blueprint works perfectly without it.

Two kinds of OpenCode component are provided:

- **Skills** (`.opencode/skills/<name>/SKILL.md`) — routers used interactively. They point at the normative phase documents in `blueprint/` and never restate them. Use the `blueprint` skill for guided, conversational work, or a phase skill (`blueprint-requirements`, `blueprint-architecture`, `blueprint-development`, `blueprint-cicd`) for a single phase.
- **Agent** (`.opencode/agents/blueprint-orchestrator.md`) — a subagent for autonomous passes with no interactive user: readiness audits, per-phase gap reports, and creating missing blueprint artifacts. It does not modify application code.

See [ADR-005](blueprint/architecture/adr/adr-005-skill-agente-adaptor-opencode.md) for the rationale behind the split.

There is deliberately **no custom primary agent**. `scripts/blueprint-init.ps1` and `scripts/blueprint-init.sh` copy `.opencode/` into every installing project, so a primary agent would appear in the agent cycle of every consumer — the adapter would impose a default on teams that only asked for guidance. Interactive work uses the built-in primary agent plus the `blueprint` skill. See [AGENTS.md](AGENTS.md) for the working rules in this repository.

GitHub Actions workflows belong in `.github/workflows/`.

## Version

Blueprint version: `1.0.0`
Status: Initial reusable release.

See [CHANGELOG.md](CHANGELOG.md) for the release history.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The gate is `.github/workflows/ci.yml`; it validates repository structure, phase documents, templates, standards, ADRs, the OpenCode adapter, every internal Markdown link, and the prose itself via `markdownlint-cli`.

Two maintainer-owned placeholders must be completed before this repository is published: the private reporting contact in [SECURITY.md](SECURITY.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), and the team in [.github/CODEOWNERS](.github/CODEOWNERS). See [ADR-007](blueprint/architecture/adr/adr-007-licencia-y-gobernanza-del-repositorio.md).

## License

This work is licensed under the [Creative Commons Attribution 4.0 International](LICENSE) licence (CC BY 4.0). You may share and adapt it, including commercially, provided you give appropriate credit, link the licence and indicate changes.
