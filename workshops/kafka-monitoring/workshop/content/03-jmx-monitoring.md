# JMX Monitoring with Prometheus

Kafka generuje stovky interných metrík cez JMX (Java Management Extensions), ale tie nie sú priamo dostupné pre Prometheus. V tejto lekcii sa naučíme, ako ich exportovať a analyzovať.

## Prečo potrebujeme JMX Exporter?

### Problém: Nekompatibilné formáty

- **Kafka** používa JMX (Java technológia) na publikovanie metrík
- **Prometheus** očakáva metriky v HTTP/text formáte
- Tieto dva systémy spolu priamo nekomunikujú

### Riešenie: JMX Exporter

**JMX Exporter** je most medzi Kafkou a Prometheusom:

```
Kafka (JMX:9101) → JMX Exporter (HTTP:7071) → Prometheus → Grafana
```

JMX Exporter:
- Pripája sa na Kafka JMX port (9101)
- Číta JMX MBeans (managed beans)
- Transformuje ich do Prometheus formátu
- Publikuje na HTTP endpoint (port 7071)

### Prečo samostatný kontajner?

Používame **Bitnami JMX Exporter** ako samostatný kontajner pretože:
- **Decoupling** - Nezávislý od Kafka procesu
- **Konfigurácia** - Centrálne pravidlá pre export metrík
- **Škálovateľnosť** - Môže monitorovať viacero JMX zdrojov
- **Reštart** - Reštart exportera neovplyvní Kafku

## Overenie JMX Exportera

Najprv skontrolujeme, že JMX Exporter beží a exportuje metriky:

```terminal:execute
command: |
  echo "=== Stav JMX Exporter kontajnera ==="
  docker ps | grep jmx-exporter
  echo ""
  echo "=== Prvých 30 riadkov metrík ==="
  curl -s http://localhost:7071/metrics | head -n 30
session: 1
```

Mal by si vidieť metriky v Prometheus formáte:
```
# HELP kafka_server_brokertopicmetrics_messagesinpersec_total Message in rate
# TYPE kafka_server_brokertopicmetrics_messagesinpersec_total counter
kafka_server_brokertopicmetrics_messagesinpersec_total{topic="monitoring-demo"} 1543.0
```

## Generovanie dát pre monitoring

Spustíme producera, ktorý bude generovať správy aby sme mali čo monitorovať:

```terminal:execute
command: |
  # Vytvor testovaciu tému
  kafka-topics --bootstrap-server localhost:9092 \
    --create --if-not-exists \
    --topic monitoring-demo \
    --partitions 3 \
    --replication-factor 1
  
  # Spusti producera na pozadí
  nohup ./generators/simple-producer.sh monitoring-demo > producer.log 2>&1 &
  
  echo "✅ Producer generuje správy do témy 'monitoring-demo'"
  echo "Metriky sa začnú aktualizovať..."
session: 2
```

Počkaj 10-15 sekúnd a overte že dáta prichádzajú:

```terminal:execute
command: |
  echo "=== Počet správ v téme ==="
  kafka-run-class kafka.tools.GetOffsetShell \
    --broker-list localhost:9092 \
    --topic monitoring-demo \
    --time -1 | awk -F: '{sum += $3} END {print "Total messages: " sum}'
session: 1
```

## Preskúmanie metrík v Prometheus

Otvor **Prometheus** tab a vyskúšaj tieto PromQL queries:

### 1. Message Rate (Správy za sekundu)

```
rate(kafka_server_brokertopicmetrics_messagesinpersec_total{topic="monitoring-demo"}[1m])
```

Klikni **Execute** a potom **Graph** - uvidíš grafické zobrazenie príchodu správ.

### 2. Throughput (Bajty za sekundu)

```
rate(kafka_server_brokertopicmetrics_bytesinpersec_total{topic="monitoring-demo"}[1m])
```

### 3. Heap Memory Utilization (Využitie pamäte)

```
jvm_memory_bytes_used{area="heap"} / jvm_memory_bytes_max{area="heap"} * 100
```

