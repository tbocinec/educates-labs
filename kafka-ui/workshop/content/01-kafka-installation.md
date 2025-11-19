---
title: Inštalácia Apache Kafka
---

# Inštalácia Apache Kafka

V tomto kroku si spustíme Apache Kafka pomocou pripravej Docker Compose konfigurácie s moderným **KRaft módom**, ktorý už nepotrebuje Zookeeper.

## Krok 1: Overenie Docker Compose súboru

V koreňovom adresári projektu už máte pripravený `docker-compose.yml` súbor. Pozrime si jeho obsah:

```bash
cat docker-compose.yml
```

Ak súbor neexistuje, môžete sa uistiť, že ste v správnom adresári:

```bash
ls -la
```

Tento súbor obsahuje kompletné nastavenie pre:
- **Kafka** s KRaft módom (broker + controller v jednom kontajneri)
- **Kafka UI** - moderné webové rozhranie pre správu Kafka

**Výhody tohto nastavenia:**
- ✅ Žiadny Zookeeper nie je potrebný
- ✅ Rýchle spustenie (menej služieb)
- ✅ Jednoduchšia konfigurácia
- ✅ KRaft je budúcnosť Kafka
- ⚡ **Optimalizované pre workshop** - memory limity a JVM tuning

## Krok 2: Spustenie služieb

Spustíme všetky služby na pozadí:

```bash
docker compose up -d
```

## Krok 3: Overenie inštalácie

Skontrolujeme, že všetky kontajnery bežia:

```bash
docker compose ps
```

Měli by ste vidieť 2 bežiace kontajnery:
- `kafka`
- `kafka-ui`

**Poznámka:** S KRaft módom už nepotrebujeme Zookeeper kontajner!

## Overenie pripojenia

Skontrolujeme logy Kafka UI, aby sme sa uistili, že sa pripojilo k Kafka:

```bash
docker logs kafka-ui
```

## Monitoring resource využitia

Môžete sledovať využitie zdrojov:

```bash
# Využitie CPU a pamäte
docker stats --no-stream

# Logy Kafka pre troubleshooting
docker logs kafka --tail 50
```

✅ **Kafka je teraz nainštalované a spustené s optimálnymi nastaveniami!**

V ďalšom kroku si otvoríme Kafka UI rozhranie.