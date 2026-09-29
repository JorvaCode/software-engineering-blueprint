# Changelog

All notable changes to the Software Engineering Blueprint are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/) and this project adheres to Semantic Versioning.

## [Unreleased]

### Added

- **Information items for all fourteen process phases** — every phase in `blueprint/01` … `blueprint/14` now carries an `## Information items` section stating its `### Inputs` and `### Outputs`, with each output naming the artifact *and* the content it shall hold. The fourteen quality gates were rewritten against the three-part test in `standards/normative-language.md` so that each one names its artifact, its criterion and its evidence. Phase `00` is excluded: it states principles rather than running a process, the same distinction ISO/IEC/IEEE 12207 makes.
- **`standards/information-items.md`** — the cross-cutting rules: what makes a declared content list sufficient, when an item is retained, how it is versioned, and the known limitation that this standard does not create cross-phase traceability. Derives from **ISO/IEC/IEEE 15289:2019**, and records the 12207 division of labour that leaves information-item content to 15289.
- **ADR-009** — records the information items decision, and why fourteen per-phase templates were rejected as disproportionate, why the declaration lives in the phase while the method lives in the standard, and explicitly what the ADR does not do: no new artifacts, no new numbers, and no traceability mechanism.
- **Architecture description vocabulary** — `standards/terms.md` gains ten terms from **ISO/IEC/IEEE 42010:2022** (stakeholder, concern, viewpoint, view, view type, model, correspondence, rationale, quality attribute scenario, sensitivity), each defined in a deliberately narrow sense and marked with its source. The scope is stated rather than implied: adopting 42010 in full would turn a process blueprint into an architecture framework.
- **Quality attribute scenarios** — `blueprint/03-architecture.md` gains a six-field scenario table (source, stimulus, environment, artifact, response, response measure), required for every concern that carries a threshold in phase 01. The response measure is the field that makes a scenario falsifiable: without it the scenario restates a concern that phase 01 already gave a number to, and the number never reaches the structural decision.
- **Stakeholders and concerns** — phase 03 declares them before the structure, because a structure is designed to satisfy concerns and a concern with no stakeholder has nobody to resolve it for. A full register is *not* required: a project states the stakeholders it knows and records the gap. Neither an absent register nor a guessed one is a defect.
- **ADR-010** — records the views, stakeholders and QAS decision, and why full ATAM was rejected as disproportionate: a workshop with a panel and a facilitator presupposes a change far larger than most of the ones this blueprint is used for.

- **`standards/normative-language.md`** — declares the modality vocabulary (`shall`, `should`, `may`, and why `prefer` is not one), the normative and non-normative status of every location in the repository, and a three-part test for a quality gate that can be falsified: it names the artifact, the criterion, and the evidence. Derives from RFC 2119 and RFC 8174, and declares the deliberate lowercase deviation from RFC 2119's all-caps rule rather than leaving it implicit.
- **`standards/terms.md`** — glossary of the load-bearing terms, each marked as inherited from a published standard or defined locally. Includes the **significant decision** criteria, which give the word "important" in the architecture phase a threshold with five objective tests.
- **ADR-008** — records the vocabulary decision, why RFC 2119 §4's caution against imposing a method does not transfer to a process blueprint, and why the option of aligning every phase with ISO/IEC/IEEE 15289 is split into its own ADR.

- **Licence** — the repository is now licensed under [Creative Commons Attribution 4.0 International](LICENSE) (CC BY 4.0), with the complete legal code. Previously the default copyright applied, which meant the reuse the project invites from its installers was not actually licensed.
- **Repository governance** — `CONTRIBUTING.md` (working rules and order of authority for human contributors), `SECURITY.md` (private vulnerability reporting, with acknowledgement and triage targets), `CODE_OF_CONDUCT.md`, `.github/CODEOWNERS`, bug and change-proposal issue templates, and a pull request template that requires declaring the lifecycle phase and a falsifiability check on any new quality gate.
- **`.editorconfig`** — encoding, line endings, indentation and final-newline rules.
- **`markdownlint-cli` gate** — a `markdown-lint` CI job with the version pinned to `0.49.1`, configured through `.markdownlint.json`. The configuration records the house style: long lines allowed, compact headings and lists.
- **ADR-007** — records the licence choice, the governance set, and why `lychee` and Vale were rejected for the documentation linting.

### Changed

