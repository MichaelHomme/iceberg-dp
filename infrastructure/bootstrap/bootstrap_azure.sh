#!/usr/bin/env bash
set -euo pipefail

if [[ -f "infrastructure/.env.infrastructure" ]]; then
  # shellcheck disable=SC1091
  source "infrastructure/.env.infrastructure"
elif [[ -f "infrastructure/.env.infrastructure.example" ]]; then
  echo "INFO: Using infrastructure/.env.infrastructure.example values."
  # shellcheck disable=SC1091
  source "infrastructure/.env.infrastructure.example"
else
  echo "ERROR: infrastructure/.env.infrastructure or .env.infrastructure.example not found."
  exit 1
fi

: "${AZURE_SUBSCRIPTION_ID:?AZURE_SUBSCRIPTION_ID is required}"
: "${AZURE_LOCATION:?AZURE_LOCATION is required}"
: "${AZURE_RESOURCE_GROUP:?AZURE_RESOURCE_GROUP is required}"
: "${TFSTATE_RESOURCE_GROUP:?TFSTATE_RESOURCE_GROUP is required}"
: "${TFSTATE_STORAGE_ACCOUNT:?TFSTATE_STORAGE_ACCOUNT is required}"
: "${TFSTATE_CONTAINER:?TFSTATE_CONTAINER is required}"

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
