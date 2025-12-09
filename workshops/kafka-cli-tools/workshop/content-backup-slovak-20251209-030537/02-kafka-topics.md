# kafka-topics - Správa tém

`kafka-topics` je **najpoužívanejší** CLI nástroj pre manažment Kafka tém.

## Základná syntax

```bash
kafka-topics --bootstrap-server <brokers> <akcia> [parametre]
```

**Akcie:**
- `--create` - Vytvorenie novej témy
- `--list` - Zoznam všetkých tém
- `--describe` - Detailné info o téme
- `--alter` - Úprava témy
- `--delete` - Zmazanie témy

## Listing tém

Začneme jednoduchým - zoznam existujúcich tém:

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --list
session: 1
```

Zatiaľ vidíš len interné témy (začínajú `__`):
- `__consumer_offsets` - Ukladá consumer offsets
- `__cluster_metadata` - KRaft metadata (namiesto ZooKeeper)

## Vytvorenie témy - Základy

### Jednoduchá téma (1 partícia, RF=1)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic my-first-topic \
    --partitions 1 \
    --replication-factor 1
session: 1
```

**Parametre:**
- `--topic` - Názov témy
- `--partitions` - Počet partícií
- `--replication-factor` - Koľko kópií (replík)

### Skontroluj vytvorenie

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --list
session: 1
```

Teraz vidíš `my-first-topic`!

## Describe témy

Zobraz detailné informácie:

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic my-first-topic
session: 1
```

**Výstup obsahuje:**
- **PartitionCount** - Počet partícií
- **ReplicationFactor** - Koľko replík
- **Leader** - Ktorý broker je leader pre partíciu
- **Replicas** - Na ktorých brokeroch sú repliky
- **Isr** - In-Sync Replicas (synchronizované)

## Vytvorenie produkčnej témy

V produkcii chceš **viac partícií** a **replication factor > 1**:

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic orders \
    --partitions 6 \
    --replication-factor 3
session: 1
```

**Prečo RF=3?**
- Každá správa má 3 kópie
- Cluster prežije výpadok 2 brokerov
- Vysoká dostupnosť (HA)

### Describe orders témy

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic orders
session: 1
```

Vidíš:
- **6 partícií** (Partition 0-5)
- Každá partícia má **3 repliky**
- **Leaderi sú rozložení** medzi brokermi (load balancing)
- **ISR** obsahuje všetkých 3 brokerov (všetko synchronizované)

## Partície - Use Cases

### Príklad: Single partition (sériové spracovanie)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic logs-sequential \
    --partitions 1 \
    --replication-factor 2
session: 1
```

**Kedy použiť 1 partíciu?**
- ✅ Potrebuješ presné poradie správ
- ✅ Nízky throughput
- ❌ Nemôžeš škálovať consumery (len 1 consumer v groupe)

### Príklad: High throughput (paralelizácia)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic events-high-volume \
    --partitions 12 \
    --replication-factor 3
session: 1
```

**Kedy použiť viac partícií?**
- ✅ Vysoký throughput (viac consumersov)
- ✅ Paralelizácia spracovania
- ✅ Load balancing medzi brokermi
- ⚠️ Stráca sa globálne poradie (len per-partition)

## Konfigurácia témy

Môžeš nastaviť topic-špecifické konfigurácie pomocou `--config`:

### Retention (doba uchovávania)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic short-retention \
    --partitions 3 \
    --replication-factor 2 \
    --config retention.ms=3600000
session: 1
```

`retention.ms=3600000` = 1 hodina (3600 sekúnd * 1000)

### Compression

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic compressed-topic \
    --partitions 4 \
    --replication-factor 3 \
    --config compression.type=gzip
session: 1
```

Podporované: `gzip`, `snappy`, `lz4`, `zstd`

### Min In-Sync Replicas

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic critical-data \
    --partitions 3 \
    --replication-factor 3 \
    --config min.insync.replicas=2
session: 1
```

**Producer musí dostať ACK od minimálne 2 replík** inak zlyháva.

Zaručuje vysokú konzistentnosť!

### Max message size

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic large-messages \
    --partitions 2 \
    --replication-factor 2 \
    --config max.message.bytes=5242880
session: 1
```

`5242880` = 5 MB (default je 1 MB)

## Describe s detailmi

Zobraz konfiguráciu témy:

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic critical-data
session: 1
```

Vidíš `min.insync.replicas=2` v konfigurácii.

## Zoznam všetkých tém

```terminal:execute
command: |
  echo "=== Všetky témy v klastri ===" 
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --list | grep -v "^__"
session: 1
```

Vyfiltrovali sme interné témy (`__`).

## Describe všetkých tém naraz

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe
session: 1
```

Zobrazí detaily **všetkých** tém (môže byť dlhý výstup).

## Alter témy (úprava)

Môžeš zmeniť **počet partícií** (iba zvýšiť, nie znížiť!):

### Zvýšenie partícií

