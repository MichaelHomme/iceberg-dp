#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/platform-engineering/.env.platform"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

INGRESS_NAMESPACE="${INGRESS_NAMESPACE:-ingress-nginx}"
INGRESS_RELEASE_NAME="${INGRESS_RELEASE_NAME:-ingress-nginx}"
INGRESS_CLASS_NAME="${INGRESS_CLASS_NAME:-nginx}"
CERT_MANAGER_NAMESPACE="${CERT_MANAGER_NAMESPACE:-cert-manager}"
CERT_MANAGER_RELEASE_NAME="${CERT_MANAGER_RELEASE_NAME:-cert-manager}"
CERT_MANAGER_CLUSTER_ISSUER_NAME="${CERT_MANAGER_CLUSTER_ISSUER_NAME:-letsencrypt-prod}"
LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-}"

if [[ -z "$LETSENCRYPT_EMAIL" ]]; then
  echo "LETSENCRYPT_EMAIL is required"
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

echo "Installing/ensuring ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade --install "$INGRESS_RELEASE_NAME" ingress-nginx/ingress-nginx \
  --namespace "$INGRESS_NAMESPACE" \
  --create-namespace \
  --set controller.ingressClassResource.name="$INGRESS_CLASS_NAME" \
  --set controller.ingressClass="$INGRESS_CLASS_NAME" \
  --set controller.service.type=LoadBalancer \
  --wait --timeout 20m

echo "Installing/ensuring cert-manager"
helm repo add jetstack https://charts.jetstack.io >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade --install "$CERT_MANAGER_RELEASE_NAME" jetstack/cert-manager \
  --namespace "$CERT_MANAGER_NAMESPACE" \
  --create-namespace \
  --set crds.enabled=true \
  --wait --timeout 20m

kubectl -n "$CERT_MANAGER_NAMESPACE" rollout status deploy/cert-manager --timeout=180s
kubectl -n "$CERT_MANAGER_NAMESPACE" rollout status deploy/cert-manager-cainjector --timeout=180s
kubectl -n "$CERT_MANAGER_NAMESPACE" rollout status deploy/cert-manager-webhook --timeout=180s

echo "Creating/updating ClusterIssuer: $CERT_MANAGER_CLUSTER_ISSUER_NAME"
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${CERT_MANAGER_CLUSTER_ISSUER_NAME}
spec:
  acme:
    email: ${LETSENCRYPT_EMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: ${CERT_MANAGER_CLUSTER_ISSUER_NAME}-account-key
    solvers:
      - http01:
          ingress:
            class: ${INGRESS_CLASS_NAME}
EOF

INGRESS_PUBLIC_IP="$(kubectl -n "$INGRESS_NAMESPACE" get svc ${INGRESS_RELEASE_NAME}-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
if [[ -z "$INGRESS_PUBLIC_IP" ]]; then
  echo "Ingress controller external IP is not ready"
  exit 1
fi

KEYCLOAK_INGRESS_HOST="${KEYCLOAK_INGRESS_HOST:-keycloak.${INGRESS_PUBLIC_IP}.nip.io}"
TRINO_INGRESS_HOST="${TRINO_INGRESS_HOST:-trino.${INGRESS_PUBLIC_IP}.nip.io}"

cat <<EONEXT

HTTPS ingress prerequisites are ready.
Use these values in platform-engineering/.env.platform:

KEYCLOAK_INGRESS_ENABLED=true
KEYCLOAK_INGRESS_CLASS_NAME=${INGRESS_CLASS_NAME}
KEYCLOAK_INGRESS_HOST=${KEYCLOAK_INGRESS_HOST}
KEYCLOAK_INGRESS_TLS_ENABLED=true
KEYCLOAK_INGRESS_TLS_SECRET_NAME=keycloak-tls
KEYCLOAK_INGRESS_CERT_MANAGER_CLUSTER_ISSUER=${CERT_MANAGER_CLUSTER_ISSUER_NAME}

TRINO_OIDC_ISSUER=https://${KEYCLOAK_INGRESS_HOST}/realms/${KEYCLOAK_REALM:-frigg-data-platform}
TRINO_WEB_UI_AUTHENTICATION_TYPE=oauth2
TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP=false
TRINO_INGRESS_ENABLED=true
TRINO_INGRESS_CLASS_NAME=${INGRESS_CLASS_NAME}
TRINO_INGRESS_HOST=${TRINO_INGRESS_HOST}
TRINO_INGRESS_TLS_ENABLED=true
TRINO_INGRESS_TLS_SECRET_NAME=trino-tls
TRINO_INGRESS_CERT_MANAGER_CLUSTER_ISSUER=${CERT_MANAGER_CLUSTER_ISSUER_NAME}

Then run:
  # Configure Keycloak realm/client/users in the Keycloak UI
  ./platform-engineering/scripts/deploy_platform.sh
EONEXT