- **`blueprint/04-design.md` and `blueprint/06-testing.md`** — both now consume the scenarios instead of choosing test levels independently. The design derives its levels from the response measures, and testing records which response measures are verified and by which check. Without these two links the mechanism would be decorative: phase 03 would produce scenarios nobody executes.
- **Unfalsifiable quality gates** — the fourteen gates no longer ask whether something is "clear, testable, feasible", "clear and maintainable", or "operationally significant". Each now names what a reviewer inspects: the numbered requirement and its verification method, the test run result and criterion coverage, the pipeline run where a skipped *required* check fails the run, the artifact identity a consumer can verify, the rehearsed rollback, and the alert-to-runbook mapping.
- **Phases that had no gate** — `12-deployment` and `14-continuous-improvement` gained one. `13-observability` keeps its scope and still introduces no SLI or SLO.
- **`blueprint/07-code-review.md`** — the checklist item "Clear and maintainable?" is replaced by a question the reviewer can actually answer from the code: does each new name assert a decision or a behaviour a third party can check?
- **Definition of Done** — gains a check that any information item introduced or changed states its content, per `standards/information-items.md`.
- **`blueprint/03-architecture.md`** — the ADR requirement and the quality gate no longer contradict each other. A significant decision, as defined in `standards/terms.md`, shall be recorded; recording one that is not significant is permitted and is not a defect. The gate now names the evidence a non-participant reviewer uses.
- **Definition of Done** — gains a verification method per acceptance criterion, a check that new vocabulary is added to `standards/terms.md`, a modality check, and a falsifiability check for any gate introduced or changed.
- **`AGENTS.md`** — loads the vocabulary and the normative language on demand, and adds two working rules: write normative text with deliberate modality, and never write a gate that cannot fail.
- **OpenCode skills reduced to routers** — `blueprint` and the four phase skills no longer duplicate the normative lifecycle. They now map each phase to its document in `blueprint/` and declare all paths as relative to the project root, so the adapter cannot silently drift from the core.
- **README** — documents the skill/agent split, the agent location, why the adapter ships no primary agent, the normative language, the governance files, and the licence.
- **CI** — the structure check now asserts the governance files and that `LICENSE` carries the CC BY 4.0 legal code, and ADR-007, ADR-008 and ADR-009 are required records.
- **CI gates for information items** — three new checks, each mutation-tested: a phase that drops `## Information items`, `### Inputs` or `### Outputs`; an output bullet that names an artifact without stating content; and a gate that regresses to the recorded unfalsifiable phrasings. The standard is also required to be reachable from `AGENTS.md` and the Definition of Done, and to keep stating the traceability limitation it does not solve.
- **CI gates for quality attribute scenarios** — four more checks, each mutation-tested: all six QAS fields present in the phase 03 table, phase 04 deriving its test strategy from the scenarios, phase 06 recording which response measures are verified, and the 42010 vocabulary defined and cited in `standards/terms.md`. The citation check matches the full standard designation rather than the bare number, because a check that only greps `42010` passes when `ISO/IEC/IEEE` is corrupted.
- **The reusable workflow no longer under-validates** — `reusable-blueprint-validation.yml` ran three `test -d` calls and nothing else, while being offered to consumers as blueprint validation. It now runs the same `scripts/validate-blueprint.sh` as the blueprint's own CI, scoped to the structural floor a consumer needs: the installed directories exist, all fifteen phase documents exist, each process phase declares its information items, and the manifest records a version. Checks that only make sense in this repository — ADRs, governance, `VERSION`, the adapter — are out of scope for a consumer.

- **`VERSION`** — the version this working tree produces, currently `1.1.0-dev` while this section is `[Unreleased]`. It carries the suffix rather than claiming `1.1.0`, because a number that lies is worse than a number with a suffix.
- **Adoption manifest** — both installers write `.blueprint-install.json` into the destination, recording the version installed, when, by which installer, and which entries were applied, so a project can answer "which blueprint is this" without searching. An existing manifest is never overwritten, because a hand-edited one may be more accurate.
- **`scripts/validate-blueprint.sh`** — the whole structural and content gate, extracted from the workflow so it runs in CI, in the reusable workflow, and locally with no Actions involved. It previously existed only inline in `ci.yml`, which meant every gate added to it had to be re-typed to be tested locally.
- **Installer test suites** — `scripts/test-installers.sh` and `scripts/test-installers.ps1` run both installers against a real temporary destination, assert the allowlist does not leak, and assert the installed copy is usable. Run in CI; `ubuntu-latest` ships `pwsh`, so the PowerShell path is covered there too.
- **CI gates for distribution** — checks that `VERSION` exists and is non-empty, that the README references it, that both installers declare an allowlist covering `.opencode/agents` and `.opencode/skills`, that neither reintroduces `node_modules` cleanup, that both write the manifest and record the version, and that ADR-011 exists. All mutation-tested.
- **ADR-011** — records the allowlist, the version and manifest, the single validation implementation, and the reference-link checking; why a content hash is not in the manifest (`sha256sum` is not POSIX, and the installers promise no external dependencies); why the allowlist is per directory and not per file; and the two defects that only appeared on execution.

### Fixed

- **Installers shipped the maintainer's working copy** — both installers copied `.opencode/` wholesale and then deleted `node_modules`, so a consumer also received the maintainer's `package.json`, lockfiles and `.gitignore`. They now copy an allowlist (`blueprint`, `templates`, `standards`, `.opencode/agents`, `.opencode/skills`) and nothing else, and the `node_modules` cleanup is gone, because with an allowlist there is nothing left to clean. The failing case is covered by tests that poison the source and assert nothing leaks.
- **The PowerShell installer could not be called from another script** — it reported progress with `Write-Host`, which writes to the information stream and bypasses the success stream, so `$out = & .\blueprint-init.ps1 C:\x` returned nothing. `[Console]::Out` is not a fix; it bypasses PowerShell entirely. It now uses `Write-Output`, with errors on real stderr, matching the Bash installer.
- **`.opencode/.gitignore` could never be committed** — it ignored itself, so every contributor reinvented a different local copy. Its rules moved to the tracked root `.gitignore` and the file is gone.
- **Reference-style links and anchors were unchecked** — the validator only inspected inline links, so `[text][ref]` with no definition, and `file.md#section` pointing at a section that no longer exists, passed silently. Both are now checked, including that a *valid* reference and anchor still pass.
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
