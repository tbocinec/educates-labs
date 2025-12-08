package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * Synchronous Humidity Producer - Blocking Mode
 * Demonstrates blocking send() for guaranteed delivery confirmation
 * NOTE: Much slower than async - use only for demos/low-frequency
 */
public class HumidityProducerSync {

    private static final String TOPIC_NAME = "humidity_readings";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final Random random = new Random();

    // Sensor configurations
    private static final SensorConfig[] SENSORS = {
        new SensorConfig(1, "kitchen", 60, 75),
        new SensorConfig(2, "bedroom", 45, 60),
        new SensorConfig(3, "outside", 25, 85)
    };

    public static void main(String[] args) {
        System.out.println("🌡️  Starting Humidity Producer (SYNC MODE)...");
        System.out.println("📊 Mode: Synchronous (blocking)");
        System.out.println("🐌 Slow but guaranteed confirmation\n");

        var producer = createProducer();

        try (producer) {
            produceReadings(producer);
        } catch (Exception e) {
            System.err.println("💥 Producer failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static KafkaProducer<String, String> createProducer() {
        var props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");

        return new KafkaProducer<>(props);
    }

    private static void produceReadings(KafkaProducer<String, String> producer) throws Exception {
        int messageCount = 0;

        while (true) {
            // Randomly select a sensor
            SensorConfig sensor = SENSORS[random.nextInt(SENSORS.length)];

            // Generate reading
            HumidityReading reading = new HumidityReading(
                sensor.sensorId(),
                sensor.location(),
                generateHumidity(sensor),
                System.currentTimeMillis() / 1000
            );

            // Convert to JSON
            String json = objectMapper.writeValueAsString(reading);
            String key = "sensor-" + sensor.sensorId();

            // Create ProducerRecord
            var record = new ProducerRecord<>(TOPIC_NAME, key, json);

            messageCount++;

            try {
                // SYNCHRONOUS SEND: Block until confirmation
                long startTime = System.currentTimeMillis();
                RecordMetadata metadata = producer.send(record).get(5, TimeUnit.SECONDS);
                long latency = System.currentTimeMillis() - startTime;

                System.out.printf("⏳ SYNC: %s | %s | %d%%%n",
                    key, reading.location(), reading.humidity());
                System.out.printf("   → partition %d, offset %d (latency: %dms)%n%n",
                    metadata.partition(), metadata.offset(), latency);

            } catch (Exception e) {
                System.err.printf("❌ FAILED: %s | %s | %d%%%n",
                    key, reading.location(), reading.humidity());
                System.err.printf("   Error: %s%n%n", e.getMessage());
            }

            // Wait between readings
            Thread.sleep(1000 + random.nextInt(2000));
        }
    }

    private static int generateHumidity(SensorConfig sensor) {
        return sensor.minHumidity() + random.nextInt(sensor.maxHumidity() - sensor.minHumidity() + 1);
    }

    record SensorConfig(int sensorId, String location, int minHumidity, int maxHumidity) {}
    record HumidityReading(int sensor_id, String location, int humidity, long read_at) {}
}

