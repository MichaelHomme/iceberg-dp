#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ENV_FILE="$REPO_ROOT/platform-engineering/.env.platform"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-data-platform}"
HELM_RELEASE_NAME="${HELM_RELEASE_NAME:-apache-platform}"
HELM_CHART_PATH="${HELM_CHART_PATH:-platform-engineering/helm/apache-platform}"
ENABLE_GATEKEEPER="${ENABLE_GATEKEEPER:-false}"
GATEKEEPER_RELEASE_NAME="${GATEKEEPER_RELEASE_NAME:-gatekeeper}"
GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"
AKS_RESOURCE_GROUP="${AKS_RESOURCE_GROUP:-}"
AKS_NAME="${AKS_NAME:-}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

if [[ -n "$AKS_RESOURCE_GROUP" || -n "$AKS_NAME" ]]; then
  if [[ -z "$AKS_RESOURCE_GROUP" || -z "$AKS_NAME" ]]; then
    echo "Both AKS_RESOURCE_GROUP and AKS_NAME must be set together"
    exit 1
  fi

  if ! command -v az >/dev/null 2>&1; then
    echo "az is required when AKS_RESOURCE_GROUP/AKS_NAME are set"
    exit 1
  fi

  echo "Refreshing kubeconfig from AKS"
  az aks get-credentials \
    --resource-group "$AKS_RESOURCE_GROUP" \
    --name "$AKS_NAME" \
    --overwrite-existing \
    --output none

  if [[ -z "${K8S_CONTEXT:-}" ]]; then
    K8S_CONTEXT="$AKS_NAME"
  fi
fi

if [[ -n "${K8S_CONTEXT:-}" ]]; then
  kubectl config use-context "$K8S_CONTEXT"
fi

echo "Creating namespaces"
kubectl get namespace "$PLATFORM_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$PLATFORM_NAMESPACE"

if [[ "$ENABLE_GATEKEEPER" == "true" ]]; then
  kubectl get namespace "$GATEKEEPER_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$GATEKEEPER_NAMESPACE"

  echo "Installing Gatekeeper"
  helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts >/dev/null 2>&1 || true
  helm repo update >/dev/null
  helm upgrade --install "$GATEKEEPER_RELEASE_NAME" gatekeeper/gatekeeper \
    --namespace "$GATEKEEPER_NAMESPACE"

  echo "Waiting for Gatekeeper controller"
  kubectl -n "$GATEKEEPER_NAMESPACE" rollout status deployment/gatekeeper-controller-manager --timeout=180s

  echo "Applying Gatekeeper templates and constraints"
  kubectl apply -f "$REPO_ROOT/platform-engineering/opa/gatekeeper/constrainttemplates"

  # Render constraints for the selected platform namespace at deploy time.
  CONSTRAINTS_SRC_DIR="$REPO_ROOT/platform-engineering/opa/gatekeeper/constraints"
  CONSTRAINTS_RENDER_DIR="$(mktemp -d)"
  trap 'rm -rf "$CONSTRAINTS_RENDER_DIR"' EXIT

  for constraint_file in "$CONSTRAINTS_SRC_DIR"/*.yaml; do
    sed "s/namespaces: \[\"data-platform\"\]/namespaces: [\"${PLATFORM_NAMESPACE}\"]/g" "$constraint_file" > "$CONSTRAINTS_RENDER_DIR/$(basename "$constraint_file")"
  done

  kubectl apply -f "$CONSTRAINTS_RENDER_DIR"
else
  echo "Skipping Gatekeeper install and OPA constraints (ENABLE_GATEKEEPER=${ENABLE_GATEKEEPER})"
fi

echo "Deploying Apache platform chart"
helm upgrade --install "$HELM_RELEASE_NAME" "$REPO_ROOT/$HELM_CHART_PATH" \
  --namespace "$PLATFORM_NAMESPACE" \
  --create-namespace

echo "Deployment complete"
