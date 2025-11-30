# Bonus: Kcat - Modern Kafka CLI Tool

Discover kcat (formerly kafkacat) - a powerful, modern alternative to traditional Kafka CLI tools with enhanced usability! 🎁

---

## Learning Objectives

In this bonus level you'll explore:
- ✅ **Kcat installation** - Modern Kafka CLI tool
- ✅ **Enhanced features** - Superior to traditional CLI tools
- ✅ **JSON processing** - Built-in JSON formatting and parsing
- ✅ **Advanced debugging** - Better error messages and diagnostics
- ✅ **Performance advantages** - Faster and more efficient
- ✅ **Modern workflows** - Integration with modern toolchains

---

## 1. Installing Kcat

Install kcat in our container environment:

```terminal:execute
command: docker exec kafka apt-get update && apt-get install -y kafkacat
background: false
```

**Verify installation:**

```terminal:execute
command: docker exec kafka kcat -V
background: false
```

**📝 About kcat:**
- Originally called "kafkacat" (now renamed to "kcat")
- Written in C (faster than Java-based tools)
- Designed for modern workflows and automation
- Better JSON handling and debugging features

---

## 2. Basic Kcat Operations

**List topics (equivalent to kafka-topics --list):**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -L
background: false
```

**Producer mode (equivalent to kafka-console-producer):**

```terminal:execute
command: docker exec kafka bash -c 'echo "Hello from kcat producer" | kcat -b localhost:9092 -t user-events -P'
background: false
```

**Consumer mode (equivalent to kafka-console-consumer):**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o beginning -c 5
background: false
```

**🎯 Kcat advantages:**
- Shorter command syntax
- Built-in offset and partition control
- Better error messages
- No Java startup overhead

---

## 3. Advanced JSON Processing

**Produce JSON messages with kcat:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -P << 'EOF'
{"user_id": "user-001", "action": "login", "timestamp": "2024-01-15T10:00:00Z", "device": "mobile"}
{"user_id": "user-002", "action": "purchase", "timestamp": "2024-01-15T10:01:00Z", "amount": 99.99}
{"user_id": "user-001", "action": "logout", "timestamp": "2024-01-15T10:05:00Z", "session_duration": 300}
EOF
background: false
```

**Consume with enhanced formatting:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -f 'Partition:%p Offset:%o Timestamp:%T\nKey:%k\nValue:%s\n---\n' -c 3
background: false
```

**🎨 Format specifiers:**
- `%p` - Partition
- `%o` - Offset  
- `%T` - Timestamp
- `%k` - Key
- `%s` - Value
- `%h` - Headers

---

## 4. Partition and Offset Control

**Read from specific partition:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -p 0 -o beginning -c 10
background: false
```

**Read from specific offset:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -p 1 -o 5 -c 3
background: false
```

**Read latest messages only:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o end -f 'Latest: %s\n'
background: false
```

**📍 Offset options:**
- `beginning` - Start from earliest
- `end` - Start from latest  
- `stored` - Use committed consumer group offset
- `123` - Specific offset number
- `-5` - 5 messages from end

---

## 5. Key-Value Message Handling

**Produce key-value messages:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -P -K: << 'EOF'
user-alice:{"action":"profile_update","timestamp":"2024-01-15T10:10:00Z","changes":["email","phone"]}
user-bob:{"action":"password_change","timestamp":"2024-01-15T10:11:00Z","security_level":"high"}
user-alice:{"action":"settings_update","timestamp":"2024-01-15T10:12:00Z","preferences":{"theme":"dark","notifications":true}}
EOF
background: false
```

**Consume with key display:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -f 'Key: %k | Value: %s | Partition: %p\n' -c 5
background: false
```

**Extract only keys:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -f '%k\n' -c 10 | sort | uniq
background: false
```

---

## 6. Real-time Monitoring and Debugging

**Monitor topic in real-time:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o end -f 'New message at %T: %s\n' &
background: false
```

**In another terminal, produce test messages:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -P -K: << 'EOF'
monitor-test:Real-time monitoring test message
EOF
background: false
```

