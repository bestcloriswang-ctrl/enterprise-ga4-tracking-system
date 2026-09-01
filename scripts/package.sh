#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "${REPO_ROOT}/VERSION")"
DIST_DIR="${REPO_ROOT}/dist"
PACKAGE_NAME="enterprise_ga4_tracking_system-v${VERSION}.zip"

"${SCRIPT_DIR}/validate.sh"
mkdir -p "${DIST_DIR}"
rm -f "${DIST_DIR}/${PACKAGE_NAME}"

(
  cd "${REPO_ROOT}/skill"
  zip -r "${DIST_DIR}/${PACKAGE_NAME}" enterprise_ga4_tracking_system \
    -x '*/.DS_Store' '*/__pycache__/*' '*.pyc'
)

echo "Package created: ${DIST_DIR}/${PACKAGE_NAME}"
(
  cd "${DIST_DIR}"
  shasum -a 256 "${PACKAGE_NAME}" > "${PACKAGE_NAME}.sha256"
)
echo "Checksum created: ${DIST_DIR}/${PACKAGE_NAME}.sha256"

MANAGER_PACKAGE="enterprise-ga4-skill-manager-v1.0.0.zip"
rm -f "${DIST_DIR}/${MANAGER_PACKAGE}"
(
  cd "${REPO_ROOT}/skill"
  zip -r "${DIST_DIR}/${MANAGER_PACKAGE}" enterprise-ga4-skill-manager \
    -x '*/.DS_Store' '*/__pycache__/*' '*.pyc'
)
echo "Manager package created: ${DIST_DIR}/${MANAGER_PACKAGE}"
