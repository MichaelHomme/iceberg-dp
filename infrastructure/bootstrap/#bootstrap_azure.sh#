#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP_ENV_FILE="${SCRIPT_DIR}/.env.infrastructure"
BOOTSTRAP_ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.infrastructure.example"
LEGACY_ENV_FILE="${INFRA_DIR}/.env.infrastructure"
LEGACY_ENV_EXAMPLE_FILE="${INFRA_DIR}/.env.infrastructure.example"

if [[ -f "${BOOTSTRAP_ENV_FILE}" ]]; then
  # shellcheck disable=SC1091
  source "${BOOTSTRAP_ENV_FILE}"
elif [[ -f "${BOOTSTRAP_ENV_EXAMPLE_FILE}" ]]; then
  echo "INFO: Using ${BOOTSTRAP_ENV_EXAMPLE_FILE} values."
  # shellcheck disable=SC1091
  source "${BOOTSTRAP_ENV_EXAMPLE_FILE}"
elif [[ -f "${LEGACY_ENV_FILE}" ]]; then
  # shellcheck disable=SC1091
  source "${LEGACY_ENV_FILE}"
elif [[ -f "${LEGACY_ENV_EXAMPLE_FILE}" ]]; then
  echo "INFO: Using ${LEGACY_ENV_EXAMPLE_FILE} values."
  # shellcheck disable=SC1091
  source "${LEGACY_ENV_EXAMPLE_FILE}"
else
  echo "ERROR: .env.infrastructure or .env.infrastructure.example not found in ${SCRIPT_DIR} or ${INFRA_DIR}."
  exit 1
fi

: "${AZURE_SUBSCRIPTION_ID:?AZURE_SUBSCRIPTION_ID is required}"
: "${AZURE_LOCATION:?AZURE_LOCATION is required}"
: "${AZURE_RESOURCE_GROUP:?AZURE_RESOURCE_GROUP is required}"
: "${TFSTATE_RESOURCE_GROUP:?TFSTATE_RESOURCE_GROUP is required}"
: "${TFSTATE_STORAGE_ACCOUNT:?TFSTATE_STORAGE_ACCOUNT is required}"
: "${TFSTATE_CONTAINER:?TFSTATE_CONTAINER is required}"
: "${TFSTATE_KEY:?TFSTATE_KEY is required}"

BACKEND_CONFIG_FILE="${INFRA_DIR}/terraform/backend.hcl"

az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

az group create \
  --name "${AZURE_RESOURCE_GROUP}" \
  --location "${AZURE_LOCATION}" \
  --output none

az group create \
  --name "${TFSTATE_RESOURCE_GROUP}" \
  --location "${AZURE_LOCATION}" \
  --output none

az storage account create \
  --resource-group "${TFSTATE_RESOURCE_GROUP}" \
  --name "${TFSTATE_STORAGE_ACCOUNT}" \
  --location "${AZURE_LOCATION}" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true \
  --output none

az storage container create \
  --account-name "${TFSTATE_STORAGE_ACCOUNT}" \
  --name "${TFSTATE_CONTAINER}" \
  --auth-mode login \
  --output none

echo "SUCCESS: Azure bootstrap complete."

cat > "${BACKEND_CONFIG_FILE}" <<EOF
resource_group_name  = "${TFSTATE_RESOURCE_GROUP}"
storage_account_name = "${TFSTATE_STORAGE_ACCOUNT}"
container_name       = "${TFSTATE_CONTAINER}"
key                  = "${TFSTATE_KEY}"
EOF

echo "Generated backend config: ${BACKEND_CONFIG_FILE}"
echo "Run Terraform init with:"
echo "  cd ${INFRA_DIR}/terraform && terraform init -reconfigure -backend-config=backend.hcl"