**Stop the monitor (use Ctrl+C).**

**Performance debugging:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -L -J | python3 -m json.tool
background: false
```

---

## 7. Message Headers Support

**Produce messages with headers:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -P -H source:mobile-app -H version:2.1.0 << 'EOF'
{"user_id": "user-003", "action": "feature_use", "feature": "dark_mode"}
EOF
background: false
```

**Consume with header display:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -f 'Headers: %h\nMessage: %s\n---\n' -c 3
background: false
```

**📧 Headers use cases:**
- Message routing information
- Tracing and correlation IDs
- Content type and encoding
- Application metadata

---

## 8. Advanced Filtering and Processing

**Filter messages by content:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o beginning | grep -i "login"
background: false
```

**Extract specific JSON fields:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o beginning -c 10 | jq -r '.user_id // empty' | sort | uniq -c
background: false
```

**Count messages per partition:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -f '%p\n' -e | sort | uniq -c
background: false
```

**🔍 Processing advantages:**
- Pipeline with standard Unix tools
- JSON processing with jq
- Better integration with scripts
- Enhanced filtering capabilities

---

## 9. Batch Processing and Automation

**Export all messages to file:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o beginning -e > /tmp/user-events-export.json
background: false
```

**Import messages from file:**

```terminal:execute
command: docker exec kafka bash -c 'echo "{"timestamp":"$(date -Iseconds)","message":"Batch imported via kcat"}" | kcat -b localhost:9092 -t user-events -P'
background: false
```

**Process messages with jq pipeline:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t user-events -C -o beginning -c 5 | jq -c '{user: .user_id, action: .action, time: .timestamp}' | head -5
background: false
```

---

## 10. Performance Comparison

**Time traditional Kafka consumer:**

```terminal:execute
command: docker exec kafka time kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --max-messages 100 > /dev/null
background: false
```

**Time kcat consumer:**

```terminal:execute
command: docker exec kafka time kcat -b localhost:9092 -t user-events -C -c 100 -e > /dev/null
background: false
```

**🚀 Performance benefits:**
- Faster startup (no JVM)
- Lower memory usage
- More efficient network usage
- Better for automation and scripts

---

## 11. Troubleshooting with Kcat

**Debug connection issues:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -L -d broker
background: false
```

**Test producer connectivity:**

```terminal:execute
command: docker exec kafka bash -c 'echo "connection test" | kcat -b localhost:9092 -t test-connectivity -P -d broker,topic,msg'
background: false
```

**Analyze broker metadata:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -L -J | jq '.brokers'
background: false
```

**🔧 Debug levels:**
- `broker` - Broker connection info
- `topic` - Topic metadata
- `msg` - Message-level debugging
- `protocol` - Protocol-level debugging

---

## 12. Schema Registry Integration (Simulation)

**Simulate Avro message production:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t schema-demo -P << 'EOF'
{"schema": "user_event", "version": 1, "data": {"user_id": 123, "action": "click", "element": "button"}}
EOF
background: false
```

**Read with schema information:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -t schema-demo -C -f 'Schema message: %s\n' -c 1
background: false
```

**📋 Schema Registry benefits with kcat:**
- Native Avro/JSON Schema support (with proper setup)
- Schema evolution handling
- Better error messages for schema mismatches

---

## 13. Monitoring and Alerting Integration

**Monitor consumer lag with kcat:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -Q -t user-events
background: false
```

**Check topic high water marks:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -Q -t user-events | awk '{total+=$3} END {print "Total messages:", total}'
background: false
```

**Create monitoring script:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-monitor.sh << 'EOF'
#!/bin/bash
TOPIC="user-events"
THRESHOLD=1000

LAG=$(kcat -b localhost:9092 -Q -t $TOPIC | awk '{lag+=$3-$2} END {print lag}')
echo "Current lag: $LAG messages"

if [ "$LAG" -gt "$THRESHOLD" ]; then
    echo "ALERT: High lag detected!"
