---
title: Security & ACLs
---

# 🎯 Kafka Security & ACLs

V tejto lekcii sa naučíš používať `kafka-acls.sh` - nástroj na správu Access Control Lists (oprávnení).

## Čo sú Kafka ACLs?

ACLs (Access Control Lists) kontrolujú:
- ✅ Kto môže čítať z tém
- ✅ Kto môže písať do tém
- ✅ Kto môže vytvárať témy
- ✅ Kto môže meniť konfiguráciu
- ✅ Consumer group permissions

**Kedy použiť:**
- Multi-tenant Kafka cluster
- Production security
- GDPR compliance
- Audit trail
- Principle of least privilege

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-acls.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--list` - Zoznam všetkých ACLs
- `--add` - Pridať ACL
- `--remove` - Odstrániť ACL
- `--allow-principal` / `--deny-principal` - User/principal
- `--operation` - Operácia (Read, Write, Create, etc.)
- `--topic` / `--group` / `--cluster` - Resource type

---

## ⚠️ Security Note

**Dôležité:** Náš demo klaster **nemá security enabled** (bez authentication)!

V produkcii by si potreboval:
- **SASL/SSL** authentication
- **authorizer.class.name** v broker config
- **Principal mapping**

Pre tento workshop simulujeme ACL operácie - v produkcii by fungovali rovnako, len s reálnymi usermi.

---

## 1️⃣ List All ACLs

Zoznam všetkých ACLs v klastri:

```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list
```

Output (ak žiadne ACLs):
```
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL)`:
(empty)
```

💡 **Empty = žiadne ACLs nastavené (open access)**

---

## 2️⃣ Grant Read Permission

Vytvoríme ACL pre čítanie z témy:

**Vytvoríme tému pre ACL demo:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic secure-topic --partitions 3 --replication-factor 2 --if-not-exists
```

**Grant read permission pre user "alice":**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:alice \
    --operation Read \
    --topic secure-topic
```

**Verify ACL:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic secure-topic
```

Output:
```
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=secure-topic, patternType=LITERAL)`:
  (principal=User:alice, host=*, operation=READ, permissionType=ALLOW)
```

---

## 3️⃣ Grant Write Permission

Povolíme write (producer):

**Grant write permission pre user "bob":**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:bob \
    --operation Write \
    --topic secure-topic
```

**List ACLs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic secure-topic
```

Teraz vidíme **2 ACLs**:
- alice → READ
- bob → WRITE

---

## 4️⃣ Grant Multiple Operations

Môžeme grant viacero operácií naraz:

**Grant Read + Write pre user "charlie":**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:charlie \
    --operation Read \
    --operation Write \
    --topic secure-topic
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic secure-topic
```

---

## 5️⃣ Consumer Group ACLs

Consumer groups potrebujú špeciálne permissions:

**Vytvoríme ACL pre consumer group:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:alice \
    --operation Read \
    --group secure-consumer-group
```

**List group ACLs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --group secure-consumer-group
```

💡 **Consumer potrebuje:**
- READ na topic
- READ na consumer group

---

## 6️⃣ Cluster-Level ACLs

Admin operácie vyžadujú cluster permissions:

**Grant CreateTopics permission:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:admin \
    --operation Create \
    --cluster
```

**Grant AlterConfigs permission:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:admin \
    --operation AlterConfigs \
    --cluster
```

**List cluster ACLs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --cluster
```

---

## 7️⃣ Wildcard ACLs

Môžeme použiť wildcard pre všetky témy:

**Grant read pre všetky témy začínajúce na "logs-":**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:log-reader \
    --operation Read \
    --topic logs- \
    --resource-pattern-type prefixed
```

**Grant write pre ALL témy (dangerous!):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:superuser \
    --operation Write \
    --topic '*'
```

**List wildcard ACLs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic '*'
```

⚠️ **Pozor:** Wildcard ACLs môžu byť security risk!

---

## 8️⃣ Deny ACLs

Môžeme explicitne deny operations:

**Deny delete pre všetkých users:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --deny-principal User:* \
    --operation Delete \
    --topic secure-topic
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic secure-topic
```

Output:
```
permissionType=DENY (explicitly blocked)
```

💡 **DENY má prioritu nad ALLOW!**

---

## 9️⃣ Remove ACLs

Vymazanie ACL:

**Remove specific ACL:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --remove \
    --allow-principal User:bob \
    --operation Write \
    --topic secure-topic \
    --force
```

**Verify removal:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic secure-topic
```

**Remove ALL ACLs pre tému:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --remove \
    --topic secure-topic \
    --force
