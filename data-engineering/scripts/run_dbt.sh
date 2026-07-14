#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/data-engineering/.env.data-engineering"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

DBT_PROJECT_DIR="${DBT_PROJECT_DIR:-data-engineering/dbt}"
DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-data-engineering/dbt/profiles}"
ACTION="${1:-all}"

if ! command -v dbt >/dev/null 2>&1; then
  echo "dbt is required"
  exit 1
fi

dbt_version_output="$(dbt --version 2>&1 || true)"
if [[ "$dbt_version_output" == *"dbt Cloud CLI"* ]]; then
  echo "dbt Core CLI is required for this script, but 'dbt' is dbt Cloud CLI"
  echo "Install dbt Core or invoke this script in an environment where dbt Core is available"
  exit 1
fi

project_arg=(--project-dir "$REPO_ROOT/$DBT_PROJECT_DIR")
profiles_arg=(--profiles-dir "$REPO_ROOT/$DBT_PROFILES_DIR")

case "$ACTION" in
  deps)
    dbt deps "${project_arg[@]}" "${profiles_arg[@]}"
    ;;
  parse)
    dbt parse "${project_arg[@]}" "${profiles_arg[@]}"
    ;;
  run)
    dbt run "${project_arg[@]}" "${profiles_arg[@]}"
    ;;
  test)
    dbt test "${project_arg[@]}" "${profiles_arg[@]}"
    ;;
  all)
    dbt deps "${project_arg[@]}" "${profiles_arg[@]}"
    dbt parse "${project_arg[@]}" "${profiles_arg[@]}"
    dbt run "${project_arg[@]}" "${profiles_arg[@]}"
    dbt test "${project_arg[@]}" "${profiles_arg[@]}"
    ;;
  *)
    echo "Usage: $0 [deps|parse|run|test|all]"
    exit 1
    ;;
esac

echo "dbt action '$ACTION' complete"
