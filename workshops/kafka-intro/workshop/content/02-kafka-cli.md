# Práca s Kafka CLI (topics, producer, consumer)

V tomto module:

1. vytvoríš Kafka topic pomocou `kafka-topics.sh`,
2. spustíš konzolového producenta (`kafka-console-producer.sh`),
3. spustíš konzolového konzumenta (`kafka-console-consumer.sh`),
4. vyskúšaš si posielanie a čítanie správ.

---

## 1. Vytvor Kafka topic

Uisti sa, že Kafka kontajner beží:

```bash
docker ps
```

Ak vidíš kontajner `kafka`, môžeš pokračovať.

Vytvoríme topic s názvom `demo-topic`:

```bash
docker exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh   --create   --topic demo-topic   --bootstrap-server localhost:9092   --partitions 1   --replication-factor 1
```

Over, že topic existuje:

```bash
docker exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh   --list   --bootstrap-server localhost:9092
```

V zozname by si mal vidieť `demo-topic`.

---

## 2. Spusti konzolového producenta (producer)

Spustíme interaktívneho producenta, ktorý bude čítať riadky z klávesnice a posielať ich do topicu:

```bash
docker exec -it kafka /opt/bitnami/kafka/bin/kafka-console-producer.sh   --topic demo-topic   --bootstrap-server localhost:9092
```

Po spustení sa objaví prázdny riadok. Teraz môžeš písať správy, napr.:

```text
ahoj kafka
druha sprava
tretia sprava z educates
```

Každý stlačený **Enter** odošle jednu správu na topic `demo-topic`.

> Z producenta sa dá odísť pomocou `Ctrl+C`.

---

## 3. Spusti konzolového konzumenta (consumer)

Otvor si **druhý terminál** (nový tab/panel v Terminal aplikácii), aby si mohol mať producenta aj konzumenta súčasne.

V druhom termináli spusti:

```bash
docker exec -it kafka /opt/bitnami/kafka/bin/kafka-console-consumer.sh   --topic demo-topic   --bootstrap-server localhost:9092   --from-beginning
```

Tento príkaz:

- sa pripojí k topicu `demo-topic`,
- prečíta všetky doterajšie správy (`--from-beginning`),
- bude zobrazovať aj nové správy, ktoré prídu.

Mal by si vidieť správy, ktoré si písal v producentovi, napr.:

```text
ahoj kafka
druha sprava
tretia sprava z educates
```

Nechaj konzumenta bežať a vráť sa do prvého terminálu k producentovi:

- napíš niekoľko ďalších riadkov,
- sleduj, ako sa okamžite zobrazia v okne konzumenta.

---

## 4. Upratovanie – vypnutie stacku

Keď máš hotovo, môžeš Kafka stack vypnúť:

```bash
docker compose down
```

Over, že kontajnery už nebežia:

```bash
docker ps
```

---

## 5. Čo si práve spravil

- vytvoril si Kafka topic `demo-topic`,
- cez konzolového producenta si posielal správy do topicu,
- cez konzolového konzumenta si tieto správy čítal,
- videl si, ako Kafka spracúva správy v reálnom čase.

Pokračuj na posledný modul: **„Zhrnutie a ďalšie kroky“**.
