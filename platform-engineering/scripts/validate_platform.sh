#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHART_PATH="$REPO_ROOT/platform-engineering/helm/apache-platform"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

echo "Linting Helm chart"
helm lint "$CHART_PATH"

echo "Rendering Helm manifests"
render_file="$(mktemp "${TMPDIR:-/tmp}/apache-platform-rendered.XXXXXX.yaml")"
trap 'rm -f "$render_file"' EXIT
helm template apache-platform "$CHART_PATH" >"$render_file"
kubectl apply --dry-run=client -f "$render_file" >/dev/null

echo "Checking OPA files"
kubectl apply --dry-run=client -f "$REPO_ROOT/platform-engineering/opa/gatekeeper/constrainttemplates" >/dev/null
kubectl apply --dry-run=client -f "$REPO_ROOT/platform-engineering/opa/gatekeeper/constraints" >/dev/null

echo "Validation complete"
