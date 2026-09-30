#!/usr/bin/env bash
#
# validate-blueprint.sh — the single implementation of the blueprint validation
# gate. Run it from the repository root:
#
#   bash scripts/validate-blueprint.sh
#
# It is called by .github/workflows/ci.yml, and by nothing else.
#
# .github/workflows/reusable-blueprint-validation.yml is a second implementation
# and deliberately so: it validates a *consuming* repository, scripts/ is never
# installed into one, and most of the checks below test facts that exist only in
# this repository (ADRs, governance, VERSION, this repository's own prose links).
# The section "Reusable workflow stays self-contained" below enforces that the two
# never collide. See ADR-011.
#
# Requires only POSIX shell utilities: no Node, no Python, no network.

set -uo pipefail

failed=0

fail() {
  echo "FAIL: $1"
  failed=1
}

check_file() {
  test -f "$1" || fail "missing file: $1"
}

check_dir() {
  test -d "$1" || fail "missing directory: $1"
}

echo "== Repository structure =="
check_file README.md
check_dir blueprint
check_dir templates
check_dir standards
check_dir examples
check_dir blueprint/architecture/adr
check_dir .opencode/skills
check_dir .opencode/agents
check_dir .github/workflows

echo "== Line endings cannot silently break the checks below (see FR-20) =="
# This runs first, before anything else parses a document, because it is the
# only fault that makes every later result untrustworthy. The gate decides a
# phase with `grep -qx '## Information items'`, which matches a whole line. A
# contributor on Windows with core.autocrlf=true — the Git for Windows default,
# and a local setting this repository cannot ship — gets CRLF, and then all
# fourteen phases fail at once for a reason that has nothing to do with the
# phase. Placed at the end, this check would be correct and useless: the reader
# would have read three false violations before reaching the real cause.
#
# core.autocrlf is not reachable from here, so the guarantee is a file that
# reaches the checkout (.gitattributes) plus this check, which names the cause
# instead of reporting its symptom fourteen times.
if [ ! -f .gitattributes ]; then
  fail "missing .gitattributes; a CRLF checkout makes this gate report fourteen false failures"
fi
# The rules the checks below depend on. *.ps1 is deliberately the other way
# round, and is asserted too rather than left to the default.
for rule in '^\* text=auto eol=lf' '^\*\.sh +text eol=lf' '^\*\.md +text eol=lf' '^\*\.yml +text eol=lf'; do
  if ! grep -qE "$rule" .gitattributes; then
    fail ".gitattributes is missing the rule ${rule#^}"
  fi
done
if ! grep -qE '^\*\.ps1 +text eol=crlf' .gitattributes; then
  fail ".gitattributes must pin *.ps1 to CRLF, which is what PowerShell tooling writes"
fi
# Restricted to the extensions this gate parses and that .gitattributes pins to
# LF, because a CR in a .ps1 is correct rather than a fault.
crlf=$(find . \( -name '*.sh' -o -name '*.md' -o -name '*.yml' \) -type f \
  -not -path './.git/*' -not -path './.opencode/node_modules/*' -not -name '.gitattributes' \
  -exec grep -lIU $'\r' {} + 2>/dev/null)
if [ -n "$crlf" ]; then
  fail "CRLF line endings in files this gate parses: $(echo "$crlf" | tr '\n' ' ') (see FR-20; run 'git add --renormalize .')"
fi

echo "== Distribution identity (see ADR-011) =="
check_file VERSION
# A version file with no content identifies nothing.
if [ ! -s VERSION ]; then
  fail "empty version file: VERSION"
fi
# The declared version has to be reachable by a consumer, otherwise it exists
# only for this repository.
for f in README.md; do
  if ! grep -q 'VERSION' "$f"; then
    fail "does not reference the VERSION file: $f"
  fi
done

echo "== Governance (see ADR-007) =="
check_file LICENSE
check_file CONTRIBUTING.md
check_file SECURITY.md
check_file CODE_OF_CONDUCT.md
check_file .editorconfig
check_file .markdownlint.json
check_file .github/PULL_REQUEST_TEMPLATE.md
check_file .github/ISSUE_TEMPLATE/bug_report.yml
check_file .github/ISSUE_TEMPLATE/feature_request.yml
if ! grep -q 'Attribution 4.0 International' LICENSE; then
  fail "LICENSE does not contain the CC BY 4.0 legal code"
fi
for f in LICENSE CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md; do
  if [ ! -s "$f" ]; then
    fail "empty governance file: $f"
  fi
done
# A governance file that exists but says "TODO(owner)" protects nothing, and the
# previous check only tested for emptiness, so the repository could report a green
# gate while every owner-dependent control in it was still unwritten. A
# placeholder in a governance file is a defect, not a note.
for f in CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md; do
  if grep -qE 'TODO\(|FIXME|XXX' "$f"; then
    fail "governance file still carries a placeholder: $f"
  fi
done
# CODEOWNERS is deliberately not required. It was required while naming a team
# that may not exist, and an entry matching no account is ignored by GitHub
# without warning, so the file gave the appearance of review enforcement and none.
# It returns as a one-file change the moment there is a second maintainer to name.
if [ -f .github/CODEOWNERS ] && grep -qE 'TODO\(|FIXME|XXX' .github/CODEOWNERS; then
  fail ".github/CODEOWNERS carries a placeholder owner"
fi

