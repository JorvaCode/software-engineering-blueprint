#!/usr/bin/env bash
#
# blueprint-init.sh — Install the Software Engineering Blueprint into a target
# project directory.
#
# Usage:
#   ./scripts/blueprint-init.sh /path/to/target-project
#
# Installs:  blueprint/  templates/  standards/   (+ .opencode/ if present)
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

REQUIRED_DIRS="blueprint templates standards"
OPTIONAL_DIRS=""
if [ -d "$BLUEPRINT_ROOT/.opencode" ]; then
  OPTIONAL_DIRS=".opencode"
fi

install_dir() {
  local name="$1"
  local src="$BLUEPRINT_ROOT/$name"
  local dst="$DEST/$name"

  if [ ! -d "$src" ]; then
    echo "[blueprint-init] ERROR: required source directory missing: $src" >&2
    failed=1
    return
  fi

  if [ -e "$dst" ]; then
    echo "[blueprint-init] WARNING: '$name' already exists in destination. Skipping to avoid overwriting existing content."
    skipped=$((skipped + 1))
    return
  fi

  if ! cp -r "$src" "$dst"; then
    echo "[blueprint-init] ERROR: failed to copy '$name'." >&2
    failed=1
    return
  fi

  # Do not ship dependency/build artifacts if the local source has them
  # (they are gitignored and are not part of the blueprint content).
  if [ -d "$dst/node_modules" ]; then
    rm -rf "$dst/node_modules"
  fi

  echo "[blueprint-init] installed  $name/"
  installed=$((installed + 1))
}

for dir in $REQUIRED_DIRS $OPTIONAL_DIRS; do
  install_dir "$dir"
done

echo ""
echo "[blueprint-init] Installed: $installed directory/directories"
echo "[blueprint-init] Skipped (already present): $skipped"

if [ "$failed" -ne 0 ]; then
  echo "[blueprint-init] Installation FAILED." >&2
  exit 1
fi

echo "[blueprint-init] Installation complete."
exit 0