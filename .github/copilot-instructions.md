# Copilot Instructions For icberg-dp

## Scope
These instructions apply to this monorepo and all subfolders.

## Repository Ownership Boundaries
- infrastructure: Azure infrastructure provisioning using Terraform and bootstrap Azure CLI scripts.
- platform-engineering: Kubernetes platform assembly on AKS using Helm, Kubernetes manifests, OPA policies, and access control setup.
- data-engineering: Airflow DAGs and dbt transformations.

## Working Rules
- Scripts-first: all operational commands must be executable from bash scripts.
- Reproducibility first: avoid one-off manual commands when a script can be created.
- Keep files modular and explicit by concern (example: network, storage, aks, policies, dags).
- Prefer official documentation links listed in this file and related skills before drafting new implementation details.

## Workflow Order
1. Bootstrap Azure prerequisites with Azure CLI scripts.
2. Apply infrastructure with Terraform.
3. Deploy platform components and policies to AKS.
4. Deploy Airflow DAGs and run dbt workflows.

## Secrets And Environment
- Use local .env files for secrets and machine-specific configuration.
- Commit only .env.example templates.
- Never commit credentials, tokens, kubeconfigs, or generated secret manifests.

## Reference Sources
Use these references as source of truth when implementing or reviewing platform assets.

### Core platform
- Apache Polaris docs: https://polaris.apache.org/
- Apache Polaris RustFS guide: https://polaris.apache.org/guides/rustfs/
- Apache Iceberg docs: https://iceberg.apache.org/docs/latest/
- Apache Superset docs: https://superset.apache.org/docs/intro
- Trino docs: https://trino.io/docs/current/

### Orchestration and transformations
- Apache Airflow docs: https://airflow.apache.org/docs/
- KubernetesPodOperator docs: https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/operators.html
- dbt docs: https://docs.getdbt.com/docs/introduction

### Security and access
- OPA docs: https://www.openpolicyagent.org/docs/latest/
- Keycloak docs: https://www.keycloak.org/documentation

### Interactive data work
- Jupyter docs: https://docs.jupyter.org/en/latest/

## Implementation Guidance
- For infrastructure requests, use the infrastructure skill.
- For AKS platform assembly, policies, and RBAC, use the platform-engineering skill.
- For DAG and transformation requests, use the data-engineering skill.
- If references conflict, prefer the official project documentation and record rationale in repository docs.