Toto ukazuje percentuálne využitie heap pamäte v JVM.

### 4. Garbage Collection Time

```
rate(jvm_gc_collection_seconds_total[5m]) * 1000
```

Milisekundy strávené v GC za sekundu (malo by byť nízke!).

## Kľúčové Kafka metriky z JMX

Pozrime sa na najdôležitejšie metriky priamo z terminálu:

### Broker Topic Metrics

```terminal:execute
command: |
  echo "=== Messages In Per Second (všetky témy) ==="
  curl -s http://localhost:7071/metrics | grep "kafka_server_brokertopicmetrics_messagesinpersec_total"
  echo ""
  echo "=== Bytes In Per Second ==="
  curl -s http://localhost:7071/metrics | grep "kafka_server_brokertopicmetrics_bytesinpersec_total"
session: 1
```

### Request Metrics

```terminal:execute
command: |
  echo "=== Produce Request Rate ==="
  curl -s http://localhost:7071/metrics | \
    grep 'kafka_network_requestmetrics_requestspersec_total{request="Produce"}'
  echo ""
  echo "=== Fetch Request Rate ==="
  curl -s http://localhost:7071/metrics | \
    grep 'kafka_network_requestmetrics_requestspersec_total{request="Fetch"}'
session: 1
```

### Replica Manager Metrics

```terminal:execute
command: |
  echo "=== Under-Replicated Partitions (malo by byť 0!) ==="
  curl -s http://localhost:7071/metrics | grep "kafka_server_replicamanager_underreplicatedpartitions"
  echo ""
  echo "=== Leader Count ==="
  curl -s http://localhost:7071/metrics | grep "kafka_server_replicamanager_leadercount"
session: 1
```

**Dôležité**: `underreplicatedpartitions` by mal byť vždy 0 v zdravom klastri!

## Vizualizácia v Grafane

Teraz sa pozrieme na **Grafana** dashboard, ktorý zobrazuje tieto metriky graficky:

1. Otvor **Grafana** tab (port 3000)
2. Klikni na **Dashboards** (ľavá strana)
3. Vyber **Kafka Dashboard**

Dashboard zobrazuje:
- 📊 **Brokers Online** - Počet bežiacich brokerov
- 📈 **Messages/sec** - Priepustnosť správ
- 💾 **Bytes In/Out** - Sieťový throughput
- 🎯 **Active Controllers** - Stav controller-a
- 📦 **Topics & Partitions** - Štatistiky

### Pozoruj metriky v reálnom čase

Nechaj dashboard otvorený a sleduj ako sa menia hodnoty. Vidíš:
- Zelené čísla indikujú normálny stav
- Grafy ukazujú trendy v čase
- Labels umožňujú filter podľa témy

## Generovanie burst trafficu

Vyskúšajme vyššiu záťaž:

```terminal:execute
command: |
  # Zastav normálny producer
  pkill -f simple-producer.sh
  
  # Spusti burst producer (vyššia záťaž)
  nohup ./generators/burst-producer.sh monitoring-demo > burst-producer.log 2>&1 &
  
  echo "🔥 Burst producer spustený!"
  echo "Pozri sa teraz do Grafany a sleduj zmeny v grafoch"
  echo "Metriky by mali dramaticky stúpnuť"
session: 2
```

**V Grafane sleduj:**
- Messages/sec graf - mal by prudko stúpnuť
- Bytes In - zvýšený throughput
- JVM Heap - môže mierne vzrásť

## Ako funguje JMX Exporter konfigurácia

Pozrime sa na konfiguráciu exportera:

```terminal:execute
command: cat prometheus/jmx-exporter/kafka-broker.yml | head -n 40
session: 1
```

Kľúčové časti konfigurácie:

**1. Pripojenie na Kafka JMX:**
```yaml
hostPort: kafka:9101
lowercaseOutputName: true
```

**2. Pravidlá pre transformáciu metrík:**
```yaml
- pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
  name: kafka_$1_$2_$3_total
  type: COUNTER
```

