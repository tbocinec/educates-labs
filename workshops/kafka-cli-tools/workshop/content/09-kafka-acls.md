# kafka-acls - Security & Authorization

The `kafka-acls` tool manages Access Control Lists to control who can access Kafka resources.

## Use Cases

- **Multi-tenant clusters**: Isolate different teams/applications
- **Production security**: Implement principle of least privilege
- **Compliance**: GDPR, audit trail requirements
- **Access control**: Granular permissions for topics, groups, clusters

> **Note:** ACLs require an Authorizer to be configured on the broker (e.g., `authorizer.class.name=kafka.security.authorizer.AclAuthorizer`). This workshop cluster runs without authorization enabled, so we'll cover the syntax and concepts without executing commands.

## Basic Syntax

```bash
kafka-acls --bootstrap-server <brokers> --add/--remove/--list [options]
```

**Resource Types:**
- `--topic` - Topic permissions
- `--group` - Consumer group permissions
- `--cluster` - Cluster-wide permissions

**Operations:**
- `Read`, `Write`, `Create`, `Delete`, `Describe`, `Alter`, `All`

## Check ACL Status

Verify if ACLs are enabled:

```terminal:execute
command: |
  kafka-acls --bootstrap-server $BOOTSTRAP --list
session: 1
```

> **Expected output:** `SecurityDisabledException: No Authorizer is configured on the broker` - This confirms ACLs are not enabled on this demo cluster.

## ACL Command Examples

Below are examples of common ACL operations. These require a properly configured Kafka cluster with authorization enabled.

### Grant Read Permission

Allow a user to read from a topic:

```bash
# Create topic first
kafka-topics --bootstrap-server $BOOTSTRAP \
  --create \
  --topic secure-topic \
  --partitions 3 \
  --replication-factor 2

# Grant read permission
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:alice \
  --operation Read \
  --topic secure-topic

# Verify ACL
kafka-acls --bootstrap-server $BOOTSTRAP \
  --list \
  --topic secure-topic
```

### Grant Write Permission

Allow a user to write to a topic:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:bob \
  --operation Write \
  --topic secure-topic
```

### Grant Multiple Operations

Grant read and write to one user:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:charlie \
  --operation Read \
  --operation Write \
  --topic secure-topic
```

### Consumer Group Permissions

Consumers need permissions for both topic and group:

```bash
# Topic read permission
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:alice \
  --operation Read \
  --topic secure-topic

# Consumer group permission
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:alice \
  --operation Read \
  --group secure-consumer-group
```

> **Consumer needs:** Read on topic + Read on consumer group

### Cluster-Level Permissions

Grant cluster-wide operations:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:admin \
  --operation Create \
  --operation Delete \
  --operation Alter \
  --cluster
```

### Wildcard Patterns

Use wildcards for multiple topics:

```bash
# Grant read access to all logs-* topics
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:monitoring \
  --operation Read \
  --topic logs- \
  --resource-pattern-type prefixed
```

### Deny Rules

Explicitly deny access:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --deny-principal User:blocked-user \
  --operation All \
  --topic secure-topic
```

> Deny rules take precedence over allow rules

### Remove ACLs

Delete specific ACL:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --remove \
  --allow-principal User:bob \
  --operation Write \
  --topic secure-topic \
  --force
```

## Real-World Scenarios

### Scenario 1: Multi-Tenant Setup

Separate teams with isolated topics:

```bash
# Team A producer access
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:team-a-producer \
  --operation Write \
  --topic team-a- \
  --resource-pattern-type prefixed

# Team A consumer access
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:team-a-consumer \
  --operation Read \
  --topic team-a- \
  --resource-pattern-type prefixed
```

### Scenario 2: Read-Only Access

Grant monitoring system read-only access:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:monitoring \
  --operation Read \
  --operation Describe \
  --topic "*" \
  --resource-pattern-type literal
```

### Scenario 3: Producer-Only Access

Application can only write, not read:

```bash
kafka-acls --bootstrap-server $BOOTSTRAP \
  --add \
  --allow-principal User:event-producer \
  --operation Write \
  --operation Describe \
  --topic events
```

## ACL Operations Reference

| Operation | Description | Typical Use |
|-----------|-------------|-------------|
| `Read` | Consume messages | Consumers |
| `Write` | Produce messages | Producers |
| `Create` | Create topics | Admin tools |
| `Delete` | Delete topics | Admin tools |
| `Describe` | View metadata | Monitoring |
| `Alter` | Change configuration | Admin operations |
| `All` | All operations | Full access |

## Enabling ACLs in Production

To enable ACLs on your Kafka cluster, configure these broker properties:

```properties
# Enable ACL Authorizer
authorizer.class.name=kafka.security.authorizer.AclAuthorizer

# Super users (bypass ACL checks)
super.users=User:admin;User:kafka

# Allow everyone if no ACL found (default: false)
allow.everyone.if.no.acl.found=false
```

Then restart brokers and configure authentication (SASL/SSL).

## Best Practices

### 1. Principle of Least Privilege

Grant only necessary permissions:
- **Producers**: Write + Describe
- **Consumers**: Read (topic + group)
- **Admins**: Create + Delete + Alter

### 2. Use Service Accounts

Create dedicated service accounts, not personal users:
```
User:app-payment-producer
User:app-payment-consumer
```

### 3. Use Prefixed Patterns

Group related topics:
```
team-a-*
logs-*
metrics-*
```

### 4. Document ACLs

Maintain documentation of who has access to what and why.

### 5. Regular Audits

Periodically review ACLs:
```bash
kafka-acls --list --bootstrap-server $BOOTSTRAP > acl-audit-$(date +%Y%m%d).txt
```

## Summary

You now understand:
- ✅ ACL command syntax and options
- ✅ How to grant read/write permissions
- ✅ Consumer group access requirements
- ✅ Wildcard patterns for multiple resources
- ✅ Deny rules and precedence
- ✅ Multi-tenant security patterns
- ✅ Principle of least privilege

> **Note:** ACL commands shown above require authorization to be enabled on the broker. In production, you'll also need authentication (SASL/SSL) configured.

## Next Steps

Next, we'll learn **kafka-leader-election** and **kafka-replica-verification** for replication management.
