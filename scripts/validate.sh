#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_ROOT="${REPO_ROOT}/skill/enterprise_ga4_tracking_system"

required_files=(
  "${REPO_ROOT}/VERSION"
  "${SKILL_ROOT}/SKILL.md"
  "${SKILL_ROOT}/agents/openai.yaml"
  "${SKILL_ROOT}/references/six-table-schema.md"
  "${SKILL_ROOT}/references/journey-analysis-plan.md"
  "${SKILL_ROOT}/references/kpi-driven-funnel.md"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "${required_file}" ]]; then
    echo "Missing required file: ${required_file}" >&2
    exit 1
  fi
done

version="$(tr -d '[:space:]' < "${REPO_ROOT}/VERSION")"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must use semantic version format: x.y.z" >&2
  exit 1
fi

if [[ "$(head -n 1 "${SKILL_ROOT}/SKILL.md")" != "---" ]]; then
  echo "SKILL.md is missing YAML frontmatter" >&2
  exit 1
fi

if ! grep -q '^name: enterprise_ga4_tracking_system$' "${SKILL_ROOT}/SKILL.md"; then
  echo "Unexpected Skill name" >&2
  exit 1
fi

if grep -R -n '\[TODO:' "${SKILL_ROOT}"; then
  echo "Unfinished TODO placeholder found" >&2
  exit 1
fi

for shell_file in "${SCRIPT_DIR}"/*.sh; do
  bash -n "${shell_file}"
done

echo "Validation passed: enterprise_ga4_tracking_system v${version}"
