output "resource_group_name" {
  description = "Infrastructure resource group name."
  value       = data.azurerm_resource_group.main.name
}

output "location" {
  description = "Infrastructure location."
  value       = data.azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "VNet ID."
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "AKS subnet ID."
  value       = azurerm_subnet.aks.id
}

output "user_vm_subnet_id" {
  description = "Future user VM subnet ID."
  value       = azurerm_subnet.user_vm.id
}

output "aks_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_id" {
  description = "AKS cluster ID."
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL used for workload identity federation."
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "aks_workload_identity_enabled" {
  description = "Whether AKS workload identity is enabled."
  value       = azurerm_kubernetes_cluster.main.workload_identity_enabled
}

output "polaris_identity" {
  description = "Polaris managed identity metadata for workload identity integration."
  value = {
    id                = azurerm_user_assigned_identity.polaris.id
    client_id         = azurerm_user_assigned_identity.polaris.client_id
    principal_id      = azurerm_user_assigned_identity.polaris.principal_id
    service_account   = var.polaris_service_account_name
    namespace         = var.workload_identity_namespace
    federated_subject = azurerm_federated_identity_credential.polaris.subject
  }
}

output "trino_identity" {
  description = "Trino managed identity metadata for workload identity integration."
  value = {
    id                = azurerm_user_assigned_identity.trino.id
    client_id         = azurerm_user_assigned_identity.trino.client_id
    principal_id      = azurerm_user_assigned_identity.trino.principal_id
    service_account   = var.trino_service_account_name
    namespace         = var.workload_identity_namespace
    federated_subject = azurerm_federated_identity_credential.trino.subject
  }
}

output "airflow_identity" {
  description = "Airflow managed identity metadata for workload identity integration."
  value = {
    id                = azurerm_user_assigned_identity.airflow.id
    client_id         = azurerm_user_assigned_identity.airflow.client_id
    principal_id      = azurerm_user_assigned_identity.airflow.principal_id
    service_account   = var.airflow_service_account_name
    namespace         = var.workload_identity_namespace
    federated_subject = azurerm_federated_identity_credential.airflow.subject
  }
}

output "acr_login_server" {
  description = "ACR login server."
  value       = azurerm_container_registry.main.login_server
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.main.name
}

output "data_storage_account_name" {
  description = "Data storage account name."
  value       = azurerm_storage_account.data.name
}

output "aks_get_credentials_command" {
  description = "Command to fetch kube credentials for the AKS cluster."
  value       = "az aks get-credentials --resource-group ${data.azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing"
}
