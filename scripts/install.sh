#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_SKILL="${REPO_ROOT}/skill/enterprise_ga4_tracking_system"
DEFAULT_SKILLS_ROOT="${CODEX_HOME:-${HOME}/.codex}/skills"
TARGET_SKILLS_ROOT="${DEFAULT_SKILLS_ROOT}"

if [[ "${1:-}" == "--target" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "Usage: $0 [--target /path/to/skills]" >&2
    exit 1
  fi
  TARGET_SKILLS_ROOT="$2"
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--target /path/to/skills]" >&2
  exit 1
fi

"${SCRIPT_DIR}/validate.sh"

mkdir -p "${TARGET_SKILLS_ROOT}"
TARGET_SKILL="${TARGET_SKILLS_ROOT}/enterprise_ga4_tracking_system"
STAGING_ROOT="$(mktemp -d)"
trap 'rm -rf "${STAGING_ROOT}"' EXIT
cp -R "${SOURCE_SKILL}" "${STAGING_ROOT}/enterprise_ga4_tracking_system"

if [[ -e "${TARGET_SKILL}" ]]; then
  BACKUP_SKILL="${TARGET_SKILL}.backup.$(date +%Y%m%d%H%M%S)"
  mv "${TARGET_SKILL}" "${BACKUP_SKILL}"
  echo "Previous installation backed up to: ${BACKUP_SKILL}"
fi

mv "${STAGING_ROOT}/enterprise_ga4_tracking_system" "${TARGET_SKILL}"
echo "Installed to: ${TARGET_SKILL}"
