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

KEYCLOAK_NAMESPACE="${KEYCLOAK_NAMESPACE:-identity}"
KEYCLOAK_RELEASE_NAME="${KEYCLOAK_RELEASE_NAME:-keycloak}"
KEYCLOAK_ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-change-me-admin-password}"
KEYCLOAK_IMAGE_TAG="${KEYCLOAK_IMAGE_TAG:-26.3.3-debian-12}"
KEYCLOAK_POSTGRESQL_IMAGE_TAG="${KEYCLOAK_POSTGRESQL_IMAGE_TAG:-17.6.0-debian-12}"
KEYCLOAK_HELM_TIMEOUT="${KEYCLOAK_HELM_TIMEOUT:-20m}"

KEYCLOAK_REALM="${KEYCLOAK_REALM:-frigg-data-platform}"
KEYCLOAK_CLIENT_ID="${KEYCLOAK_CLIENT_ID:-trino}"
KEYCLOAK_CLIENT_SECRET="${KEYCLOAK_CLIENT_SECRET:-change-me-trino-client-secret}"

ADMIN_USER_EMAIL="${ADMIN_USER_EMAIL:-michael.homme@fb.no}"
ADMIN_USER_PASSWORD="${ADMIN_USER_PASSWORD:-ChangeMe.Admin.123!}"
ENGINEER_USER_EMAIL="${ENGINEER_USER_EMAIL:-alexander.field.fb.no}"
ENGINEER_USER_PASSWORD="${ENGINEER_USER_PASSWORD:-ChangeMe.Engineer.123!}"
ANALYST_USER_EMAIL="${ANALYST_USER_EMAIL:-olav.syse@fb.no}"
ANALYST_USER_PASSWORD="${ANALYST_USER_PASSWORD:-ChangeMe.Analyst.123!}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

echo "Installing Keycloak (Phase 1)"
helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
helm repo update >/dev/null

set +e
helm upgrade --install "$KEYCLOAK_RELEASE_NAME" bitnami/keycloak \
  --namespace "$KEYCLOAK_NAMESPACE" \
  --create-namespace \
  --set auth.adminUser="$KEYCLOAK_ADMIN_USER" \
  --set auth.adminPassword="$KEYCLOAK_ADMIN_PASSWORD" \
  --set image.tag="$KEYCLOAK_IMAGE_TAG" \
  --set postgresql.image.tag="$KEYCLOAK_POSTGRESQL_IMAGE_TAG" \
  --set proxy=edge \
  --set postgresql.enabled=true \
  --wait \
  --timeout "$KEYCLOAK_HELM_TIMEOUT"
ret=$?
set -e

if [[ $ret -ne 0 ]]; then
  echo "ERROR: Keycloak helm install/upgrade failed. Collecting diagnostics..."
  kubectl -n "$KEYCLOAK_NAMESPACE" get pods,sts,pvc || true
  kubectl -n "$KEYCLOAK_NAMESPACE" describe pod -l app.kubernetes.io/name=keycloak | sed -n '1,200p' || true
  kubectl -n "$KEYCLOAK_NAMESPACE" describe pod -l app.kubernetes.io/component=primary | sed -n '1,200p' || true
  exit $ret
fi

echo "Waiting for Keycloak pod"
KEYCLOAK_POD="$(kubectl -n "$KEYCLOAK_NAMESPACE" get pod -l app.kubernetes.io/name=keycloak -o jsonpath='{.items[0].metadata.name}')"

exec_kcadm() {
  kubectl -n "$KEYCLOAK_NAMESPACE" exec "$KEYCLOAK_POD" -- /opt/bitnami/keycloak/bin/kcadm.sh "$@"
}

echo "Authenticating Keycloak admin API"
exec_kcadm config credentials --server http://127.0.0.1:8080 --realm master --user "$KEYCLOAK_ADMIN_USER" --password "$KEYCLOAK_ADMIN_PASSWORD" >/dev/null

echo "Creating realm if missing: $KEYCLOAK_REALM"
if ! exec_kcadm get "realms/$KEYCLOAK_REALM" >/dev/null 2>&1; then
  exec_kcadm create realms -s realm="$KEYCLOAK_REALM" -s enabled=true >/dev/null
fi

echo "Creating OIDC client if missing: $KEYCLOAK_CLIENT_ID"
if ! exec_kcadm get clients -r "$KEYCLOAK_REALM" -q clientId="$KEYCLOAK_CLIENT_ID" | grep -q '"id"'; then
  exec_kcadm create clients -r "$KEYCLOAK_REALM" \
    -s clientId="$KEYCLOAK_CLIENT_ID" \
    -s enabled=true \
    -s protocol=openid-connect \
    -s publicClient=false \
    -s directAccessGrantsEnabled=true \
    -s standardFlowEnabled=true \
    -s 'redirectUris=["*"]' \
    -s 'webOrigins=["*"]' \
    -s secret="$KEYCLOAK_CLIENT_SECRET" >/dev/null
fi

create_or_update_user() {
  local email="$1"
  local password="$2"

  if ! exec_kcadm get users -r "$KEYCLOAK_REALM" -q username="$email" | grep -q '"id"'; then
    exec_kcadm create users -r "$KEYCLOAK_REALM" \
      -s username="$email" \
      -s email="$email" \
      -s enabled=true >/dev/null
  fi

  local user_id
  user_id="$(exec_kcadm get users -r "$KEYCLOAK_REALM" -q username="$email" --fields id --format csv | tail -n 1)"
  exec_kcadm set-password -r "$KEYCLOAK_REALM" --userid "$user_id" --new-password "$password" >/dev/null
}

echo "Creating/updating users"
create_or_update_user "$ADMIN_USER_EMAIL" "$ADMIN_USER_PASSWORD"
create_or_update_user "$ENGINEER_USER_EMAIL" "$ENGINEER_USER_PASSWORD"
create_or_update_user "$ANALYST_USER_EMAIL" "$ANALYST_USER_PASSWORD"

echo "Creating Trino OIDC secret in namespace: $PLATFORM_NAMESPACE"
kubectl -n "$PLATFORM_NAMESPACE" create secret generic trino-oidc-secret \
  --from-literal=client-secret="$KEYCLOAK_CLIENT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "SUCCESS: Keycloak Phase 1 setup complete"
echo "OIDC issuer: http://${KEYCLOAK_RELEASE_NAME}.${KEYCLOAK_NAMESPACE}.svc.cluster.local:8080/realms/${KEYCLOAK_REALM}"
echo "Next: deploy Trino with OIDC enabled via values override"