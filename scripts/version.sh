#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION_FILE="${REPO_ROOT}/VERSION"

case "${1:-show}" in
  show)
    tr -d '[:space:]' < "${VERSION_FILE}"
    echo
    ;;
  set)
    next_version="${2:-}"
    if [[ ! "${next_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Usage: $0 set x.y.z" >&2
      exit 1
    fi
    printf '%s\n' "${next_version}" > "${VERSION_FILE}"
    echo "Version set to ${next_version}. Update CHANGELOG.md before release."
    ;;
  *)
    echo "Usage: $0 {show|set x.y.z}" >&2
    exit 1
    ;;
esac
