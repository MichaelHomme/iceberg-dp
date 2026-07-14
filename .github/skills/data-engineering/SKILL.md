---
name: data-engineering
description: "Use when working on Airflow DAGs, KubernetesPodOperator tasks, dbt project assets, and data transformation orchestration that targets the AKS platform and Iceberg ecosystem."
---

# Data Engineering Skill

## Purpose
Develop reproducible Airflow and dbt workflows for data ingestion, orchestration, and transformation in this platform.

## Use This Skill For
- Airflow DAG definitions and scheduling.
- KubernetesPodOperator task design and runtime parameters.
- dbt project setup, model organization, testing, and execution scripts.
- Integration patterns between Airflow, Trino, Polaris, and Iceberg catalogs.

## Do Not Use This Skill For
- Terraform provisioning.
- Helm and base Kubernetes platform assembly.

## Required Approach
- Keep DAG deployment and validation script-driven.
- Keep dbt commands script-driven (deps, parse, run, test).
- Keep environment-specific configuration externalized from code.

## Reference Sources
- Apache Airflow docs: https://airflow.apache.org/docs/
- KubernetesPodOperator docs: https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/operators.html
- dbt docs: https://docs.getdbt.com/docs/introduction
- Apache Iceberg docs: https://iceberg.apache.org/docs/latest/
- Apache Polaris docs: https://polaris.apache.org/
- Apache Polaris RustFS guide: https://polaris.apache.org/guides/rustfs/
- Trino docs: https://trino.io/docs/current/
