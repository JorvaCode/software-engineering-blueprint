#!/usr/bin/env bash
#
# validate-blueprint.sh — the single implementation of the blueprint validation
# gate. Run it from the repository root:
#
#   bash scripts/validate-blueprint.sh
#
# It is called by .github/workflows/ci.yml and by
# .github/workflows/reusable-blueprint-validation.yml, so the three can never
# disagree. A validation that exists in two places is a validation that will
# eventually exist in two versions. See ADR-011.
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
check_file .github/CODEOWNERS
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

echo "== Installers =="
check_file scripts/blueprint-init.ps1
check_file scripts/blueprint-init.sh
for i in scripts/blueprint-init.ps1 scripts/blueprint-init.sh; do
  if [ ! -s "$i" ]; then
    fail "empty installer: $i"
  fi
done

# An installer that copies a whole directory ships whatever happens to be in
# the maintainer's working copy. Both installers therefore use an allowlist, and
# the allowlist is the thing under test: copying .opencode as a unit, or copying
# any build manifest, is the defect this check exists to catch.
echo "== Installers copy an allowlist, not a directory tree =="
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  if grep -qE '^\s*(OPTIONAL_DIRS|optionalDirs)\s*=\s*"?\.opencode"?' "$i"; then
    fail "${i} copies .opencode as a whole directory instead of an allowlist"
  fi
  if ! grep -q 'ALLOWLIST\|allowlist' "$i"; then
    fail "${i} does not declare an install allowlist"
  fi
done
# The allowlist has to name the adapter subdirectories explicitly, or the
# installer silently stops shipping the skills and the agent.
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  for entry in '.opencode/agents' '.opencode/skills'; do
    if ! grep -q "$entry" "$i"; then
      fail "${i} does not install ${entry}"
    fi
  done
done
# An allowlist makes a post-copy denylist unnecessary. If one is still there, the
# installer has not actually been converted.
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  if grep -q 'node_modules' "$i"; then
    fail "${i} still removes node_modules after copying; the allowlist makes that cleanup unnecessary"
  fi
done

echo "== Installers write an adoption manifest =="
for i in scripts/blueprint-init.sh scripts/blueprint-init.ps1; do
  if ! grep -q 'blueprint-install.json' "$i"; then
    fail "${i} does not write .blueprint-install.json"
  fi
  if ! grep -q 'VERSION' "$i"; then
    fail "${i} does not record the blueprint version in the manifest"
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
  adr-011-distribucion-versionada-y-manifiesto.md; do
  check_file "blueprint/architecture/adr/${a}"
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
# These are the exact phrasings the audit found to be unfalsifiable. They
# are listed rather than pattern-matched, because a gate that cannot fail
# is the failure mode, and the failure mode is specific to these words.
if grep -rnEi \
  'clear, testable, feasible|clear and maintainable|appropriately|as needed|good (practice|quality)|high quality|clean and maintainable' \
  blueprint/0*.md blueprint/1*.md; then
  fail "quality gate regressed to unfalsifiable adjectives (see ADR-009)"
fi

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
# The known limitation is only honest if it is stated in the artifact
# that carries the limitation, not just in the ADR.
if ! grep -q 'not yet make the phases checkable against each other' standards/information-items.md; then
  fail "standards/information-items.md must state the traceability limitation it does not solve"
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
    {
      grep -oE '\]\([^)]*\)' "$doc" | sed 's/^](//; s/)$//'
      grep -oE '^\[[^]]+\]:[[:space:]]*[^[:space:]]+' "$doc" | sed -E 's/^\[[^]]+\]:[[:space:]]*//'
    } 2>/dev/null
  )
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
