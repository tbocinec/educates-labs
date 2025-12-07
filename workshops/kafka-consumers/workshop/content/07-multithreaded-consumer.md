# Multithreaded Consumer Pattern

Learn to scale consumer processing with worker threads while maintaining the single-consumer-per-thread safety rule.

---

## 🎯 What You'll Learn

- Why Kafka consumers are not thread-safe
- Single consumer + worker pool pattern
- Backpressure handling
- Offset commit coordination
- Performance trade-offs

---

## The Thread-Safety Problem

**Critical rule:** Kafka consumers are **NOT** thread-safe!

❌ **Wrong - Multiple threads using same consumer:**

```java
// DON'T DO THIS!
KafkaConsumer<K, V> consumer = new KafkaConsumer<>(props);

ExecutorService executor = Executors.newFixedThreadPool(10);
for (int i = 0; i < 10; i++) {
    executor.submit(() -> {
        consumer.poll(Duration.ofMillis(1000));  // UNSAFE!
    });
}
```

**Problem:** Race conditions, corrupted state, crashes!

---

## Correct Multithreading Patterns

### Pattern 1: One Consumer Per Thread

```java
// Multiple consumers, each in own thread
for (int i = 0; i < NUM_CONSUMERS; i++) {
    Thread thread = new Thread(() -> {
        KafkaConsumer<K, V> consumer = new KafkaConsumer<>(props);
        // Each thread has its own consumer
        while (true) {
            ConsumerRecords<K, V> records = consumer.poll(timeout);
            processRecords(records);
        }
        consumer.close();
    });
    thread.start();
}
```

**Pros:** Simple, each consumer independent  
**Cons:** Limited by partition count, more connections

### Pattern 2: Single Consumer + Worker Pool (Our Implementation)

```java
// One consumer thread, workers process messages
KafkaConsumer<K, V> consumer = new KafkaConsumer<>(props);
ExecutorService workers = Executors.newFixedThreadPool(NUM_WORKERS);

while (true) {
    ConsumerRecords<K, V> records = consumer.poll(timeout);
    
    List<Future<?>> futures = new ArrayList<>();
    for (ConsumerRecord<K, V> record : records) {
        futures.add(workers.submit(() -> process(record)));
    }
    
    // Wait for all workers
    for (Future<?> f : futures) {
        f.get();
    }
    
    consumer.commitSync();  // Commit after all processed
}
```

**Pros:** Better throughput, more workers than partitions  
**Cons:** More complex, requires coordination

---

## Examine Multithreaded Consumer

Look at our implementation:

```editor:open
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
line: 30
```

**Key components:**
- **ThreadPoolExecutor** - Fixed worker pool
- **ArrayBlockingQueue** - Bounded queue (backpressure)
- **CallerRunsPolicy** - Handles queue overflow
- **Future tracking** - Wait for completion before commit

---

## Worker Pool Configuration

```editor:select-matching-text
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
text: "WORKER_THREADS = 4"
```

Our consumer uses:
- **4 worker threads** - Parallel processing
- **100 queue capacity** - Bounded backpressure
- **CallerRunsPolicy** - Consumer thread processes if queue full

---

## Run the Multithreaded Consumer

Start the multithreaded consumer:

```terminal:execute
command: ./run-consumer-multithreaded.sh
background: false
```

**You should see:**
```
📖 Starting Multithreaded Humidity Consumer...
📊 Consumer Group: humidity-analytics-group
🔄 Pattern: Single consumer + Worker pool
⚙️  Worker threads: 4

📦 Batch #1 - Received 15 messages, submitting to worker pool...
⏳ Waiting for 15 tasks to complete...
   ✓ [1] bedroom: 56% ✅ NORMAL (worker: pool-2-thread-1)
   ✓ [2] kitchen: 72% ⬆️ HIGH (worker: pool-2-thread-2)
   ✓ [3] outside: 38% ✅ NORMAL (worker: pool-2-thread-3)
   ✓ [4] kitchen: 68% ✅ NORMAL (worker: pool-2-thread-4)
...
✅ Batch complete - Processed: 15, Failed: 0 (Total: 15/15)
```

**Notice:** Different worker threads processing messages in parallel!

**Let it run for 1 minute** to see multiple batches.

---

## Understanding the Worker Pattern

### Flow:

```
1. Consumer polls batch → [M1, M2, M3, M4, M5...]
2. Submit to workers  → [W1, W2, W3, W4] processing in parallel
3. Wait for completion → Future.get() on all tasks
4. Commit offsets     → Only after ALL successful
```

### Timing:

```
Sequential:  [M1 200ms][M2 200ms][M3 200ms][M4 200ms] = 800ms

Parallel:    [M1 200ms]
             [M2 200ms]  } = 200ms (4x faster!)
             [M3 200ms]
             [M4 200ms]
```

---

## Backpressure Handling

Our worker pool uses a **bounded queue**:

```java
new ArrayBlockingQueue<>(QUEUE_CAPACITY)  // 100 tasks max
```

**What happens when queue is full?**

