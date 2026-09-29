# AGENTS.md

Working rules for AI assistants in this repository.

## What this repository is

The normative definition of a software engineering lifecycle: 14 phases, the artifact each
phase must produce, and the quality gates that apply. It is IDE and technology agnostic.
Read `README.md` first.

## Order of authority

1. `blueprint/00-principles.md` … `blueprint/14-continuous-improvement.md` — normative.
2. `standards/` — engineering standards that apply to every change here.
3. `templates/` — the required format for any artifact you produce.
4. `.opencode/skills/` and `.opencode/agents/` — an **adapter**, not a source of truth.

If a skill and a phase document disagree, the phase document wins and the skill is a bug.
This applies to the requirements, architecture, development and cicd skills, and to the
`blueprint-orchestrator` agent.

## Reference loading

Read phase documents on demand. Do not preload the lifecycle.

- Requirements and analysis: `blueprint/01-requirements.md`, `blueprint/02-analysis.md`
- Architecture and design: `blueprint/03-architecture.md`, `blueprint/04-design.md`
- Implementation, testing, review, quality: `blueprint/05-implementation.md` … `blueprint/08-security-quality.md`
- Pipeline, delivery, operations: `blueprint/09-continuous-integration.md` … `blueprint/14-continuous-improvement.md`
- Done criteria: `standards/definition-of-done.md`
- Commits and branches: `standards/git.md`
- Design quality, SOLID, Clean Code and pattern selection: `standards/code-design.md`

All paths are relative to this repository root.

## Working rules

1. Determine the lifecycle phase before acting on a change.
2. Do not implement while requirements are ambiguous. Ask.
3. Inspect before assuming. The default answer is the existing architecture.
4. Never skip a phase silently. If one does not apply, say so explicitly.
5. Write tests in the same change as the code, never as a follow-up.
6. Every acceptance criterion maps to a test or an explicit verification step.
7. Do not introduce unrelated refactoring.
8. A pattern is a finding only when the design justifies it. Never add an abstraction,
   base class or interface that has no stated problem behind it.
9. A significant architectural decision needs an ADR in `blueprint/architecture/adr/`,
   following the format of the existing ones.
10. Close every change against `standards/definition-of-done.md` and report what was
   skipped and why.

## Adapter rules

- Skills are **routers**. They point at `blueprint/`. If you find yourself restating a
  phase inside a skill, stop — the phase document is the source.
- Do not add a custom **primary** agent. `.opencode/` is copied into every project that
  installs the blueprint (`scripts/blueprint-init.ps1`, `scripts/blueprint-init.sh`), so a
  primary agent would impose a default on consumers who only asked for guidance. The
  rationale is in `blueprint/architecture/adr/adr-005-skill-agente-adaptor-opencode.md`.
- Use the `blueprint-orchestrator` subagent for autonomous passes with no interactive user:
  readiness audits and per-phase gap reports. Do not use it for interactive work — a
  subagent cannot iterate with the user inside its turn.
- OpenCode is optional. Never treat its absence as a gap in the blueprint.

## Validation

`.github/workflows/ci.yml` is the gate. It validates repository structure, phase documents,
templates, standards, ADRs, the OpenCode adapter and every internal markdown link. Run it
before opening a pull request, or push to the branch and let Actions report.