echo "== Installers =="
check_file scripts/blueprint-init.ps1
check_file scripts/blueprint-init.sh
for i in scripts/blueprint-init.ps1 scripts/blueprint-init.sh; do
  if [ ! -s "$i" ]; then
    fail "empty installer: $i"
  fi
done

# One licence cannot honestly cover both the documentation and the code, and
# Creative Commons says so itself rather than leaving it to be discovered:
# a CC licence has no terms about distributing source code, addresses patents
# only by exclusion, and is incompatible with the major software licences. So the
# split has to be real in the files, not only in the ADR. See ADR-012.
echo "== Licence split: documentation CC BY 4.0, code Apache-2.0 (see ADR-012) =="
check_file LICENSE-CODE
if [ ! -s LICENSE-CODE ]; then
  fail "empty licence file: LICENSE-CODE"
fi
# Matched as a phrase, not as a version string. "Version 2.0" on its own also
# appears in a file that is not the licence, which is how a check passes after
# the text it was written for is replaced with something else.
if ! grep -q 'Apache License' LICENSE-CODE; then
  fail "LICENSE-CODE does not contain the Apache-2.0 legal code"
fi
if ! grep -q 'Version 2.0, January 2004' LICENSE-CODE; then
  fail "LICENSE-CODE does not carry the Apache-2.0 version line"
fi
# A split nobody can find is a split that does not exist. Each file has to point
# at the other, or a reader who opens the wrong one concludes the whole
# repository is under that single licence.
if ! grep -q 'LICENSE-CODE' LICENSE; then
  fail "LICENSE does not point at LICENSE-CODE, so the code licence is invisible to a reader of LICENSE"
fi
if ! grep -q 'CC BY 4.0' LICENSE-CODE; then
  fail "LICENSE-CODE does not say what the documentation is under"
fi
# The documentation has to stop claiming the repository is single-licensed, in
# every place a human reads it.
for d in README.md CONTRIBUTING.md; do
  if ! grep -q 'LICENSE-CODE' "$d"; then
    fail "${d} still describes the repository as single-licensed; it must name LICENSE-CODE"
  fi
done

# An installer that copies a whole directory ships whatever happens to be in
# the maintainer's working copy. Both installers therefore use an allowlist, and
# the allowlist is the thing under test: copying .opencode as a unit, or copying
# any build manifest, is the defect this check exists to catch.
echo "== Installers copy an allowlist, not a directory tree =="
# The DECLARED allowlist is the thing under test, and it is parsed rather than
# grepped. Grepping the whole file is not a weaker test, it is a different and
# useless one: both installers name every required entry in their header comment,
# so a check that greps the file still passes after the executable allowlist has
# been changed to copy .opencode as a unit. That is precisely the regression this
# check exists to catch, and it is caught only by reading the assignment.
declare_allowlist() {
  if grep -qE '^[[:space:]]*ALLOWLIST[[:space:]]*=' "$1"; then
    sed -nE 's/^[[:space:]]*ALLOWLIST[[:space:]]*="([^"]*)".*/\1/p' "$1" | head -1
  else
    sed -nE 's/^[[:space:]]*\$allowlist[[:space:]]*=.*@\((.*)\).*/\1/p' "$1" \
      | head -1 | tr -d "'," | tr -s ' ' | sed -E 's/^ //; s/ $//'
  fi
}
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  allowlist=$(declare_allowlist "$i")
  if [ -z "$allowlist" ]; then
    fail "${i} does not declare an install allowlist"
    continue
  fi
  for entry in blueprint templates standards .opencode/agents .opencode/skills; do
    # Unquoted on purpose: this word-splits the allowlist into its entries.
    if ! printf '%s\n' $allowlist | grep -qxF "$entry"; then
      fail "${i} allowlist does not install ${entry}"
    fi
  done
  # The whole-directory form, compared as a whole token so that a correctly
  # spelled .opencode/agents is not mistaken for it.
  if printf '%s\n' $allowlist | grep -qxF '.opencode'; then
    fail "${i} allowlist copies .opencode as a whole directory; list its subdirectories instead"
  fi
done

# An allowlist makes a post-copy denylist unnecessary. If one is still there, the
# installer has not actually been converted. Matched on the removal rather than
# on the word, so a comment describing the old behaviour does not fail the gate.
echo "== Installers do not fall back to a post-copy denylist =="
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  if grep -qE '(rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*[^|;]*node_modules)|(Remove-Item[^|;]*node_modules)' "$i"; then
    fail "${i} still removes node_modules after copying; the allowlist makes that cleanup unnecessary"
  fi
done

echo "== Installers write an adoption manifest =="
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  if ! grep -q 'blueprint-install\.json' "$i"; then
    fail "${i} does not write .blueprint-install.json"
  fi
  if ! grep -q 'VERSION' "$i"; then
    fail "${i} does not record the blueprint version in the manifest"
  fi
done

# CC BY 4.0 conditions reuse on attribution. A consumer handed the content
# without the terms holds a permission whose condition it cannot satisfy, so the
# licences are part of what an install delivers rather than an optional extra.
# Both identifiers are required because a manifest naming only the documentation
# licence understates the terms the consumer received. See ADR-012.
echo "== Installers deliver the licences and record both (see ADR-012) =="
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  for l in LICENSE LICENSE-CODE; do
    if ! grep -q "$l" "$i"; then
      fail "${i} does not distribute ${l}"
    fi
  done
  for lic in CC-BY-4.0 Apache-2.0; do
    if ! grep -q "$lic" "$i"; then
      fail "${i} does not record ${lic} in the manifest"
    fi
  done
done

