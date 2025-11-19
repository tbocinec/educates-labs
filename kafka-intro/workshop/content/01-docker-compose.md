# Spustenie Kafka cez Docker Compose

V tomto module:

1. Overíme, že Docker v session funguje.
2. Vytvoríme súbor `docker-compose.yml` pomocou Editoru.
3. Spustíme Zookeeper + Kafka kontajnery pomocou `docker compose`.

---

## 1. Over, že Docker beží

Otvori si panel **Terminal** (vpravo alebo dole, podľa šablóny) a spusti:

```bash
docker version
```

Ak vidíš informácie o klientovi a serveri, Docker beží.

Pre istotu skús ešte:

```bash
docker ps
```

Ak je tabuľka prázdna (žiadne kontajnery), je to v poriadku – ešte sme nič nespustili.

---

## 2. Vytvor `docker-compose.yml` v Editore

Prepnúť sa do panelu **Editor**:

1. V ľavom strome vytvor nový súbor v home adresári (typicky `/home/educates`):  
   **Názov súboru:** `docker-compose.yml`
2. Do nového súboru vlož nasledujúci obsah:

```yaml
version: "3.8"

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.7.1
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "127.0.0.1:2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.7.1
    container_name: kafka
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    ports:
      - "127.0.0.1:9092:9092"
```

Krátke vysvetlenie:

- **zookeeper** – jednoduchý Zookeeper server pre Kafka.
- **kafka** – samotný Kafka broker.
- Porty mapujeme na `127.0.0.1`, aby boli dostupné z prostredia workshopu.

Nezabudni súbor uložiť (`Ctrl+S`).

---

## 3. Spusti Kafka stack

Vráť sa do panelu **Terminal**. Uisti sa, že si v adresári, kde je `docker-compose.yml` (napríklad):

```bash
pwd
ls
```

A potom spusti:

```bash
docker compose up -d
```

Tým sa na pozadí spustí Zookeeper aj Kafka.

Skontroluj bežiace kontajnery:

```bash
docker ps
```

Mali by sa zobraziť minimálne dva kontajnery:

- `zookeeper`
- `kafka`

Ak Kafka ešte štartuje, chvíľu počkaj a spusti `docker ps` znova.

---

## 4. Kontrola logov (nepovinné, ale užitočné)

Ak chceš, môžeš sa pozrieť do logov Kafka kontajnera:

```bash
docker logs kafka --tail=50
```

Mali by si vidieť informácie o štarte brokera, prípadne listeneroch.

Keď máš broker bežiaci, pokračuj na ďalší modul: **„Práca s Kafka CLI (topics, producer, consumer)”**.
