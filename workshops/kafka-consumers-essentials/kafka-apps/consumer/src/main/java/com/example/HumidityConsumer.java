package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Essential Kafka Consumer - Demonstrates both auto-commit and manual commit
 * Switch modes by changing USE_MANUAL_COMMIT
 */
public class HumidityConsumer {

    private static final Logger logger = LoggerFactory.getLogger(HumidityConsumer.class);
    private static final String TOPIC_NAME = "humidity_readings";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final String GROUP_ID = "humidity-monitor";
    private static final Duration POLL_TIMEOUT = Duration.ofMillis(1000);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    // Switch between auto and manual commit modes
    private static final boolean USE_MANUAL_COMMIT = false; // Change to true for manual mode

    public static void main(String[] args) {
        System.out.println("📖 Starting Kafka Consumer...");
        System.out.println("📊 Consumer Group: " + GROUP_ID);
        System.out.println("🔄 Commit Mode: " + (USE_MANUAL_COMMIT ? "MANUAL" : "AUTO") + "\n");

        if (USE_MANUAL_COMMIT) {
            System.out.println("⚙️  Config: Manual commit enabled (at-least-once)\n");
        } else {
            System.out.println("⚙️  Config: Auto-commit every 5 seconds\n");
        }

        var consumer = createConsumer();

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\n🔄 Shutting down consumer gracefully...");
            consumer.close();
        }));

        try (consumer) {
            consumer.subscribe(List.of(TOPIC_NAME));
            System.out.println("✅ Subscribed to topic: " + TOPIC_NAME);
            System.out.println("🔄 Polling for messages... (Press Ctrl+C to stop)\n");
            System.out.println("=".repeat(80));

            consumeMessages(consumer);

        } catch (Exception e) {
            System.err.println("💥 Consumer failed: " + e.getMessage());
            logger.error("Consumer failed", e);
            System.exit(1);
        }
    }

    private static org.apache.kafka.clients.consumer.KafkaConsumer<String, String> createConsumer() {
        var props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        if (USE_MANUAL_COMMIT) {
            // MANUAL COMMIT configuration
            props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        } else {
            // AUTO COMMIT configuration
            props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
            props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, 5000);
        }

        // Performance settings
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 50);
        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
        props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 3000);
        props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 300000);

        return new org.apache.kafka.clients.consumer.KafkaConsumer<>(props);
    }

    private static void consumeMessages(org.apache.kafka.clients.consumer.KafkaConsumer<String, String> consumer) {
        int messageCount = 0;
        int batchCount = 0;

        try {
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(POLL_TIMEOUT);

                if (records.isEmpty()) {
                    Thread.sleep(1000);
                    continue;
                }

                batchCount++;
                System.out.printf("\n📦 Batch #%d - Processing %d messages...%n", batchCount, records.count());

                // Track offsets per partition
                Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();

                // Process all messages in batch
                for (ConsumerRecord<String, String> record : records) {
                    messageCount++;

                    try {
                        // Process the message
                        processReading(record, messageCount);

                        // Track offset for this partition
                        var partition = new TopicPartition(record.topic(), record.partition());
                        offsets.put(partition, new OffsetAndMetadata(record.offset() + 1));

                    } catch (Exception e) {
                        System.err.printf("❌ Failed to process message at partition %d offset %d: %s%n",
                            record.partition(), record.offset(), e.getMessage());
                        logger.error("Processing failed", e);
                        // In production: send to DLQ or retry topic
                    }
                }

                // Commit offsets based on mode
                if (USE_MANUAL_COMMIT) {
                    // Manual commit AFTER successful processing
                    try {
                        consumer.commitSync(offsets);
                        System.out.printf("✅ Committed offsets for %d partitions%n", offsets.size());
                        logger.info("Committed batch {} with {} messages", batchCount, records.count());

                    } catch (Exception e) {
                        System.err.println("❌ Failed to commit offsets: " + e.getMessage());
                        logger.error("Commit failed", e);
                        // Messages will be reprocessed on next poll
                    }
                } else {
                    // Auto-commit happens in background
                    System.out.printf("⏳ Auto-commit will save offsets in background%n");
                }

                System.out.println("─".repeat(80));
            }
        } catch (InterruptedException e) {
            logger.warn("Consumer interrupted");
            Thread.currentThread().interrupt();
        }
    }

    private static void processReading(ConsumerRecord<String, String> record, int count) throws Exception {
        // Parse JSON
        var reading = objectMapper.readValue(record.value(), HumidityReading.class);
        var timestamp = Instant.ofEpochSecond(reading.read_at());

        System.out.printf("🌡️  [%d] %s: %d%% (partition %d, offset %d)%n",
            count, reading.location(), reading.humidity(), record.partition(), record.offset());

        // Simulate processing (e.g., storing to database, triggering alerts)
        if (reading.humidity() > 80) {
            System.out.printf("   ⚠️  HIGH HUMIDITY ALERT in %s!%n", reading.location());
        } else if (reading.humidity() < 30) {
            System.out.printf("   ⚠️  LOW HUMIDITY ALERT in %s!%n", reading.location());
        }

        logger.info("Processed reading from {} at partition {} offset {}",
            reading.location(), record.partition(), record.offset());
    }

    record HumidityReading(int sensor_id, String location, int humidity, long read_at) {}
}

