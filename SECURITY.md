# Security Policy

## Scope

This repository contains **documentation and workflow definitions, not executable application code**. The realistic attack surface is therefore narrow, but not zero:

- GitHub Actions workflows (`.github/workflows/`), which execute on every push and pull request.
- The installer scripts (`scripts/blueprint-init.ps1`, `scripts/blueprint-init.sh`), which consumers run locally.
- The normative text itself, if a consuming project treats it as binding policy.

A compromise of a workflow here propagates to every project that adopts the blueprint, and to every pull request opened against this repository.

## Reporting a vulnerability

**Do not open a public issue.** Use GitHub's private vulnerability reporting:

1. Go to **Security** → **Advisories** → **Report a vulnerability** on this repository, or
2. Use the *Report a vulnerability* button on the **Security** tab.

This is the only reporting channel, and there is deliberately no email address: a mailbox
nobody reads is worse than no mailbox, because a reporter believes they have reported and
stop looking. If the *Report a vulnerability* button is absent, the reporting feature is
not enabled for this repository, which is a setup gap on the maintainer side rather than a
reason to publish the report. Open an issue that states only that a security report should
be routed privately, with no technical detail, so the omission becomes visible.

Please include the affected file, the impact you believe it has, and the reproduction steps if you have them.

## What to report

| Report | Example |
| --- | --- |
| Workflow injection | A workflow interpolating untrusted input into a `run:` block |
| Unsafe permissions | A workflow granting `write` or `contents: write` where `read` suffices |
| Third-party action risk | An action pinned to a mutable tag such as `@master` or `@v2` where a commit SHA is required |
| Installer risk | `scripts/blueprint-init.*` writing outside the destination, following a symlink, or overwriting existing content without warning |
| Command injection | A shell or PowerShell path built from unvalidated input |
| Integrity of the normative text | A silent change to a quality gate that weakens a control without an ADR |

## What is out of scope

- Missing hardening suggestions with no demonstrated impact.
- Vulnerabilities in the projects that *adopt* the blueprint. Report those to the project.
- Reports generated purely by an automated scanner with no demonstrated path to impact.
- The absence of security controls in consuming projects. That is the consumer's decision; see [blueprint/08-security-quality.md](blueprint/08-security-quality.md).

## Response

| Stage | Target |
| --- | --- |
| Acknowledgement | 3 business days |
| Triage and severity assessment | 10 business days |
| Fix or documented mitigation | Agreed with the reporter |

There is no bug bounty for this repository. If that changes, this section is updated first.
