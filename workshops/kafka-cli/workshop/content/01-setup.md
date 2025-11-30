# Environment Setup & Kafka Startup

Welcome to the comprehensive Kafka CLI Tools workshop! 🚀

Kafka and Kafka UI have been automatically started when this session began.

**Workshop Environment:**
- ☕ **Java JDK 21** - ready for Kafka CLI tools
- 📝 **Text Editor** - accessible via **Editor** tab at the top
- 🐳 **Docker** - running Kafka services
- 🔧 **Kafka CLI Tools** - all Kafka command-line utilities available

---

## What You'll Learn

This workshop covers **8 comprehensive levels** of Kafka CLI mastery:

1. **📁 Topic Management** - Create, list, describe, alter, delete topics
2. **📤📥 Producer & Consumer** - Basic messaging with CLI tools
3. **🔀 Partitions & Ordering** - Understanding keys, hashing, parallelization
4. **👥 Consumer Groups** - Group management, lag monitoring, offset control
5. **⚙️ Topic Configuration** - Retention, cleanup policies, practical scenarios
6. **🔧 Admin Tools** - Log directories, partition reassignment, broker tools
7. **🔐 Security & ACL** - Access control lists and user management
8. **🎁 Bonus: Kcat** - Modern Kafka CLI alternative

---

## Kafka Architecture Refresher

**Apache Kafka** is a distributed streaming platform with these key components:

- **Broker** - Server that stores and processes messages
- **Topic** - Named feed/category of messages
- **Partition** - Ordered log within a topic (enables parallelism)
- **Producer** - Client that publishes messages to topics
- **Consumer** - Client that subscribes to topics and processes messages
- **Consumer Group** - Set of consumers working together

---

## Verify Kafka is Running

Let's confirm our Kafka environment is ready:

```terminal:execute
command: docker compose ps
background: false
```

**Expected services:**
- ✅ `kafka` - (healthy)
- ✅ `kafka-ui` - (healthy)

---

## Test Kafka CLI Availability

Verify Kafka CLI tools are accessible:

```terminal:execute
command: docker exec kafka kafka-topics --version
background: false
```

**Check all available Kafka commands:**

```terminal:execute
command: docker exec kafka find /usr/bin -name "kafka-*" | head -10
background: false
```

This shows the rich set of CLI tools we'll explore in this workshop.

---

## Kafka UI Dashboard

Access the visual interface:

- **Dashboard** tab at the top of this workshop
- **URL:** http://localhost:8080

**Features we'll use:**
- 📊 **Cluster Overview** - Broker and topic status
- 📝 **Topic Management** - Visual topic operations
- 💬 **Message Browser** - View messages in topics
- 👥 **Consumer Groups** - Monitor consumer activity

---

## Workshop Navigation Tips

**Terminal Commands:**
- All commands use `docker exec kafka` prefix
- Commands are clickable for easy execution
- Use **Ctrl+C** to stop running consumers

**Documentation References:**
- Each level includes links to official Kafka docs
- **Best practices** highlighted throughout
- **Real-world scenarios** with practical examples

---

## Environment Details

**Kafka Configuration:**
- **Version:** 7.7.1 (latest)
- **Mode:** KRaft (no Zookeeper needed)
- **Bootstrap Server:** localhost:9092
- **Partitions:** Default 1, customizable
- **Replication:** 1 (single broker setup)

**Optimization for Learning:**
- Minimal resource usage
- Fast startup times
- Comprehensive logging
- Visual monitoring

---

## Ready to Begin!

Your Kafka environment is now ready for hands-on CLI exploration.

**Next Level:** We'll start with **Topic Management** - the foundation of all Kafka operations.

**🎯 Learning Approach:**
- **Hands-on examples** with immediate feedback
- **Progressive complexity** from basic to advanced
- **Real scenarios** you'll encounter in production
- **Best practices** for operational excellence

Let's master Kafka CLI tools step by step! 🚀