# The rule that protects a consumer's own repository is that its LICENSE is never
# overwritten, and a later edit is far more likely to drop that guard than to
# break the copy. It is therefore asserted where it can actually be observed: in
# the functional suite that runs both installers against a real destination. This
# asserts the suite is still asserting it, so the coverage cannot be deleted
# without the gate noticing.
echo "== The licence delivery behaviour has functional coverage (see ADR-012) =="
for t in scripts/test-installers.sh scripts/test-installers.ps1; do
  check_file "$t"
done
if ! grep -q 'pre-existing LICENSE is not overwritten' scripts/test-installers.sh; then
  fail "scripts/test-installers.sh does not assert that a destination LICENSE survives the install"
fi
if ! grep -q 'pre-existing LICENSE is not overwritten' scripts/test-installers.ps1; then
  fail "scripts/test-installers.ps1 does not assert that a destination LICENSE survives the install"
fi
# A manifest that lists licence files it did not deliver is the same false report
# that commit 679dbb4 removed from the entries array, reintroduced under a new
# key. Assert the honest-reporting half, not just the delivery half.
if ! grep -q 'manifest claims no delivered licence file' scripts/test-installers.sh; then
  fail "scripts/test-installers.sh does not assert that an undelivered licence file is not claimed"
fi

# The reusable workflow is a second implementation, deliberately, and the docs
# say so. What it must never be is a claim to be this gate: a consuming
# repository has no scripts/ directory, because the installers exclude it, so a
# step calling this file there fails for every consumer. Comments may discuss the
# relationship; executable lines may not.
#
# Only the executable form is checked. Prose is not, because a phrase is not a
# fact: the false claim this replaced ("it runs in the reusable workflow") put
# the subject in one sentence and the assertion in the next, and no regex over
# sentences catches that without also firing on the correction that says the
# opposite. Review the wording; check the behaviour here.
echo "== Reusable workflow stays self-contained =="
RW=.github/workflows/reusable-blueprint-validation.yml
if [ -f "$RW" ] && grep -vn '^[[:space:]]*#' "$RW" | grep -q 'scripts/validate-blueprint\.sh'; then
  fail "${RW} executes scripts/validate-blueprint.sh, which no consumer has"
fi

# Documentation that describes the installers has to describe the installers that
# exist. A consumer who reads the adoption checklist is entitled to the behaviour
# the installers actually have, and the checklist drifts silently otherwise.
echo "== Adoption documentation matches the installers =="
check_doc_adoption() {
  # Matched as a whole code-formatted token. Do not try to tell ".opencode/"
  # from ".opencode/agents/" by what follows the slash: the subdirectory names
  # will change, the fact that the whole directory is not copied will not. The
  # directory is only described as a unit when it is written as exactly that.
  if grep -q '`\.opencode/`' "$1"; then
    fail "${1} describes the installers as copying .opencode/ as a whole directory"
  fi
  for entry in .opencode/agents .opencode/skills; do
    if ! grep -q "$entry" "$1"; then
      fail "${1} does not name the installed entry ${entry}"
    fi
  done
  if ! grep -q 'blueprint-install\.json' "$1"; then
    fail "${1} does not mention the adoption manifest .blueprint-install.json"
  fi
}
for d in README.md examples/adoption-checklist.md; do
  if [ -f "$d" ]; then
    check_doc_adoption "$d"
  fi
done

echo "== Directories that must be installable =="
for d in blueprint templates standards; do
  check_dir "$d"
done

echo "== Blueprint phase documents (00-14) =="
for i in $(seq -w 0 14); do
  if ! compgen -G "blueprint/${i}-*.md" > /dev/null; then
    fail "missing phase document: blueprint/${i}-*.md"
  fi
done

echo "== Templates =="
for t in requirement.md adr.md change.md; do
  check_file "templates/${t}"
done

echo "== Standards =="
for s in definition-of-done.md git.md code-design.md normative-language.md terms.md information-items.md; do
  check_file "standards/${s}"
done

echo "== Architecture decision records =="
for a in \
  adr-001-blueprint-agnostic-ide-tecnologia.md \
  adr-002-opencode-adaptador-opcional.md \
  adr-003-blueprint-docs-as-code.md \
  adr-004-modelo-distribucion-reutilizacion.md \
  adr-005-skill-agente-adaptor-opencode.md \
  adr-006-calidad-diseno-codigo-solid-clean-code-patrones.md \
  adr-007-licencia-y-gobernanza-del-repositorio.md \
  adr-008-terminologia-y-modalidad-normativa.md \
  adr-009-information-items-por-fase.md \
  adr-010-vistas-y-escenarios-de-atributo-de-calidad.md \
  adr-011-distribucion-versionada-y-manifiesto.md \
  adr-012-licencia-del-codigo-y-distribucion-de-licencias.md \
  adr-013-trazabilidad-de-extremo-a-extremo.md; do
  check_file "blueprint/architecture/adr/${a}"
done

