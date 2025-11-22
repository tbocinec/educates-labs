---
title: Poslanie správ
---

# Poslanie správ do Kafka

Teraz si pošleme prvé správy do našich topicov a pozrieme si ich v Kafka UI.

## Krok 1: Poslanie jednoduchých správ

### Pomocou Kafka producer nástroja

Pošleme niekoľko testovacích správ do nášho topicu `workshop-messages`:

```bash
echo "Prvá správa z workshopu!" | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages
```

Pošleme viac správ naraz:

```bash
cat << 'EOF' | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages
Vitajte v Kafka workshope!
Toto je druhá správa
Apache Kafka je skvelý nástroj
Pre real-time processing
EOF
```

## Krok 2: Poslanie správ s kľúčom

Správy môžu mať kľúče, ktoré ovplyvňujú ich distribúciu do partícií:

```bash
cat << 'EOF' | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages \
  --property "parse.key=true" \
  --property "key.separator=:"
user1:Prvý užívateľ sa prihlásil
user2:Druhý užívateľ sa prihlásil
user1:Prvý užívateľ odoslal správu
system:Systémová správa
user2:Druhý užívateľ sa odhlásil
EOF
```

## Krok 3: Poslanie JSON správ

Pošleme štruktúrované JSON správy:

```bash
cat << 'EOF' | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic user-events
{"user_id": "123", "event": "login", "timestamp": "2024-01-15T10:00:00Z"}
{"user_id": "456", "event": "page_view", "page": "/products", "timestamp": "2024-01-15T10:01:00Z"}
{"user_id": "123", "event": "purchase", "product": "laptop", "amount": 999.99, "timestamp": "2024-01-15T10:05:00Z"}
{"user_id": "789", "event": "login", "timestamp": "2024-01-15T10:10:00Z"}
{"user_id": "456", "event": "logout", "timestamp": "2024-01-15T10:15:00Z"}
EOF
```

## Krok 4: Overenie správ v termináli

Môžeme si prečítať správy aj pomocou console consumer:

```bash
echo "Čítanie posledných správ z workshop-messages:"
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages \
  --from-beginning \
  --max-messages 10
```

Pre topic s JSON správami:

```bash
echo "Čítanie JSON správ z user-events:"
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic user-events \
  --from-beginning \
  --max-messages 10
```

## Krok 5: Kontinuálne posielanie správ

Vytvoríme script na kontinuálne posielanie správ:

```bash
# Spustime na pozadí generátor správ
(
  for i in {1..20}; do
    echo "Automatická správa #$i - $(date)"
    sleep 2
  done
) | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages &

echo "Generátor správ spustený na pozadí..."
```

## Krok 6: Simulácia real-time traffic

Vytvoríme simulátor užívateľských udalostí:

```bash
cat > generate_events.sh << 'EOF'
#!/bin/bash
users=("alice" "bob" "charlie" "diana" "eve")
events=("login" "logout" "page_view" "purchase" "search")

for i in {1..15}; do
  user=${users[$RANDOM % ${#users[@]}]}
  event=${events[$RANDOM % ${#events[@]}]}
  timestamp=$(date -Iseconds)
  
  echo "{\"user_id\": \"$user\", \"event\": \"$event\", \"timestamp\": \"$timestamp\", \"session_id\": \"$RANDOM\"}"
  sleep 1
done
EOF

chmod +x generate_events.sh

echo "Generovanie real-time udalostí..."
./generate_events.sh | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic user-events
```

## Krok 7: Štatistiky topicov

Pozrieme si základné štatistiky:

```bash
echo "Počet správ v workshop-messages:"
docker exec kafka kafka-log-dirs \
  --bootstrap-server localhost:9092 \
  --json | grep -o '"size":[0-9]*' | head -5

echo "Informácie o topicu workshop-messages:"
docker exec kafka kafka-topics --describe \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages
```

✅ **Úspešne sme poslali správy do Kafka!**

Teraz máme:
- ✉️ Textové správy v `workshop-messages`
- 🔑 Správy s kľúčmi
- 📋 JSON formátované správy v `user-events`
- 🤖 Automaticky generované správy

V ďalšom kroku si všetky tieto správy pozrieme v Kafka UI rozhrania.