Toto pravidlo:
- **Zachytí** JMX metriky končiace na `PerSec`
- **Transformuje** ich na Prometheus formát s `_total` suffixom
- **Označí** ako `COUNTER` typ (kumulatívna hodnota)

## Typy metrík v Prometheus

### Counter (Počítadlo)
- Vždy len rastie
- Príklad: `kafka_server_brokertopicmetrics_messagesinpersec_total`
- **Použitie**: Použi `rate()` funkciu pre per-second hodnoty

### Gauge (Merač)
- Môže stúpať aj klesať
- Príklad: `jvm_memory_bytes_used`
- **Použitie**: Priame hodnoty alebo `avg_over_time()`

### Histogram/Summary
- Distribúcia hodnôt s percentilami
- Príklad: Request latencies (p50, p95, p99)

## Prometheus Query API

Metriky môžeš dotazovať aj programaticky:

```terminal:execute
command: |
  curl -s 'http://localhost:9090/api/v1/query?query=rate(kafka_server_brokertopicmetrics_messagesinpersec_total[1m])' | \
    python3 -m json.tool | head -n 30
session: 1
```

Toto je užitočné pre:
- Vlastné monitoring skripty
- Integráciu s inými systémami
- Automatizované alerty

## Best Practices

### 1. Filtruj metriky
Neexportuj všetky JMX metriky - má to vplyv na výkon:
```yaml
# Exportuj len potrebné patterns
- pattern: kafka.server.*
- pattern: kafka.network.*
```

### 2. Používaj rate() pre counters
```promql
# ❌ Zlé - zobrazí kumulatívnu hodnotu
kafka_server_brokertopicmetrics_messagesinpersec_total

# ✅ Správne - zobrazí rate
rate(kafka_server_brokertopicmetrics_messagesinpersec_total[1m])
```

### 3. Nastav baseline
Poznaj normálne hodnoty pre tvoje prostredie:
- Typický message rate
- Normálne heap usage
- Priemerná latencia

### 4. Kombinuj s CLI nástrojmi
JMX metriky + CLI nástroje = kompletný obraz

## Monitoring Checklist

Pri monitoringu Kafky sleduj:

| Metrika | Normálna hodnota | Alert threshold |
|---------|------------------|-----------------|
| Under-replicated partitions | 0 | > 0 |
| Heap usage | < 70% | > 85% |
| GC time | < 50ms/sec | > 200ms/sec |
| Request queue size | < 50 | > 100 |
| Network processor idle | > 50% | < 20% |

## Úlohy na precvičenie

1. **V Prometheus** vytvor query, ktorý zobrazí priemerné bytes/message
2. **V Grafane** nájdi panel s JVM Garbage Collection a pozoruj ho počas burst trafficu
3. **V terminále** nájdi metriku, ktorá ukazuje offline partitions (malo by byť 0)

## Reštartovanie producer-a na normálnu záťaž

```terminal:execute
command: |
  pkill -f burst-producer.sh
  nohup ./generators/simple-producer.sh monitoring-demo > producer.log 2>&1 &
  echo "✅ Vrátili sme sa na normálnu záťaž"
session: 2
```

Sleduj v Grafane, ako sa metriky vrátia na normálne hodnoty.

## Zhrnutie

JMX monitoring ti poskytuje:
- ✅ **Detailné insights** - Stovky broker metrík
- ✅ **Historické dáta** - Prometheus ukladá time-series
- ✅ **Vizualizáciu** - Grafana dashboardy
- ✅ **Štandardizáciu** - Prometheus formát je industry standard

**Kľúčové poznatky:**
- JMX Exporter je nevyhnutný most medzi Kafka a Prometheus
- Metriky je potrebné transformovať pomocou pattern rules
- Grafana zobrazuje metriky v prehľadných dashboardoch
- Generovanie trafficu je potrebné pre zmysluplné hodnoty

Ďalej sa pozrieme na Kafka Exporter pre detailné consumer group monitoring!

