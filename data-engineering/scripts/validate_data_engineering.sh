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
DATA_PLATFORM_NAMESPACE="${DATA_PLATFORM_NAMESPACE:-data-platform}"
AIRFLOW_DAGS_CONFIGMAP="${AIRFLOW_DAGS_CONFIGMAP:-airflow-dags}"
DAG_DIR="$REPO_ROOT/data-engineering/airflow/dags"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required"
  exit 1
fi

echo "Compiling DAG Python files"
python3 -m compileall "$DAG_DIR"

echo "Validating DAG ConfigMap render"
if command -v kubectl >/dev/null 2>&1; then
  kubectl create configmap "$AIRFLOW_DAGS_CONFIGMAP" \
    --from-file="$DAG_DIR" \
    --dry-run=client \
    -o yaml >/dev/null
else
  echo "WARN: kubectl not found; skipping ConfigMap render validation"
fi

echo "Running dbt parse"
if command -v dbt >/dev/null 2>&1; then
  dbt_version_output="$(dbt --version 2>&1 || true)"
  if [[ "$dbt_version_output" == *"dbt Cloud CLI"* ]]; then
    echo "WARN: dbt command points to dbt Cloud CLI; skipping dbt Core parse validation"
  else
    dbt deps --project-dir "$REPO_ROOT/$DBT_PROJECT_DIR" --profiles-dir "$REPO_ROOT/$DBT_PROFILES_DIR"
    dbt parse --project-dir "$REPO_ROOT/$DBT_PROJECT_DIR" --profiles-dir "$REPO_ROOT/$DBT_PROFILES_DIR"
  fi
else
  echo "WARN: dbt not found; skipping dbt validation"
fi

echo "Validation complete"
