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
POLARIS_AZURE_ENABLED="${POLARIS_AZURE_ENABLED:-false}"
POLARIS_AZURE_CREDENTIALS_SECRET_NAME="${POLARIS_AZURE_CREDENTIALS_SECRET_NAME:-polaris-azure-credentials}"
POLARIS_AZURE_TENANT_ID="${POLARIS_AZURE_TENANT_ID:-}"
POLARIS_AZURE_CLIENT_ID="${POLARIS_AZURE_CLIENT_ID:-}"
POLARIS_AZURE_CLIENT_SECRET="${POLARIS_AZURE_CLIENT_SECRET:-}"
POLARIS_CATALOG_DEFAULT_BASE_LOCATION="${POLARIS_CATALOG_DEFAULT_BASE_LOCATION:-}"
POLARIS_BOOTSTRAP_CREDENTIALS="${POLARIS_BOOTSTRAP_CREDENTIALS:-}"
POLARIS_OIDC_ENABLED="${POLARIS_OIDC_ENABLED:-false}"
POLARIS_AUTHENTICATION_TYPE="${POLARIS_AUTHENTICATION_TYPE:-mixed}"
POLARIS_OIDC_AUTH_SERVER_URL="${POLARIS_OIDC_AUTH_SERVER_URL:-}"
POLARIS_OIDC_CLIENT_ID="${POLARIS_OIDC_CLIENT_ID:-}"
POLARIS_OIDC_APPLICATION_TYPE="${POLARIS_OIDC_APPLICATION_TYPE:-service}"
POLARIS_OIDC_TLS_VERIFICATION="${POLARIS_OIDC_TLS_VERIFICATION:-}"
POLARIS_OIDC_PRINCIPAL_ID_CLAIM_PATH="${POLARIS_OIDC_PRINCIPAL_ID_CLAIM_PATH:-}"
POLARIS_OIDC_PRINCIPAL_NAME_CLAIM_PATH="${POLARIS_OIDC_PRINCIPAL_NAME_CLAIM_PATH:-email}"
POLARIS_OIDC_ROLE_CLAIM_PATH="${POLARIS_OIDC_ROLE_CLAIM_PATH:-realm_access/roles}"
POLARIS_OIDC_ROLE_FILTER="${POLARIS_OIDC_ROLE_FILTER:-^POLARIS_.*$}"
POLARIS_OIDC_ROLE_MAPPING_REGEX="${POLARIS_OIDC_ROLE_MAPPING_REGEX:-^POLARIS_(.*)$}"
POLARIS_OIDC_ROLE_MAPPING_REPLACEMENT="${POLARIS_OIDC_ROLE_MAPPING_REPLACEMENT:-PRINCIPAL_ROLE:$1}"
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
KEYCLOAK_NAMESPACE="${KEYCLOAK_NAMESPACE:-frigg-pot-platform}"
KEYCLOAK_RELEASE_NAME="${KEYCLOAK_RELEASE_NAME:-keycloak}"
KEYCLOAK_REALM="${KEYCLOAK_REALM:-frigg-data-platform}"
KEYCLOAK_ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-}"
KEYCLOAK_IMAGE_REGISTRY="${KEYCLOAK_IMAGE_REGISTRY:-docker.io}"
KEYCLOAK_IMAGE_REPOSITORY="${KEYCLOAK_IMAGE_REPOSITORY:-bitnamilegacy/keycloak}"
KEYCLOAK_IMAGE_TAG="${KEYCLOAK_IMAGE_TAG:-}"
KEYCLOAK_POSTGRESQL_IMAGE_REGISTRY="${KEYCLOAK_POSTGRESQL_IMAGE_REGISTRY:-}"
KEYCLOAK_POSTGRESQL_IMAGE_REPOSITORY="${KEYCLOAK_POSTGRESQL_IMAGE_REPOSITORY:-}"
KEYCLOAK_POSTGRESQL_IMAGE_TAG="${KEYCLOAK_POSTGRESQL_IMAGE_TAG:-}"
KEYCLOAK_HELM_TIMEOUT="${KEYCLOAK_HELM_TIMEOUT:-20m}"
KEYCLOAK_ENABLED="${KEYCLOAK_ENABLED:-true}"
KEYCLOAK_HELM_REPO_NAME="${KEYCLOAK_HELM_REPO_NAME:-bitnami}"
KEYCLOAK_HELM_REPO_URL="${KEYCLOAK_HELM_REPO_URL:-https://charts.bitnami.com/bitnami}"
KEYCLOAK_HELM_CHART_VERSION="${KEYCLOAK_HELM_CHART_VERSION:-25.2.0}"
KEYCLOAK_AUTH_SECRET_NAME="${KEYCLOAK_AUTH_SECRET_NAME:-keycloak}"
KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY="${KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY:-admin-password}"
KEYCLOAK_POSTGRESQL_ENABLED="${KEYCLOAK_POSTGRESQL_ENABLED:-}"
KEYCLOAK_POSTGRESQL_EXISTING_SECRET="${KEYCLOAK_POSTGRESQL_EXISTING_SECRET:-}"
KEYCLOAK_POSTGRESQL_SECRET_USER_KEY="${KEYCLOAK_POSTGRESQL_SECRET_USER_KEY:-password}"
KEYCLOAK_POSTGRESQL_SECRET_ADMIN_KEY="${KEYCLOAK_POSTGRESQL_SECRET_ADMIN_KEY:-postgres-password}"
KEYCLOAK_EXTERNAL_DATABASE_HOST="${KEYCLOAK_EXTERNAL_DATABASE_HOST:-}"
KEYCLOAK_EXTERNAL_DATABASE_PORT="${KEYCLOAK_EXTERNAL_DATABASE_PORT:-5432}"
KEYCLOAK_EXTERNAL_DATABASE_USER="${KEYCLOAK_EXTERNAL_DATABASE_USER:-bn_keycloak}"
KEYCLOAK_EXTERNAL_DATABASE_DATABASE="${KEYCLOAK_EXTERNAL_DATABASE_DATABASE:-bitnami_keycloak}"
KEYCLOAK_EXTERNAL_DATABASE_PASSWORD="${KEYCLOAK_EXTERNAL_DATABASE_PASSWORD:-}"
KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET="${KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET:-}"
KEYCLOAK_EXTERNAL_DATABASE_SECRET_USER_KEY="${KEYCLOAK_EXTERNAL_DATABASE_SECRET_USER_KEY:-db-user}"
KEYCLOAK_EXTERNAL_DATABASE_SECRET_PASSWORD_KEY="${KEYCLOAK_EXTERNAL_DATABASE_SECRET_PASSWORD_KEY:-db-password}"
KEYCLOAK_CLIENT_ID="${KEYCLOAK_CLIENT_ID:-${TRINO_OIDC_CLIENT_ID:-trino}}"
KEYCLOAK_CLIENT_SECRET="${KEYCLOAK_CLIENT_SECRET:-${TRINO_OIDC_CLIENT_SECRET:-}}"
AKS_RESOURCE_GROUP="${AKS_RESOURCE_GROUP:-}"
AKS_NAME="${AKS_NAME:-}"

