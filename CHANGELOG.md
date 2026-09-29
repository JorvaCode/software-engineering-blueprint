# Changelog

All notable changes to the Software Engineering Blueprint are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to Semantic Versioning.

## [Unreleased]

### Changed

- **OpenCode skills reduced to routers** — `blueprint` and the four phase skills no longer duplicate the normative lifecycle. They now map each phase to its document in `blueprint/` and declare all paths as relative to the project root, so the adapter cannot silently drift from the core.
- **README** — documents the skill/agent split and the agent location.

### Added

- **`blueprint-orchestrator` OpenCode subagent** — autonomous full-lifecycle pass for readiness audits and per-phase gap reports, creating missing blueprint artifacts without touching application code.
- **ADR-005** — records the decision to separate the interactive skill from the autonomous subagent.
- **CI validation** — checks `.opencode/agents/` and the orchestrator agent definition.

## [1.0.0] - 2026-09-22

Initial reusable release.

### Added

- **Complete software engineering lifecycle blueprint** — a tool-agnostic, reusable process from requirements specification through deployment, observability and continuous improvement.
- **14 lifecycle phases** — Requirements, Analysis, Architecture, Technical Design, Implementation, Testing, Code Review, Security & Quality, Continuous Integration, Packaging, Continuous Delivery, Deployment, Observability, Continuous Improvement; each one defines what must happen, expected artifacts and quality gates.
- **Requirements and templates** — requirement template (`templates/requirement.md`), along with ADR and change templates, plus the formal requirements artifact for the blueprint itself (`blueprint/requirements/software-engineering-blueprint.md`).
- **Architecture and ADRs** — architecture decision records documenting the fundamental decisions of the blueprint (`blueprint/architecture/adr/`).
- **Standards** — Definition of Done (`standards/definition-of-done.md`) and Git standard (`standards/git.md`).
- **OpenCode Skills as an optional adapter** — discoverable from `.opencode/skills/<name>/SKILL.md`; OpenCode is an adapter, not a dependency.
- **Automatic validation via GitHub Actions** — CI checking repository structure, required documents/templates/standards, ADRs, OpenCode skills, internal Markdown links, and empty files.
- **Reusable workflow** — `reusable-blueprint-validation.yml` for consuming projects.
- **PowerShell and Bash installers** — `scripts/blueprint-init.ps1` and `scripts/blueprint-init.sh` to install the blueprint into an existing project (no Node, Python or external dependencies).
- **Adoption documentation** — `examples/adoption-checklist.md` including how to install the blueprint into an existing project.
- **IDE-agnostic and technology-agnostic compatibility** — usable from IntelliJ IDEA, Visual Studio, VS Code and any other IDE, with the project choosing its own language, framework, cloud, registry and deployment platform.