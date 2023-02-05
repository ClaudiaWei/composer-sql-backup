import re
from airflow import DAG
from airflow import configuration as conf
from airflow.utils.dates import days_ago
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import (
    KubernetesPodOperator
)
from datetime import timedelta

SQL_ALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')

result = re.search(r'postgresql\+psycopg2:\/\/(?P<username>.*):(?P<password>.*)@(?P<host>.*):(?P<port>.*)\/(?P<database>.*)', SQL_ALCHEMY_DATABASE_URI)
host = 'airflow-sqlproxy-service.default.svc.cluster.local'
username = result.group('username')
password = result.group('password')
database = result.group('database')
port = result.group('port')

with DAG(
    dag_id="composer-sql-backup",
    start_date=days_ago(1),
    schedule_interval='0 17 * * *',
    catchup=False,
    tags=["backup"]
) as dag:
    ios_model = KubernetesPodOperator(
      task_id='backup',
      name='backup',
      namespace='default',
      image='claudia84012345/sql_backup_to_gcs:0.0.4',
      startup_timeout_seconds=300,
      resources={'limit_memory': "1Gi", 'limit_cpu': "500m"},
      node_selector={"iam.gke.io/gke-metadata-server-enabled": "true"},
      annotations={"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"},
      service_account_name="airflow-sql-backup",
      arguments=['-h', host, '-u', username, '-w', password, '-d', database, '-p', port],
      execution_timeout=timedelta(minutes=5)
    )