TRINO_OIDC_SCOPES_HELM="${TRINO_OIDC_SCOPES//,/\\,}"

create_or_update_secret_literal() {
  local namespace="$1"
  local name="$2"
  local key="$3"
  local value="$4"

  kubectl -n "$namespace" create secret generic "$name" \
    --from-literal="${key}=${value}" \
    --dry-run=client -o yaml | kubectl apply -f -
}

upsert_secret_literal_in_namespace() {
  local namespace="$1"
  local name="$2"
  local key="$3"
  local value="$4"

  kubectl -n "$namespace" create secret generic "$name" \
    --from-literal="${key}=${value}" \
    --dry-run=client -o yaml | kubectl apply -f -
}

generate_random_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 48 | tr -d '\n'
  else
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 64
  fi
}

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required"
  exit 1
fi

if ! kubectl -n "$KEYCLOAK_NAMESPACE" get svc "$KEYCLOAK_RELEASE_NAME" >/dev/null 2>&1; then
  detected_keycloak_namespace="$(kubectl get svc -A --no-headers 2>/dev/null | awk -v svc="$KEYCLOAK_RELEASE_NAME" '$2==svc {print $1; exit}')"
  if [[ -n "$detected_keycloak_namespace" ]]; then
    echo "KEYCLOAK_NAMESPACE '$KEYCLOAK_NAMESPACE' does not contain service '$KEYCLOAK_RELEASE_NAME'; using detected namespace '$detected_keycloak_namespace'"
    KEYCLOAK_NAMESPACE="$detected_keycloak_namespace"
  fi
