package com.example;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

/**
 * Order Consumer using Avro with Schema Registry
 * Demonstrates schema-based message consumption with automatic schema resolution
 */
public class OrderConsumer {

    private static final String TOPIC_NAME = "orders";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final String SCHEMA_REGISTRY_URL = "http://localhost:8081";
    private static final String GROUP_ID = "order-processor-group";

    public static void main(String[] args) {
        System.out.println("🛒 Starting Order Consumer with Avro Schema Registry");
        System.out.println("📊 Topic: " + TOPIC_NAME);
        System.out.println("👥 Group: " + GROUP_ID);
        System.out.println("🔗 Schema Registry: " + SCHEMA_REGISTRY_URL);
        System.out.println();

        var consumer = createConsumer();

        try (consumer) {
            consumer.subscribe(Collections.singletonList(TOPIC_NAME));
            System.out.println("✅ Subscribed to topic: " + TOPIC_NAME);
            System.out.println("⏳ Waiting for messages...\n");

            consumeOrders(consumer);
        } catch (Exception e) {
            System.err.println("💥 Consumer failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static KafkaConsumer<String, OrderCreated> createConsumer() {
        var props = new Properties();

        // Kafka settings
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, KafkaAvroDeserializer.class.getName());

        // Schema Registry settings
        props.put("schema.registry.url", SCHEMA_REGISTRY_URL);

        // Use specific Avro record type (not GenericRecord)
        props.put(KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, true);

        // Consumer behavior
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
        props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, 5000);

        return new KafkaConsumer<>(props);
    }

    private static void consumeOrders(KafkaConsumer<String, OrderCreated> consumer) {
        int messageCount = 0;
        double totalRevenue = 0.0;

        while (true) {
            ConsumerRecords<String, OrderCreated> records = consumer.poll(Duration.ofMillis(1000));

            for (ConsumerRecord<String, OrderCreated> record : records) {
                OrderCreated order = record.value();
                messageCount++;
                totalRevenue += order.getTotalPrice();

                System.out.println("═══════════════════════════════════════════════");
                System.out.printf("📦 Order Received #%d%n", messageCount);
                System.out.println("───────────────────────────────────────────────");
                System.out.printf("   Order ID:    %s%n", order.getOrderId());
                System.out.printf("   Customer:    %s%n", order.getCustomerId());
                System.out.printf("   Product:     %s%n", order.getProductId());
                System.out.printf("   Quantity:    %d%n", order.getQuantity());
                System.out.printf("   Total Price: $%.2f%n", order.getTotalPrice());
                System.out.printf("   Created At:  %d (epoch)%n", order.getCreatedAt());
                System.out.println("───────────────────────────────────────────────");
                System.out.printf("   Partition:   %d | Offset: %d%n",
                    record.partition(), record.offset());
                System.out.println("═══════════════════════════════════════════════");
                System.out.printf("💰 Total Revenue: $%.2f | Messages: %d%n%n",
                    totalRevenue, messageCount);
            }

            if (records.isEmpty()) {
                // Show periodic status
                if (messageCount > 0) {
                    System.out.printf("⏳ Waiting for more messages... (Processed: %d)%n", messageCount);
                }
            }
        }
    }
}