echo "== Every ADR follows templates/adr.md =="
# The template declares the required structure, and until now nothing checked
# that an ADR followed it. Three of the eleven were written with Spanish
# headings, Status and Date as a metadata list rather than sections, and a
# Consequences section with no split, so "the template's headings are required"
# (standards/normative-language.md) was a claim with no check behind it.
#
# Extra sections are permitted: the template is a floor, not a ceiling. ADR-011
# keeps a Verification section and folds its former Scope line into Context.
for adr in blueprint/architecture/adr/adr-*.md; do
  for section in '## Status' '## Context' '## Options considered' '## Decision' '## Consequences' '### Positive' '### Negative / trade-offs' '## Date'; do
    if ! grep -qF "$section" "$adr"; then
      fail "$adr is missing the template section: ${section}"
    fi
  done
  if ! head -n 1 "$adr" | grep -qE '^# ADR-[0-9]{3}: .+'; then
    fail "$adr does not start with a '# ADR-NNN: <title>' heading"
  fi
  status=$(awk '/^## Status/{getline; while ($0 ~ /^[[:space:]]*$/) getline; print; exit}' "$adr")
  case "$status" in
    Proposed|Accepted|Superseded|Rejected) ;;
    *) fail "$adr has an invalid Status: '${status}' (expected Proposed, Accepted, Superseded or Rejected)" ;;
  esac
  adr_date=$(awk '/^## Date/{getline; while ($0 ~ /^[[:space:]]*$/) getline; print; exit}' "$adr")
  if ! printf '%s' "$adr_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    fail "$adr has a Date that is not YYYY-MM-DD: '${adr_date}'"
  fi
done

echo "== Code design standard is referenced by the phases that gate on it =="
for d in 00-principles 04-design 05-implementation 07-code-review 08-security-quality; do
  if ! grep -q 'standards/code-design.md' "blueprint/${d}.md"; then
    fail "phase does not reference standards/code-design.md: blueprint/${d}.md"
  fi
done
if ! grep -q 'standards/code-design.md' standards/definition-of-done.md; then
  fail "definition of done does not reference standards/code-design.md"
fi

echo "== Code design standard keeps patterns optional =="
if ! grep -q 'Absence is not a finding' standards/code-design.md; then
  fail "standards/code-design.md must state that the absence of a pattern is not a finding"
fi

echo "== Normative language is declared and reachable =="
# The convention only governs if every agent and contributor is pointed at it.
for f in AGENTS.md CONTRIBUTING.md standards/definition-of-done.md; do
  if ! grep -q 'standards/normative-language.md' "$f"; then
    fail "does not reference standards/normative-language.md: $f"
  fi
done
# A gate that cannot fail is not a gate, so the rule must state the test.
if ! grep -q 'Artifact' standards/normative-language.md; then
  fail "standards/normative-language.md must state the falsifiability test for a gate"
fi
# 'Important' is replaced by a defined threshold, so the threshold must be referenced.
if ! grep -q 'standards/terms.md' blueprint/03-architecture.md; then
  fail "blueprint/03-architecture.md does not reference standards/terms.md"
fi
if ! grep -q 'Significant decision' standards/terms.md; then
  fail "standards/terms.md must define the significant decision criteria"
fi

echo "== Every process phase declares its information items =="
# A phase that names an artifact without stating its content leaves the
# reader to guess, so both the section and the subsection are required.
# Phase 00 is a statement of principles, not a process, and is excluded:
# see standards/information-items.md.
for i in $(seq -w 1 14); do
  for doc in blueprint/${i}-*.md; do
    [ -f "$doc" ] || { fail "missing phase document: blueprint/${i}-*.md"; continue; }
    grep -qx '## Information items' "$doc" \
      || fail "phase does not declare '## Information items': ${doc}"
    for sub in '### Inputs' '### Outputs'; do
      grep -qx "$sub" "$doc" || fail "phase missing '${sub}': ${doc}"
    done
    # A name with no content is not an information item, so every
    # output bullet has to carry text after the artifact name.
    awk -v doc="$doc" '
      /^### Outputs/ { inout = 1; next }
      /^## /        { inout = 0 }
      inout && /^- / && !/\*\*[^*]+\*\* +[^[:space:]]/ { print "FAIL: unnamed output: " doc; bad = 1 }
      END           { exit bad ? 1 : 0 }
    ' "$doc" || failed=1
  done
done

echo "== Quality gates name an artifact and cannot be satisfied by adjectives =="
# The scope is the gate itself, not the whole document. A phase may legitimately
# discuss feasibility in its guidance; what cannot pass is a gate that asks for
# it. The previous version grepped whole files for a fixed phrase, which is why
# "numbered, testable and feasible" sat in phase 01 with the gate green: the
# phrase it looked for had the word "clear" in front of it.
#
# standards/normative-language.md is excluded from the prose sweep below
# because a standard that defines the ban has to quote what it bans, and
# quoting "clear, testable, feasible" is the definition working, not failing.
# The words are matched individually, not as a fixed phrase. The previous
# version searched for "clear, testable, feasible" as one string, so a gate
# reading "numbered, testable and feasible" passed, and that is the exact
# sentence phase 01 carried while this check reported the repository green.
UNFALSIFIABLE='\btestable\b|\bfeasible\b|\bappropriately\b|\bas needed\b|\bgood +(practice|quality)\b|\bhigh quality\b|\bclear\b|\bclean\b|\bconvincing\b|\bplausible\b|\brobust\b|\badequate\b|\breasonable\b|\bcomplete\b|\bconsidered\b|\baddressed\b|\bwhere applicable\b|\bwhere needed\b'
for doc in blueprint/[0-9][0-9]-*.md; do
  gate=$(awk '/^## +Quality gate/{f=1;next} /^## /{f=0} f' "$doc")
  if printf '%s\n' "$gate" | grep -qEi "$UNFALSIFIABLE"; then
    fail "quality gate in $doc uses an adjective that cannot fail (see standards/normative-language.md)"
  fi
