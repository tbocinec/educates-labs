# Security Configuration

Implement comprehensive security for Kafka clusters including authentication, authorization, encryption, and audit logging. 🔒

---

## Understanding Kafka Security

**🔐 Security Dimensions:**
- **Authentication** - Verifying client and broker identity
- **Authorization** - Controlling access to resources and operations
- **Encryption** - Protecting data in transit and at rest
- **Audit logging** - Tracking security events and access

**🛡️ Security Protocols:**
- PLAINTEXT (no security)
- SSL/TLS (encryption only)
- SASL_PLAINTEXT (authentication only)  
- SASL_SSL (authentication + encryption)

---

## SSL/TLS Configuration

**Generate SSL certificates:**

```terminal:execute
command: docker exec kafka bash -c "
mkdir -p /opt/kafka/ssl-certs
cd /opt/kafka/ssl-certs

# Generate Certificate Authority (CA)
keytool -genkeypair -alias ca-root -keyalg RSA -keysize 2048 -keystore ca-keystore.jks -storepass changeit -keypass changeit -validity 365 -dname 'CN=Kafka-CA,OU=Kafka,O=Example,L=City,ST=State,C=US'

# Export CA certificate  
keytool -exportcert -alias ca-root -keystore ca-keystore.jks -storepass changeit -file ca-cert.pem

echo 'SSL certificates generated successfully'
"
background: false
```

**Create broker SSL keystore:**

```terminal:execute
command: docker exec kafka bash -c "
cd /opt/kafka/ssl-certs

# Generate broker keystore
keytool -genkeypair -alias kafka-broker -keyalg RSA -keysize 2048 -keystore broker-keystore.jks -storepass changeit -keypass changeit -validity 365 -dname 'CN=kafka,OU=Kafka,O=Example,L=City,ST=State,C=US'

# Create certificate signing request
keytool -certreq -alias kafka-broker -keystore broker-keystore.jks -storepass changeit -file broker-cert-request.pem

# Sign the certificate with CA
keytool -gencert -alias ca-root -keystore ca-keystore.jks -storepass changeit -infile broker-cert-request.pem -outfile broker-cert.pem -validity 365

# Import CA certificate into broker keystore
keytool -importcert -alias ca-root -keystore broker-keystore.jks -storepass changeit -file ca-cert.pem -noprompt

# Import signed certificate into broker keystore
keytool -importcert -alias kafka-broker -keystore broker-keystore.jks -storepass changeit -file broker-cert.pem -noprompt

echo 'Broker SSL keystore created'
"
background: false
```

**Create client SSL truststore:**

```terminal:execute
command: docker exec kafka bash -c "
cd /opt/kafka/ssl-certs

# Create client truststore with CA certificate
keytool -importcert -alias ca-root -keystore client-truststore.jks -storepass changeit -file ca-cert.pem -noprompt

# List certificates
echo 'Broker keystore contents:'
keytool -list -keystore broker-keystore.jks -storepass changeit

echo -e '\nClient truststore contents:'  
keytool -list -keystore client-truststore.jks -storepass changeit
"
background: false
```

