FROM apache/airflow:2.9.3-python3.11

# O dbt vive num venv isolado para nao disputar pinos de dependencia
# (protobuf, jinja2, click, pydantic) com o Airflow.
USER root
# git: exigido pelo "dbt debug" e por packages instalados via repositorio
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/dbt_venv && chown airflow:root /opt/dbt_venv

USER airflow
COPY requirements.txt /tmp/requirements.txt
RUN python -m venv /opt/dbt_venv \
    && /opt/dbt_venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/dbt_venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
    && /opt/dbt_venv/bin/dbt --version
