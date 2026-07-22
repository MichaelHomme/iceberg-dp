#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/data-engineering/.env.data-engineering"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

DATA_PLATFORM_NAMESPACE="${DATA_PLATFORM_NAMESPACE:-frigg-pot-platform}"
AIRFLOW_DAGS_CONFIGMAP="${AIRFLOW_DAGS_CONFIGMAP:-airflow-dags}"
AIRFLOW_SCHEDULER_DEPLOYMENT="${AIRFLOW_SCHEDULER_DEPLOYMENT:-}"
AIRFLOW_WEBSERVER_DEPLOYMENT="${AIRFLOW_WEBSERVER_DEPLOYMENT:-}"
DAG_DIR="$REPO_ROOT/data-engineering/airflow/dags"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if [[ -n "${K8S_CONTEXT:-}" ]]; then
  kubectl config use-context "$K8S_CONTEXT"
fi

echo "Ensuring namespace exists"
kubectl get namespace "$DATA_PLATFORM_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$DATA_PLATFORM_NAMESPACE"

echo "Applying DAG ConfigMap"
kubectl create configmap "$AIRFLOW_DAGS_CONFIGMAP" \
  --from-file="$DAG_DIR" \
  --namespace "$DATA_PLATFORM_NAMESPACE" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "Restarting Airflow deployments when configured"
if [[ -n "$AIRFLOW_SCHEDULER_DEPLOYMENT" ]]; then
  kubectl -n "$DATA_PLATFORM_NAMESPACE" rollout restart deployment "$AIRFLOW_SCHEDULER_DEPLOYMENT"
fi

if [[ -n "$AIRFLOW_WEBSERVER_DEPLOYMENT" ]]; then
  kubectl -n "$DATA_PLATFORM_NAMESPACE" rollout restart deployment "$AIRFLOW_WEBSERVER_DEPLOYMENT"
fi

echo "DAG deployment complete"
