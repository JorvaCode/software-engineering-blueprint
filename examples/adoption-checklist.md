# Adoption Checklist

## Installing the blueprint into an existing project

The repository ships two identical installers (Windows PowerShell and POSIX shell). They copy the reusable blueprint content into the target project directory, and only that: nothing else is ever copied, so a build manifest, a lockfile or a `node_modules` directory in the source tree cannot reach your project.

The entries are an explicit allowlist: `blueprint/`, `templates/`, `standards/` and, when the adapter is present, `.opencode/agents/` and `.opencode/skills/`. Repository-only files (`.git/`, `.github/`, `scripts/`, `README.md`, ...) are never copied, existing files are never overwritten without warning, and the installers require no Node, no Python and no external dependencies.

Windows:

```powershell
.\scripts\blueprint-init.ps1 C:\proyectos\mi-app
```

Linux/macOS:

```bash
./scripts/blueprint-init.sh /home/user/proyectos/mi-app
```

The destination directory is created if it does not exist. A directory already present in the destination is skipped with a warning; nothing is silently overwritten. The installer prints every directory installed and returns a non-zero exit code on failure.

Each run also writes `.blueprint-install.json` in the destination, recording the blueprint version, when it was installed, by which installer, and which entries were applied. Keep it. It is how the project answers "which blueprint is this, and has it been modified since" without searching, and an existing manifest is never overwritten, so a hand-edited one survives a re-install.

## Initial adoption
- [ ] Copy blueprint into repository or reference the central blueprint repository.
- [ ] Record the installed blueprint version in `.blueprint-install.json`.
- [ ] Define project technology stack.
- [ ] Define environments.
- [ ] Define required quality/security gates.
- [ ] Adopt `standards/code-design.md` as the design quality criterion.
- [ ] Define deployment target.
- [ ] Enable CI.
- [ ] Define CD strategy.
- [ ] Configure observability.
- [ ] Enable relevant OpenCode skills if OpenCode is used.

## First feature
- [ ] Requirement
- [ ] Acceptance criteria
- [ ] Analysis
- [ ] Design
- [ ] Pattern selection: justified, or explicitly not needed
- [ ] Implementation
- [ ] Tests
- [ ] Review
- [ ] CI
- [ ] Artifact
- [ ] Delivery
- [ ] Deployment
- [ ] Observability
- [ ] Feedback
