# Software Engineering Blueprint v1.0

A tool-agnostic, reusable blueprint for professional software delivery, from requirements specification through Continuous Integration (CI), Continuous Delivery (CD), deployment and observability.

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
- `.opencode/skills/` — optional OpenCode adapter.
- `.github/workflows/` — example CI workflow and reusable workflow.
- `examples/` — examples for adopting the blueprint.

## Quick start

Copy the relevant directories into a project or keep this repository as a centralized blueprint repository.

The OpenCode skills are automatically discoverable from `.opencode/skills/<name>/SKILL.md`.

GitHub Actions workflows belong in `.github/workflows/`.

## Version

Blueprint version: `1.0.0`
Status: Initial reusable release.