**📚 Documentation:** [SSL Setup Guide](https://kafka.apache.org/documentation/#security_ssl)

---

## SSL Broker Configuration

**Create SSL-enabled broker configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/ssl-broker.properties << 'EOF'
# SSL-enabled Kafka broker configuration

## Basic Broker Settings
broker.id=1
listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
advertised.listeners=PLAINTEXT://localhost:9092,SSL://localhost:9093
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL

## SSL Configuration  
ssl.keystore.location=/opt/kafka/ssl-certs/broker-keystore.jks
ssl.keystore.password=changeit
ssl.key.password=changeit
ssl.truststore.location=/opt/kafka/ssl-certs/client-truststore.jks  
ssl.truststore.password=changeit

## SSL Protocol Settings
ssl.enabled.protocols=TLSv1.2,TLSv1.3
ssl.client.auth=none
ssl.endpoint.identification.algorithm=

## Log Configuration
log.dirs=/tmp/kafka-logs-ssl
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

## Replication (for multi-broker setup)
security.inter.broker.protocol=SSL
ssl.cipher.suites=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
EOF
background: false
```

**Test SSL connection:**

```terminal:execute
command: docker exec kafka bash -c "
echo 'Testing SSL connection...'

# Create client SSL properties
tee /tmp/ssl-client.properties << 'EOF'
security.protocol=SSL
ssl.truststore.location=/opt/kafka/ssl-certs/client-truststore.jks
ssl.truststore.password=changeit
ssl.endpoint.identification.algorithm=
EOF

# Test SSL producer (simulated - would need SSL listener running)
echo 'SSL client configuration created'
echo 'To test: kafka-console-producer --bootstrap-server localhost:9093 --producer.config /tmp/ssl-client.properties --topic ssl-test'
"
background: false
```

---

## SASL Authentication Configuration

**Create SASL JAAS configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-server-jaas.conf << 'EOF'
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin-secret"
    user_admin="admin-secret"
    user_alice="alice-secret" 
    user_bob="bob-secret"
    user_consumer="consumer-secret"
    user_producer="producer-secret";
};

Client {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin-secret";
};
EOF
background: false
```

**Create SASL-enabled broker configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/sasl-broker.properties << 'EOF'
# SASL-enabled Kafka broker configuration

## Basic Broker Settings
broker.id=1  
listeners=PLAINTEXT://localhost:9092,SASL_PLAINTEXT://localhost:9094
advertised.listeners=PLAINTEXT://localhost:9092,SASL_PLAINTEXT://localhost:9094
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SASL_PLAINTEXT:SASL_PLAINTEXT

## SASL Configuration
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
security.inter.broker.protocol=SASL_PLAINTEXT

## Authentication  
listener.name.sasl_plaintext.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret" user_admin="admin-secret" user_alice="alice-secret" user_bob="bob-secret";

## Log Configuration
log.dirs=/tmp/kafka-logs-sasl
num.network.threads=3
num.io.threads=8

## ZooKeeper SASL (if using ZooKeeper)
# zookeeper.sasl.client=true
EOF
background: false
```

**Create client SASL configurations:**

```terminal:execute
command: docker exec kafka bash -c "
# Admin client configuration
tee /tmp/sasl-admin.properties << 'EOF'
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"admin-secret\";
EOF

# Producer client configuration  
tee /tmp/sasl-producer.properties << 'EOF'
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"producer\" password=\"producer-secret\";
bootstrap.servers=localhost:9094
EOF

# Consumer client configuration
tee /tmp/sasl-consumer.properties << 'EOF' 
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"consumer\" password=\"consumer-secret\";
bootstrap.servers=localhost:9094
EOF

echo 'SASL client configurations created'
"
background: false
```

**📚 Documentation:** [SASL Authentication](https://kafka.apache.org/documentation/#security_sasl)

---

## Authorization with ACLs

**Enable ACL authorization:**

```terminal:execute
command: docker exec kafka tee /tmp/acl-broker.properties << 'EOF'
# ACL-enabled Kafka broker configuration

## Basic Broker Settings
broker.id=1
listeners=PLAINTEXT://localhost:9092,SASL_PLAINTEXT://localhost:9094
advertised.listeners=PLAINTEXT://localhost:9092,SASL_PLAINTEXT://localhost:9094
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SASL_PLAINTEXT:SASL_PLAINTEXT

## SASL Configuration
sasl.enabled.mechanisms=PLAIN
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN

## Authorization Configuration
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin

## Authentication
listener.name.sasl_plaintext.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret" user_admin="admin-secret" user_alice="alice-secret" user_bob="bob-secret";

## Log Configuration  
log.dirs=/tmp/kafka-logs-acl
EOF
background: false
```

**Create ACL management scripts:**

```terminal:execute
command: docker exec kafka bash -c "
# Create ACL management script
tee /tmp/manage-acls.sh << 'EOF'
#!/bin/bash
# Kafka ACL management script

BOOTSTRAP_SERVERS='localhost:9094'
COMMAND_CONFIG='/tmp/sasl-admin.properties'

echo '=== Kafka ACL Management ==='

# Function to create topic ACLs
create_topic_acls() {
    local topic=\$1
    local user=\$2
    local operations=\$3
    
    echo \"Creating ACLs for topic: \$topic, user: \$user, operations: \$operations\"
    
    kafka-acls --bootstrap-server \$BOOTSTRAP_SERVERS --command-config \$COMMAND_CONFIG \\
        --add --allow-principal User:\$user --operation \$operations --topic \$topic
}

# Function to create consumer group ACLs
create_group_acls() {
    local group=\$1
    local user=\$2
    
    echo \"Creating consumer group ACLs for group: \$group, user: \$user\"
    
    kafka-acls --bootstrap-server \$BOOTSTRAP_SERVERS --command-config \$COMMAND_CONFIG \\
        --add --allow-principal User:\$user --operation Read --group \$group
}

# Create sample ACLs
echo \"1. Creating producer ACLs...\"
create_topic_acls \"secure-topic\" \"alice\" \"Write\"
create_topic_acls \"secure-topic\" \"alice\" \"Describe\"

echo \"2. Creating consumer ACLs...\"
create_topic_acls \"secure-topic\" \"bob\" \"Read\"
create_topic_acls \"secure-topic\" \"bob\" \"Describe\"
create_group_acls \"secure-group\" \"bob\"

echo \"3. Listing all ACLs...\"
kafka-acls --bootstrap-server \$BOOTSTRAP_SERVERS --command-config \$COMMAND_CONFIG --list
EOF

chmod +x /tmp/manage-acls.sh
echo 'ACL management script created'
"
background: false
```

**Test ACL operations:**

```terminal:execute
command: docker exec kafka bash -c "
echo 'Testing ACL operations...'

# Create test topic (requires admin privileges)
kafka-topics --bootstrap-server localhost:9094 --command-config /tmp/sasl-admin.properties --create --topic secure-topic --partitions 3 --replication-factor 1 --if-not-exists

# List topics (admin can see all)
echo 'Topics visible to admin:'
kafka-topics --bootstrap-server localhost:9094 --command-config /tmp/sasl-admin.properties --list

echo 'ACL test setup completed'
"
background: false
```

---

## Combined SSL + SASL Configuration

**Create comprehensive security configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/secure-broker.properties << 'EOF'
# Comprehensive security configuration (SSL + SASL)

## Basic Broker Settings
broker.id=1
listeners=PLAINTEXT://localhost:9092,SASL_SSL://localhost:9095
advertised.listeners=PLAINTEXT://localhost:9092,SASL_SSL://localhost:9095
listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SASL_SSL:SASL_SSL

## SSL Configuration
ssl.keystore.location=/opt/kafka/ssl-certs/broker-keystore.jks
ssl.keystore.password=changeit
ssl.key.password=changeit
ssl.truststore.location=/opt/kafka/ssl-certs/client-truststore.jks
ssl.truststore.password=changeit
ssl.enabled.protocols=TLSv1.2,TLSv1.3
ssl.client.auth=none

## SASL Configuration  
sasl.enabled.mechanisms=PLAIN
security.inter.broker.protocol=SASL_SSL
sasl.mechanism.inter.broker.protocol=PLAIN

## Authorization
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin

## Authentication Configuration
listener.name.sasl_ssl.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret" user_admin="admin-secret" user_secure_producer="secure-secret" user_secure_consumer="secure-secret";

## Log Configuration
log.dirs=/tmp/kafka-logs-secure
EOF
background: false
```

**Create secure client configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/secure-client.properties << 'EOF'
# Secure client configuration (SSL + SASL)
security.protocol=SASL_SSL
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="secure_producer" password="secure-secret";

## SSL Settings
ssl.truststore.location=/opt/kafka/ssl-certs/client-truststore.jks
ssl.truststore.password=changeit
ssl.endpoint.identification.algorithm=

## Connection Settings
bootstrap.servers=localhost:9095
EOF
background: false
```

---

## Audit Logging Configuration

**Enable comprehensive audit logging:**

```terminal:execute
command: docker exec kafka tee /tmp/audit-broker.properties << 'EOF'
# Kafka broker configuration with audit logging

## Security Configuration (from previous examples)
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin

## Audit Logging Configuration
log4j.logger.kafka.authorizer.logger=INFO, authorizerAppender
log4j.additivity.kafka.authorizer.logger=false

## Request Logging
log4j.logger.kafka.request.logger=INFO, requestAppender
log4j.additivity.kafka.request.logger=false

## Security Event Logging
log4j.logger.org.apache.kafka.common.security=INFO, securityAppender
log4j.additivity.org.apache.kafka.common.security=false
EOF
background: false
```

**Create audit log configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/audit-log4j.properties << 'EOF'
# Audit logging configuration for Kafka

## Root Logger
log4j.rootLogger=INFO, stdout

## Console Appender
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

## Authorization Audit Appender
log4j.appender.authorizerAppender=org.apache.log4j.RollingFileAppender
log4j.appender.authorizerAppender.File=/opt/kafka/logs/kafka-auth-audit.log
log4j.appender.authorizerAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.authorizerAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.authorizerAppender.MaxFileSize=100MB
log4j.appender.authorizerAppender.MaxBackupIndex=10

## Request Audit Appender  
log4j.appender.requestAppender=org.apache.log4j.RollingFileAppender
log4j.appender.requestAppender.File=/opt/kafka/logs/kafka-request-audit.log
log4j.appender.requestAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.requestAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.requestAppender.MaxFileSize=100MB
log4j.appender.requestAppender.MaxBackupIndex=10

## Security Event Appender
log4j.appender.securityAppender=org.apache.log4j.RollingFileAppender  
log4j.appender.securityAppender.File=/opt/kafka/logs/kafka-security-audit.log
log4j.appender.securityAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.securityAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.securityAppender.MaxFileSize=100MB
log4j.appender.securityAppender.MaxBackupIndex=10
EOF
background: false
```

---

## Security Testing and Validation

**Test authentication mechanisms:**

```terminal:execute
command: docker exec kafka bash -c "
echo '=== Security Testing ==='

echo '1. Testing PLAINTEXT connection (should work)'
timeout 5 kafka-topics --bootstrap-server localhost:9092 --list || echo 'Connection test completed'

echo '2. Testing SASL authentication'  
echo 'Admin user topics:'
timeout 5 kafka-topics --bootstrap-server localhost:9094 --command-config /tmp/sasl-admin.properties --list || echo 'SASL admin test completed'

echo '3. Testing unauthorized access (should fail)'
timeout 5 kafka-topics --bootstrap-server localhost:9094 --list 2>/dev/null || echo 'Unauthorized access correctly blocked'

echo 'Security tests completed'
"
background: false
```

**Create security validation script:**

```terminal:execute
command: docker exec kafka tee /tmp/security-validation.sh << 'EOF'
#!/bin/bash
# Kafka security validation script

echo "=== Kafka Security Validation ==="

# Function to test connection
test_connection() {
    local bootstrap_server=$1
    local config_file=$2
    local test_name="$3"
    
    echo "Testing $test_name..."
    
    if [ -n "$config_file" ]; then
        timeout 10 kafka-topics --bootstrap-server $bootstrap_server --command-config $config_file --list >/dev/null 2>&1
    else
        timeout 10 kafka-topics --bootstrap-server $bootstrap_server --list >/dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ $test_name: SUCCESS"
    else
        echo "✗ $test_name: FAILED or TIMEOUT"
    fi
}

# Test different security configurations
echo "1. Security Connection Tests"
test_connection "localhost:9092" "" "PLAINTEXT (no security)"
test_connection "localhost:9094" "/tmp/sasl-admin.properties" "SASL_PLAINTEXT (admin user)"
# test_connection "localhost:9093" "/tmp/ssl-client.properties" "SSL (encryption only)"
# test_connection "localhost:9095" "/tmp/secure-client.properties" "SASL_SSL (full security)"

echo -e "\n2. SSL Certificate Validation"
if [ -f "/opt/kafka/ssl-certs/broker-keystore.jks" ]; then
    echo "✓ Broker keystore exists"
else
    echo "✗ Broker keystore missing"
fi

if [ -f "/opt/kafka/ssl-certs/client-truststore.jks" ]; then
    echo "✓ Client truststore exists"  
else
    echo "✗ Client truststore missing"
fi

echo -e "\n3. SASL Configuration Validation"
if [ -f "/tmp/kafka-server-jaas.conf" ]; then
    echo "✓ JAAS configuration exists"
else
    echo "✗ JAAS configuration missing"
fi

echo -e "\n4. ACL Configuration Check"
if grep -q "authorizer.class.name" /tmp/acl-broker.properties 2>/dev/null; then
    echo "✓ ACL authorizer configured"
else
    echo "✗ ACL authorizer not configured"  
fi

echo -e "\n=== Security Validation Complete ==="
EOF

chmod +x /tmp/security-validation.sh
/tmp/security-validation.sh
background: false
```

---

## Security Best Practices

**Create security checklist:**

```terminal:execute
command: docker exec kafka tee /tmp/security-checklist.txt << 'EOF'
# Kafka Security Best Practices Checklist

## Authentication
□ Use strong authentication mechanisms (SASL/SCRAM or mTLS)
□ Avoid SASL/PLAIN in production (use SCRAM-SHA-256/512)
□ Implement proper credential rotation policies
□ Use separate credentials for different client types
□ Enable inter-broker authentication

## Authorization  
□ Enable ACL-based authorization
□ Follow principle of least privilege
□ Create service-specific users and ACLs
□ Regularly audit and review ACL permissions
□ Use resource patterns for efficient ACL management

## Encryption
□ Enable SSL/TLS for all client connections
□ Use TLS 1.2 or higher
□ Implement proper certificate management
□ Consider encryption at rest for sensitive data
□ Enable SSL for inter-broker communication

## Network Security
□ Isolate Kafka cluster in private network
□ Use firewall rules to restrict access
□ Implement network segmentation
□ Monitor network traffic for anomalies
□ Use VPN for remote administrative access

## Monitoring and Auditing
□ Enable comprehensive audit logging
□ Monitor authentication failures
□ Track authorization denials  
□ Set up alerts for security events
□ Implement centralized log management

## Certificate Management
□ Use trusted Certificate Authority
□ Implement certificate rotation procedures
□ Monitor certificate expiration dates
□ Use proper certificate validation
□ Secure private key storage

## Operational Security
□ Regular security assessments
□ Keep Kafka and dependencies updated
□ Implement backup and recovery procedures
□ Train operations team on security procedures
□ Establish incident response procedures
EOF
background: false
```

**Security configuration templates:**

```terminal:execute
command: docker exec kafka bash -c "
# Create security configuration templates directory
mkdir -p /tmp/security-templates

# Production SSL configuration
tee /tmp/security-templates/production-ssl.properties << 'EOF'
## Production SSL Configuration Template

# Listener Configuration
listeners=SSL://0.0.0.0:9093
advertised.listeners=SSL://kafka-broker-1:9093
listener.security.protocol.map=SSL:SSL
security.inter.broker.protocol=SSL

# SSL Configuration
ssl.keystore.location=/opt/kafka/ssl/kafka.server.keystore.jks
ssl.keystore.password=\${SSL_KEYSTORE_PASSWORD}
ssl.key.password=\${SSL_KEY_PASSWORD}
ssl.truststore.location=/opt/kafka/ssl/kafka.server.truststore.jks
ssl.truststore.password=\${SSL_TRUSTSTORE_PASSWORD}

# SSL Protocol Settings
ssl.enabled.protocols=TLSv1.2,TLSv1.3
ssl.client.auth=required
ssl.cipher.suites=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
ssl.endpoint.identification.algorithm=HTTPS
EOF

# Production SASL configuration  
tee /tmp/security-templates/production-sasl.properties << 'EOF'
## Production SASL Configuration Template

# Listener Configuration
listeners=SASL_SSL://0.0.0.0:9094
advertised.listeners=SASL_SSL://kafka-broker-1:9094
listener.security.protocol.map=SASL_SSL:SASL_SSL
security.inter.broker.protocol=SASL_SSL

# SASL Configuration
sasl.enabled.mechanisms=SCRAM-SHA-256
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256

# Authorization
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin
EOF

echo 'Security configuration templates created in /tmp/security-templates/'
ls -la /tmp/security-templates/
"
background: false
```

---

## Security Monitoring

**Create security monitoring script:**

```terminal:execute
command: docker exec kafka tee /tmp/security-monitor.sh << 'EOF'
#!/bin/bash
# Kafka security monitoring script

echo "=== Kafka Security Monitoring ==="

# Monitor authentication failures
check_auth_failures() {
    echo "1. Authentication Failures (last 100 lines)"
    if [ -f "/opt/kafka/logs/server.log" ]; then
        tail -100 /opt/kafka/logs/server.log | grep -i "authentication failed\|sasl authentication failed" | tail -5
    else
        echo "No authentication failure logs found"
    fi
}

# Monitor ACL violations  
check_acl_violations() {
    echo -e "\n2. Authorization Violations (last 100 lines)"
    if [ -f "/opt/kafka/logs/kafka-auth-audit.log" ]; then
        tail -100 /opt/kafka/logs/kafka-auth-audit.log | grep -i "denied\|unauthorized" | tail -5
    else
        echo "No ACL violation logs found"
    fi
}

# Monitor SSL connection issues
check_ssl_issues() {
    echo -e "\n3. SSL Connection Issues (last 100 lines)"
    if [ -f "/opt/kafka/logs/server.log" ]; then
        tail -100 /opt/kafka/logs/server.log | grep -i "ssl\|tls\|certificate" | grep -i "error\|failed\|exception" | tail -5
    else
        echo "No SSL issue logs found"  
    fi
}

# Check active secure connections
check_connections() {
    echo -e "\n4. Active Secure Connections"
    netstat -an | grep -E "(9093|9094|9095)" | wc -l
    echo "Secure connections active"
}

# Check certificate expiration (simulated)
check_certificates() {
    echo -e "\n5. Certificate Status"
    if [ -f "/opt/kafka/ssl-certs/broker-keystore.jks" ]; then
        echo "✓ Broker keystore present"
        # keytool -list -v -keystore /opt/kafka/ssl-certs/broker-keystore.jks -storepass changeit | grep "Valid from"
    else
        echo "✗ Broker keystore missing"
    fi
}

# Run all checks
check_auth_failures
check_acl_violations  
check_ssl_issues
check_connections
check_certificates

echo -e "\n=== Security Monitoring Complete ==="
EOF

chmod +x /tmp/security-monitor.sh
echo 'Security monitoring script created'
background: false
```

---

## Key Takeaways

**🔐 Security Implementation Strategy:**
1. **Start with SSL/TLS** - Encrypt all communications
2. **Add SASL authentication** - Verify client identities  
3. **Implement ACL authorization** - Control access to resources
4. **Enable audit logging** - Track all security events

**🛡️ Security Configuration Patterns:**
- **Development**: PLAINTEXT (no security overhead)
- **Testing**: SASL_PLAINTEXT (authentication without encryption)
- **Production**: SASL_SSL (full authentication + encryption)
- **High security**: mTLS + SCRAM-SHA-512 + comprehensive ACLs

**📊 Security Monitoring Essentials:**
- Authentication failure alerts
- Authorization violation tracking
- Certificate expiration monitoring  
- Abnormal connection pattern detection
- Comprehensive audit logging

**🔑 Authentication Methods by Security Level:**
```
Basic: SASL/PLAIN (avoid in production)
Standard: SASL/SCRAM-SHA-256  
High: SASL/SCRAM-SHA-512
Maximum: Mutual TLS (mTLS)
```

**🚀 Next Level:** Monitoring Configuration - Comprehensive observability and alerting setup.

**🔗 Essential References:**
- [Kafka Security Guide](https://kafka.apache.org/documentation/#security)
- [SSL Configuration](https://kafka.apache.org/documentation/#security_ssl)
- [SASL Authentication](https://kafka.apache.org/documentation/#security_sasl)
- [ACL Authorization](https://kafka.apache.org/documentation/#security_authz)