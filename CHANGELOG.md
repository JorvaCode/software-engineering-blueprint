# Changelog

All notable changes to the Software Engineering Blueprint are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to Semantic Versioning.

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