done
# The modality sweep targets the directive forms, not the bare words. "Consider
# the rollback path" is a pseudo-obligation and is banned; "the options
# considered" is the name of a section that templates/adr.md fixes, and banning
# it would break the template. That distinction is a known limit of this check,
# not an oversight: a check that could tell the two apart without a hand-written
# exception list would need to parse English.
BANNED_MODALITY='\bprefer\b|\b(need|have|try) to\b|\bconsider(s|ed|ing)? +(the|this|these|a|an|whether|against|how)\b'
for doc in standards/*.md; do
  case "$doc" in
    standards/normative-language.md) continue ;;
  esac
  if grep -qEi "$BANNED_MODALITY" "$doc"; then
    fail "$doc uses a non-modality word banned by standards/normative-language.md"
  fi
done

echo "== Information items standard is declared and reachable =="
for f in AGENTS.md standards/definition-of-done.md; do
  if ! grep -q 'standards/information-items.md' "$f"; then
    fail "does not reference standards/information-items.md: $f"
  fi
done
# The standard only governs if it states its own scope, so a process
# phase that omitted the section has to be detectable from the file.
if ! grep -q 'Information Items' standards/information-items.md; then
  fail "standards/information-items.md does not define the required section"
fi
# The residual limitation is only honest if it is stated in the artifact that
# carries it, and it is no longer the one ADR-009 recorded. The previous check
# required the sentence "not yet make the phases checkable against each other"
# to be present, which made it impossible to fix the limitation: the gate
# failed the moment it stopped being true.
if grep -q 'not yet make the phases checkable against each other' standards/information-items.md; then
  fail "standards/information-items.md still declares traceability unresolved; ADR-013 resolves it"
fi
# Replacing it with silence would be worse than the stale claim, so the
# residual limit has to be named: the rule is review-enforced, not tool-checked.
if ! grep -q 'enforced by review' standards/information-items.md; then
  fail "standards/information-items.md must state that traceability is review-enforced, not tool-checked"
fi

echo "== The traceability chain is closed from requirement to release =="
# ADR-013 closes the limitation ADR-009 recorded, and it does so with a field
# on items that already exist rather than a new artifact. That decision is only
# real if each end of the chain names the identifier, so the check below is the
# chain and not the prose around it. A phase that drops its half leaves the
# requirement unreachable from the release, which is the exact defect F13 found.
if ! grep -qx '## Traceability' standards/information-items.md; then
  fail "standards/information-items.md must declare the '## Traceability' section"
fi
# The three statements that make the chain usable. The delivery endpoint is
# the one that was missing entirely, so it is checked by name in phase 11
# rather than by counting occurrences.
for anchor in \
  'blueprint/11-continuous-delivery.md:Release record.*requirements and changes it delivers' \
  'blueprint/01-requirements.md:AC-nn' \
  'blueprint/05-implementation.md:FR-nn' \
  'blueprint/06-testing.md:criterion coverage' \
  'blueprint/14-continuous-improvement.md:FR-nn' ; do
  doc=${anchor%%:*}; pattern=${anchor#*:}
  if ! grep -qiE "$pattern" "$doc"; then
    fail "traceability anchor missing: ${doc} does not name '${pattern}'"
  fi
done
# Phase 04 already required the design to name its requirement. The chain
# only holds if that link is still there, so its absence is a regression.
if ! grep -q 'requirement it satisfies' blueprint/04-design.md; then
  fail "blueprint/04-design.md lost the requirement link; the chain starts at design"
fi

echo "== The requirements register is living and checkable =="
REG=blueprint/requirements/software-engineering-blueprint.md
# The defect this phase fixes is that the register described v1.0.0 while
# VERSION said 1.1.0-dev. Banning the string "v1.0.0" would be wrong: the
# delivery table has to name the release that shipped FR-01..FR-08. So the
# check is the cross-reference instead, and it fails the moment someone bumps
# VERSION and forgets the register, which is the staleness itself.
if [ ! -f "$REG" ]; then
  fail "missing the requirements register: $REG"
else
  if ! grep -qF "$(tr -d '[:space:]' < VERSION)" "$REG"; then
    fail "$REG does not name the current VERSION; a living register tracks what the repository is held to"
  fi
  # Every requirement has to carry its verification and the artifact that
  # realises it, per standards/information-items.md. A row missing either is
  # the failure mode the Definition of Done already describes: prose that
  # sounds checkable and names no check.
  awk -v doc="$REG" '
    /^\| (FR|NFR|AC)-[0-9]+ \|/ {
      row = $0
      n = split(row, cell, "|")
      # Leading and trailing pipes give two empty fields; a 4-column row
      # therefore splits into 6.
      if (n != 6) { print "FAIL: " doc ": " cell[2] " has " (n - 2) " columns, expected 4"; bad = 1; next }
      for (i = 2; i <= 5; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", cell[i])
        if (cell[i] == "") { print "FAIL: " doc ": " cell[2] " has an empty column " (i - 1); bad = 1 }
      }
    }
    END { exit bad ? 1 : 0 }
  ' "$REG" || failed=1
  # An identifier reused for a different requirement breaks every link that
  # names it, so a duplicate is a defect and not a formatting issue.
  dups=$(grep -oE '^\| (FR|NFR|AC)-[0-9]+' "$REG" | sort | uniq -d)
  if [ -n "$dups" ]; then
    fail "$REG reuses a requirement identifier: $(echo "$dups" | tr '\n' ' ')"
  fi
  # The register is living, so it has to say how it is maintained. Without
  # the rule the document decays into exactly the frozen snapshot it replaced.
  # Headings are anchored: a substring match would accept a mention of the
  # word inside a sentence and call the section present.
  for heading in '^## Maintenance' '^## Traceability' '^## Delivery' '^### Not provided'; do
    if ! grep -qE "$heading" "$REG"; then
      fail "$REG is missing the section ${heading#^}"
    fi
  done
fi

echo "== The templates carry the fields the standards already require =="
# The templates were thinner than the standards governing them: requirement.md
# omitted the verification method the Definition of Done demands, and change.md
# omitted the pattern justification ADR-006 requires. Each field below is
# checked by the heading that introduces it, not by a word that could appear
# in the surrounding prose.
grep -qx '## Traceability' templates/requirement.md \
  || fail "templates/requirement.md must declare a '## Traceability' section"
grep -qE '^\| ID \| Requirement \| Verification \|' templates/requirement.md \
  || fail "templates/requirement.md must require a Verification column per requirement"
grep -q 'AC-nn' templates/requirement.md \
  || fail "templates/requirement.md must number acceptance criteria as AC-nn"
grep -q 'quality attribute' templates/requirement.md \
  || fail "templates/requirement.md must require the quality attribute on an NFR"
grep -qx '### Patterns' templates/change.md \
  || fail "templates/change.md must declare a '### Patterns' section"
grep -qx '### ADR' templates/change.md \
  || fail "templates/change.md must declare a '### ADR' section"
grep -qx '## Deletions' templates/change.md \
  || fail "templates/change.md must declare a '## Deletions' section"
grep -qE '^\| Criterion \| Level \| Check that verifies it \|' templates/change.md \
  || fail "templates/change.md must require the check that verifies each criterion"
# change.md records the identifier, but a change that satisfies no requirement
# has to be able to say so, or the field becomes an invention obligation.
grep -q 'satisfies none' templates/change.md \
  || fail "templates/change.md must allow a change that satisfies no requirement to say so"

echo "== CI runs are bounded and superseded runs are cancelled (see FR-21) =="
# A job with no timeout holds its concurrency slot for the six hours GitHub
# allows. And without a concurrency group, a push to a branch with an open pull
# request queues a second full run, so a reviewer reads the verdict of a commit
# that is no longer the head.
for wf in .github/workflows/ci.yml .github/workflows/reusable-blueprint-validation.yml; do
  if ! grep -q '^concurrency:' "$wf"; then
    fail "$wf declares no concurrency group; superseded runs queue instead of cancelling"
  fi
  # Count jobs by parsing the jobs: block, not by counting two-space keys. A
  # trigger such as `  push:` is indented exactly like a job, so the first
  # version of this check reported four jobs for a three-job workflow and
  # compared a timeout count against a number that was never a job count.
  jobs=$(awk '
    /^jobs:/                 { injobs = 1; next }
    /^[A-Za-z]/              { injobs = 0 }
    injobs && /^  [A-Za-z0-9_-]+:[[:space:]]*$/ { c++ }
    END                      { print c + 0 }
  ' "$wf")
  bounds=$(awk '
    /^jobs:/                 { injobs = 1; next }
    /^[A-Za-z]/              { injobs = 0 }
    injobs && /^    timeout-minutes: [0-9]+[[:space:]]*$/ { c++ }
    END                      { print c + 0 }
  ' "$wf")
  if [ "$jobs" -eq 0 ]; then
    fail "$wf declares no jobs, so the job parse found nothing to bound"
  fi
  if [ "$bounds" -lt "$jobs" ]; then
    fail "$wf declares $bounds timeout-minutes for $jobs jobs; every job needs a bound"
  fi
done

echo "== The documented example pins something that works (see FR-22) =="
# The header comment contradicted itself: it told the consumer to pin a tag and
# never a branch, then told them to pin the branch, and its example used the
# one tag that does not carry the checks the file describes. All three mutations
# below are regressions of that contradiction.
RW=.github/workflows/reusable-blueprint-validation.yml
if grep -q 'Pin a tag, never a branch' "$RW"; then
  fail "$RW still claims a tag is the only valid pin, which the comment below it contradicts"
fi
if grep -qE 'uses: .*reusable-blueprint-validation\.yml@v1\.0\.0' "$RW"; then
  fail "$RW documents an example that pins v1.0.0, which does not carry the floor it describes"
fi
# The honest statement has to name the tradeoff, or the example looks arbitrary.
for claim in 'Pin the branch' 're-pin to a tag'; do
  if ! grep -q "$claim" "$RW"; then
    fail "$RW must state '$claim' so the example is not arbitrary"
  fi
done

echo "== Third-party pins are declared, not assumed (see 'Not provided') =="
# dependabot cannot cover the npm pin: it reads a package.json and this
# repository has none on purpose. What is checked is that the gap is declared,
# because an npm entry that silently opens no pull requests is a check that
# looks present and is not.
if [ ! -f .github/dependabot.yml ]; then
  fail "missing .github/dependabot.yml; a pinned action goes stale with nothing proposing the bump"
fi
if ! grep -q 'package-ecosystem: github-actions' .github/dependabot.yml; then
  fail ".github/dependabot.yml does not cover the actions the gate uses"
fi
if ! grep -q 'package-ecosystem: npm' .github/dependabot.yml; then
  # Correct, and the reason has to be written down where a reader looks.
  if ! grep -q 'package.json' blueprint/requirements/software-engineering-blueprint.md; then
    fail "dependabot omits npm, so the reason it is omitted must be declared in the register"
  fi
fi
# The checkout action is the one input that is not pinned exactly. The gate
# refuses to say "pinned" about it, because that is a claim the file cannot
# support.
if ! grep -q 'actions/checkout@v5' .github/workflows/ci.yml; then
  fail "ci.yml no longer pins actions/checkout to the major tag its comment describes"
fi
if ! grep -q 'major tag, not to a commit SHA' .github/workflows/ci.yml; then
  fail "ci.yml must declare that the checkout pin is a major tag and not an exact SHA"
fi
# The register claimed a POSIX shell. It uses seq -w, compgen and process
# substitution, so that was false, and a false dependency is worse than a
# demanding one.
if grep -qi 'A POSIX shell for the repository' blueprint/requirements/software-engineering-blueprint.md; then
  fail "the register still claims the gate needs a POSIX shell; it needs bash"
fi
if ! grep -q 'Bash, not a POSIX shell' blueprint/requirements/software-engineering-blueprint.md; then
  fail "the register must state the real shell dependency of the gate"
fi

echo "== Quality attribute scenarios are wired into the phases that consume them =="
# The six fields are what make a scenario falsifiable. A scenario that
# restates a concern is not one, so every field is required.
for field in Source Stimulus Environment Artifact Response 'Response measure'; do
  if ! grep -qE "^\| ${field} \|" blueprint/03-architecture.md; then
    fail "blueprint/03-architecture.md is missing the QAS field: ${field}"
  fi
done
# Declaring scenarios that nothing executes would make the mechanism
# decorative, so the consuming phases have to reference them.
if ! grep -q 'quality attribute scenarios' blueprint/04-design.md; then
  fail "blueprint/04-design.md does not derive its test strategy from the scenarios"
fi
if ! grep -q 'Scenario coverage' blueprint/06-testing.md; then
  fail "blueprint/06-testing.md does not record which response measures are verified"
fi
# The vocabulary only carries weight if the standard it comes from is
# cited where the terms are defined.
for t in Stakeholder Concern Viewpoint View Model Correspondence Rationale; do
  if ! grep -qE "^\| \*\*${t}\*\* \|" standards/terms.md; then
    fail "standards/terms.md does not define: ${t}"
  fi
done
if ! grep -q 'ISO/IEC/IEEE 42010:2022' standards/terms.md; then
  fail "standards/terms.md does not cite ISO/IEC/IEEE 42010:2022 for the architecture vocabulary"
fi

echo "== Modality is used consistently in normative text =="
# MUST and SHALL are exact synonyms, so this repository uses shall only.
# Two exemptions, both deliberate:
#   - normative-language.md and terms.md are where the convention is defined,
#     so they are the one place the words being discussed may be quoted.
#   - 'what must happen' is a nominal phrase, not modality.
# The globs cover the phase documents, the requirements register, the
# standards and the templates. ADRs are excluded by the globs themselves:
# a historical ADR quoting the previous wording is a record, not a rule.
if grep -rnE '\bmust\b' blueprint/0*.md blueprint/1*.md standards/ templates/ 2>/dev/null \
  | grep -v 'what must happen' \
  | grep -v 'standards/normative-language.md' \
  | grep -v 'standards/terms.md'; then
  fail "normative text uses 'must' where it should use 'shall' (see ADR-008)"
fi
# 'prefer' is not modality, so it cannot carry an obligation.
if grep -rnE '\bPrefer\b' blueprint/0*.md blueprint/1*.md standards/ templates/ 2>/dev/null; then
  fail "normative text uses 'Prefer' as if it were modality (see ADR-008)"
fi

echo "== OpenCode adapter =="
for s in blueprint blueprint-architecture blueprint-cicd blueprint-development blueprint-requirements; do
  check_file ".opencode/skills/${s}/SKILL.md"
  if [ -z "$(head -n 1 ".opencode/skills/${s}/SKILL.md")" ]; then
    fail "skill without frontmatter: ${s}"
  fi
done
check_file .opencode/agents/blueprint-orchestrator.md
if ! head -n 1 .opencode/agents/blueprint-orchestrator.md | grep -q '^---$'; then
  fail "agent without frontmatter: blueprint-orchestrator"
fi
if ! grep -q '^description:' .opencode/agents/blueprint-orchestrator.md; then
  fail "agent without description: blueprint-orchestrator"
fi

echo "== Adapter must not duplicate the normative lifecycle =="
for s in blueprint blueprint-architecture blueprint-cicd blueprint-development blueprint-requirements; do
  if grep -qE '^## (Core lifecycle|Fundamental rules|Phase [0-9])' ".opencode/skills/${s}/SKILL.md"; then
    fail "skill ${s} restates the lifecycle instead of routing to blueprint/"
  fi
  if grep -qE '^#+ .*(Justification test|Absence is not a finding|SOLID as a diagnostic)' ".opencode/skills/${s}/SKILL.md"; then
    fail "skill ${s} restates standards/code-design.md instead of routing to it"
  fi
done

echo "== The adapter routes to every standard =="
# standards/ is normative and .opencode/ is an adapter, not a source of truth. An
# adapter that does not name a standard cannot route a reader to it, and three of
# the six were unreachable from .opencode/ in any file. AGENTS.md is the core
# router; this asserts the adapter has not fallen behind it.
for s in standards/*.md; do
  if ! grep -rq "$s" AGENTS.md; then
    fail "AGENTS.md does not route to $s, so the standard is unreachable"
  fi
  if ! grep -rq "$s" .opencode/; then
    fail ".opencode/ never references $s, so the adapter cannot route to it"
  fi
done

echo "== Empty markdown files =="
empty_files=$(find . -name '*.md' -type f -not -path './.git/*' -not -path './.opencode/node_modules/*' -empty | sort)
if [ -n "$empty_files" ]; then
  echo "empty markdown files:"
  echo "$empty_files"
  failed=1
fi

echo "== Internal markdown links =="
# Reference-style links are resolved too. An inline-only check passes a document
# whose [text][ref] definitions were deleted, which is how a link rots.
#
# Code is stripped first. A document that explains link syntax contains the
# literal form in a code span, and that is an example, not a link. Stripping can
# only hide a real link, never invent a false one, so it fails in the safe
# direction.
strip_code() {
  sed -E '/^[[:space:]]*(```|~~~)/,/^[[:space:]]*(```|~~~)/d; s/`[^`]*`//g'
}
while IFS= read -r doc; do
  while IFS= read -r link; do
    case "$link" in
      *://*|mailto:*|'#'*) continue ;;
    esac
    target=${link%%#*}
    [ -n "$target" ] || continue
    full="$(dirname "$doc")/${target}"
    if [ ! -f "$full" ]; then
      if [ ! -f "${full}.md" ]; then
        fail "broken link '${link%%#*}' in '${doc#./}'"
      fi
    fi
  done < <(
    strip_code < "$doc" | {
      grep -oE '\]\([^)]*\)' | sed 's/^](//; s/)$//'
      grep -oE '^\[[^]]+\]:[[:space:]]*[^[:space:]]+' | sed -E 's/^\[[^]]+\]:[[:space:]]*//'
    } 2>/dev/null
  )
