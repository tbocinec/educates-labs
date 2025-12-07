package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * Humidity Sensor Data Producer
 * Simulates three humidity sensors sending readings to Kafka
 */
public class HumidityProducer {

    private static final Logger logger = LoggerFactory.getLogger(HumidityProducer.class);
    private static final String TOPIC_NAME = "humidity_readings";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final Random random = new Random();

    // Sensor configurations
    private static final SensorConfig[] SENSORS = {
        new SensorConfig(1, "kitchen", 60, 75),    // High humidity area
        new SensorConfig(2, "bedroom", 45, 60),    // Moderate humidity
        new SensorConfig(3, "outside", 25, 85)     // Variable outdoor humidity
    };

    public static void main(String[] args) {
        System.out.println("🌡️  Starting Humidity Sensor Data Producer...");
        logger.info("🌡️  Starting Humidity Sensor Data Producer...");

        var producer = createProducer();

        try (producer) {
            System.out.println("✅ Producer connected to Kafka at " + BOOTSTRAP_SERVERS);
            System.out.println("📊 Simulating 3 humidity sensors:");
            System.out.println("   📍 Sensor 1 - Kitchen (high moisture area)");
            System.out.println("   📍 Sensor 2 - Bedroom (climate controlled)");
            System.out.println("   📍 Sensor 3 - Outside (variable weather)");
            System.out.println("\n🔄 Sending continuous readings... (Press Ctrl+C to stop)\n");

            produceReadings(producer);

        } catch (Exception e) {
            System.err.println("💥 Producer failed: " + e.getMessage());
            logger.error("💥 Producer failed", e);
            System.exit(1);
        }
    }

    private static org.apache.kafka.clients.producer.KafkaProducer<String, String> createProducer() {
        var props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, 3);
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");

        return new org.apache.kafka.clients.producer.KafkaProducer<>(props);
    }

    private static void produceReadings(org.apache.kafka.clients.producer.KafkaProducer<String, String> producer)
            throws Exception {

        int messageCount = 0;

        while (true) {
            // Randomly select a sensor
            SensorConfig sensor = SENSORS[random.nextInt(SENSORS.length)];

            // Generate reading
            HumidityReading reading = new HumidityReading(
                sensor.sensorId(),
                sensor.location(),
                generateHumidity(sensor),
                System.currentTimeMillis() / 1000  // Unix timestamp
            );

            // Convert to JSON
            String json = objectMapper.writeValueAsString(reading);
            String key = "sensor-" + sensor.sensorId();

            // Send to Kafka
            var record = new ProducerRecord<>(TOPIC_NAME, key, json);
            var future = producer.send(record);

            messageCount++;
            final int msgNum = messageCount;

            future.get(5, TimeUnit.SECONDS);
            RecordMetadata metadata = future.get();

            System.out.printf("📨 [%d] Sensor %d (%s): %d%% humidity → partition %d, offset %d%n",
                msgNum, reading.sensor_id(), reading.location(), reading.humidity(),
                metadata.partition(), metadata.offset());

            logger.info("Sent reading from sensor {} to partition {} at offset {}",
                reading.sensor_id(), metadata.partition(), metadata.offset());

            // Wait between readings (2-5 seconds)
            Thread.sleep(2000 + random.nextInt(3000));
        }
    }

    private static int generateHumidity(SensorConfig sensor) {
        // Generate realistic humidity values within sensor's range
        return sensor.minHumidity() + random.nextInt(sensor.maxHumidity() - sensor.minHumidity() + 1);
    }

    // Sensor configuration record
    record SensorConfig(int sensorId, String location, int minHumidity, int maxHumidity) {}

    // Humidity reading record - matches the JSON structure
    record HumidityReading(int sensor_id, String location, int humidity, long read_at) {}
}

