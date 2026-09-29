# Changelog

All notable changes to the Software Engineering Blueprint are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to Semantic Versioning.

## [Unreleased]

### Added

- **`standards/normative-language.md`** — declares the modality vocabulary (`shall`, `should`, `may`, and why `prefer` is not one), the normative and non-normative status of every location in the repository, and a three-part test for a quality gate that can be falsified: it names the artifact, the criterion, and the evidence. Derives from RFC 2119 and RFC 8174, and declares the deliberate lowercase deviation from RFC 2119's all-caps rule rather than leaving it implicit.
- **`standards/terms.md`** — glossary of the load-bearing terms, each marked as inherited from a published standard or defined locally. Includes the **significant decision** criteria, which give the word "important" in the architecture phase a threshold with five objective tests.
- **ADR-008** — records the vocabulary decision, why RFC 2119 §4's caution against imposing a method does not transfer to a process blueprint, and why the option of aligning every phase with ISO/IEC/IEEE 15289 is split into its own ADR.

- **Licence** — the repository is now licensed under [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0), with the complete legal code. Previously the default copyright applied, which meant the reuse the project invites from its installers was not actually licensed.
- **Repository governance** — `CONTRIBUTING.md` (working rules and order of authority for human contributors), `SECURITY.md` (private vulnerability reporting, with acknowledgement and triage targets), `CODE_OF_CONDUCT.md`, `.github/CODEOWNERS`, bug and change-proposal issue templates, and a pull request template that requires declaring the lifecycle phase and a falsifiability check on any new quality gate.
- **`.editorconfig`** — encoding, line endings, indentation and final-newline rules.
- **`markdownlint-cli` gate** — a `markdown-lint` CI job with the version pinned to `0.49.1`, configured through `.markdownlint.json`. The configuration records the house style: long lines allowed, compact headings and lists.
- **ADR-007** — records the licence choice, the governance set, and why `lychee` and Vale were rejected for the documentation linting.

### Changed

- **`blueprint/03-architecture.md`** — the ADR requirement and the quality gate no longer contradict each other. A significant decision, as defined in `standards/terms.md`, shall be recorded; recording one that is not significant is permitted and is not a defect. The gate now names the evidence a non-participant reviewer uses.
- **Definition of Done** — gains a verification method per acceptance criterion, a check that new vocabulary is added to `standards/terms.md`, a modality check, and a falsifiability check for any gate introduced or changed.
- **`AGENTS.md`** — loads the vocabulary and the normative language on demand, and adds two working rules: write normative text with deliberate modality, and never write a gate that cannot fail.
- **OpenCode skills reduced to routers** — `blueprint` and the four phase skills no longer duplicate the normative lifecycle. They now map each phase to its document in `blueprint/` and declare all paths as relative to the project root, so the adapter cannot silently drift from the core.
- **README** — documents the skill/agent split, the agent location, why the adapter ships no primary agent, the normative language, the governance files, and the licence.
- **CI** — the structure check now asserts the governance files and that `LICENSE` carries the CC BY 4.0 legal code, and ADR-007 and ADR-008 are required records.

### Fixed

- **Modality** — `must` becomes `shall` in the eight places where it was used as modality, since RFC 2119 defines them as exact synonyms. The two nominal uses ("what must happen") and the historical quote preserved in ADR-006 are left untouched.
- **`prefer` as pseudo-modality** — replaced with `should` in the four normative documents that used it, starting with principle 3 and the git standard.
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
