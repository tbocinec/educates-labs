package com.example;

import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

/**
 * Modern Kafka Producer using latest Java features and best practices.
 * Sends numbered messages with timestamps to a Kafka topic.
 */
public class KafkaProducer {
    
    private static final Logger logger = LoggerFactory.getLogger(KafkaProducer.class);
    private static final String TOPIC_NAME = "test-messages";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public static void main(String[] args) {
        System.out.println("🚀 Starting Modern Kafka Producer with Java 21...");
        logger.info("🚀 Starting Modern Kafka Producer with Java 21...");
        
        var producer = createProducer();
        
        try (producer) {
            System.out.println("✅ Producer connected to Kafka at " + BOOTSTRAP_SERVERS);
            logger.info("✅ Producer connected to Kafka at {}", BOOTSTRAP_SERVERS);
            System.out.println("📝 Sending messages to topic: " + TOPIC_NAME);
            logger.info("📝 Sending messages to topic: {}", TOPIC_NAME);
            
            sendMessages(producer);
            
        } catch (Exception e) {
            System.err.println("💥 Producer failed: " + e.getMessage());
            logger.error("💥 Producer failed: {}", e.getMessage(), e);
            System.exit(1);
        }
    }
    
    /**
     * Creates a Kafka producer with modern configuration and best practices
     */
    private static org.apache.kafka.clients.producer.KafkaProducer<String, String> createProducer() {
        var props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, 3);
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 5);
        props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        
        return new org.apache.kafka.clients.producer.KafkaProducer<>(props);
    }
    
    /**
     * Sends messages using modern async patterns with CompletableFuture
     */
    private static void sendMessages(org.apache.kafka.clients.producer.KafkaProducer<String, String> producer) 
            throws InterruptedException {
        
        System.out.println("\n📤 Starting to send 50 messages...");
        
        // Send 50 messages with modern async handling
        for (int i = 1; i <= 50; i++) {
            var timestamp = LocalDateTime.now().format(TIMESTAMP_FORMAT);
            var message = "Message #%d - Timestamp: %s".formatted(i, timestamp);
            var key = "msg-%d".formatted(i);
            
            var record = new ProducerRecord<>(TOPIC_NAME, key, message);
            
            // Modern async send with CompletableFuture-style handling
            final int messageNumber = i;
            var future = producer.send(record);
            
            // Handle result asynchronously
            CompletableFuture.supplyAsync(() -> {
                try {
                    RecordMetadata metadata = future.get(5, TimeUnit.SECONDS);
                    String successMsg = "✅ Sent message #%d to partition %d at offset %d"
                        .formatted(messageNumber, metadata.partition(), metadata.offset());
                    System.out.println(successMsg);
                    logger.info(successMsg);
                    return metadata;
                } catch (Exception e) {
                    String errorMsg = "❌ Failed to send message #%d: %s".formatted(messageNumber, e.getMessage());
                    System.err.println(errorMsg);
                    logger.error(errorMsg);
                    return null;
                }
            });
            
            // Wait between messages
            Thread.sleep(1000);
        }
        
        // Flush any remaining messages
        producer.flush();
        System.out.println("\n🎉 Finished sending all messages!");
        logger.info("🎉 Finished sending all messages!");
    }
}