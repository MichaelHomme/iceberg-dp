resource "azurerm_user_assigned_identity" "polaris" {
  name                = var.polaris_identity_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "trino" {
  name                = var.trino_identity_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_user_assigned_identity" "airflow" {
  name                = var.airflow_identity_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_federated_identity_credential" "polaris" {
  name      = "${local.name_prefix}-polaris-fic"
  parent_id = azurerm_user_assigned_identity.polaris.id
  issuer    = azurerm_kubernetes_cluster.main.oidc_issuer_url
  audience  = ["api://AzureADTokenExchange"]
  subject   = "system:serviceaccount:${var.workload_identity_namespace}:${var.polaris_service_account_name}"
}

resource "azurerm_federated_identity_credential" "trino" {
  name      = "${local.name_prefix}-trino-fic"
  parent_id = azurerm_user_assigned_identity.trino.id
  issuer    = azurerm_kubernetes_cluster.main.oidc_issuer_url
  audience  = ["api://AzureADTokenExchange"]
  subject   = "system:serviceaccount:${var.workload_identity_namespace}:${var.trino_service_account_name}"
}

resource "azurerm_federated_identity_credential" "airflow" {
  name      = "${local.name_prefix}-airflow-fic"
  parent_id = azurerm_user_assigned_identity.airflow.id
  issuer    = azurerm_kubernetes_cluster.main.oidc_issuer_url
  audience  = ["api://AzureADTokenExchange"]
  subject   = "system:serviceaccount:${var.workload_identity_namespace}:${var.airflow_service_account_name}"
}

resource "azurerm_role_assignment" "polaris_storage_blob" {
  count                = var.polaris_storage_blob_role_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.polaris.principal_id
  role_definition_name = var.polaris_storage_blob_role
  scope                = azurerm_storage_account.data.id
}

resource "azurerm_role_assignment" "trino_storage_blob" {
  count                = var.trino_storage_blob_role_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.trino.principal_id
  role_definition_name = var.trino_storage_blob_role
  scope                = azurerm_storage_account.data.id
}

resource "azurerm_role_assignment" "airflow_storage_blob" {
  count                = var.airflow_storage_blob_role_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.airflow.principal_id
  role_definition_name = var.airflow_storage_blob_role
  scope                = azurerm_storage_account.data.id
}