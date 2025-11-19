---
title: Preskúmanie Kafka UI
---

# Preskúmanie Kafka UI

Teraz si podrobne pozrieme Kafka UI a všetky správy, ktoré sme poslali.

## Krok 1: Otvorenie Kafka UI

**Otvorte Kafka UI** v browseri:
- 🔗 http://localhost:8080
- 📋 Alebo kliknite na tab **"Kafka UI Dashboard"** v Educates

## Krok 2: Preskúmanie topicov

### Základný prehľad
1. **Kliknite na "Topics"** v ľavom menu
2. **Pozrite si zoznam topicov:**
   - `workshop-messages`
   - `user-events`
   - Systémové topicy (začínajúce s `__`)

### Detaily topicu workshop-messages
1. **Kliknite na topic "workshop-messages"**
2. **Pozrite si záložky:**

#### 📊 Overview
- **Partitions:** 3
- **Messages:** počet správ
- **Size:** veľkosť dát
- **Consumers:** aktívne consumery

#### 💬 Messages
- **Zobraziť všetky správy** - kliknite "Live mode OFF" a potom "Load Messages"
- **Filtrovanie správ** - môžete filtrovať podľa offsetu, kľúča, hodnoty
- **Formátovanie** - JSON, AVRO, Plain text

## Krok 3: Analýza správ

### V záložke Messages:

1. **Nastavte parametre:**
   - **Offset:** `Earliest`
   - **Limit:** `50`
   - **Filter:** necháme prázdne

2. **Kliknite "Submit"**

3. **Preskúmajte správy:**
   - 📝 **Content** - obsah správy
   - 🔑 **Key** - kľúč správy (ak je)
   - 📍 **Partition** - číslo partície
   - 📊 **Offset** - pozícia správy
   - ⏰ **Timestamp** - čas vytvorenia

### Preskúmanie JSON správ v user-events

1. **Prejdite na topic "user-events"**
2. **V záložke Messages:**
   - Kliknite **"Submit"** pre načítanie správ
   - **JSON formát** - Kafka UI automaticky rozpozná a formátuje JSON
   - **Rozbaľte JSON** - kliknite na správu pre detail

## Krok 4: Monitoring v reálnom čase

### Live Mode
1. **V záložke Messages**
2. **Prepnite "Live mode ON"**
3. **Pošlite novú správu v termináli:**

```bash
echo "Live správa - $(date)" | docker exec -i kafka kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages
```

4. **Pozorujte** ako sa správa okamžite zobrazí v UI

## Krok 5: Preskúmanie Brokers

1. **Kliknite na "Brokers"** v ľavom menu
2. **Pozrite si informácie o broker-ovi:**
   - **ID:** 1
   - **Host:** kafka:29092
   - **Topics:** zoznam topicov na tomto brokeri
   - **Role:** broker,controller (KRaft mód)

## Krok 6: Consumers a Consumer Groups

### Vytvorenie consumer group

Vytvoríme consumer group v termináli:

```bash
# Spustíme consumer na pozadí
docker exec -d kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic workshop-messages \
  --group workshop-consumers \
  --from-beginning
```

### Pozretie consumer groups v UI

1. **Kliknite na "Consumers"** v ľavom menu
2. **Nájdite "workshop-consumers" group**
3. **Kliknite na ňu pre detail:**
   - **Members:** členovia group
   - **Topic assignments:** priradené partície
   - **Lag:** oneskorenie spracovávania

## Krok 7: Advanced funkcie

### Schema Registry (ak je dostupné)
- Správa schém pre AVRO/JSON správy
- Validácia formátu správ

### Topic Configuration
1. **V topic detail**
2. **Záložka "Settings"**
3. **Pozrite konfiguráciu:**
   - `cleanup.policy`
   - `retention.ms`
   - `segment.ms`

### Kafka Connect (ak je dostupné)
- Integrácia s externými systémami
- Connectors pre databázy, súborové systémy, atď.

## Krok 8: Praktické úlohy

### Úloha 1: Nájdenie konkrétnej správy
1. V topic `user-events` nájdite správu s `event: "purchase"`
2. Použite filter v Messages záložke

### Úloha 2: Analýza distribúcie
1. V topic `workshop-messages` pozrite rozdelenie správ do partícií
2. Všimnite si ako správy s rovnakým kľúčom idú do tej istej partície

### Úloha 3: Monitoring lag
1. Vytvorte pomalý consumer
2. Sledujte ako rastie lag v Consumers záložke

## Krok 9: Export a údržba

### Export správ
Kafka UI umožňuje exportovať správy do rôznych formátov (JSON, CSV).

### Mazanie topicov
**Pozor:** Buďte opatrní s mazaním v produkcii!

## Tipý a triky

💡 **Užitočné funkcie:**
- **Search** - vyhľadávanie v správach
- **Filters** - filtrovanie podľa rôznych kritérií  
- **Pagination** - navigácia cez veľké množstvo správ
- **Time range** - filtrovanie podľa času
- **Partition view** - zobrazenie správ z konkrétnej partície

✅ **Vynikajúco! Teraz ovládate Kafka UI!**

Naučili ste sa:
- 👀 Zobrazovať správy v real-time
- 🔍 Filtrovať a vyhľadávať správy  
- 📊 Monitorovať broker a consumer groups
- ⚙️ Spravovať konfiguráciu topicov
- 📈 Sledovať metriky a výkonnosť