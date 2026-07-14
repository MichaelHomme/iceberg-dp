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
GATEKEEPER_RELEASE_NAME="${GATEKEEPER_RELEASE_NAME:-gatekeeper}"
GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"

if [[ "$PLATFORM_NAMESPACE" != "data-platform" ]]; then
  echo "WARN: PLATFORM_NAMESPACE is '$PLATFORM_NAMESPACE' but Gatekeeper constraints in platform-engineering/opa/gatekeeper/constraints are scoped to 'data-platform'. Update match.namespaces accordingly."
fi
if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

if [[ -n "${K8S_CONTEXT:-}" ]]; then
  kubectl config use-context "$K8S_CONTEXT"
fi

echo "Creating namespaces"
kubectl get namespace "$GATEKEEPER_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$GATEKEEPER_NAMESPACE"
kubectl get namespace "$PLATFORM_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$PLATFORM_NAMESPACE"

echo "Installing Gatekeeper"
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade --install "$GATEKEEPER_RELEASE_NAME" gatekeeper/gatekeeper \
  --namespace "$GATEKEEPER_NAMESPACE"

echo "Waiting for Gatekeeper controller"
kubectl -n "$GATEKEEPER_NAMESPACE" rollout status deployment/gatekeeper-controller-manager --timeout=180s

echo "Applying Gatekeeper templates and constraints"
kubectl apply -f "$REPO_ROOT/platform-engineering/opa/gatekeeper/constrainttemplates"
kubectl apply -f "$REPO_ROOT/platform-engineering/opa/gatekeeper/constraints"

echo "Deploying Apache platform chart"
helm upgrade --install "$HELM_RELEASE_NAME" "$REPO_ROOT/$HELM_CHART_PATH" \
  --namespace "$PLATFORM_NAMESPACE" \
  --create-namespace

echo "Deployment complete"
