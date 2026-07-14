import os

import pendulum
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator

DEFAULT_ARGS = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 1,
}


with DAG(
    dag_id="iceberg_pipeline",
    description="Reference DAG that runs dbt parse and dbt run in Kubernetes pods.",
    default_args=DEFAULT_ARGS,
    start_date=pendulum.datetime(2024, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    tags=["iceberg", "dbt", "kubernetes"],
) as dag:
    kpo_namespace = os.getenv("AIRFLOW_KPO_NAMESPACE", "data-platform")
    dbt_image = os.getenv("DBT_IMAGE", "ghcr.io/dbt-labs/dbt-core:1.8.latest")

    dbt_parse = KubernetesPodOperator(
        task_id="dbt_parse",
        name="dbt-parse",
        namespace=kpo_namespace,
        image=dbt_image,
        cmds=["bash", "-lc"],
        arguments=[
            "dbt deps --project-dir /opt/dbt --profiles-dir /opt/dbt/profiles && "
            "dbt parse --project-dir /opt/dbt --profiles-dir /opt/dbt/profiles"
        ],
        get_logs=True,
        is_delete_operator_pod=True,
        in_cluster=True,
    )

    dbt_run = KubernetesPodOperator(
        task_id="dbt_run",
        name="dbt-run",
        namespace=kpo_namespace,
        image=dbt_image,
        cmds=["bash", "-lc"],
        arguments=[
            "dbt run --project-dir /opt/dbt --profiles-dir /opt/dbt/profiles && "
            "dbt test --project-dir /opt/dbt --profiles-dir /opt/dbt/profiles"
        ],
        get_logs=True,
        is_delete_operator_pod=True,
        in_cluster=True,
    )

    dbt_parse >> dbt_run