```terminal:execute
command: |
  echo "Pôvodný počet partícií:"
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic my-first-topic | grep PartitionCount
  
  echo ""
  echo "Zvýšime na 3 partície:"
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --alter \
    --topic my-first-topic \
    --partitions 3
  
  echo ""
  echo "Nový počet partícií:"
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic my-first-topic | grep PartitionCount
session: 1
```

**Dôležité:**
- ✅ Zvýšenie partícií - OK
- ❌ Zníženie partícií - NEJDE
- ⚠️ Ovplyvní key-based partitioning (existujúce keys môžu ísť do iných partícií)

### Zmena konfigurácie (kafka-configs)

Pre zmenu konfigurácie použijeme `kafka-configs` (naučíme sa v Level 8):

```terminal:execute
command: |
  docker exec kafka-1 kafka-configs \
    --bootstrap-server kafka-1:19092 \
    --alter \
    --entity-type topics \
    --entity-name short-retention \
    --add-config retention.ms=7200000
session: 1
```

Zmenili sme retention z 1h na 2h.

## Mazanie tém

### Ostražitosť s mazaním!

Mazanie je **permanentné** - všetky dáta sa stratia!

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --delete \
    --topic my-first-topic
session: 1
```

### Overenie zmazania

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --list | grep my-first-topic || echo "Téma my-first-topic bola zmazaná"
session: 1
```

## Časté use cases

### Use case 1: Kópia témy s inou konfiguráciou

```terminal:execute
command: |
  # Získaj konfiguráciu existujúcej témy
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --describe \
    --topic orders
  
  # Vytvor novú tému s rovnakou konfiguráciou
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic orders-backup \
    --partitions 6 \
    --replication-factor 3 \
    --config retention.ms=604800000
session: 1
```

### Use case 2: Téma pre testing (rýchle mazanie)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic test-tmp \
    --partitions 1 \
    --replication-factor 1 \
    --config retention.ms=60000 \
    --config segment.ms=60000
session: 1
```

Retention 1 minúta = dáta sa zmažú po minúte.

### Use case 3: Dead Letter Queue (DLQ)

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic orders-dlq \
    --partitions 3 \
    --replication-factor 3 \
    --config retention.ms=2592000000
session: 1
```

DLQ téma pre chybné správy (retention 30 dní).

## Názvoslovie tém - Best Practices

### ✅ Dobré mená

```
orders
user-events
payment-transactions
inventory-updates
logs-application-prod
```

### ❌ Zlé mená

```
test
tmp
my_topic_123
UPPERCASE
topic-with-very-long-name-that-is-hard-to-remember
```

**Odporúčania:**
- Lowercase
- Oddel slovami pomocou `-` (nie `_`)
- Popisné meno (nie skratky)
- Environment suffix (`-prod`, `-staging`)

## Validácia témy

Skontroluj či téma existuje:

```terminal:execute
command: |
  TOPIC="orders"
  if docker exec kafka-1 kafka-topics --bootstrap-server kafka-1:19092 --list | grep -q "^${TOPIC}$"; then
    echo "✅ Téma '${TOPIC}' existuje"
  else
    echo "❌ Téma '${TOPIC}' neexistuje"
  fi
session: 1
```

## Vizualizácia v Kafka UI

Otvor **Kafka UI** (port 8080) a:
1. Klikni na **Topics**
2. Uvidíš všetky vytvorené témy
3. Klikni na `orders` - vidíš partície, repliky, konfiguráciu

CLI príkazy sa okamžite prejavia v UI!

## Časté chyby

### Chyba: Replication factor vyšší ako počet brokerov

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic invalid-rf \
    --partitions 3 \
    --replication-factor 5 || echo "❌ Chyba: RF=5, ale máme len 3 brokery!"
session: 1
```

**Riešenie:** RF nesmie byť vyšší ako počet brokerov.

### Chyba: Téma už existuje

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic orders \
    --partitions 3 \
    --replication-factor 2 || echo "❌ Chyba: Téma už existuje!"
session: 1
```

**Riešenie:** Použi `--if-not-exists`:

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --create \
    --topic orders \
    --partitions 3 \
    --replication-factor 2 \
    --if-not-exists
  echo "✅ Príkaz uspel (téma už existovala)"
session: 1
```

### Chyba: Zníženie partícií

```terminal:execute
command: |
  docker exec kafka-1 kafka-topics \
    --bootstrap-server kafka-1:19092 \
    --alter \
    --topic orders \
    --partitions 3 || echo "❌ Chyba: Nemôžeš znížiť počet partícií!"
session: 1
```

## Zhrnutie

Naučili sme sa:

- ✅ `--list` - Zoznam tém
- ✅ `--create` - Vytvorenie témy s rôznymi parametrami
- ✅ `--describe` - Detailné informácie
- ✅ `--alter` - Úprava partícií
- ✅ `--delete` - Mazanie tém
- ✅ Topic configs (retention, compression, min.insync.replicas)
- ✅ Best practices pre názvy tém
- ✅ Časté chyby a riešenia

## Ďalej

V ďalšej lekcii použijeme **kafka-console-producer** na posielanie správ do týchto tém! 📤
