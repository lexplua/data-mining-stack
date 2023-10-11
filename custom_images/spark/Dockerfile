FROM bitnami/spark:3.4.1

# Install Delta Lake

ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar $SPARK_HOME/jars

USER 1001


