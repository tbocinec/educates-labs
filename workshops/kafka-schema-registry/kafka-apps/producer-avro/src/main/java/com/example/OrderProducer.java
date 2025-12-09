package com.example;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;
import java.util.Random;
import java.util.UUID;

/**
 * Order Producer using Avro with Schema Registry
 * Demonstrates schema-based message production with automatic schema registration
 */
public class OrderProducer {

    private static final String TOPIC_NAME = "orders";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final String SCHEMA_REGISTRY_URL = "http://localhost:8081";
    private static final Random random = new Random();

    // Sample data for realistic orders
    private static final String[] CUSTOMERS = {"CUST-001", "CUST-002", "CUST-003", "CUST-004", "CUST-005"};
    private static final String[] PRODUCTS = {
        "LAPTOP-PRO", "WIRELESS-MOUSE", "USB-KEYBOARD",
        "MONITOR-27", "HEADPHONES-BT", "WEBCAM-HD"
    };
    private static final double[] PRICES = {1299.99, 29.99, 49.99, 399.99, 89.99, 59.99};

    public static void main(String[] args) {
        System.out.println("🛒 Starting Order Producer with Avro Schema Registry");
        System.out.println("📊 Topic: " + TOPIC_NAME);
        System.out.println("🔗 Schema Registry: " + SCHEMA_REGISTRY_URL);
        System.out.println();

        var producer = createProducer();

        try (producer) {
            produceOrders(producer);
        } catch (Exception e) {
            System.err.println("💥 Producer failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static KafkaProducer<String, OrderCreated> createProducer() {
        var props = new Properties();

        // Kafka settings
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class.getName());

        // Schema Registry settings
        props.put("schema.registry.url", SCHEMA_REGISTRY_URL);

        // Producer optimizations
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");

        return new KafkaProducer<>(props);
    }

    private static void produceOrders(KafkaProducer<String, OrderCreated> producer) throws Exception {
        int orderCount = 0;

        while (true) {
            // Generate random order
            String orderId = "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            String customerId = CUSTOMERS[random.nextInt(CUSTOMERS.length)];
            int productIdx = random.nextInt(PRODUCTS.length);
            String productId = PRODUCTS[productIdx];
            int quantity = 1 + random.nextInt(5);
            double totalPrice = PRICES[productIdx] * quantity;
            long createdAt = System.currentTimeMillis() / 1000;

            // Create Avro record (generated from schema)
            OrderCreated order = OrderCreated.newBuilder()
                .setOrderId(orderId)
                .setCustomerId(customerId)
                .setProductId(productId)
                .setQuantity(quantity)
                .setTotalPrice(totalPrice)
                .setCreatedAt(createdAt)
                .build();

            // Use order ID as key for partitioning
            String key = orderId;
            var record = new ProducerRecord<>(TOPIC_NAME, key, order);

            // Send with callback
            producer.send(record, (metadata, exception) -> {
                if (exception != null) {
                    System.err.println("❌ Failed to send order: " + key);
                    exception.printStackTrace();
                } else {
                    System.out.printf("✅ Order sent: %s | Customer: %s | Product: %s | Qty: %d | $%.2f%n",
                        key, order.getCustomerId(), order.getProductId(),
                        order.getQuantity(), order.getTotalPrice());
                    System.out.printf("   📍 Partition: %d | Offset: %d%n",
                        metadata.partition(), metadata.offset());
                }
            });

            orderCount++;

            // Flush every 5 messages to see results
            if (orderCount % 5 == 0) {
                producer.flush();
                System.out.println();
            }

            // Wait between orders
            Thread.sleep(2000 + random.nextInt(3000));
        }
    }
}