done < <(find . -name '*.md' -type f -not -path './.git/*' -not -path './.opencode/node_modules/*' | sort)

echo "== Reference-style links resolve to a definition =="
# Checking definitions alone is not enough. A document can define every reference
# it uses and still have an undefined one, because the two are separate: delete
# a definition and every [text][ref] that pointed at it becomes a dead link that
# renders as literal text. Markdown reference definitions are document-scoped, so
# a use with no definition in the same file is a defect.
#
# A [text][ref](url) use carries its own inline target, so it does not need a
# definition and is skipped, as is the collapsed [text][] form.
while IFS= read -r doc; do
  defs=$(strip_code < "$doc" | grep -oE '^\[[^]]+\]:' 2>/dev/null | tr '[:upper:]' '[:lower:]')
  while IFS= read -r use; do
    [ -n "$use" ] || continue
    label=$(printf '%s' "$use" | sed -E 's/^\]\[//; s/\]$//' | tr '[:upper:]' '[:lower:]')
    [ -n "$label" ] || continue
    if ! printf '%s\n' "$defs" | grep -qxF "[$label]:"; then
      fail "reference-style link '[${label}]' is used but never defined in '${doc#./}'"
    fi
  done < <(strip_code < "$doc" | grep -oE '\]\[[^]]+\](\([^)]*\))?' 2>/dev/null | grep -v '(')
