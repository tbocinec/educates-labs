# Security & Access Control Lists (ACL) - Advanced Topic

Explore Kafka's security features and access control mechanisms for production-grade deployments! 🔐

**⚠️ Note:** This is an advanced optional section. Our current setup runs without authentication for simplicity.

---

## Learning Objectives

In this advanced level you'll explore:
- ✅ **ACL concepts** - Understanding Kafka authorization
- ✅ **Security principles** - Authentication vs authorization
- ✅ **User management** - Creating and managing Kafka users
- ✅ **Permission models** - Read, write, admin operations
- ✅ **Production security** - Best practices and patterns
- ✅ **Security monitoring** - Auditing and logging

---

## 1. Understanding Kafka Security Model

**Current security status (no authentication):**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -i security
background: false
```

**📋 Kafka Security Components:**
- **Authentication** - Who are you? (SASL, SSL, OAuth)
- **Authorization** - What can you do? (ACL system)
- **Encryption** - Protect data in transit (SSL/TLS)
- **Auditing** - Track what happened (logs)

**🔍 Current setup limitations:**
- No authentication required
- All operations permitted
- No ACL enforcement
- Suitable for development/learning only

---

## 2. ACL Command Structure Overview

**View available ACL operations:**

```terminal:execute
command: docker exec kafka kafka-acls --help | head -20
background: false
```

**Basic ACL command structure:**
```bash
kafka-acls --bootstrap-server localhost:9092 \
  --operation OPERATION \
  --topic TOPIC_PATTERN \
  --principal Principal:USERNAME \
  --[add|remove|list]
```

**⚠️ Important:** ACLs require authentication to be enabled. We'll demonstrate the commands in simulation mode.

---

## 3. ACL Operations and Resources

**Understand ACL resource types:**

**Resource types:**
- **Topic** - Access to specific topics
- **Group** - Consumer group permissions
- **Cluster** - Administrative operations
- **TransactionalId** - Transaction permissions

**Operations:**
- **Read** - Consume messages
- **Write** - Produce messages  
- **Create** - Create topics/groups
- **Delete** - Delete resources
- **Alter** - Modify configurations
- **Describe** - View metadata
- **All** - All permissions

---

## 4. Simulated ACL Examples

**Example 1: Grant read access to a topic**
```bash
# This would work with authentication enabled:
kafka-acls --bootstrap-server localhost:9092 \
  --add \
  --operation Read \
  --topic user-events \
  --principal User:analytics-service
```

**Example 2: Grant write access with wildcards**
```bash
# Allow writing to all metrics topics:
kafka-acls --bootstrap-server localhost:9092 \
  --add \
  --operation Write \
  --topic metrics-* \
  --principal User:metrics-collector
```

**Example 3: Consumer group permissions**
```bash
# Allow joining specific consumer group:
kafka-acls --bootstrap-server localhost:9092 \
  --add \
  --operation Read \
  --group analytics-team \
  --principal User:analytics-service
```

---

## 5. Security Configuration Examples

**Understand what secure Kafka configuration looks like:**

**Server properties (server.properties) for SASL/PLAIN:**
```properties
# Authentication
listeners=SASL_PLAINTEXT://localhost:9092
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN

# Authorization  
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
super.users=User:admin

# JAAS Configuration
listener.security.protocol.map=SASL_PLAINTEXT:SASL_PLAINTEXT
```

**Client configuration for authenticated access:**
```properties
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
  username="user1" \
  password="password1";
```

---

## 6. User Management Simulation

**Create user credentials file (JAAS format):**

```terminal:execute
command: docker exec kafka tee /tmp/kafka_server_jaas.conf << 'EOF'
KafkaServer {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin-secret"
  user_admin="admin-secret"
  user_producer="producer-pass"
  user_consumer="consumer-pass";
};
EOF
background: false
```

**📝 User accounts in this example:**
- `admin` - Administrative user
- `producer` - Application that writes data
- `consumer` - Application that reads data

---

## 7. Topic-Level Security Patterns

**Pattern 1: Service-specific topics**
```bash
# Analytics service can only read analytics topics
kafka-acls --add --operation Read --topic analytics.* --principal User:analytics-service

