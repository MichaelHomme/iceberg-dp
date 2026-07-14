#!/usr/bin/env bash
set -euo pipefail

if [[ -f "infrastructure/.env.infrastructure" ]]; then
  # shellcheck disable=SC1091
  source "infrastructure/.env.infrastructure"
else
  echo "ERROR: infrastructure/.env.infrastructure not found. Copy from .env.infrastructure.example first."
  exit 1
fi

cd infrastructure/terraform
terraform fmt -check
terraform validate
terraform plan -out=tfplan
