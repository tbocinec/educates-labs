FROM flink:1.18-java11

# Download Flink Kafka Connector for Flink 1.18
RUN wget -P /opt/flink/lib/ \
    https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.2-1.18/flink-sql-connector-kafka-3.0.2-1.18.jar

# Verify the connector was downloaded
RUN ls -lh /opt/flink/lib/flink-sql-connector-kafka-*.jar
