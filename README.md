# icberg-dp

Open-source data platform monorepo for Azure AKS, organized by engineering ownership and reproducible workflows.

## Goal
Build a modular data platform using Apache-licensed components where possible, with:
- Infrastructure provisioned by Terraform.
- Platform services deployed to AKS with Kubernetes manifests and Helm.
- Data workloads orchestrated by Airflow and transformed with dbt.
- Script-first operations for reproducibility across environments.

## Architecture Components
Planned platform stack includes:
- Storage and table format: Apache Iceberg, RustFS.
- Catalog and governance: Apache Polaris.
- Query engine: Trino.
- Visualization: Apache Superset.
- Identity and access: Keycloak.
- Policy enforcement: Open Policy Agent.
- Interactive workloads: Jupyter.
- Orchestration and transformations: Apache Airflow and dbt.

## Monorepo Ownership Model
This repository is split into 3 ownership/workflow areas:

1. infrastructure
- Azure bootstrap scripts and Terraform code.
- Core resources: resource group, state storage, VNet/subnets, AKS, ACR, Key Vault.
- Outputs and handoff values consumed by downstream areas.

2. platform-engineering
- Kubernetes namespaces, Helm releases, service wiring, RBAC.
- Policy-as-code using OPA.
- Platform-level access setup including fictional personas (data-analyst, data-engineer, admin).

3. data-engineering
- Airflow DAGs using KubernetesPodOperator.
- dbt project for transformations and tests.
- Scripted execution and validation for data pipelines.

## Current Status
Initial repository customization has been implemented:
- Copilot repository guidance: `.github/copilot-instructions.md`
- Skills:
  - `.github/skills/infrastructure/SKILL.md`
  - `.github/skills/platform-engineering/SKILL.md`
  - `.github/skills/data-engineering/SKILL.md`
- Git ignore baseline: `.gitignore`

Scaffolding for infra/platform/data folders will be added next.

## Repository Conventions
- Scripts-first: all actions should be runnable through bash scripts.
- Reproducible runs: avoid one-off/manual deployment commands.
- Secrets hygiene:
  - Use local `.env` files.
  - Commit only `.env.example` templates.
  - Never commit credentials, kubeconfig files, or generated secret manifests.
- Keep resource code modular by concern (example: `network.tf`, `aks.tf`, `storage.tf`).

## Planned Execution Flow
1. Bootstrap Azure prerequisites with Azure CLI scripts.
2. Run Terraform plan/apply for infrastructure.
3. Deploy platform components and policy controls to AKS.
4. Deploy Airflow assets and run dbt workflows.

## Primary References
- Apache Polaris: https://polaris.apache.org/
- Polaris RustFS guide: https://polaris.apache.org/guides/rustfs/
- Apache Iceberg: https://iceberg.apache.org/docs/latest/
- Trino: https://trino.io/docs/current/
- Apache Superset: https://superset.apache.org/docs/intro
- Apache Airflow: https://airflow.apache.org/docs/
- Airflow KubernetesPodOperator: https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/operators.html
- dbt: https://docs.getdbt.com/docs/introduction
- OPA: https://www.openpolicyagent.org/docs/latest/
- Keycloak: https://www.keycloak.org/documentation
- Jupyter: https://docs.jupyter.org/en/latest/

## Next Steps
1. Add base folder scaffolding for `infrastructure`, `platform-engineering`, and `data-engineering`.
2. Add root and per-area `.env.example` templates.
3. Add Azure bootstrap scripts for resource group and Terraform state storage.
4. Add Terraform baseline files and variables/outputs.
5. Add initial Helm/Kubernetes, OPA, Airflow, and dbt scaffolding.