fi

rewrite_keycloak_oidc_url_namespace() {
  local current_url="$1"
  if [[ "$current_url" =~ ^https?://${KEYCLOAK_RELEASE_NAME}\.([a-z0-9-]+)\.svc\.cluster\.local/realms/ ]]; then
    local url_namespace="${BASH_REMATCH[1]}"
    if [[ "$url_namespace" != "$KEYCLOAK_NAMESPACE" ]]; then
      local corrected_url
      corrected_url="$(printf '%s' "$current_url" | sed -E "s#(https?://${KEYCLOAK_RELEASE_NAME})\.[a-z0-9-]+(\.svc\.cluster\.local/realms/)#\\1.${KEYCLOAK_NAMESPACE}\\2#")"
      printf '%s' "$corrected_url"
      return
    fi
  fi
  printf '%s' "$current_url"
}

rewritten_trino_oidc_issuer="$(rewrite_keycloak_oidc_url_namespace "$TRINO_OIDC_ISSUER")"
if [[ "$rewritten_trino_oidc_issuer" != "$TRINO_OIDC_ISSUER" ]]; then
  echo "Rewriting TRINO_OIDC_ISSUER to namespace '$KEYCLOAK_NAMESPACE'"
  TRINO_OIDC_ISSUER="$rewritten_trino_oidc_issuer"
fi

rewritten_polaris_oidc_url="$(rewrite_keycloak_oidc_url_namespace "$POLARIS_OIDC_AUTH_SERVER_URL")"
if [[ "$rewritten_polaris_oidc_url" != "$POLARIS_OIDC_AUTH_SERVER_URL" ]]; then
  echo "Rewriting POLARIS_OIDC_AUTH_SERVER_URL to namespace '$KEYCLOAK_NAMESPACE'"
  POLARIS_OIDC_AUTH_SERVER_URL="$rewritten_polaris_oidc_url"
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

if [[ "$KEYCLOAK_ENABLED" == "true" ]]; then
  echo "Ensuring Keycloak namespace exists"
  kubectl get namespace "$KEYCLOAK_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$KEYCLOAK_NAMESPACE"

  if [[ -n "${KEYCLOAK_ADMIN_PASSWORD:-}" ]]; then
    echo "Creating/updating Keycloak admin secret: $KEYCLOAK_AUTH_SECRET_NAME"
    upsert_secret_literal_in_namespace "$KEYCLOAK_NAMESPACE" "$KEYCLOAK_AUTH_SECRET_NAME" "$KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY" "$KEYCLOAK_ADMIN_PASSWORD"
  fi

  keycloak_release_exists="false"
  if helm -n "$KEYCLOAK_NAMESPACE" status "$KEYCLOAK_RELEASE_NAME" >/dev/null 2>&1; then
    keycloak_release_exists="true"
  fi

  echo "Installing/upgrading Keycloak release"
  helm repo add "$KEYCLOAK_HELM_REPO_NAME" "$KEYCLOAK_HELM_REPO_URL" >/dev/null 2>&1 || true
  helm repo update >/dev/null

  KEYCLOAK_HELM_ARGS=(
    --namespace "$KEYCLOAK_NAMESPACE"
    --create-namespace
    --version "$KEYCLOAK_HELM_CHART_VERSION"
    --set-string auth.adminUser="$KEYCLOAK_ADMIN_USER"
    --set-string image.registry="$KEYCLOAK_IMAGE_REGISTRY"
    --set-string image.repository="$KEYCLOAK_IMAGE_REPOSITORY"
    --wait
    --timeout "$KEYCLOAK_HELM_TIMEOUT"
  )

  if [[ "$keycloak_release_exists" == "true" ]]; then
    KEYCLOAK_HELM_ARGS+=(--reuse-values)
  fi

  if [[ -n "$KEYCLOAK_IMAGE_TAG" ]]; then
    KEYCLOAK_HELM_ARGS+=(--set-string image.tag="$KEYCLOAK_IMAGE_TAG")
  fi

  if [[ -n "${KEYCLOAK_ADMIN_PASSWORD:-}" ]]; then
    KEYCLOAK_HELM_ARGS+=(--set-string auth.existingSecret="$KEYCLOAK_AUTH_SECRET_NAME")
    KEYCLOAK_HELM_ARGS+=(--set-string auth.passwordSecretKey="$KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY")
  fi

  should_set_db_mode="false"
  if [[ "$keycloak_release_exists" == "false" ]]; then
    should_set_db_mode="true"
  fi
  if [[ -n "$KEYCLOAK_POSTGRESQL_ENABLED" || -n "$KEYCLOAK_EXTERNAL_DATABASE_HOST" || -n "$KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET" ]]; then
    should_set_db_mode="true"
  fi

  if [[ "$should_set_db_mode" == "true" ]]; then
    if [[ "$KEYCLOAK_POSTGRESQL_ENABLED" == "false" || -n "$KEYCLOAK_EXTERNAL_DATABASE_HOST" || -n "$KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET" ]]; then
      KEYCLOAK_HELM_ARGS+=(--set postgresql.enabled=false)

      if [[ -z "$KEYCLOAK_EXTERNAL_DATABASE_HOST" ]]; then
        echo "External DB mode requires KEYCLOAK_EXTERNAL_DATABASE_HOST"
        exit 1
      fi

      KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.host="$KEYCLOAK_EXTERNAL_DATABASE_HOST")
      KEYCLOAK_HELM_ARGS+=(--set externalDatabase.port="$KEYCLOAK_EXTERNAL_DATABASE_PORT")
      KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.user="$KEYCLOAK_EXTERNAL_DATABASE_USER")
      KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.database="$KEYCLOAK_EXTERNAL_DATABASE_DATABASE")

      if [[ -n "$KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET" ]]; then
        KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.existingSecret="$KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET")
        KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.existingSecretUserKey="$KEYCLOAK_EXTERNAL_DATABASE_SECRET_USER_KEY")
        KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.existingSecretPasswordKey="$KEYCLOAK_EXTERNAL_DATABASE_SECRET_PASSWORD_KEY")
      else
        if [[ -z "$KEYCLOAK_EXTERNAL_DATABASE_PASSWORD" ]]; then
          echo "External DB mode requires KEYCLOAK_EXTERNAL_DATABASE_PASSWORD when KEYCLOAK_EXTERNAL_DATABASE_EXISTING_SECRET is not set"
          exit 1
        fi
        KEYCLOAK_HELM_ARGS+=(--set-string externalDatabase.password="$KEYCLOAK_EXTERNAL_DATABASE_PASSWORD")
      fi
    else
      KEYCLOAK_HELM_ARGS+=(--set postgresql.enabled=true)

      if [[ -n "$KEYCLOAK_POSTGRESQL_EXISTING_SECRET" ]]; then
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.auth.existingSecret="$KEYCLOAK_POSTGRESQL_EXISTING_SECRET")
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.auth.secretKeys.userPasswordKey="$KEYCLOAK_POSTGRESQL_SECRET_USER_KEY")
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.auth.secretKeys.adminPasswordKey="$KEYCLOAK_POSTGRESQL_SECRET_ADMIN_KEY")
      fi

      if [[ -n "$KEYCLOAK_POSTGRESQL_IMAGE_REGISTRY" ]]; then
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.image.registry="$KEYCLOAK_POSTGRESQL_IMAGE_REGISTRY")
      fi
      if [[ -n "$KEYCLOAK_POSTGRESQL_IMAGE_REPOSITORY" ]]; then
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.image.repository="$KEYCLOAK_POSTGRESQL_IMAGE_REPOSITORY")
      fi
      if [[ -n "$KEYCLOAK_POSTGRESQL_IMAGE_TAG" ]]; then
        KEYCLOAK_HELM_ARGS+=(--set-string postgresql.image.tag="$KEYCLOAK_POSTGRESQL_IMAGE_TAG")
      fi
    fi
  fi

  helm upgrade --install "$KEYCLOAK_RELEASE_NAME" "$KEYCLOAK_HELM_REPO_NAME/keycloak" "${KEYCLOAK_HELM_ARGS[@]}"
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

