# Upratovanie a osvedčené postupy

Postupom času Docker nazbiera nepoužívané images, zastavené kontajnery, osirotené volumes a nepoužívané siete. V tejto časti sa naučíte, ako uvoľniť miesto na disku a osvojiť si osvedčené postupy.

---

## Zobrazenie využitia Docker prostriedkov

**Získajte rýchly prehľad o tom, čo zaberá miesto:**

```terminal:execute
command: docker system df
```

---

## Odstránenie zastavených kontajnerov

**Vypíšte všetky zastavené kontajnery:**

```terminal:execute
command: docker ps -a --filter "status=exited"
```

**Odstráňte všetky zastavené kontajnery naraz:**

```terminal:execute
command: docker container prune -f
```

---

## Odstránenie nepoužívaných images

**Odstráňte visiace (dangling) images** (vrstvy, na ktoré sa už neodkazuje žiadny označený image):

```terminal:execute
command: docker image prune -f
```

**Odstráňte VŠETKY nepoužívané images** (images, ktoré nie sú priradené žiadnemu kontajneru):

```terminal:execute
command: docker image prune -a -f
```

> **Upozornenie:** Prepínač `-a` odstráni všetky images, na ktoré neodkazuje aspoň jeden kontajner. Používajte opatrne v prostrediach, kde chcete zachovať uložené (cached) images pre rýchlejšie štartovanie.

---

## Odstránenie nepoužívaných volumes

Osirotené volumes sú volumes, ktoré už nie sú pripojené k žiadnemu kontajneru. Sú častým zdrojom skrytého využitia disku:

```terminal:execute
command: docker volume ls
```

**Odstráňte všetky osirotené volumes:**

```terminal:execute
command: docker volume prune -f
```

> **Dôležité:** Dáta vo volume sa natrvalo vymažú. Pred prune vždy overte, čo volumes obsahujú.

---

## Odstránenie nepoužívaných sietí

```terminal:execute
command: docker network prune -f
```

Tento príkaz odstráni všetky používateľom definované siete, ktoré aktuálne nepoužíva žiadny kontajner.

---

## Jadrová možnosť: upratanie celého systému

Príkaz `docker system prune` odstráni **všetky** nepoužívané prostriedky jediným príkazom:

```terminal:execute
command: docker system prune -f
```

Ak chcete zahrnúť aj **nepoužívané volumes** (predvolene nie sú zahrnuté):

```terminal:execute
command: docker system prune --volumes -f
```

**Overte, že je všetko čisté:**

```terminal:execute
command: docker system df
```

---

## Zhrnutie osvedčených postupov

### Mapovanie portov
- Sprístupňujte iba porty, ktoré musia byť dostupné zvonka
- Používajte naviazanie na konkrétne rozhranie (`127.0.0.1:8080:80`) pre služby, ktoré by nemali byť verejne prístupné
- V produkcii uprednostnite explicitné priradenie host portov pred náhodnými portmi

### Správa dát
- Používajte **named volumes** pre perzistentné dáta (databázy, úložiská súborov)
- Používajte **bind mounts** pre vývojové postupy (živé načítavanie kódu)
- Nikdy neukladajte dôležité dáta do zapisovateľnej vrstvy kontajnera
- Pravidelne zálohujte named volumes

### Sieťovanie
- Používajte **používateľom definované bridge siete** namiesto predvoleného bridge
- Využívajte automatické DNS rozlíšenie použitím mien kontajnerov
- Izolujte citlivé služby (databázy) na oddelených sieťach
- Oddeľte frontend a backend služby na rôznych sieťach

### Bezpečnosť
- Obmedzte prostriedky kontajnera pomocou prepínačov `--memory` a `--cpus`
- Kde je to možné, používajte read-only pripojenie súborového systému (`:ro`)
- Nikdy nesprístupňujte databázové porty verejnej sieti
