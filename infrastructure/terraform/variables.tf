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
