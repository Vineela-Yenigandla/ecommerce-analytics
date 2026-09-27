"""Daily orchestration: ingest raw files, then build and test dbt models."""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_ROOT = "/opt/airflow/ecommerce-analytics"
DBT_DIR = f"{PROJECT_ROOT}/dbt/ecommerce"

default_args = {
    "owner": "analytics_engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": True,
    "execution_timeout": timedelta(hours=1),
}

with DAG(
    dag_id="ecommerce_analytics",
    description="Ingest Olist source files and build the dbt star schema.",
    schedule="0 2 * * *",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    dagrun_timeout=timedelta(hours=3),
    default_args=default_args,
    tags=["dbt", "ecommerce", "analytics"],
) as dag:

    ingest = BashOperator(
        task_id="ingest_raw_files",
        bash_command=f"cd {PROJECT_ROOT} && python ingestion/load_raw.py",
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_DIR} && dbt deps",
    )

    source_freshness = BashOperator(
        task_id="dbt_source_freshness",
        bash_command=f"cd {DBT_DIR} && dbt source freshness || true",
    )

    snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"cd {DBT_DIR} && dbt snapshot --target prod",
    )

    build = BashOperator(
        task_id="dbt_build",
        bash_command=f"cd {DBT_DIR} && dbt build --target prod",
    )

    docs = BashOperator(
        task_id="dbt_docs_generate",
        bash_command=f"cd {DBT_DIR} && dbt docs generate --target prod",
    )

    ingest >> dbt_deps >> source_freshness >> snapshot >> build >> docs
