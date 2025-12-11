package com.workshop;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

/**
 * Flink Job: Mold Alert System
 *
 * Monitors humidity sensor data and alerts when mold risk is detected (humidity > 70%).
 *
 * Input Topic: raw_sensors
 * Output Topic: critical_sensors
 *
 * Filter Logic: Keep only readings where humidity > 70
 * Transform: Add "status": "CRITICAL_MOLD_RISK" to alerts
 */
public class MoldAlertJob {

    private static final String KAFKA_BOOTSTRAP_SERVERS = "kafka:29092";
    private static final String INPUT_TOPIC = "raw_sensors";
    private static final String OUTPUT_TOPIC = "critical_sensors";
    private static final String CONSUMER_GROUP = "mold-alert-group";
    private static final int HUMIDITY_THRESHOLD = 70;

    public static void main(String[] args) throws Exception {

        System.out.println("🚨 Starting Mold Alert Job...");
        System.out.println("📥 Input: " + INPUT_TOPIC);
        System.out.println("📤 Output: " + OUTPUT_TOPIC);
        System.out.println("⚠️  Alert Threshold: Humidity > " + HUMIDITY_THRESHOLD + "%\n");

        // 1. Set up the execution environment
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1); // Single parallelism for workshop simplicity

        // 2. Define the Kafka Source (Read from 'raw_sensors')
        KafkaSource<String> source = KafkaSource.<String>builder()
            .setBootstrapServers(KAFKA_BOOTSTRAP_SERVERS)
            .setTopics(INPUT_TOPIC)
            .setGroupId(CONSUMER_GROUP)
            .setStartingOffsets(OffsetsInitializer.earliest())
            .setValueOnlyDeserializer(new SimpleStringSchema())
            .build();

        DataStream<String> sensorStream = env.fromSource(
            source,
            WatermarkStrategy.noWatermarks(),
            "Humidity Sensor Source"
        );

        // 3. Transformation: Filter for Humidity > 70 and tag as critical
        ObjectMapper mapper = new ObjectMapper();

        DataStream<String> criticalStream = sensorStream
            .filter(jsonString -> {
                try {
                    JsonNode node = mapper.readTree(jsonString);

                    // Check if 'humidity' field exists
                    if (!node.has("humidity")) {
                        return false;
                    }

                    int humidity = node.get("humidity").asInt();

                    // THE CORE LOGIC: Filter for mold risk
                    boolean isCritical = humidity > HUMIDITY_THRESHOLD;

                    if (isCritical) {
                        String sensorId = node.has("sensor_id") ?
                            node.get("sensor_id").asText() : "unknown";
                        String location = node.has("location") ?
                            node.get("location").asText() : "unknown";
                        System.out.printf("🚨 ALERT: Sensor %s (%s) - %d%% humidity detected!%n",
                            sensorId, location, humidity);
                    }

                    return isCritical;

                } catch (Exception e) {
                    System.err.println("❌ Failed to parse JSON: " + e.getMessage());
                    return false; // Drop malformed data
                }
            })
            .map(jsonString -> {
                try {
                    // Add alert status to the message
                    ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
                    node.put("status", "CRITICAL_MOLD_RISK");
                    node.put("alert_time", System.currentTimeMillis());
                    return mapper.writeValueAsString(node);
                } catch (Exception e) {
                    return jsonString; // Return original if transformation fails
                }
            })
            .name("Mold Alert Filter & Transform");

        // 4. Sink: Write to 'critical_sensors' topic
        KafkaSink<String> sink = KafkaSink.<String>builder()
            .setBootstrapServers(KAFKA_BOOTSTRAP_SERVERS)
            .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                .setTopic(OUTPUT_TOPIC)
                .setValueSerializationSchema(new SimpleStringSchema())
                .build()
            )
            .build();

        criticalStream.sinkTo(sink).name("Critical Sensors Sink");

        // 5. Execute the job
        env.execute("Humidity Mold Alert Job");
    }
}

