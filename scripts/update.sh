#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if ! git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This directory is not a Git working tree; clone the team repository before using update.sh." >&2
  exit 1
fi

git -C "${REPO_ROOT}" pull --ff-only
"${SCRIPT_DIR}/install.sh" "$@"
