#!/usr/bin/env bash
set -euo pipefail

if [[ -f "infrastructure/.env.infrastructure" ]]; then
  # shellcheck disable=SC1091
  source "infrastructure/.env.infrastructure"
else
  echo "ERROR: infrastructure/.env.infrastructure not found. Copy from .env.infrastructure.example first."
  exit 1
fi

: "${TFSTATE_RESOURCE_GROUP:?TFSTATE_RESOURCE_GROUP is required}"
: "${TFSTATE_STORAGE_ACCOUNT:?TFSTATE_STORAGE_ACCOUNT is required}"
: "${TFSTATE_CONTAINER:?TFSTATE_CONTAINER is required}"
: "${TFSTATE_KEY:?TFSTATE_KEY is required}"

cd infrastructure/terraform
terraform init \
  -backend-config="resource_group_name=${TFSTATE_RESOURCE_GROUP}" \
  -backend-config="storage_account_name=${TFSTATE_STORAGE_ACCOUNT}" \
  -backend-config="container_name=${TFSTATE_CONTAINER}" \
  -backend-config="key=${TFSTATE_KEY}"
