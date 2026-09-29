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

## Repository structure

- `blueprint/` — normative lifecycle definition.
- `templates/` — reusable project artifacts.
- `standards/` — engineering standards.
- `AGENTS.md` — working rules for AI assistants in this repository.
- `.opencode/skills/` — optional OpenCode adapter (routers to `blueprint/`).
- `.opencode/agents/` — optional OpenCode subagent for autonomous blueprint passes.
- `.github/workflows/` — example CI workflow and reusable workflow.
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
