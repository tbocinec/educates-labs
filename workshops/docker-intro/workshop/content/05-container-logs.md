# Práca s logmi containers

Logy sú hlavným nástrojom na pozorovanie toho, čo sa deje vo vnútri containera. Docker zachytáva všetko, čo hlavný proces containera zapíše na **stdout** a **stderr**, a sprístupňuje to cez príkaz `docker logs`.

---

## Príprava containera, ktorý generuje logy

Spustime Nginx container a vytvorme nejaký log výstup:

```terminal:execute
command: docker run -d --name log-demo -p 8080:80 nginx:latest
```

**Vygenerujte nejakú prevádzku, aby vznikli záznamy v logu:**

```terminal:execute
command: for i in $(seq 1 10); do curl -s -o /dev/null http://localhost:8080; done
```

---

## Zobrazenie logov

**Zobrazte všetky logy z containera:**

```terminal:execute
command: docker logs log-demo
```

Mali by ste vidieť záznamy z access logu Nginxu zobrazujúce HTTP požiadavky, ktoré sme práve vykonali.

---

## Sledovanie logov v reálnom čase

Prepínač `-f` (follow) streamuje nové záznamy logu tak, ako prichádzajú — podobne ako `tail -f`:

```terminal:execute
command: docker logs -f log-demo
```

Kým je stream logu aktívny, vygenerujte z druhého terminálu ďalšiu prevádzku:

```terminal:execute
command: curl http://localhost:8080
session: 2
```

Nové záznamy uvidíte pribúdať v reálnom čase. **Stlačením `Ctrl+C`** sledovanie logov ukončíte.

---

## Zobrazenie časových značiek (timestamps)

Pridaním prepínača `-t` sa pred každý riadok logu doplní presná časová značka:

```terminal:execute
command: docker logs -t log-demo
```

Časové značky sú vo formáte ISO 8601 a sú neoceniteľné pri korelovaní udalostí naprieč viacerými containers.

---

## Tail: obmedzenie výstupu logu

Pri containers, ktoré produkujú veľký objem logov, použite `--tail` na zobrazenie iba najnovších záznamov:

**Zobrazte iba posledných 5 riadkov logu:**

```terminal:execute
command: docker logs --tail 5 log-demo
```

**Skombinujte s follow, aby ste videli nové záznamy počnúc od posledných 3 riadkov:**

```terminal:execute
command: docker logs --tail 3 -f log-demo
```

Stlačením `Ctrl+C` sledovanie ukončíte.

---

## Filtrovanie logov podľa času

Prepínače `--since` a `--until` filtrujú logy podľa času:

**Zobrazte logy za posledných 30 sekúnd:**

```terminal:execute
command: docker logs --since 30s log-demo
```

**Zobrazte logy za posledné 2 minúty:**

```terminal:execute
command: docker logs --since 2m log-demo
```

Použiť môžete aj absolútne časové značky:

```
docker logs --since "2026-02-10T10:00:00" log-demo
docker logs --until "2026-02-10T10:30:00" log-demo
```

---

## Kombinovanie logov s grep

Keďže Docker vypisuje logy na stdout, môžete ich posunúť cez štandardné Unixové nástroje na pokročilé filtrovanie:

**Nájdite iba GET požiadavky:**

```terminal:execute
command: docker logs log-demo 2>&1 | grep "GET"
```

**Spočítajte počet riadkov logu:**

```terminal:execute
command: docker logs log-demo 2>&1 | wc -l
```

> **Poznámka:** Nginx zapisuje access logy na **stdout** a error logy na **stderr**. Zápis `2>&1` presmeruje stderr na stdout, takže `grep` zachytí oba streamy.

---



## Cleanup

```terminal:execute
command: docker rm -f log-demo
```