# Metrics service can only write to metrics topics  
kafka-acls --add --operation Write --topic metrics.* --principal User:metrics-service
```

**Pattern 2: Environment separation**
```bash
# Production services can't access dev topics
kafka-acls --add --operation Read,Write --topic prod.* --principal User:prod-service
kafka-acls --add --operation Read,Write --topic dev.* --principal User:dev-service
```

**Pattern 3: Read-only analytics**
```bash
# Analytics users get read-only access to all data topics
kafka-acls --add --operation Read --topic data.* --principal User:analyst
kafka-acls --add --operation Read --group analytics-* --principal User:analyst
```

---

## 8. Administrative ACL Patterns

**Cluster administration permissions:**
```bash
# Grant cluster admin rights
kafka-acls --add --operation All --cluster --principal User:kafka-admin

# Topic management only
kafka-acls --add --operation Create,Delete,Alter --topic * --principal User:topic-manager

# Consumer group management
kafka-acls --add --operation Read,Delete --group * --principal User:group-manager
```

**🔐 Principle of least privilege:**
- Grant minimum required permissions
- Use specific topic patterns instead of wildcards
- Regular permission audits
- Time-limited access for temporary needs

---

## 9. ACL Listing and Auditing

**Simulated ACL listing commands:**

```bash
# List all ACLs
kafka-acls --bootstrap-server localhost:9092 --list

# List ACLs for specific user
kafka-acls --bootstrap-server localhost:9092 --list --principal User:analytics-service

# List ACLs for specific topic
kafka-acls --bootstrap-server localhost:9092 --list --topic user-events

# List ACLs for resource pattern
kafka-acls --bootstrap-server localhost:9092 --list --topic metrics-*
```

**📊 ACL audit checklist:**
- Who has access to what topics?
- Are there overprivileged accounts?
- Are wildcards used appropriately?
- Do service accounts have minimal permissions?

---

## 10. Security Best Practices

**🎯 Production Security Checklist:**

**1. Authentication:**
- ✅ Enable SASL or SSL client authentication
- ✅ Use strong passwords or certificates
- ✅ Rotate credentials regularly
- ✅ Separate service accounts per application

**2. Authorization:**
- ✅ Enable ACL authorization
- ✅ Follow principle of least privilege
- ✅ Use specific resource patterns
- ✅ Regular permission reviews

**3. Network Security:**
- ✅ Use SSL/TLS for encryption
- ✅ Network segmentation
- ✅ Firewall rules
- ✅ VPN or private networks

**4. Monitoring:**
- ✅ Enable security logging
- ✅ Monitor authentication failures
- ✅ Track authorization denials
- ✅ Audit ACL changes

---

## 11. Common Security Scenarios

**Scenario 1: Multi-tenant Kafka**
```bash
# Tenant A can only access their topics
kafka-acls --add --operation Read,Write --topic tenant-a.* --principal User:tenant-a-service

# Tenant B isolated to their namespace  
kafka-acls --add --operation Read,Write --topic tenant-b.* --principal User:tenant-b-service

# Shared monitoring topic (read-only)
kafka-acls --add --operation Read --topic monitoring.metrics --principal User:tenant-a-service
kafka-acls --add --operation Read --topic monitoring.metrics --principal User:tenant-b-service
```

**Scenario 2: Microservices Security**
```bash
# Order service
kafka-acls --add --operation Write --topic orders.events --principal User:order-service
kafka-acls --add --operation Read --group order-processors --principal User:order-service

# Payment service
kafka-acls --add --operation Write --topic payments.events --principal User:payment-service
kafka-acls --add --operation Read --topic orders.events --principal User:payment-service

# Analytics service (read-only)
kafka-acls --add --operation Read --topic *.events --principal User:analytics-service
```

---

## 12. Security Monitoring and Logging

**Example security log entries:**

```terminal:execute
command: docker exec kafka tee /tmp/security-events.log << 'EOF'
[2024-01-15 10:15:32] INFO Authentication successful: User:producer-service from 10.0.1.15
[2024-01-15 10:15:45] WARN Authorization denied: User:unauthorized-user tried to READ topic:sensitive-data
[2024-01-15 10:16:02] INFO ACL added: User:admin granted WRITE permission to topic:new-events
[2024-01-15 10:16:18] ERROR Authentication failed: Invalid credentials for User:hacker-attempt from 192.168.1.100
EOF
background: false
```

**Security monitoring tools:**
```bash
# Monitor authentication logs
tail -f /var/log/kafka/kafka-security.log | grep "Authentication"

# Track authorization failures
grep "Authorization denied" /var/log/kafka/kafka-security.log

