#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ENV_FILE="$REPO_ROOT/platform-engineering/.env.platform"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

PLATFORM_NAMESPACE="${PLATFORM_NAMESPACE:-frigg-pot-platform}"
HELM_RELEASE_NAME="${HELM_RELEASE_NAME:-apache-platform}"
HELM_CHART_PATH="${HELM_CHART_PATH:-platform-engineering/helm/apache-platform}"
ENABLE_GATEKEEPER="${ENABLE_GATEKEEPER:-false}"
GATEKEEPER_RELEASE_NAME="${GATEKEEPER_RELEASE_NAME:-gatekeeper}"
GATEKEEPER_NAMESPACE="${GATEKEEPER_NAMESPACE:-gatekeeper-system}"
POLARIS_AZURE_ENABLED="${POLARIS_AZURE_ENABLED:-false}"
POLARIS_AZURE_CREDENTIALS_SECRET_NAME="${POLARIS_AZURE_CREDENTIALS_SECRET_NAME:-polaris-azure-credentials}"
POLARIS_AZURE_TENANT_ID="${POLARIS_AZURE_TENANT_ID:-}"
POLARIS_AZURE_CLIENT_ID="${POLARIS_AZURE_CLIENT_ID:-}"
POLARIS_AZURE_CLIENT_SECRET="${POLARIS_AZURE_CLIENT_SECRET:-}"
POLARIS_CATALOG_DEFAULT_BASE_LOCATION="${POLARIS_CATALOG_DEFAULT_BASE_LOCATION:-}"
POLARIS_BOOTSTRAP_CREDENTIALS="${POLARIS_BOOTSTRAP_CREDENTIALS:-}"
TRINO_OIDC_ENABLED="${TRINO_OIDC_ENABLED:-false}"
TRINO_OIDC_ISSUER="${TRINO_OIDC_ISSUER:-}"
TRINO_OIDC_CLIENT_ID="${TRINO_OIDC_CLIENT_ID:-}"
TRINO_OIDC_SCOPES="${TRINO_OIDC_SCOPES:-openid,email,profile}"
TRINO_OIDC_PRINCIPAL_FIELD="${TRINO_OIDC_PRINCIPAL_FIELD:-email}"
TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP="${TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP:-false}"
TRINO_WEB_UI_AUTHENTICATION_TYPE="${TRINO_WEB_UI_AUTHENTICATION_TYPE:-oauth2}"
TRINO_OIDC_CREATE_SECRET="${TRINO_OIDC_CREATE_SECRET:-false}"
TRINO_OIDC_CLIENT_SECRET="${TRINO_OIDC_CLIENT_SECRET:-}"
TRINO_OIDC_SECRET_NAME="${TRINO_OIDC_SECRET_NAME:-trino-oidc-secret}"
TRINO_OIDC_SECRET_KEY="${TRINO_OIDC_SECRET_KEY:-client-secret}"
TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET="${TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET:-false}"
TRINO_INTERNAL_COMMUNICATION_SHARED_SECRET="${TRINO_INTERNAL_COMMUNICATION_SHARED_SECRET:-}"
TRINO_INTERNAL_COMMUNICATION_SECRET_NAME="${TRINO_INTERNAL_COMMUNICATION_SECRET_NAME:-trino-internal-communication-secret}"
TRINO_INTERNAL_COMMUNICATION_SECRET_KEY="${TRINO_INTERNAL_COMMUNICATION_SECRET_KEY:-shared-secret}"
TRINO_INGRESS_ENABLED="${TRINO_INGRESS_ENABLED:-false}"
TRINO_INGRESS_CLASS_NAME="${TRINO_INGRESS_CLASS_NAME:-nginx}"
TRINO_INGRESS_HOST="${TRINO_INGRESS_HOST:-}"
TRINO_INGRESS_TLS_ENABLED="${TRINO_INGRESS_TLS_ENABLED:-false}"
TRINO_INGRESS_TLS_SECRET_NAME="${TRINO_INGRESS_TLS_SECRET_NAME:-}"
TRINO_INGRESS_CERT_MANAGER_CLUSTER_ISSUER="${TRINO_INGRESS_CERT_MANAGER_CLUSTER_ISSUER:-}"
AKS_RESOURCE_GROUP="${AKS_RESOURCE_GROUP:-}"
AKS_NAME="${AKS_NAME:-}"