With `CallerRunsPolicy`:
1. Queue full (100 tasks waiting)
2. Consumer thread tries to submit task #101
3. **Consumer thread processes it itself** (blocks polling)
4. Provides natural backpressure

**Alternative policies:**
- `AbortPolicy` - Throw exception (fail fast)
- `DiscardPolicy` - Silently drop (data loss!)
- `DiscardOldestPolicy` - Drop oldest task

---

## Commit Coordination

Critical: Only commit after **all** workers finish:

```editor:select-matching-text
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
text: "Wait for all tasks to complete"
```

**Why?**
```
❌ Bad:
Poll batch → Submit to workers → Commit → Continue
                                    ↑
                          Workers still processing!
                          Crash = message loss

✅ Good:
Poll batch → Submit to workers → Wait for all → Commit → Continue
                                        ↑
                              All processed successfully
```

---

## Simulated Heavy Processing

Our multithreaded consumer simulates heavier processing:

```editor:select-matching-text
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
text: "Thread.sleep(100"
```

Each message takes 100-300ms to process. Without multithreading:
- 10 messages × 200ms = 2 seconds

With 4 workers:
- 10 messages / 4 threads × 200ms = ~500ms

**4x throughput improvement!**

---

## Monitor Thread Activity

Check consumer group lag while multithreaded consumer runs:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-analytics-group
background: false
```

Notice:
- Single consumer instance (one consumer thread)
- Low lag despite slower processing (workers help!)

---

## Error Handling in Workers

What if a worker fails?

```editor:select-matching-text
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
text: "failedCount"
```

Our implementation:
1. **Catches exceptions** in worker
2. **Increments failedCount** (atomic counter)
3. **Continues with other messages**
4. **Still commits offsets** (may need DLQ in production)

**Production improvement:**
```java
} catch (Exception e) {
    logger.error("Processing failed", e);
    sendToDeadLetterQueue(record);  // Don't lose failed messages
    failedCount.incrementAndGet();
}
```

---

## Performance Comparison

Stop the multithreaded consumer and compare with basic consumer:

```terminal:interrupt
session: 1
```

Let's compare processing rates. Start basic consumer:

```terminal:execute
command: timeout 30 ./run-consumer-basic.sh | grep "Reading #" | wc -l
background: false
```

Now multithreaded:

```terminal:execute
command: timeout 30 ./run-consumer-multithreaded.sh | grep "✓" | wc -l
background: false
```

**Multithreaded should process more messages** in same time!

---

## Worker Pool Sizing

How many workers?

### CPU-Bound Tasks
```
Workers = Number of CPU cores
```

### I/O-Bound Tasks (Database, API calls)
```
Workers = Number of cores × (1 + wait_time/compute_time)
```

**Example:** 
- 4 cores
- 90% I/O wait (wait_time/compute_time = 9)

```
Workers = 4 × (1 + 9) = 40 workers
```

**Our scenario:** 
Humidity analysis is I/O-bound (database writes, API calls), so 4+ workers makes sense.

---

## Max Poll Interval Consideration

With workers, ensure processing completes within `max.poll.interval.ms`:

```
max.poll.interval.ms > (max.poll.records / workers) × avg_processing_time
```

**Example:**
- max.poll.records = 100
- workers = 4
- avg_processing_time = 200ms

```
max.poll.interval.ms > (100 / 4) × 200ms = 5000ms

Safe value: 60000ms (1 minute)
```

Our configuration:

```editor:select-matching-text
file: ~/kafka-apps/consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java
text: "MAX_POLL_INTERVAL_MS_CONFIG, 600000"
```

600 seconds = 10 minutes (very safe!)

---

## Alternative: CompletableFuture Pattern

Modern Java approach using CompletableFuture:

```java
List<CompletableFuture<Void>> futures = new ArrayList<>();

for (ConsumerRecord<K, V> record : records) {
    CompletableFuture<Void> future = CompletableFuture
        .supplyAsync(() -> processRecord(record), executorService)
        .exceptionally(ex -> {
            logger.error("Processing failed", ex);
            return null;
        });
    futures.add(future);
}

// Wait for all
CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
consumer.commitSync();
```

**Benefits:**
- Modern async API
- Better composition
- Exception handling

---

## Trade-offs Summary

### Single-threaded Consumer
**Pros:**
- ✅ Simple, no coordination needed
- ✅ Easy to reason about
- ✅ No thread safety concerns

**Cons:**
- ❌ Limited throughput
- ❌ Slow processing blocks consumer

### Multithreaded Consumer
**Pros:**
- ✅ Higher throughput
- ✅ Better resource utilization
- ✅ Can have more workers than partitions

**Cons:**
- ❌ More complex
- ❌ Requires careful coordination
- ❌ Harder to debug

---

## Key Takeaways

✅ **Kafka consumers are NOT thread-safe**  
✅ **Single consumer + worker pool** is common pattern  
✅ **Bounded queue** provides backpressure  
✅ **Wait for workers** before committing  
✅ **Size worker pool** based on workload type  
✅ **max.poll.interval.ms** must account for parallelism  

---

## Next Steps

You've mastered multithreaded consumption! Next, we'll explore comprehensive **error handling and retry strategies**.