if [[ "$POLARIS_OIDC_ENABLED" == "true" ]]; then
  if [[ -z "$POLARIS_OIDC_AUTH_SERVER_URL" ]]; then
    POLARIS_OIDC_AUTH_SERVER_URL="http://${KEYCLOAK_RELEASE_NAME}.${KEYCLOAK_NAMESPACE}.svc.cluster.local/realms/${KEYCLOAK_REALM}"
    echo "POLARIS_OIDC_AUTH_SERVER_URL not set; derived from Keycloak settings: $POLARIS_OIDC_AUTH_SERVER_URL"
  fi

  if [[ -z "$POLARIS_OIDC_CLIENT_ID" ]]; then
    POLARIS_OIDC_CLIENT_ID="$KEYCLOAK_CLIENT_ID"
    echo "POLARIS_OIDC_CLIENT_ID not set; defaulting to: $POLARIS_OIDC_CLIENT_ID"
  fi

  if [[ -z "$POLARIS_OIDC_AUTH_SERVER_URL" || -z "$POLARIS_OIDC_CLIENT_ID" ]]; then
    echo "POLARIS_OIDC_ENABLED=true requires resolvable POLARIS_OIDC_AUTH_SERVER_URL and POLARIS_OIDC_CLIENT_ID"
    exit 1
  fi
