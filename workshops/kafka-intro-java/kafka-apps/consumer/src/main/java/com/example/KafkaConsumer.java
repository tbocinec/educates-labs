package com.example;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.List;
import java.util.Properties;

/**
 * Modern Kafka Consumer using latest Java features and best practices.
 * Reads messages from a Kafka topic and displays them on console.
 */
public class KafkaConsumer {
    
    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumer.class);
    private static final String TOPIC_NAME = "test-messages";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final String GROUP_ID = "test-consumer-group";
    private static final Duration POLL_TIMEOUT = Duration.ofMillis(1000);
    
    public static void main(String[] args) {
        System.out.println("📖 Starting Modern Kafka Consumer with Java 21...");
        logger.info("📖 Starting Modern Kafka Consumer with Java 21...");
        
        var consumer = createConsumer();
        
        // Setup graceful shutdown
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\n🔄 Shutting down consumer gracefully...");
            logger.info("🔄 Shutting down consumer gracefully...");
            consumer.close();
        }));
        
        try (consumer) {
            System.out.println("✅ Consumer connected to Kafka at " + BOOTSTRAP_SERVERS);
            logger.info("✅ Consumer connected to Kafka at {}", BOOTSTRAP_SERVERS);
            System.out.println("📖 Subscribing to topic: " + TOPIC_NAME + " with group: " + GROUP_ID);
            logger.info("📖 Subscribing to topic: {} with group: {}", TOPIC_NAME, GROUP_ID);
            
            // Subscribe to topic
            consumer.subscribe(List.of(TOPIC_NAME));
            
            System.out.println("🔄 Starting to consume messages... (Press Ctrl+C to stop)");
            logger.info("🔄 Starting to consume messages... (Press Ctrl+C to stop)");
            System.out.println("\n" + "=".repeat(80));
            System.out.println("📋 RECEIVED MESSAGES:");
            System.out.println("=".repeat(80));
            
            consumeMessages(consumer);
            
        } catch (Exception e) {
            System.err.println("💥 Consumer failed: " + e.getMessage());
            logger.error("💥 Consumer failed: {}", e.getMessage(), e);
            System.exit(1);
        }
        
        System.out.println("🏁 Consumer stopped gracefully");
        logger.info("🏁 Consumer stopped gracefully");
    }
    
    /**
     * Creates a Kafka consumer with modern configuration and best practices
     */
    private static org.apache.kafka.clients.consumer.KafkaConsumer<String, String> createConsumer() {
        var props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
        props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, 1000);
        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 100);
        props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 1024);
        props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, 500);
        
        return new org.apache.kafka.clients.consumer.KafkaConsumer<>(props);
    }
    
    /**
     * Continuously polls and processes messages using modern patterns
     */
    private static void consumeMessages(org.apache.kafka.clients.consumer.KafkaConsumer<String, String> consumer) {
        int messageCount = 0;
        
        try {
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(POLL_TIMEOUT);
                
                if (records.isEmpty()) {
                    // Add breathing room if no messages
                    Thread.sleep(2000);
                    continue;
                }
                
                // Process messages using modern forEach
                for (var record : records) {
                    messageCount++;
                    displayMessage(record, messageCount);
                    
                    logger.info("Processed message #{} from partition {} at offset {}", 
                              messageCount, record.partition(), record.offset());
                }
            }
        } catch (InterruptedException e) {
            logger.warn("Consumer interrupted");
            Thread.currentThread().interrupt();
        } catch (Exception e) {
            logger.error("❌ Error while consuming messages: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Displays message information in a formatted way
     */
    private static void displayMessage(ConsumerRecord<String, String> record, int messageCount) {
        System.out.printf("📨 Message #%d:%n", messageCount);
        System.out.printf("   🔑 Key: %s%n", record.key());
        System.out.printf("   💬 Value: %s%n", record.value());
        System.out.printf("   📍 Partition: %d, Offset: %d%n", record.partition(), record.offset());
        System.out.printf("   ⏰ Timestamp: %s%n", new java.util.Date(record.timestamp()));
        System.out.println("   " + "-".repeat(50));
        
        // Add milestone logging for every 10th message
        if (messageCount % 10 == 0) {
            logger.info("🎯 Milestone: Processed {} messages", messageCount);
        }
    }
}