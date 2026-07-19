subscription_id     = "3f5adb21-57ce-4445-8313-1c22abfb65af"
location            = "norwayeast"
resource_group_name = "rg-frigg-pot"
environment         = "dev"

vnet_cidr           = "10.20.0.0/16"
aks_subnet_cidr     = "10.20.1.0/24"
user_vm_subnet_cidr = "10.20.2.0/24"

aks_name                = "frigg-dev-aks"
kubernetes_version      = null
node_pool_name          = "system"
node_vm_size            = "Standard_D4s_v5"
node_count_min          = 2
node_count_max          = 6
private_cluster_enabled = false

acr_name                  = "friggdevacr001"
key_vault_name            = "frigg-dev-kv-001"
data_storage_account_name = "friggdevdata001"

tags = {
  project = "frigg-dp"
  owner   = "platform"
}