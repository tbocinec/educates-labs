---
title: Vytvorenie topicu
---

# Vytvorenie topicu

Topic v Kafka je kanál, do ktorého sa posielajú správy. V tomto kroku si vytvoríme náš prvý topic.

## Čo je Topic?

Topic je kategória alebo meno kanála, do ktorého sa publikujú správy. Produceri zapisujú údaje do topicov a consumeri čítajú z topicov.

## Krok 1: Vytvorenie topicu cez Kafka UI

### Pomocou webového rozhrania:

1. **Otvorte Kafka UI** (http://localhost:8080 alebo tab "Kafka UI Dashboard")
2. **Vyberte cluster "local"**
3. **Kliknite na "Topics"** v ľavom menu
4. **Kliknite na tlačidlo "Create Topic"**
5. **Vyplňte formulár:**
   - **Topic Name:** `workshop-messages`
   - **Number of partitions:** `3`
   - **Replication factor:** `1`
   - **Cleanup policy:** `delete`
6. **Kliknite "Create"**

## Krok 2: Vytvorenie topicu cez príkazový riadok

Alternatívne môžeme vytvoriť topic pomocou príkazového riadku:

```bash
docker exec kafka kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic workshop-messages
```

## Krok 3: Overenie vytvorenia topicu

Skontrolujme, že sa topic úspešne vytvoril:

```bash
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

Alebo pomocou API:

```bash
curl -s http://localhost:8080/api/clusters/local/topics | jq '.[] | .name'
```

## Krok 4: Zobrazenie detailov topicu

Pozrieme si detaily nášho topicu:

```bash
docker exec kafka kafka-topics --describe \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages
```

## Krok 5: Preskúmanie v Kafka UI

V Kafka UI:
1. **Kliknite na náš topic "workshop-messages"**
2. **Pozrite si záložky:**
   - **Overview** - Základné informácie
   - **Messages** - Správy v topicu (zatiaľ prázdny)
   - **Consumers** - Pripojené consumery
   - **Settings** - Nastavenia topicu

## Vytvorenie ďalšieho topicu pre experimenty

Vytvoríme ešte jeden topic pre ďalšie experimenty:

```bash
docker exec kafka kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 1 \
  --topic user-events
```

## Overenie všetkých topicov

Zobraziť všetky dostupné topicy:

```bash
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

✅ **Úspešne sme vytvorili topicy!**

Teraz máme:
- `workshop-messages` - hlavný topic pre workshop
- `user-events` - dodatočný topic pre experimenty

V ďalšom kroku si pošleme prvé správy do našich topicov.