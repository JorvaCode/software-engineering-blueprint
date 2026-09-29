#!/usr/bin/env bash
# Functional tests for both installers, run against a real temporary destination.
# A change to a script that nobody runs is not a tested script, and reading an
# installer does not reveal that its output cannot be captured. See ADR-011.
#
# Run: bash scripts/test-installers.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK=$(mktemp -d)
pass=0
fail=0

ok()   { echo "  PASS  $1"; pass=$((pass + 1)); }
bad()  { echo "  ****  $1  -> $2"; fail=$((fail + 1)); }

check() {
  if eval "$2"; then ok "$1"; else bad "$1" "$2"; fi
}

# Poison the source with artifacts the allowlist must NOT ship.
touch "$REPO/.opencode/package.json"
printf 'poison\n' > "$REPO/.opencode/package-lock.json"
printf 'poison\n' > "$REPO/.opencode/bun.lock"
# .opencode/ is the directory the OpenCode tooling manages, so a stray file there
# is the realistic contamination vector and the allowlist must exclude it.
printf 'poison\n' > "$REPO/.opencode/STRAY-LOCAL-FILE.md"
# A stray file inside a content directory is a DIFFERENT case. The allowlist is
# directory-level by design, so this one is expected to ship. Asserting it pins
# the known limitation instead of leaving it implicit.
printf 'poison\n' > "$REPO/blueprint/LEFTOVER-FROM-LOCAL-WORK.md"
cleanup() {
  rm -f "$REPO/.opencode/package.json" "$REPO/.opencode/package-lock.json" \
        "$REPO/.opencode/bun.lock" "$REPO/.opencode/STRAY-LOCAL-FILE.md" \
        "$REPO/blueprint/LEFTOVER-FROM-LOCAL-WORK.md"
  rm -rf "$WORK"
}
trap cleanup EXIT

cd "$REPO" || exit 1

echo "== bash installer =="
DEST="$WORK/bash-target"
out=$(bash scripts/blueprint-init.sh "$DEST" 2>&1)
rc=$?
check "exit code is 0" "[ $rc -eq 0 ]"
check "blueprint/ installed"        "[ -d '$DEST/blueprint' ]"
check "templates/ installed"       "[ -d '$DEST/templates' ]"
check "standards/ installed"       "[ -d '$DEST/standards' ]"
check ".opencode/skills installed" "[ -d '$DEST/.opencode/skills' ]"
check ".opencode/agents installed" "[ -d '$DEST/.opencode/agents' ]"
check "manifest written"           "[ -f '$DEST/.blueprint-install.json' ]"
check "manifest has a version"     "grep -q '\"version\"' '$DEST/.blueprint-install.json'"
check "manifest version matches VERSION" \
  "grep -q \"\\\"version\\\": \\\"\$(head -n1 VERSION | tr -d '[:space:]')\\\"\" '$DEST/.blueprint-install.json'"
check "manifest is valid JSON"     "python3 -c \"import json,sys;json.load(open('$DEST/.blueprint-install.json'))\" 2>/dev/null || node -e \"JSON.parse(require('fs').readFileSync('$DEST/.blueprint-install.json','utf8'))\""

echo "  --- the allowlist must not leak anything ---"
check "no .opencode/package.json shipped"  "[ ! -e '$DEST/.opencode/package.json' ]"
check "no package-lock.json shipped"       "[ ! -e '$DEST/.opencode/package-lock.json' ]"
check "no bun.lock shipped"                "[ ! -e '$DEST/.opencode/bun.lock' ]"
check "no node_modules shipped"            "[ ! -e '$DEST/.opencode/node_modules' ]"
check "stray file in .opencode/ not shipped" "[ ! -e '$DEST/.opencode/STRAY-LOCAL-FILE.md' ]"
check "no .git shipped"                    "[ ! -e '$DEST/.git' ]"
check "no .github shipped"                 "[ ! -e '$DEST/.github' ]"
check "no scripts/ shipped"                "[ ! -e '$DEST/scripts' ]"
check "no README.md shipped"               "[ ! -e '$DEST/README.md' ]"
check "no .opencode/.gitignore shipped"    "[ ! -e '$DEST/.opencode/.gitignore' ]"

echo "  --- known limitation, pinned on purpose ---"
check "KNOWN: a stray file inside an allowlisted content dir DOES ship" \
  "[ -e '$DEST/blueprint/LEFTOVER-FROM-LOCAL-WORK.md' ]"

echo "  --- the manifest records what was applied, not the allowlist ---"
# A destination that already has one of the allowlisted entries. That entry is
# skipped, so it was NOT applied, and a manifest that lists it anyway tells the
# consumer something false about their own repository. See ADR-011.
DEST_SKIP="$WORK/bash-skip-target"
mkdir -p "$DEST_SKIP/templates"
out3=$(bash scripts/blueprint-init.sh "$DEST_SKIP" 2>&1)
check "pre-existing entry is skipped" "echo \"\$out3\" | grep -q 'already exists'"
check "manifest written for a partial install" "[ -f '$DEST_SKIP/.blueprint-install.json' ]"
check "manifest does NOT record the skipped entry" "! grep -q '\"templates\"' '$DEST_SKIP/.blueprint-install.json'"
check "manifest DOES record an entry that was applied" "grep -q '\"blueprint\"' '$DEST_SKIP/.blueprint-install.json'"
check "partial manifest is valid JSON" \
  "python3 -c \"import json;json.load(open('$DEST_SKIP/.blueprint-install.json'))\" 2>/dev/null || node -e \"JSON.parse(require('fs').readFileSync('$DEST_SKIP/.blueprint-install.json','utf8'))\""
check "full install records all 5 entries" \
  "[ \$(grep -c '^    \"' '$DEST/.blueprint-install.json') -eq 5 ]"

echo "  --- installed content is usable ---"
check "all 15 phase docs copied" "[ \$(ls -1 '$DEST/blueprint'/[0-9][0-9]-*.md 2>/dev/null | wc -l) -eq 15 ]"
check "5 skills copied"          "[ \$(ls -1 '$DEST/.opencode/skills' | wc -l) -eq 5 ]"
check "every phase declares information items" \
  "for d in '$DEST'/blueprint/[0-9][0-9]-*.md; do case \"\$(basename \$d)\" in 00-*) continue;; esac; grep -q '^## Information items' \"\$d\" || exit 1; done"

echo "  --- re-running is safe and does not clobber the manifest ---"
printf 'hand-edited\n' > "$DEST/.blueprint-install.json"
out2=$(bash scripts/blueprint-init.sh "$DEST" 2>&1)
check "second run exits 0"          "[ \$? -eq 0 ]"
check "existing manifest preserved"  "grep -q 'hand-edited' '$DEST/.blueprint-install.json'"
check "second run warns about manifest" "echo \"\$out2\" | grep -q 'already exists'"

echo
echo "== PowerShell installer =="
DEST_PS="$WORK/ps-target"
if command -v pwsh > /dev/null 2>&1; then
  pwsh -NoProfile -File "$SCRIPT_DIR/test-installers.ps1" > /dev/null 2>&1
  check "the PowerShell installer passes its own suite (see test-installers.ps1)" \
    "[ \$? -eq 0 ]"
else
  echo "  SKIP  pwsh not available; run test-installers.ps1 where PowerShell exists"
fi

echo
echo "installer tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
