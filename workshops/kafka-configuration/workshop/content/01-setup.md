# Environment Setup & Workshop Introduction

Welcome to Kafka Configuration Mastery! Learn to configure every aspect of Apache Kafka for optimal performance. 🔧

---

## What You'll Learn

This workshop covers **8 comprehensive configuration areas**:

1. **🖥️ Broker Configuration** - Server-level settings and performance tuning
2. **📁 Topic Configuration** - Topic-specific settings and retention policies  
3. **📤 Producer Configuration** - Client-side producer optimization
4. **📥 Consumer Configuration** - Client-side consumer optimization
5. **⚡ Performance Tuning** - Advanced performance optimization
6. **🔐 Security Configuration** - Authentication and authorization setup
7. **📊 Monitoring Configuration** - JMX metrics and observability
8. **✅ Best Practices** - Production-ready configuration strategies

---

## Workshop Environment

**Kafka Setup:**
- ☕ **Kafka 7.7.1** - Latest Confluent Platform
- 📊 **Kafka UI** - Visual configuration management
- 🔧 **Pre-configured Examples** - Ready-to-use configuration files
- 📝 **Text Editor** - For editing configuration files

**Pre-loaded Configuration Examples:**
- `/opt/kafka/config-examples/broker-high-throughput.properties`
- `/opt/kafka/config-examples/producer-performance.properties`  
- `/opt/kafka/config-examples/consumer-performance.properties`
- `/opt/kafka/config-examples/topic-configs.json`

---

## Configuration Philosophy

**🎯 Configuration Strategy:**
- **Purpose-driven** - Configure based on use case requirements
- **Performance-focused** - Balance throughput, latency, and resource usage
- **Production-ready** - Settings that work in real environments
- **Measurable** - Configuration changes you can observe and validate

**⚖️ Key Trade-offs:**
- **Throughput vs Latency** - Higher throughput often means higher latency
- **Durability vs Performance** - More replicas = better durability but slower writes
- **Memory vs Disk** - Larger buffers = better performance but more memory usage
- **Simplicity vs Optimization** - Default settings vs fine-tuned configuration

---

## Verify Environment

Let's confirm our setup is ready:

```terminal:execute
command: docker compose ps
background: false
```

**Expected services:**
- ✅ `kafka` - (healthy)  
- ✅ `kafka-ui` - (healthy)

**Check configuration examples:**

```terminal:execute
command: docker exec kafka ls -la /opt/kafka/config-examples/
background: false
```

**Access Kafka UI Dashboard:**
- Click the **Dashboard** tab at the top
- URL: http://localhost:8080

---

## Configuration Approach

**📋 Our Learning Method:**

1. **Understand the Setting** - What does each configuration do?
2. **See the Default** - What's the current/default value?
3. **Apply the Change** - Modify configuration dynamically when possible
4. **Observe the Impact** - Measure the difference
5. **Document the Use Case** - When to use this configuration

**🔧 Configuration Tools:**
- `kafka-configs` - Dynamic configuration changes
- `kafka-topics` - Topic creation with configuration
- Configuration files - Broker-level settings
- JMX metrics - Performance monitoring

---

## Workshop Structure

Each level follows this pattern:

**📖 Configuration Reference**
- Link to official Apache Kafka documentation
- Description of configuration parameters
- Default values and ranges

**🛠️ Hands-on Practice**  
- Apply configuration changes
- Test different settings
- Observe performance impact

**🎯 Use Case Examples**
- Real-world scenarios
- Configuration recommendations
- Best practice guidelines

---

## Configuration Documentation

**📚 Essential References:**
- [Broker Configurations](https://kafka.apache.org/documentation/#brokerconfigs)
- [Topic Configurations](https://kafka.apache.org/documentation/#topicconfigs)
- [Producer Configurations](https://kafka.apache.org/documentation/#producerconfigs)  
- [Consumer Configurations](https://kafka.apache.org/documentation/#consumerconfigs)

**🎯 Configuration Categories:**
- **Core Settings** - Essential for basic operation
- **Performance Settings** - Throughput and latency optimization
- **Reliability Settings** - Durability and fault tolerance
- **Resource Settings** - Memory, disk, and network usage

---

## Ready to Configure!

Your Kafka configuration lab is ready for hands-on exploration.

**🚀 Learning Goals:**
- Master configuration parameters and their impact
- Learn to balance performance trade-offs
- Apply production-ready configuration patterns
- Develop configuration troubleshooting skills

**Let's start with broker configuration fundamentals!** 🔧

**🔗 Quick Reference:**
- **Official Documentation:** [Kafka Configuration](https://kafka.apache.org/documentation/#configuration)
- **Best Practices Guide:** [Production Configuration](https://kafka.apache.org/documentation/#bestpractices)