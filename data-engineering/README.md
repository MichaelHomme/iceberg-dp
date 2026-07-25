# Data Engineering

Script-driven Airflow and dbt assets for orchestration and transformation workloads on the AKS-based platform.

## Layout
- `airflow/dags/`: Airflow DAG definitions.
- `dbt/`: dbt project, models, and profile template.
- `scripts/deploy_dags.sh`: packages DAGs into a ConfigMap and applies it to Kubernetes.
- `scripts/validate_data_engineering.sh`: validates DAG syntax, dbt parse, and DAG ConfigMap generation.
- `scripts/run_dbt.sh`: wrapper for dbt deps/parse/run/test.

## Quick Start
```bash
cp data-engineering/.env.data-engineering.example data-engineering/.env.data-engineering
bash data-engineering/scripts/validate_data_engineering.sh
bash data-engineering/scripts/deploy_dags.sh
bash data-engineering/scripts/run_dbt.sh all
```

## Notes
- Keep runtime-specific values in `data-engineering/.env.data-engineering`.
- Keep secrets out of source control; pass credentials using env vars or secret stores.
- `scripts/run_dbt.sh` expects dbt Core CLI, not dbt Cloud CLI.
- Set `AIRFLOW_KPO_NAMESPACE` to the workload identity namespace used by infrastructure (`frigg-pot-platform` by default).
- Set `AIRFLOW_KPO_SERVICE_ACCOUNT_NAME` to a service account annotated for Azure workload identity (`airflow-sa` by default).