```

---

## 🔟 ACL Operations Reference

Všetky možné operácie:

| Operation | Popis | Use Case |
|-----------|-------|----------|
| **Read** | Čítanie z topic/group | Consumer |
| **Write** | Písanie do topic | Producer |
| **Create** | Vytváranie tém | Admin, auto-create |
| **Delete** | Mazanie tém | Admin |
| **Alter** | Zmena topic configs | Admin |
| **Describe** | Describe topics/groups | Monitoring |
| **ClusterAction** | Cluster-level operations | Admin |
| **AlterConfigs** | Zmena broker configs | Admin |
| **DescribeConfigs** | Read configs | Monitoring |
| **IdempotentWrite** | Idempotent producer | Reliable producer |
| **All** | Všetky operácie | Superuser |

---

## 🎯 Use Cases

### 1. Multi-Tenant Setup
**Scenario**: Každý team má vlastné témy:

**Team A môže len svoje témy:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --create --topic team-a-events --partitions 3 --replication-factor 2 --if-not-exists
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:team-a \
    --operation Read \
    --operation Write \
    --topic team-a-events
```

**Team B nemôže čítať team-a témy:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --deny-principal User:team-b \
    --operation Read \
    --topic team-a-events
```

### 2. Read-Only Access
**Scenario**: Monitoring tool potrebuje len read:
```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:prometheus \
    --operation Describe \
    --cluster
```

### 3. Producer-Only Access
**Scenario**: Logger application len píše, nečíta:
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --create --topic application-logs --partitions 6 --replication-factor 2 --if-not-exists
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:log-app \
    --operation Write \
    --topic application-logs
```

### 4. GDPR Compliance
**Scenario**: Audit kto má access k PII data:
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --create --topic user-pii --partitions 3 --replication-factor 3 --if-not-exists
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --add \
    --allow-principal User:gdpr-processor \
    --operation Read \
    --operation Write \
    --topic user-pii
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-acls.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list \
    --topic user-pii
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Poznámka:** Kafka UI v našom demo nemá ACL support (needs authentication enabled).

V produkcii by si videl:
- Topics → ACLs tab
- Users a ich permissions
- Denied operations v audit log

---

## ⚠️ Common Errors

### 1. "Authorization failed"
```
ERROR Not authorized to access topic 'xyz'
```
**Riešenie:**
- Over ACLs: `kafka-acls.sh --list --topic xyz`
- Grant potrebné permissions

### 2. "Authorizer not configured"
```
ERROR No Authorizer is configured on the broker
```
**Riešenie:**
- Broker config musí obsahovať:
```properties
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
```

### 3. "Principal format incorrect"
```
ERROR Invalid principal format
```
**Riešenie:**
- Musí byť: `User:username` alebo `User:CN=...` (SSL)
- Nie: `username` (bez prefix)

### 4. "DENY overrides ALLOW"
```
Operation denied even though ALLOW exists
```
**Riešenie:**
- DENY má vyššiu prioritu
- Skontroluj `--deny-principal` ACLs

---

## 🎓 Best Practices

✅ **DO:**
- Používaj **principle of least privilege** (len potrebné permissions)
- Dokumentuj ACLs (kto má prístup a prečo)
- Používaj **prefixed patterns** pre topic families
- Pravidelne audit ACLs (`--list`)
- Používaj DENY pre kritické operácie (napr. Delete)

❌ **DON'T:**
- Nepoužívaj wildcard `User:*` ALLOW (security risk)
- Nedelete ACLs bez verifikácie (môže zlomiť aplikácie)
- Nezabudni na consumer group permissions (Read na topic + group)
- Nepoužívaj hardcoded principals v scriptoch (use variables)

---

## 📊 ACL Matrix Example

| User | Topic | Read | Write | Create | Delete |
|------|-------|------|-------|--------|--------|
| **alice** | secure-topic | ✅ | ❌ | ❌ | ❌ |
| **bob** | secure-topic | ❌ | ✅ | ❌ | ❌ |
| **charlie** | secure-topic | ✅ | ✅ | ❌ | ❌ |
| **admin** | * | ✅ | ✅ | ✅ | ✅ |
| **monitoring** | * | ✅ | ❌ | ❌ | ❌ |

---

## 🎯 Summary

Naučili sme sa:
- ✅ List ACLs pomocou `--list`
- ✅ Grant permissions (`--add --allow-principal`)
- ✅ Deny operations (`--add --deny-principal`)
- ✅ Topic, group a cluster ACLs
- ✅ Wildcard patterns
- ✅ Remove ACLs
- ✅ ACL operations reference (Read, Write, Create, etc.)
- ✅ Real-world use cases (multi-tenant, GDPR, read-only access)

**Next Level:** Naučíme sa replication management pomocou `kafka-leader-election.sh` a `kafka-replica-verification.sh`! 🚀
