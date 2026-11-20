import pendulum

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator


with DAG(
    dag_id="energia_viva",
    description="Pipeline ETL de EnergiaViva S.A.",
    schedule="0 2 * * *",
    start_date=pendulum.datetime(2026, 11, 19, tz="America/Argentina/Buenos_Aires"),
    catchup=False,
    tags=["big-data", "etl"],
) as dag:
    ejecutar_pipeline = BashOperator(
        task_id="ejecutar_pipeline",
        bash_command="""
            cd "/mnt/c/Users/IPF-2026/Desktop/tps-big-data/tp-final-big-data--EnergiaViva-SA"
            /home/ipf-2026-ivan/airflow-venv/bin/python pipeline.py
        """,
    )