# Monitor ACL changes
grep "ACL" /var/log/kafka/kafka-security.log
```

---

## 13. SSL/TLS Configuration Example

**SSL-enabled Kafka configuration:**
```properties
# Server SSL Configuration
listeners=SSL://localhost:9093
security.inter.broker.protocol=SSL
ssl.keystore.location=/etc/kafka/ssl/kafka.server.keystore.jks
ssl.keystore.password=keystore-password
ssl.key.password=key-password
ssl.truststore.location=/etc/kafka/ssl/kafka.server.truststore.jks
ssl.truststore.password=truststore-password

# Client authentication (mutual TLS)
ssl.client.auth=required

# ACL authorization
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
super.users=User:CN=admin
```

**Client SSL configuration:**
```properties
security.protocol=SSL
ssl.truststore.location=/etc/kafka/ssl/client.truststore.jks
ssl.truststore.password=truststore-password
ssl.keystore.location=/etc/kafka/ssl/client.keystore.jks
ssl.keystore.password=keystore-password
ssl.key.password=key-password
```

---

## 14. Migration to Secure Kafka

**Step-by-step security migration:**

**Phase 1: Enable SSL (encryption only)**
```properties
# Add SSL listener alongside plaintext
listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
```

**Phase 2: Enable authentication**
```properties
# Require SSL for external access
listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
ssl.client.auth=required
```

**Phase 3: Enable authorization**
```properties
# Enable ACLs
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
```

**Phase 4: Remove plaintext listener**
```properties
# SSL only
listeners=SSL://localhost:9093
```

---

## 15. Visual Security Monitoring

**In a production environment with security enabled:**

**Dashboard features:**
- Authentication status per client
- Authorization denial alerts
- Active user sessions
- Permission matrices
- Security audit logs

**🔐 Security dashboard would show:**
- User authentication status
- Failed authentication attempts
- ACL violations
- Active sessions per user
- Resource access patterns

---

## Security Command Reference

**🔑 Authentication Commands:**
```bash
# Configure JAAS authentication
export KAFKA_OPTS="-Djava.security.auth.login.config=/path/to/jaas.conf"

# Test authentication
kafka-console-producer --bootstrap-server localhost:9092 \
  --producer-property security.protocol=SASL_PLAINTEXT \
  --producer-property sasl.mechanism=PLAIN \
  --producer-property sasl.jaas.config="org.apache.kafka.common.security.plain.PlainLoginModule required username='user' password='pass';"
```

**🛡️ Authorization Commands:**
```bash
# Add ACL
kafka-acls --bootstrap-server localhost:9092 --add \
  --operation READ --topic TOPIC --principal User:USERNAME

# List ACLs
kafka-acls --bootstrap-server localhost:9092 --list

# Remove ACL
kafka-acls --bootstrap-server localhost:9092 --remove \
  --operation READ --topic TOPIC --principal User:USERNAME
```

---

## Security Implementation Roadmap

**🎯 For production deployment:**

**Phase 1: Planning (Week 1-2)**
- Security requirements analysis
- User and service inventory
- Permission mapping
- Certificate planning

**Phase 2: SSL Implementation (Week 3-4)**
- Certificate generation and distribution
- SSL listener configuration
- Client SSL configuration
- Testing encrypted connections

**Phase 3: Authentication (Week 5-6)**
- SASL/authentication setup
- User account creation
- Client configuration updates
- Authentication testing

**Phase 4: Authorization (Week 7-8)**
- ACL design and documentation
- ACL implementation
- Permission testing
- Security monitoring setup

---

## Key Security Takeaways

**🔐 Essential Security Principles:**

1. **Defense in Depth**
   - Network security + authentication + authorization
   - Multiple layers of protection
   - Fail-safe defaults

2. **Principle of Least Privilege**
   - Grant minimum required permissions
   - Regular permission audits
   - Time-limited access

3. **Security Monitoring**
   - Log all security events
   - Alert on suspicious activity
   - Regular security reviews

4. **Operational Security**
   - Secure credential management
   - Regular security updates
   - Incident response procedures

**⚠️ Production Reality:**
Our workshop runs without authentication for learning purposes. Production Kafka clusters should ALWAYS have security enabled with proper authentication, authorization, and encryption.

**🚀 Ready for Level 8!**

Next: **Bonus: Kcat** - Modern Kafka CLI alternative with enhanced features and usability.

**🔗 Security References:**
- [Kafka Security Guide](https://kafka.apache.org/documentation/#security)
- [ACL Documentation](https://kafka.apache.org/documentation/#security_authz)
- [SSL Configuration](https://kafka.apache.org/documentation/#security_ssl)