TRINO_OIDC_SCOPES_HELM="${TRINO_OIDC_SCOPES//,/\\,}"

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
    sed "s/namespaces: \[\"frigg-pot-platform\"\]/namespaces: [\"${PLATFORM_NAMESPACE}\"]/g" "$constraint_file" > "$CONSTRAINTS_RENDER_DIR/$(basename "$constraint_file")"
  done

  kubectl apply -f "$CONSTRAINTS_RENDER_DIR"
else
  echo "Skipping Gatekeeper install and OPA constraints (ENABLE_GATEKEEPER=${ENABLE_GATEKEEPER})"
fi

if [[ "$POLARIS_AZURE_ENABLED" == "true" ]]; then
  if [[ -z "$POLARIS_AZURE_TENANT_ID" || -z "$POLARIS_AZURE_CLIENT_ID" || -z "$POLARIS_AZURE_CLIENT_SECRET" ]]; then
    echo "POLARIS_AZURE_ENABLED=true requires POLARIS_AZURE_TENANT_ID, POLARIS_AZURE_CLIENT_ID, and POLARIS_AZURE_CLIENT_SECRET"
    exit 1
  fi

  echo "Creating/updating Polaris Azure credentials secret: $POLARIS_AZURE_CREDENTIALS_SECRET_NAME"
  kubectl -n "$PLATFORM_NAMESPACE" create secret generic "$POLARIS_AZURE_CREDENTIALS_SECRET_NAME" \
    --from-literal=AZURE_TENANT_ID="$POLARIS_AZURE_TENANT_ID" \
    --from-literal=AZURE_CLIENT_ID="$POLARIS_AZURE_CLIENT_ID" \
    --from-literal=AZURE_CLIENT_SECRET="$POLARIS_AZURE_CLIENT_SECRET" \
    --dry-run=client -o yaml | kubectl apply -f -
fi

if [[ "$TRINO_OIDC_ENABLED" == "true" ]]; then
  if [[ -z "$TRINO_OIDC_ISSUER" || -z "$TRINO_OIDC_CLIENT_ID" ]]; then
    echo "TRINO_OIDC_ENABLED=true requires TRINO_OIDC_ISSUER and TRINO_OIDC_CLIENT_ID"
    exit 1
  fi

  if [[ "$TRINO_OIDC_CREATE_SECRET" == "true" && -z "$TRINO_OIDC_CLIENT_SECRET" ]]; then
    echo "TRINO_OIDC_CREATE_SECRET=true requires TRINO_OIDC_CLIENT_SECRET"
    exit 1
  fi

  if [[ "$TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET" == "true" && -z "$TRINO_INTERNAL_COMMUNICATION_SHARED_SECRET" ]]; then
    echo "TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET=true requires TRINO_INTERNAL_COMMUNICATION_SHARED_SECRET"
    exit 1
  fi
fi

if [[ "$TRINO_INGRESS_ENABLED" == "true" ]]; then
  if [[ -z "$TRINO_INGRESS_HOST" ]]; then
    echo "TRINO_INGRESS_ENABLED=true requires TRINO_INGRESS_HOST"
    exit 1
  fi

  if [[ "$TRINO_INGRESS_TLS_ENABLED" == "true" && -z "$TRINO_INGRESS_TLS_SECRET_NAME" ]]; then
    echo "TRINO_INGRESS_TLS_ENABLED=true requires TRINO_INGRESS_TLS_SECRET_NAME"
    exit 1
  fi
fi

HELM_ARGS=(
  --namespace "$PLATFORM_NAMESPACE"
  --create-namespace
)

if [[ "$POLARIS_AZURE_ENABLED" == "true" ]]; then
  HELM_ARGS+=(--set polaris.azure.enabled=true)
  HELM_ARGS+=(--set polaris.azure.credentialsSecretName="$POLARIS_AZURE_CREDENTIALS_SECRET_NAME")
