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
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Multithreaded Consumer with Worker Pool
 * Demonstrates single consumer thread with worker pool for processing
 */
public class HumidityConsumerMultithreaded {

    private static final Logger logger = LoggerFactory.getLogger(HumidityConsumerMultithreaded.class);
    private static final String TOPIC_NAME = "humidity_readings";
    private static final String BOOTSTRAP_SERVERS = "localhost:9092";
    private static final String GROUP_ID = "humidity-analytics-group";
    private static final Duration POLL_TIMEOUT = Duration.ofMillis(1000);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    // Worker pool configuration
    private static final int WORKER_THREADS = 4;
    private static final int QUEUE_CAPACITY = 100;

    private static final AtomicInteger processedCount = new AtomicInteger(0);
    private static final AtomicInteger failedCount = new AtomicInteger(0);

    public static void main(String[] args) {
        System.out.println("📖 Starting Multithreaded Humidity Consumer...");
        System.out.println("📊 Consumer Group: " + GROUP_ID);
        System.out.println("🔄 Pattern: Single consumer + Worker pool");
        System.out.println("⚙️  Worker threads: " + WORKER_THREADS);
        System.out.println("📦 Queue capacity: " + QUEUE_CAPACITY + "\n");

        // Create worker pool
        ExecutorService workerPool = new ThreadPoolExecutor(
            WORKER_THREADS,
            WORKER_THREADS,
            0L, TimeUnit.MILLISECONDS,
            new ArrayBlockingQueue<>(QUEUE_CAPACITY),
            new ThreadPoolExecutor.CallerRunsPolicy() // Backpressure handling
        );

        var consumer = createConsumer();

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\n🔄 Shutting down...");
            consumer.close();
            workerPool.shutdown();
            try {
                if (!workerPool.awaitTermination(10, TimeUnit.SECONDS)) {
                    workerPool.shutdownNow();
                }
            } catch (InterruptedException e) {
                workerPool.shutdownNow();
            }
            System.out.printf("📊 Final stats - Processed: %d, Failed: %d%n",
                processedCount.get(), failedCount.get());
        }));

        try (consumer) {
            consumer.subscribe(List.of(TOPIC_NAME));
            System.out.println("✅ Subscribed to topic: " + TOPIC_NAME);
            System.out.println("🔄 Polling for messages... (Press Ctrl+C to stop)\n");
            System.out.println("=".repeat(80));

            consumeMessages(consumer, workerPool);

        } catch (Exception e) {
            System.err.println("💥 Consumer failed: " + e.getMessage());
            logger.error("Consumer failed", e);
            System.exit(1);
        } finally {
            workerPool.shutdown();
        }
    }

    private static org.apache.kafka.clients.consumer.KafkaConsumer<String, String> createConsumer() {
        var props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);

        // Larger poll interval for multithreaded processing
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 100);
        props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 600000); // 10 minutes
        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
        props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 3000);

        return new org.apache.kafka.clients.consumer.KafkaConsumer<>(props);
    }

    private static void consumeMessages(
            org.apache.kafka.clients.consumer.KafkaConsumer<String, String> consumer,
            ExecutorService workerPool) {

        int batchCount = 0;

        try {
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(POLL_TIMEOUT);

                if (records.isEmpty()) {
                    Thread.sleep(1000);
                    continue;
                }

                batchCount++;
                System.out.printf("\n📦 Batch #%d - Received %d messages, submitting to worker pool...%n",
                    batchCount, records.count());

                // Submit all records to worker pool
                Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();
                List<Future<?>> futures = new ArrayList<>();

                for (ConsumerRecord<String, String> record : records) {
                    // Submit to worker pool
                    Future<?> future = workerPool.submit(() -> processRecord(record));
                    futures.add(future);

                    // Track offset
                    var partition = new TopicPartition(record.topic(), record.partition());
                    offsets.put(partition, new OffsetAndMetadata(record.offset() + 1));
                }

                // Wait for all tasks to complete
                System.out.printf("⏳ Waiting for %d tasks to complete...%n", futures.size());
                for (Future<?> future : futures) {
                    try {
                        future.get(30, TimeUnit.SECONDS);
                    } catch (Exception e) {
                        logger.error("Worker task failed", e);
                        failedCount.incrementAndGet();
                    }
                }

                // Commit offsets after all processing is done
                try {
                    consumer.commitSync(offsets);
                    System.out.printf("✅ Batch complete - Processed: %d, Failed: %d (Total: %d/%d)%n",
                        processedCount.get(), failedCount.get(),
                        processedCount.get(), processedCount.get() + failedCount.get());

                } catch (Exception e) {
                    System.err.println("❌ Failed to commit offsets: " + e.getMessage());
                    logger.error("Commit failed", e);
                }

                System.out.println("─".repeat(80));
            }
        } catch (InterruptedException e) {
            logger.warn("Consumer interrupted");
            Thread.currentThread().interrupt();
        }
    }

    private static void processRecord(ConsumerRecord<String, String> record) {
        try {
            var reading = objectMapper.readValue(record.value(), HumidityReading.class);

            // Simulate heavier processing (analytics, database writes, etc.)
            Thread.sleep(100 + new Random().nextInt(200));

            // Analyze humidity trends
            String status = analyzeHumidity(reading);

            int count = processedCount.incrementAndGet();
            System.out.printf("   ✓ [%d] %s: %d%% %s (worker: %s)%n",
                count, reading.location(), reading.humidity(), status,
                Thread.currentThread().getName());

            logger.info("Processed reading from {} in thread {}",
                reading.location(), Thread.currentThread().getName());

        } catch (Exception e) {
            System.err.printf("   ✗ Failed to process record: %s%n", e.getMessage());
            logger.error("Processing failed", e);
            failedCount.incrementAndGet();
        }
    }

    private static String analyzeHumidity(HumidityReading reading) {
        if (reading.humidity() > 80) {
            return "⚠️ VERY HIGH";
        } else if (reading.humidity() > 70) {
            return "⬆️ HIGH";
        } else if (reading.humidity() < 30) {
            return "⬇️ LOW";
        } else if (reading.humidity() < 40) {
            return "📉 SLIGHTLY LOW";
        } else {
            return "✅ NORMAL";
        }
    }

    record HumidityReading(int sensor_id, String location, int humidity, long read_at) {}
}