fi
EOF
background: false
```

```terminal:execute
command: docker exec kafka chmod +x /tmp/kafka-monitor.sh && /tmp/kafka-monitor.sh
background: false
```

---

## 14. Integration with Modern Tools

**Docker Compose integration example:**

```yaml
version: '3.8'
services:
  kafka-monitor:
    image: edenhill/kcat:1.7.1
    command: >
      kcat -b kafka:9092 -C -t monitoring 
      -f 'Alert: %T %k %s\n' 
      -o beginning
    depends_on:
      - kafka
```

**Kubernetes job example:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kafka-export
spec:
  template:
    spec:
      containers:
      - name: kcat
        image: edenhill/kcat:1.7.1
        command: ["kcat", "-b", "kafka:9092", "-t", "events", "-C", "-e"]
      restartPolicy: Never
```

---

## 15. Visual Integration

**Kcat vs Traditional Kafka Tools comparison:**

| **Feature** | **Traditional Kafka CLI** | **Kcat** |
|------------|---------------------------|----------|
| **Startup Speed** | Slow (JVM) | Fast (native) |
| **Memory Usage** | High | Low |
| **JSON Support** | Manual | Built-in |
| **Format Control** | Limited | Extensive |
| **Debugging** | Basic | Advanced |
| **Automation** | Complex | Simple |
| **Headers** | Limited | Full support |

**🏆 When to use kcat:**
- Automation and scripting
- Performance-critical applications  
- Modern container environments
- JSON-heavy workloads
- Enhanced debugging needs

---

## Kcat Command Reference

**🎯 Essential Kcat Commands:**

**Producer:**
```bash
# Simple producer
echo "message" | kcat -b localhost:9092 -t topic -P

# Key-value producer  
echo "key:value" | kcat -b localhost:9092 -t topic -P -K:

# With headers
echo "message" | kcat -b localhost:9092 -t topic -P -H "header:value"
```

**Consumer:**
```bash
# Basic consumer
kcat -b localhost:9092 -t topic -C

# Formatted consumer
kcat -b localhost:9092 -t topic -C -f '%p:%o:%k:%s\n'

# Specific partition/offset
kcat -b localhost:9092 -t topic -C -p 0 -o beginning -c 10
```

**Metadata:**
```bash
# List topics and brokers
kcat -b localhost:9092 -L

# JSON metadata
kcat -b localhost:9092 -L -J

# Query watermarks  
kcat -b localhost:9092 -Q -t topic
```

---

## Modern Kafka Workflow with Kcat

**🔄 Development workflow:**

**1. Quick testing:**
```bash
# Test producer
echo '{"test": true}' | kcat -b localhost:9092 -t test -P

# Check result
kcat -b localhost:9092 -t test -C -c 1
```

**2. Debugging:**
```bash
# Debug connection
kcat -b localhost:9092 -L -d broker

# Monitor in real-time
kcat -b localhost:9092 -t events -C -o end
```

**3. Data processing:**
```bash
# Export and process
kcat -b localhost:9092 -t events -C -e | jq '.user_id' | sort | uniq -c
```

**4. Automation:**
```bash
# Scripted monitoring
kcat -b localhost:9092 -Q -t events | awk '{print $1 ":" $3-$2}'
```

---

## Current Kcat Environment

**Verify our kcat setup:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -L | head -10
background: false
```

**Test with our existing topics:**

```terminal:execute
command: docker exec kafka kcat -b localhost:9092 -Q -t user-events
background: false
```

**🎁 Kcat benefits demonstrated:**
- ✅ **Faster execution** than traditional tools
- ✅ **Better JSON handling** and formatting
- ✅ **Enhanced debugging** capabilities  
- ✅ **Modern integration** with containers and orchestration
- ✅ **Automation-friendly** syntax and options

**🚀 Ready for Level 9!**

Next: **Workshop Summary** - Review of everything we've learned and next steps for your Kafka journey.

**🔗 Kcat Resources:**
- [Kcat GitHub Repository](https://github.com/edenhill/kcat)
- [Kcat Documentation](https://github.com/edenhill/kcat#kcat)
- [Advanced Kcat Examples](https://github.com/edenhill/kcat/blob/master/examples.md)