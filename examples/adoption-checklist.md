# Adoption Checklist

## Installing the blueprint into an existing project

The repository ships two identical installers (Windows PowerShell and POSIX shell). They copy the reusable blueprint content — `blueprint/`, `templates/`, `standards/` and, when present, `.opencode/` — into the target project directory. They never copy repository-only files (`.git/`, `.github/`, `scripts/`, `README.md`, ...), never overwrite existing files without warning, and require no Node, Python or external dependencies.

Windows:

```powershell
.\scripts\blueprint-init.ps1 C:\proyectos\mi-app
```

Linux/macOS:

```bash
./scripts/blueprint-init.sh /home/user/proyectos/mi-app
```

The destination directory is created if it does not exist. A directory already present in the destination is skipped with a warning; nothing is silently overwritten. The installer prints every directory installed and returns a non-zero exit code on failure.

## Initial adoption
- [ ] Copy blueprint into repository or reference the central blueprint repository.
- [ ] Define project technology stack.
- [ ] Define environments.
- [ ] Define required quality/security gates.
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
- [ ] Implementation
- [ ] Tests
- [ ] Review
- [ ] CI
- [ ] Artifact
- [ ] Delivery
- [ ] Deployment
- [ ] Observability
- [ ] Feedback
