#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="bestcloriswang-ctrl/enterprise-ga4-tracking-system"
SKILL_NAME="enterprise_ga4_tracking_system"
DEFAULT_SKILLS_ROOT="${CODEX_HOME:-${HOME}/.codex}/skills"
SKILLS_ROOT="${ENTERPRISE_GA4_SKILLS_ROOT:-${DEFAULT_SKILLS_ROOT}}"
TARGET_SKILL="${SKILLS_ROOT}/${SKILL_NAME}"

latest_tag() {
  local effective_url
  effective_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPOSITORY}/releases/latest")"
  basename "${effective_url}"
}

installed_version() {
  if [[ -f "${TARGET_SKILL}/VERSION" ]]; then
    tr -d '[:space:]' < "${TARGET_SKILL}/VERSION"
  elif [[ -f "${TARGET_SKILL}/SKILL.md" ]]; then
    printf '%s\n' "unknown"
  else
    printf '%s\n' "not-installed"
  fi
}

validate_staged_skill() {
  local staged_skill="$1"
  [[ -f "${staged_skill}/SKILL.md" ]] || return 1
  [[ -f "${staged_skill}/VERSION" ]] || return 1
  [[ "$(head -n 1 "${staged_skill}/SKILL.md")" == "---" ]] || return 1
  grep -q '^name: enterprise_ga4_tracking_system$' "${staged_skill}/SKILL.md"
}

install_release() {
  local tag="$1"
  local version="${tag#v}"
  local package_name="${SKILL_NAME}-${tag}.zip"
  local release_root="https://github.com/${REPOSITORY}/releases/download/${tag}"
  local temporary_root
  local backup_path=""

  temporary_root="$(mktemp -d)"
  trap 'rm -rf "${temporary_root}"' RETURN

  curl -fL "${release_root}/${package_name}" -o "${temporary_root}/${package_name}"
  curl -fL "${release_root}/${package_name}.sha256" -o "${temporary_root}/${package_name}.sha256"
  (
    cd "${temporary_root}"
    shasum -a 256 -c "${package_name}.sha256"
    unzip -q "${package_name}" -d unpacked
  )

  local staged_skill="${temporary_root}/unpacked/${SKILL_NAME}"
  if ! validate_staged_skill "${staged_skill}"; then
    echo "Downloaded release is not a valid ${SKILL_NAME} Skill." >&2
    exit 1
  fi

  local staged_version
  staged_version="$(tr -d '[:space:]' < "${staged_skill}/VERSION")"
  if [[ "${staged_version}" != "${version}" ]]; then
    echo "Release tag ${tag} does not match packaged VERSION ${staged_version}." >&2
    exit 1
  fi

  mkdir -p "${SKILLS_ROOT}"
  if [[ -e "${TARGET_SKILL}" ]]; then
    backup_path="${TARGET_SKILL}.backup.v$(installed_version).$(date +%Y%m%d%H%M%S)"
    mv "${TARGET_SKILL}" "${backup_path}"
  fi
  mv "${staged_skill}" "${TARGET_SKILL}"

  echo "Installed version: ${version}"
  echo "Target path: ${TARGET_SKILL}"
  if [[ -n "${backup_path}" ]]; then
    echo "Backup path: ${backup_path}"
  fi
}

rollback_latest() {
  local latest_backup
  latest_backup="$(find "${SKILLS_ROOT}" -maxdepth 1 -type d -name "${SKILL_NAME}.backup.*" -print | sort | tail -n 1)"
  if [[ -z "${latest_backup}" ]]; then
    echo "No backup is available for rollback." >&2
    exit 1
  fi

  local current_backup=""
  if [[ -e "${TARGET_SKILL}" ]]; then
    current_backup="${TARGET_SKILL}.pre-rollback.$(date +%Y%m%d%H%M%S)"
    mv "${TARGET_SKILL}" "${current_backup}"
  fi
  mv "${latest_backup}" "${TARGET_SKILL}"
  echo "Restored version: $(installed_version)"
  echo "Target path: ${TARGET_SKILL}"
  if [[ -n "${current_backup}" ]]; then
    echo "Previous current version preserved at: ${current_backup}"
  fi
}

command="${1:-status}"
case "${command}" in
  status)
    echo "Installed version: $(installed_version)"
    echo "Latest version: $(latest_tag | sed 's/^v//')"
    echo "Target path: ${TARGET_SKILL}"
    ;;
  install)
    install_release "$(latest_tag)"
    ;;
  update)
    current="$(installed_version)"
    newest_tag="$(latest_tag)"
    newest="${newest_tag#v}"
    if [[ "${current}" == "${newest}" ]]; then
      echo "Already up to date: ${current}"
      exit 0
    fi
    install_release "${newest_tag}"
    ;;
  rollback)
    rollback_latest
    ;;
  *)
    echo "Usage: $0 {status|install|update|rollback}" >&2
    exit 1
    ;;
esac
