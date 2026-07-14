# Infrastructure

Terraform and bootstrap automation for Azure AKS platform infrastructure.

## What This Sets Up
- Resource group consumed by Terraform (created by bootstrap script).
- Terraform remote state storage account and container (created by bootstrap script).
- VNet with AKS subnet and a dedicated future user VM subnet.
- AKS cluster with autoscaling default node pool.
- Azure Container Registry (ACR).
- Azure Key Vault (RBAC enabled).
- Data storage account (ADLS Gen2 enabled) with private containers.

## Prerequisites
- Azure CLI authenticated (`az login`).
- Terraform >= 1.6.
- A copied env file:
  - `cp infrastructure/.env.infrastructure.example infrastructure/.env.infrastructure`

## Run Order
1. Bootstrap Azure prerequisites:
   - `bash infrastructure/bootstrap/bootstrap_azure.sh`
2. Initialize Terraform backend:
   - `bash infrastructure/scripts/tf_init.sh`
3. Plan:
   - `bash infrastructure/scripts/tf_plan.sh`
4. Apply:
   - `bash infrastructure/scripts/tf_apply.sh`

## Notes
- Start with `TF_VAR_private_cluster_enabled=false` for dev.
- Switch to `true` later to move toward private AKS API mode.
- The user VM subnet is created now for future secure access patterns; no VM/bastion resources are provisioned in v1.