fi

if [[ -n "$POLARIS_CATALOG_DEFAULT_BASE_LOCATION" ]]; then
  HELM_ARGS+=(--set-string polaris.config.POLARIS_CATALOG_DEFAULT_BASE_LOCATION="$POLARIS_CATALOG_DEFAULT_BASE_LOCATION")
fi

if [[ -n "$POLARIS_BOOTSTRAP_CREDENTIALS" ]]; then
  HELM_ARGS+=(--set-string polaris.config.POLARIS_BOOTSTRAP_CREDENTIALS="$POLARIS_BOOTSTRAP_CREDENTIALS")
fi

if [[ "$TRINO_OIDC_ENABLED" == "true" ]]; then
  HELM_ARGS+=(--set trino.oidc.enabled=true)
  HELM_ARGS+=(--set-string trino.oidc.issuer="$TRINO_OIDC_ISSUER")
  HELM_ARGS+=(--set-string trino.oidc.clientId="$TRINO_OIDC_CLIENT_ID")
  HELM_ARGS+=(--set-string trino.oidc.scopes="$TRINO_OIDC_SCOPES_HELM")
  HELM_ARGS+=(--set-string trino.oidc.principalField="$TRINO_OIDC_PRINCIPAL_FIELD")
  HELM_ARGS+=(--set trino.oidc.allowInsecureOverHttp="$TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP")
  HELM_ARGS+=(--set-string trino.oidc.webUiAuthenticationType="$TRINO_WEB_UI_AUTHENTICATION_TYPE")
  HELM_ARGS+=(--set trino.oidc.createSecret="$TRINO_OIDC_CREATE_SECRET")
  HELM_ARGS+=(--set-string trino.oidc.secretName="$TRINO_OIDC_SECRET_NAME")
  HELM_ARGS+=(--set-string trino.oidc.secretKey="$TRINO_OIDC_SECRET_KEY")
  HELM_ARGS+=(--set trino.internalCommunication.createSecret="$TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET")
  HELM_ARGS+=(--set-string trino.internalCommunication.secretName="$TRINO_INTERNAL_COMMUNICATION_SECRET_NAME")
  HELM_ARGS+=(--set-string trino.internalCommunication.secretKey="$TRINO_INTERNAL_COMMUNICATION_SECRET_KEY")

  if [[ "$TRINO_OIDC_CREATE_SECRET" == "true" ]]; then
    HELM_ARGS+=(--set-string trino.oidc.clientSecret="$TRINO_OIDC_CLIENT_SECRET")
  fi

  if [[ "$TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET" == "true" ]]; then
    HELM_ARGS+=(--set-string trino.internalCommunication.sharedSecret="$TRINO_INTERNAL_COMMUNICATION_SHARED_SECRET")
  fi
fi

if [[ "$TRINO_INGRESS_ENABLED" == "true" ]]; then
  HELM_ARGS+=(--set trino.ingress.enabled=true)
  HELM_ARGS+=(--set-string trino.ingress.className="$TRINO_INGRESS_CLASS_NAME")
  HELM_ARGS+=(--set-string trino.ingress.host="$TRINO_INGRESS_HOST")
  HELM_ARGS+=(--set trino.ingress.tls.enabled="$TRINO_INGRESS_TLS_ENABLED")

  if [[ "$TRINO_INGRESS_TLS_ENABLED" == "true" ]]; then
    HELM_ARGS+=(--set-string trino.ingress.tls.secretName="$TRINO_INGRESS_TLS_SECRET_NAME")
  fi

  if [[ -n "$TRINO_INGRESS_CERT_MANAGER_CLUSTER_ISSUER" ]]; then
    HELM_ARGS+=(--set-string trino.ingress.annotations.cert-manager\\.io/cluster-issuer="$TRINO_INGRESS_CERT_MANAGER_CLUSTER_ISSUER")
  fi
fi

echo "Deploying Apache platform chart"
helm upgrade --install "$HELM_RELEASE_NAME" "$REPO_ROOT/$HELM_CHART_PATH" \
  "${HELM_ARGS[@]}"

echo "Deployment complete"
