#!/usr/bin/env bash
set -euo pipefail

cd infrastructure/terraform

if [[ ! -f "tfplan" ]]; then
  echo "ERROR: tfplan not found. Run infrastructure/scripts/tf_plan.sh first."
  exit 1
fi

terraform apply tfplan
