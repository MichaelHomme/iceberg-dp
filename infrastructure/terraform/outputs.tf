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
