#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="bestcloriswang-ctrl/enterprise-ga4-tracking-system"
CURRENT_VERSION="$(tr -d '[:space:]' < "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/VERSION")"
CACHE_ROOT="${XDG_CACHE_HOME:-${HOME}/.cache}/codex-enterprise-ga4"
CACHE_FILE="${CACHE_ROOT}/last-version-check"
CHECK_INTERVAL_SECONDS=86400

now="$(date +%s)"
if [[ -f "${CACHE_FILE}" ]]; then
  if modified="$(stat -f %m "${CACHE_FILE}" 2>/dev/null)"; then
    :
  else
    modified="$(stat -c %Y "${CACHE_FILE}" 2>/dev/null || printf '0')"
  fi
  if (( now - modified < CHECK_INTERVAL_SECONDS )); then
    cached_version="$(tr -d '[:space:]' < "${CACHE_FILE}")"
    if [[ -n "${cached_version}" && "${cached_version}" != "${CURRENT_VERSION}" ]]; then
      echo "UPDATE_AVAILABLE current=${CURRENT_VERSION} latest=${cached_version}"
    else
      echo "CHECK_SKIPPED current=${CURRENT_VERSION} reason=checked-within-24h"
    fi
    exit 0
  fi
fi

if ! effective_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPOSITORY}/releases/latest")"; then
  echo "CHECK_FAILED current=${CURRENT_VERSION} reason=network"
  exit 0
fi

latest_tag="$(basename "${effective_url}")"
latest_version="${latest_tag#v}"
mkdir -p "${CACHE_ROOT}"
printf '%s\n' "${latest_version}" > "${CACHE_FILE}"

if [[ "${latest_version}" == "${CURRENT_VERSION}" ]]; then
  echo "UP_TO_DATE current=${CURRENT_VERSION}"
else
  echo "UPDATE_AVAILABLE current=${CURRENT_VERSION} latest=${latest_version}"
fi
