---
title: Nastavenie Kafka UI
---

# Nastavenie Kafka UI

Kafka UI je teraz spustené a dostupné na porte 8080. V tomto kroku si otvoríme webové rozhranie a preskúmame ho.

## Krok 1: Otvorenie Kafka UI

Kafka UI môžete otvoriť rôznymi spôsobmi:

### Možnosť 1: Dashboard tab (odporúčané)
Kliknite na tab **"kafka-ui"** v hornej lište Educates

### Možnosť 2: Priamy prístup
Kafka UI by malo byť dostupné na: http://localhost:8080

### Možnosť 3: Ingress URL  
Educates môže vystaviť službu cez ingress na externej URL

## Krok 2: Overenie pripojenia v termináli

Najprv si overíme, že je Kafka UI dostupné:

```bash
curl -f http://localhost:8080 && echo "✅ Kafka UI je dostupné!" || echo "❌ Kafka UI nie je dostupné"
```

## Krok 3: Kontrola dostupnosti API

Skontrolujeme, že sa Kafka UI úspešne pripojilo k Kafka clusteru:

```bash
curl -s http://localhost:8080/api/clusters | jq .
```

Ak je všetko v poriadku, uvidíte informácie o Kafka clusteri s názvom "local".

## Krok 4: Preskúmanie rozhrania

Po otvorení Kafka UI uvidíte:

### Hlavná stránka
- **Clusters** - Zoznam pripojených Kafka clusterov
- **Topics** - Zoznam všetkých topicov
- **Brokers** - Informácie o Kafka brokeroch
- **Consumers** - Aktívne consumer groups

### Navigácia
- Ľavé menu obsahuje hlavné sekcie
- Horné menu zobrazuje informácie o vybranom clusteri

## Krok 5: Overenie Kafka brokera

V Kafka UI:
1. Kliknite na cluster **"local"**
2. Prejdite do sekcie **"Brokers"**
3. Malo by tam byť uvedené 1 broker s ID `1`

## Alternatívne overenie cez príkazový riadok

Môžeme tiež overiť Kafka broker priamo pomocou Kafka nástrojov:

```bash
docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

✅ **Kafka UI je teraz pripravené na použitie!**

V ďalšom kroku si vytvoríme náš prvý topic.