fi

if [[ "$TRINO_OIDC_ENABLED" == "true" ]]; then
  if [[ -z "$TRINO_OIDC_ISSUER" ]]; then
    TRINO_OIDC_ISSUER="http://${KEYCLOAK_RELEASE_NAME}.${KEYCLOAK_NAMESPACE}.svc.cluster.local/realms/${KEYCLOAK_REALM}"
    echo "TRINO_OIDC_ISSUER not set; derived from Keycloak settings: $TRINO_OIDC_ISSUER"
  fi

  if [[ -z "$TRINO_OIDC_CLIENT_ID" ]]; then
    TRINO_OIDC_CLIENT_ID="trino"
    echo "TRINO_OIDC_CLIENT_ID not set; defaulting to: $TRINO_OIDC_CLIENT_ID"
  fi

  if [[ -z "$TRINO_OIDC_ISSUER" || -z "$TRINO_OIDC_CLIENT_ID" ]]; then
    echo "TRINO_OIDC_ENABLED=true requires resolvable TRINO_OIDC_ISSUER and TRINO_OIDC_CLIENT_ID"
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

  if [[ "$TRINO_OIDC_CREATE_SECRET" == "false" ]]; then
    if [[ -n "$KEYCLOAK_CLIENT_SECRET" ]]; then
      echo "Creating/updating Trino OIDC secret from Keycloak client secret: $TRINO_OIDC_SECRET_NAME"
      create_or_update_secret_literal "$PLATFORM_NAMESPACE" "$TRINO_OIDC_SECRET_NAME" "$TRINO_OIDC_SECRET_KEY" "$KEYCLOAK_CLIENT_SECRET"
    elif ! kubectl -n "$PLATFORM_NAMESPACE" get secret "$TRINO_OIDC_SECRET_NAME" >/dev/null 2>&1; then
      echo "Missing secret $TRINO_OIDC_SECRET_NAME in namespace $PLATFORM_NAMESPACE"
      echo "Set KEYCLOAK_CLIENT_SECRET (or TRINO_OIDC_CLIENT_SECRET), or set TRINO_OIDC_CREATE_SECRET=true"
      exit 1
    fi
  fi

  if [[ "$TRINO_INTERNAL_COMMUNICATION_CREATE_SECRET" == "false" ]] && ! kubectl -n "$PLATFORM_NAMESPACE" get secret "$TRINO_INTERNAL_COMMUNICATION_SECRET_NAME" >/dev/null 2>&1; then
    generated_shared_secret="$(generate_random_secret)"
    echo "Creating internal communication secret: $TRINO_INTERNAL_COMMUNICATION_SECRET_NAME"
    create_or_update_secret_literal "$PLATFORM_NAMESPACE" "$TRINO_INTERNAL_COMMUNICATION_SECRET_NAME" "$TRINO_INTERNAL_COMMUNICATION_SECRET_KEY" "$generated_shared_secret"
  fi

  if [[ "$TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP" == "false" && "$TRINO_INGRESS_TLS_ENABLED" != "true" ]]; then
    echo "TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP=false with no TLS ingress can block OIDC login; enabling for this deployment"
    TRINO_OIDC_ALLOW_INSECURE_OVER_HTTP="true"
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

