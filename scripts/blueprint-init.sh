#!/usr/bin/env bash
#
# blueprint-init.sh — Install the Software Engineering Blueprint into a target
# project directory.
#
# Usage:
#   ./scripts/blueprint-init.sh /path/to/target-project
#
# Installs, by allowlist:
#   blueprint/  templates/  standards/
#   .opencode/agents/  .opencode/skills/     (only if present in the source)
#
# Also writes .blueprint-install.json in the destination, recording the
# installed version. The allowlist is deliberate: copying a directory wholesale
# ships whatever happens to be in the maintainer's working copy, and a consumer
# that receives someone else's package.json is a consumer with a bug they did
# not write. See ADR-011.
#
# Does NOT install: .git/  .github/  scripts/  README.md  or other
# repository-only files.
#
# Tool- and IDE-agnostic: requires no Node, no Python and no external
# dependencies (only POSIX shell utilities and cp/rm/mkdir).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <destination-directory>" >&2
  exit 1
fi

DEST="$1"

installed=0
skipped=0
failed=0

echo "[blueprint-init] Installing Software Engineering Blueprint into: $DEST"
echo "[blueprint-init] Source: $BLUEPRINT_ROOT"

if [ ! -d "$BLUEPRINT_ROOT" ]; then
  echo "[blueprint-init] ERROR: source directory not found: $BLUEPRINT_ROOT" >&2
  exit 1
fi

if [ ! -d "$DEST" ]; then
  echo "[blueprint-init] Destination does not exist. Creating directory: $DEST"
  if ! mkdir -p "$DEST"; then
    echo "[blueprint-init] ERROR: cannot create destination directory: $DEST" >&2
    exit 1
  fi
fi

# The install allowlist. Adding an entry here is a distribution decision and
# needs an ADR; nothing else is copied, ever.
ALLOWLIST="blueprint templates standards .opencode/agents .opencode/skills"

install_entry() {
  local name="$1"
  local src="$BLUEPRINT_ROOT/$name"
  local dst="$DEST/$name"
  local parent

  # The OpenCode adapter is optional; a copy of the blueprint without it is a
  # valid install, because the adapter is not a dependency (ADR-002).
  case "$name" in
    .opencode/*)
      if [ ! -d "$src" ]; then
        echo "[blueprint-init] skip       $name/ (not present in source)"
        return
      fi
      ;;
    *)
      if [ ! -d "$src" ]; then
        echo "[blueprint-init] ERROR: required source directory missing: $src" >&2
        failed=1
        return
      fi
      ;;
  esac

  if [ -e "$dst" ]; then
    echo "[blueprint-init] WARNING: '$name' already exists in destination. Skipping to avoid overwriting existing content."
    skipped=$((skipped + 1))
    return
  fi

  parent="$(dirname "$dst")"
  if [ "$parent" != "$DEST" ] && [ ! -d "$parent" ]; then
    if ! mkdir -p "$parent"; then
      echo "[blueprint-init] ERROR: cannot create '$parent'." >&2
      failed=1
      return
    fi
  fi

  if ! cp -r "$src" "$dst"; then
    echo "[blueprint-init] ERROR: failed to copy '$name'." >&2
    failed=1
    return
  fi

  echo "[blueprint-init] installed  $name/"
  installed=$((installed + 1))
}

for entry in $ALLOWLIST; do
  install_entry "$entry"
done

# Record what was installed, so a consumer can tell which blueprint it has and
# whether it has been modified since. The version is the identifier; there is no
# content hash because computing one would need a tool this installer does not
# promise to have. See ADR-011.
VERSION_FILE="$BLUEPRINT_ROOT/VERSION"
if [ -f "$VERSION_FILE" ]; then
  BP_VERSION="$(head -n 1 "$VERSION_FILE" | tr -d '[:space:]')"
else
  BP_VERSION="unknown"
fi

if [ ! -e "$DEST/.blueprint-install.json" ]; then
  cat > "$DEST/.blueprint-install.json" <<EOF
{
  "blueprint": "software-engineering-blueprint",
  "version": "$BP_VERSION",
  "installedAt": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "installer": "scripts/blueprint-init.sh",
  "entries": [
$(printf '    "%s",\n' $ALLOWLIST | sed '$ s/,$//')
  ]
}
EOF
  echo "[blueprint-init] wrote      .blueprint-install.json (version $BP_VERSION)"
else
  echo "[blueprint-init] WARNING: '.blueprint-install.json' already exists. Leaving it untouched."
fi

echo ""
echo "[blueprint-init] Installed: $installed item(s)"
echo "[blueprint-init] Skipped (already present): $skipped"

if [ "$failed" -ne 0 ]; then
  echo "[blueprint-init] Installation FAILED." >&2
  exit 1
fi

echo "[blueprint-init] Installation complete."
exit 0
