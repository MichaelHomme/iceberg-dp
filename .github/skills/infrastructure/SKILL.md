---
name: infrastructure
description: "Use when working on Terraform, Azure bootstrap scripts, AKS/VNet/subnet/storage/ACR/Key Vault provisioning, infrastructure variables and outputs, or environment bootstrap for this repository."
---

# Infrastructure Skill

## Purpose
Implement and maintain Azure infrastructure for this monorepo with reproducible bash scripts and Terraform.

## Use This Skill For
- Azure bootstrap scripts using Azure CLI.
- Terraform resource modeling for network, AKS, storage, ACR, and Key Vault.
- Variables, outputs, and handoff values consumed by platform-engineering.
- Dev-first infrastructure changes that preserve future private-network migration options.

## Do Not Use This Skill For
- Helm chart authoring or Kubernetes policy implementation.
- Airflow DAG or dbt model authoring.

## Required Approach
- Keep bootstrap idempotent.
- Keep Terraform files split by resource concern.
- Use variables and outputs to avoid hardcoding environment-specific values.

## Reference Sources
- Terraform docs: https://developer.hashicorp.com/terraform/docs
- Terraform azurerm provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- Azure AKS docs: https://learn.microsoft.com/azure/aks/
- Azure networking docs: https://learn.microsoft.com/azure/virtual-network/
- Azure Key Vault docs: https://learn.microsoft.com/azure/key-vault/
- Azure Storage docs: https://learn.microsoft.com/azure/storage/