if [[ "$POLARIS_OIDC_ENABLED" == "true" ]]; then
  HELM_ARGS+=(--set-string polaris.config.POLARIS_AUTHENTICATION_TYPE="$POLARIS_AUTHENTICATION_TYPE")
  HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_TENANT_ENABLED="true")
  HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_AUTH_SERVER_URL="$POLARIS_OIDC_AUTH_SERVER_URL")
  HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_CLIENT_ID="$POLARIS_OIDC_CLIENT_ID")
  HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_APPLICATION_TYPE="$POLARIS_OIDC_APPLICATION_TYPE")
  if [[ -n "$POLARIS_OIDC_TLS_VERIFICATION" ]]; then
    HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_TLS_VERIFICATION="$POLARIS_OIDC_TLS_VERIFICATION")
  fi
  if [[ -n "$POLARIS_OIDC_PRINCIPAL_ID_CLAIM_PATH" ]]; then
    HELM_ARGS+=(--set-string polaris.config.POLARIS_OIDC_PRINCIPAL_MAPPER_ID_CLAIM_PATH="$POLARIS_OIDC_PRINCIPAL_ID_CLAIM_PATH")
  fi
  if [[ -n "$POLARIS_OIDC_PRINCIPAL_NAME_CLAIM_PATH" ]]; then
    HELM_ARGS+=(--set-string polaris.config.POLARIS_OIDC_PRINCIPAL_MAPPER_NAME_CLAIM_PATH="$POLARIS_OIDC_PRINCIPAL_NAME_CLAIM_PATH")
  fi
  HELM_ARGS+=(--set-string polaris.config.QUARKUS_OIDC_ROLES_ROLE_CLAIM_PATH="$POLARIS_OIDC_ROLE_CLAIM_PATH")
  HELM_ARGS+=(--set-string polaris.config.POLARIS_OIDC_PRINCIPAL_ROLES_MAPPER_FILTER="$POLARIS_OIDC_ROLE_FILTER")
  HELM_ARGS+=(--set-string polaris.config.POLARIS_OIDC_PRINCIPAL_ROLES_MAPPER_MAPPINGS_0_REGEX="$POLARIS_OIDC_ROLE_MAPPING_REGEX")
  HELM_ARGS+=(--set-string polaris.config.POLARIS_OIDC_PRINCIPAL_ROLES_MAPPER_MAPPINGS_0_REPLACEMENT="$POLARIS_OIDC_ROLE_MAPPING_REPLACEMENT")
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
