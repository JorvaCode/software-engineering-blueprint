# Changelog

All notable changes to the Software Engineering Blueprint are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to Semantic Versioning.

## [Unreleased]

### Added

- **Licence** — the repository is now licensed under [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0), with the complete legal code. Previously the default copyright applied, which meant the reuse the project invites from its installers was not actually licensed.
- **Repository governance** — `CONTRIBUTING.md` (working rules and order of authority for human contributors), `SECURITY.md` (private vulnerability reporting, with acknowledgement and triage targets), `CODE_OF_CONDUCT.md`, `.github/CODEOWNERS`, bug and change-proposal issue templates, and a pull request template that requires declaring the lifecycle phase and a falsifiability check on any new quality gate.
- **`.editorconfig`** — encoding, line endings, indentation and final-newline rules.
- **`markdownlint-cli` gate** — a `markdown-lint` CI job with the version pinned to `0.49.1`, configured through `.markdownlint.json`. The configuration records the house style: long lines allowed, compact headings and lists.
- **ADR-007** — records the licence choice, the governance set, and why `lychee` and Vale were rejected for the documentation linting.

### Changed

- **OpenCode skills reduced to routers** — `blueprint` and the four phase skills no longer duplicate the normative lifecycle. They now map each phase to its document in `blueprint/` and declare all paths as relative to the project root, so the adapter cannot silently drift from the core.
- **README** — documents the skill/agent split, the agent location, why the adapter ships no primary agent, the governance files, and the licence.
- **CI** — the structure check now asserts the governance files and that `LICENSE` carries the CC BY 4.0 legal code, and ADR-007 is a required record.

### Fixed

- **Template placeholders** — the `<ID>`, `<Title>` and `<Decision title>` tokens in `templates/` are now marked as code, so they render as placeholders instead of being parsed as HTML.
- **Consistency** — the `.opencode/skills/<name>/SKILL.md` path is marked as code in the two ADRs and the requirements document, where the rest of the repository already did so.
- **Trailing newlines** — six files ended without a final newline.

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