done < <(find . -name '*.md' -type f -not -path './.git/*' -not -path './.opencode/node_modules/*' | sort)

echo "== Markdown heading anchors referenced by links =="
# A link to file.md#section is only useful if the heading exists. This is the
# part of link checking that is most often skipped and most often wrong.
anchor_anchors() {
  # GitHub-style slug: lowercase, drop punctuation except - and _, spaces to -.
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g'
}
while IFS= read -r doc; do
  while IFS= read -r ref; do
    case "$ref" in
      *://*|mailto:*) continue ;;
    esac
    case "$ref" in
      *#*) : ;;
      *) continue ;;
    esac
    target=${ref%%#*}
    anchor=${ref#*#}
    [ -n "$anchor" ] || continue
    if [ -z "$target" ]; then
      full="$doc"
    else
      if [ -f "$target" ]; then
        full="$target"
      elif [ -f "${target}.md" ]; then
        full="${target}.md"
      elif [ -f "$(dirname "$doc")/${target}" ]; then
        full="$(dirname "$doc")/${target}"
      else
        continue
      fi
    fi
    if [ ! -f "$full" ]; then
      continue
    fi
    found=0
    while IFS= read -r heading; do
      text="${heading#\#\# }"
      text="${text#\#\#\# }"
      text="${text#\#\#\#\# }"
      text="${text#\#\#\#\#\# }"
      text="${text#\#\#\#\#\#\# }"
      if [ "$(anchor_anchors "$text")" = "$anchor" ]; then
        found=1
        break
      fi
    done < <(grep -E '^#{1,6} ' "$full")
    if [ "$found" -eq 0 ]; then
      fail "broken anchor '#${anchor}' in '${doc#./}' (target: ${full#./})"
    fi
  done < <(
    {
      grep -oE '\]\([^)]*#[^)]*\)' "$doc" | sed 's/^](//; s/)$//'
      grep -oE '^\[[^]]+\]:[[:space:]]*[^[:space:]]*#[^[:space:]]+' "$doc" | sed -E 's/^\[[^]]+\]:[[:space:]]*//'
    } 2>/dev/null
  )
done < <(find . -name '*.md' -type f -not -path './.git/*' -not -path './.opencode/node_modules/*' | sort)

if [ "$failed" -eq 1 ]; then
  echo "Blueprint validation FAILED"
  exit 1
fi
echo "Blueprint validation OK"
