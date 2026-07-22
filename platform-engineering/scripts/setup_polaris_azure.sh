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
POLARIS_AZURE_CREDENTIALS_SECRET_NAME="${POLARIS_AZURE_CREDENTIALS_SECRET_NAME:-polaris-azure-credentials}"
POLARIS_AZURE_TENANT_ID="${POLARIS_AZURE_TENANT_ID:-}"
POLARIS_AZURE_CLIENT_ID="${POLARIS_AZURE_CLIENT_ID:-}"
POLARIS_AZURE_CLIENT_SECRET="${POLARIS_AZURE_CLIENT_SECRET:-}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if [[ -z "$POLARIS_AZURE_TENANT_ID" || -z "$POLARIS_AZURE_CLIENT_ID" || -z "$POLARIS_AZURE_CLIENT_SECRET" ]]; then
  echo "Missing required variables. Set POLARIS_AZURE_TENANT_ID, POLARIS_AZURE_CLIENT_ID, and POLARIS_AZURE_CLIENT_SECRET."
  exit 1
fi

echo "Creating/updating Polaris Azure credentials secret in namespace: $PLATFORM_NAMESPACE"
kubectl -n "$PLATFORM_NAMESPACE" create secret generic "$POLARIS_AZURE_CREDENTIALS_SECRET_NAME" \
  --from-literal=AZURE_TENANT_ID="$POLARIS_AZURE_TENANT_ID" \
  --from-literal=AZURE_CLIENT_ID="$POLARIS_AZURE_CLIENT_ID" \
  --from-literal=AZURE_CLIENT_SECRET="$POLARIS_AZURE_CLIENT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Polaris Azure credentials secret is ready: $POLARIS_AZURE_CREDENTIALS_SECRET_NAME"
