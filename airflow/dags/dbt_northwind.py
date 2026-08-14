"""Orquestra o projeto dbt do Northwind.

O dbt roda num venv isolado (/opt/dbt_venv), montado no container pelo Dockerfile,
para nao conflitar com as dependencias do proprio Airflow.
"""

from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.operators.bash import BashOperator

DBT_BIN = "/opt/dbt_venv/bin/dbt"
DBT_PROJECT_DIR = "/opt/airflow/northwind_dbt"

default_args = {
    "owner": "vitor",
    "retries": 1,
    "retry_delay": pendulum.duration(minutes=2),
}

with DAG(
    dag_id="dbt_northwind",
    description="Roda deps, run e test do projeto dbt northwind_dbt",
    default_args=default_args,
    start_date=pendulum.datetime(2026, 8, 1, tz="America/Sao_Paulo"),
    schedule="0 6 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["dbt", "northwind", "elt"],
) as dag:

    def dbt_task(task_id: str, command: str) -> BashOperator:
        return BashOperator(
            task_id=task_id,
            cwd=DBT_PROJECT_DIR,
            bash_command=f"{DBT_BIN} {command} --target dev",
        )

    dbt_debug = dbt_task("dbt_debug", "debug")
    dbt_deps = dbt_task("dbt_deps", "deps")
    dbt_run = dbt_task("dbt_run", "run")
    dbt_test = dbt_task("dbt_test", "test")

    dbt_debug >> dbt_deps >> dbt_run >> dbt_test
