# Imagem Base
FROM python:3.5-slim
LABEL maintainer="Frederico"
LABEL about='projeto de controle do fluxo de dados via airflow'

# Argumentos de configuração do AirFlow
# outras variaveis de ambiente estão no .env
ARG AIRFLOW_VERSION=1.10.10
ARG AIRFLOW_HOME=/usr/local/airflow

# Export na variavel de ambiente AIRFLOW_HOME onde airflow será instalado
ENV AIRFLOW_HOME=${AIRFLOW_HOME}

# Instalar Dependencias e Ferramentas
RUN apt-get update -yqq && \
    apt-get upgrade -yqq && \
    apt-get install -yqq --no-install-recommends \ 
    wget \
    libczmq-dev \
    curl \
    libssl-dev \
    git \
    inetutils-telnet \
    bind9utils freetds-dev \
    libkrb5-dev \
    libsasl2-dev \
    libffi-dev libpq-dev \
    freetds-bin build-essential \
    default-libmysqlclient-dev \
    apt-utils \
    rsync \
    zip \
    unzip \
    gcc \
    vim \
    locales \
    && apt-get clean

COPY ./requirements-python3.5.txt /requirements-python3.5.txt

# Atualizar pip
# Criar usuario Aiflow
# Instalar apache airflow com subpackages
RUN pip install --upgrade pip && \
    useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow && \
    pip install apache-airflow[crypto,postgres,ssh,docker,slack]==${AIRFLOW_VERSION} --constraint /requirements-python3.5.txt

# Copiar o entrypoint.sh do para o container (no caminho AIRFLOW_HOME)
COPY ./entrypoint.sh ./entrypoint.sh

# Seta o arquivo entrypoint.sh como executavel
RUN chmod +x ./entrypoint.sh

# Seta o usuario airflow como dono dos arquivos
RUN chown -R airflow: ${AIRFLOW_HOME}

# Seleciona o usuario
USER airflow

# Seta o diretorio de trabalho (é como um cd dentro de um container)
WORKDIR ${AIRFLOW_HOME}

# Criar a pasta dags onde gravaremos as  DAGs (Directed Acyclic Graphs)
RUN mkdir dags

# Expõe a Porta (apenas indica onde o conteinar tem que mapear)
EXPOSE 8080

# Executar entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]