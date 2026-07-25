---
name: platform-engineering
description: "Use when working on Helm charts, Kubernetes namespaces/services/pods, OPA policies, Keycloak integration, and platform component assembly for Superset, Trino, Polaris, Iceberg-related services, and Jupyter workloads on AKS."
---

# Platform Engineering Skill

## Purpose
Define and operate Kubernetes platform components on AKS using reproducible scripts and versioned manifests/charts.

## Use This Skill For
- Helm release definitions and values management.
- Kubernetes resources for namespaces, workloads, services, and RBAC.
- Keycloak-based identity and role mapping for test personas.
- Wiring platform components together (Polaris, Trino, Superset, Jupyter).

## Do Not Use This Skill For
- Terraform infrastructure provisioning.
- Airflow DAG business logic or dbt model authoring.

## Persona Baseline
- data-analyst
- data-engineer
- admin

## Required Approach
- All deploy and validation operations run through scripts.
- Keep chart values environment-aware and easy to override.
- Store only non-secret defaults in committed files.

## Reference Sources
- Apache Polaris docs: https://polaris.apache.org/
- Apache Polaris RustFS guide: https://polaris.apache.org/guides/rustfs/
- Apache Iceberg docs: https://iceberg.apache.org/docs/latest/
- Trino docs: https://trino.io/docs/current/
- Apache Superset docs: https://superset.apache.org/docs/intro
- Keycloak docs: https://www.keycloak.org/documentation
- Kubernetes docs: https://kubernetes.io/docs/home/
- Helm docs: https://helm.sh/docs/
- Jupyter docs: https://docs.jupyter.org/en/latest/
