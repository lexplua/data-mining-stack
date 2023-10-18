FROM bitnami/spark:3.4.1

# Install Delta Lake

ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar $SPARK_HOME/jars

# Add files for Kafka + Spark structured streaming support
ADD --chmod=664 https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.4.1/spark-sql-kafka-0-10_2.12-3.4.1.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-10-assembly_2.12/3.4.1/spark-streaming-kafka-0-10-assembly_2.12-3.4.1.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.4.1/kafka-clients-3.4.1.jar $SPARK_HOME/jars
ADD --chmod=664 https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.12.0/commons-pool2-2.12.0.jar  $SPARK_HOME/jars


USER 1001


