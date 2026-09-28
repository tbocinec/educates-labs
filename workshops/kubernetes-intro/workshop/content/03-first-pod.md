---
title: Váš prvý Pod
---

# Úroveň 2: Váš prvý Pod

**Pod** je najmenšia nasaditeľná jednotka v Kubernetes. Predstavuje jednu
inštanciu bežiaceho procesu — typicky obaľuje jeden container (môže ich však
obsahovať aj viac).

> **Dokumentácia**: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

## Vytvorenie Podu imperatívne

Najrýchlejšia cesta k Podu je príkaz `kubectl run`:

```terminal:execute
command: kubectl run hello-pod --image=nginx:1.27
```

Vytvorí sa Pod s názvom `hello-pod`, v ktorom beží container image `nginx:1.27`.

## Kontrola stavu Podu

Vypíšte Pody vo vašom namespace:

```terminal:execute
command: kubectl get pods
```

Mali by ste vidieť `hello-pod`, ktorého stav sa postupne mení z
`ContainerCreating` na `Running`.

Prepínač `-o wide` pridá ďalšie údaje, napríklad node a IP adresu:

```terminal:execute
command: kubectl get pods -o wide
```

## Detailný popis Podu

Príkaz `describe` poskytne podrobné informácie o zdroji vrátane udalostí:

```terminal:execute
command: kubectl describe pod hello-pod
```

Prejdite si výstup a všimnite si kľúčové sekcie:

- **Metadata** — názov, namespace, labels
- **Containers** — image, porty, stav
- **Conditions** — pripravenosť Podu a stav plánovania
- **Events** — chronologický záznam toho, čo sa dialo (stiahnutie image, vytvorenie containera, spustenie)

## Logy Podu

Pozrite si logy containera, teda čo Nginx vypísal:

```terminal:execute
command: kubectl logs hello-pod
```

Na sledovanie logov naživo (ako `tail -f`) slúži prepínač `-f`. Spustite to
v druhom termináli:

```terminal:execute
command: kubectl logs hello-pod -f
session: 2
```

Keď skončíte, sledovanie zastavte klávesou `Ctrl+C` v druhom termináli.

## Spúšťanie príkazov vnútri Podu

V bežiacom containeri viete spúšťať príkazy cez `kubectl exec`:

```terminal:execute
command: kubectl exec hello-pod -- hostname
```

Dvojica `--` oddeľuje prepínače `kubectl` od príkazu, ktorý sa má vykonať vnútri
containera.

Spustite interaktívny shell:

```terminal:execute
command: kubectl exec -it hello-pod -- /bin/bash
```

Teraz ste vnútri Nginx containera! Overme, že Nginx niečo servíruje:

```terminal:execute
command: curl localhost:80
```

Zistite verziu Nginxu:

```terminal:execute
command: nginx -v
```

Opustite shell containera:

```terminal:execute
command: exit
```

## Port forwarding

Najprv sa uistite, že ste zastavili sledovanie logov z predchádzajúceho kroku.
Ak ešte beží, stlačte v druhom termináli `Ctrl+C`:

```terminal:execute
command: ""
session: 2
```

Na prístup k Podu z vášho prostredia slúži `kubectl port-forward`. Spustite ho
v druhom termináli:

```terminal:execute
command: kubectl port-forward hello-pod 8080:80 &
session: 2
```

Teraz otestujte spojenie z prvého terminálu:

```terminal:execute
command: curl localhost:8080
```

Zastavte port-forward:

```terminal:execute
command: kill %1 2>/dev/null; echo "Port-forward stopped"
session: 2
```

## Zmazanie Podu

Po skončení Pod upracte:

```terminal:execute
command: kubectl delete pod hello-pod
```

Overte, že je preč:

```terminal:execute
command: kubectl get pods
```

> **Dôležité**: Keď zmažete samostatný Pod, je nenávratne preč. Nič ho
> automaticky nevytvorí znova. Práve preto sa v praxi používajú **Deployments**
> (kapitola 5).

## Rýchly dry run

Pred vytvorením zdroja si viete pozrieť, čo by vzniklo, pomocou
`--dry-run=client`:

```terminal:execute
command: kubectl run test-pod --image=nginx:1.27 --dry-run=client -o yaml
```

Vypíše sa YAML manifest **bez** toho, aby sa Pod naozaj vytvoril. Výborná pomôcka
na generovanie YAML šablón!

## Zhrnutie

V tejto kapitole ste sa naučili:
- `kubectl run` — vytvorenie Podu imperatívne
- `kubectl get pods` — výpis Podov
- `kubectl describe pod` — podrobnosti o Pode
- `kubectl logs` — logy containera
- `kubectl exec` — spustenie príkazu vnútri containera
- `kubectl port-forward` — lokálny prístup na port Podu
- `kubectl delete pod` — odstránenie Podu
- `--dry-run=client -o yaml` — náhľad bez vytvorenia

Ďalej sa naučíme definovať Pody pomocou YAML manifestov — teda **deklaratívne**.
