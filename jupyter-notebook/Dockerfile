FROM jupyter/datascience-notebook:python-3.9.13

USER root
RUN apt-get update && apt-get -y install curl
# Spark dependencies
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)
ARG spark_version="3.4.1"
ARG hadoop_version="3"
ARG scala_version
ARG openjdk_version="17"

ENV APACHE_SPARK_VERSION="${spark_version}" \
    HADOOP_VERSION="${hadoop_version}"

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    "openjdk-${openjdk_version}-jre-headless" \
    ca-certificates-java && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Spark installation
WORKDIR /tmp

# You need to use https://archive.apache.org/dist/ website if you want to download old Spark versions
# But it seems to be slower, that's why we use recommended site for download
RUN if [ -z "${scala_version}" ]; then \
    curl --progress-bar --location --output "spark.tgz" \
        "https://dlcdn.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"; \
  else \
    curl --progress-bar --location --output "spark.tgz" \
        "https://dlcdn.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${scala_version}.tgz"; \
  fi && \
  tar xzf "spark.tgz" -C /usr/local --owner root --group root --no-same-owner && \
  rm "spark.tgz"

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH="${PATH}:${SPARK_HOME}/bin"

RUN if [ -z "${scala_version}" ]; then \
    ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" "${SPARK_HOME}"; \
  else \
    ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${scala_version}" "${SPARK_HOME}"; \
  fi && \
  # Add a link in the before_notebook hook in order to source automatically PYTHONPATH && \
  mkdir -p /usr/local/bin/before-notebook.d && \
  ln -s "${SPARK_HOME}/sbin/spark-config.sh" /usr/local/bin/before-notebook.d/spark-config.sh && \
  echo "export JAVA_HOME=/usr/lib/jvm/java-${openjdk_version}-openjdk-amd64/" >> "/usr/local/bin/before-notebook.d/spark-config.sh"

# Install Delta Lake
ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar $SPARK_HOME/jars

# Install S3 drivers
ADD --chmod=664 https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar $SPARK_HOME/jars

USER ${NB_UID}

# Install pyarrow
# NOTE: It's important to ensure compatibility between Pandas versions.
# The pandas version in this Dockerfile should match the version
# on which the Pandas API for Spark is built.
# To find the right version:
# 1. Check out the Spark branch you are on.
# 2. Find the pandas version in the file spark/dev/infra/Dockerfile.
# Install pyarrow
# Temporarily pin pandas to version 1.5.3, see: https://github.com/jupyter/docker-stacks/issues/1924
RUN mamba install --yes \
    'pandas>=1.5.3,<2.0.0' \
    'pyarrow' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


WORKDIR "${HOME}"

# Install PySpark and findspark
RUN pip install --user pyspark==3.4.1 \
    findspark
RUN pip install --user delta-spark==2.4.0

USER root
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG MINIO_PORT
ARG MINIO_HOSTNAME
RUN cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.pyspark.python	python" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.hadoop.fs.s3a.access.key	${AWS_ACCESS_KEY_ID}" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.hadoop.fs.s3a.secret.key	${AWS_SECRET_ACCESS_KEY}" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.hadoop.fs.s3a.endpoint	http://${MINIO_HOSTNAME}:${MINIO_PORT}" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.hadoop.fs.s3a.path.style.access	true" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.hadoop.fs.s3a.impl	org.apache.hadoop.fs.s3a.S3AFileSystem" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.databricks.delta.retentionDurationCheck.enabled	false" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.sql.extensions	io.delta.sql.DeltaSparkSessionExtension" >> $SPARK_HOME/conf/spark-defaults.conf
RUN echo "spark.sql.catalog.spark_catalog	org.apache.spark.sql.delta.catalog.DeltaCatalog" >> $SPARK_HOME/conf/spark-defaults.conf
