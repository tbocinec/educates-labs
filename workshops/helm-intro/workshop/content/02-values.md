---
title: Zmena values
---

# Úroveň 2: Zmena values

Chart bez konfigurácie by bol nanič. **Values** sú spôsob, akým jeden chart
prispôsobíte pre dev, staging aj produkciu bez kopírovania jediného súboru.

## Poradie prednosti

Hodnota môže prísť z viacerých miest. Neskoršie vyhráva:

```
predvolené vo values.yaml chartu   (najnižšia priorita)
      ↓
-f moje-values.yaml                (váš súbor)
      ↓
--set kľúč=hodnota                 (najvyššia priorita)
```

> **Dokumentácia**: [Values Files](https://helm.sh/docs/chart_template_guide/values_files/)

## Rýchla zmena cez --set

Dobré na jednu-dve hodnoty:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo --set replicaCount=3 --wait
```

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/name=my-app-podinfo
```

Tri repliky. Pozrite sa, čo Helm považuje za prebité:

```terminal:execute
command: helm get values my-app
```

Len `replicaCount` — teda vaše prebitia, nie celá množina values.

## Values súbor

Pre čokoľvek reálne patria values do súboru, ktorý viete prejsť v review a
commitnúť do Gitu.

```editor:open-file
file: exercises/podinfo-values.yaml
```

Nastavuje počet replík, limity zdrojov a vlastnú správu. Aplikujte ho:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --wait
```

```terminal:execute
command: helm get values my-app
```

## Dorazila zmena až do aplikácie?

Podinfo hlási svoju konfiguráciu na `/api/info`:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 10 http://my-app-podinfo:9898/api/info
```

Hľadajte pole `message`: `"Hello from the Helm workshop!"`. Tento reťazec
precestoval z vášho values súboru cez šablónu chartu do premennej prostredia a
von z bežiaceho containera.

## Pozrieť si výsledok pred aplikovaním

Skúste zmenu, ale namiesto nasadenia si ju nechajte len vykresliť:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --set replicaCount=5 --dry-run=client | grep -A2 "replicas:"
```

Nič sa nezmenilo — Helm len ukázal, čo by spravil. Overte si to:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/name=my-app-podinfo --no-headers | wc -l
```

Stále dve repliky z values súboru. `--dry-run=client` je najužitočnejší návyk
z celého workshopu: pred zmenou, ktorou si nie ste istí, sa najprv pozrite, čo
z nej vylezie.

> **Pozor pri `helm upgrade`:** predvolene vychádza z predvolených hodnôt chartu
> plus toho, čo mu odovzdáte **tentoraz**. Hodnoty z minulého upgradu sa
> neprenášajú. Preto je najbezpečnejšie **vždy odovzdať svoj values súbor** —
> potom je jediným zdrojom pravdy ten súbor, nie stav v klastri.

## Zhrnutie

V tejto kapitole ste sa naučili:
- Poradie prednosti: predvolené chartu → values súbor → `--set` vyhráva
- `helm get values` ukáže vaše prebitia
- `--set` je fajn na jednu-dve hodnoty, ďalej použite súbor
- `--dry-run=client` ukáže výsledok bez toho, aby sa čokoľvek zmenilo
- Values držte v commitnutom súbore a odovzdávajte ho pri každom upgrade

Ďalej: čo robiť, keď upgrade dopadne zle.
