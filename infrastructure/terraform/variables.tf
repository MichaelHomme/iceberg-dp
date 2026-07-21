variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region for infrastructure."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Existing Azure resource group name created by bootstrap scripts."
  type        = string
}

variable "environment" {
  description = "Environment name (for example: dev)."
  type        = string
  default     = "dev"
}

variable "vnet_cidr" {
  description = "CIDR block for platform VNet."
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "CIDR block for AKS subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "user_vm_subnet_cidr" {
  description = "CIDR block for future user/jump-host subnet (VMs not created in v1)."
  type        = string
  default     = "10.20.2.0/24"
}

variable "aks_name" {
  description = "AKS cluster name."
  type        = string
  default     = "frigg-dev-aks"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = null
}

variable "node_pool_name" {
  description = "Default node pool name."
  type        = string
  default     = "system"
}

variable "node_vm_size" {
  description = "VM size for the AKS node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "node_count_min" {
  description = "Minimum node count for autoscaling node pool."
  type        = number
  default     = 2
}

variable "node_count_max" {
  description = "Maximum node count for autoscaling node pool."
  type        = number
  default     = 6
}

variable "private_cluster_enabled" {
  description = "Set true to enable private AKS API server."
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable AKS OIDC issuer. Required for workload identity federation."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable AKS workload identity."
  type        = bool
  default     = true
}

variable "workload_identity_namespace" {
  description = "Kubernetes namespace that hosts workload identity-enabled service accounts."
  type        = string
  default     = "frigg-pot-platform"
}

variable "polaris_identity_name" {
  description = "User-assigned managed identity name for Polaris."
  type        = string
  default     = "frigg-dev-polaris-mi"
}

variable "trino_identity_name" {
  description = "User-assigned managed identity name for Trino."
  type        = string
  default     = "frigg-dev-trino-mi"
}

variable "airflow_identity_name" {
  description = "User-assigned managed identity name for Airflow."
  type        = string
  default     = "frigg-dev-airflow-mi"
}

variable "polaris_service_account_name" {
  description = "Kubernetes service account name used by Polaris."
  type        = string
  default     = "polaris-sa"
}

variable "trino_service_account_name" {
  description = "Kubernetes service account name used by Trino."
  type        = string
  default     = "trino-sa"
}

variable "airflow_service_account_name" {
  description = "Kubernetes service account name used by Airflow."
  type        = string
  default     = "airflow-sa"
}

variable "polaris_storage_blob_role_enabled" {
  description = "Assign Azure Blob data-plane role for Polaris identity on the data storage account."
  type        = bool
  default     = true
}

variable "trino_storage_blob_role_enabled" {
  description = "Assign Azure Blob data-plane role for Trino identity on the data storage account."
  type        = bool
  default     = true
}

variable "airflow_storage_blob_role_enabled" {
  description = "Assign Azure Blob data-plane role for Airflow identity on the data storage account."
  type        = bool
  default     = false
}

variable "polaris_storage_blob_role" {
  description = "Azure role assigned to Polaris identity for Blob access."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "trino_storage_blob_role" {
  description = "Azure role assigned to Trino identity for Blob access."
  type        = string
  default     = "Storage Blob Data Contributor"
}

variable "airflow_storage_blob_role" {
  description = "Azure role assigned to Airflow identity for Blob access."
  type        = string
  default     = "Storage Blob Data Reader"
}

variable "acr_name" {
  description = "ACR name. Must be globally unique and 5-50 lowercase alphanumeric characters."
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name. Must be globally unique."
  type        = string
}

variable "data_storage_account_name" {
  description = "Storage account name for platform data (Iceberg objects)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default = {
    project = "frigg-dp"
  }
}
