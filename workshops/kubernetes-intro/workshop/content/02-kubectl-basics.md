---
title: Základy kubectl
---

# Základy kubectl

`kubectl` (vyslovuje sa „kube-control" alebo „kube-cuddle") je hlavný nástroj
príkazového riadku na prácu s Kubernetes. Všetko — od nasadenia aplikácie po
zisťovanie stavu klastra — ide cez `kubectl`.

> **Dokumentácia**: [kubectl Overview](https://kubernetes.io/docs/reference/kubectl/) | [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Štruktúra príkazu

Všeobecná syntax vyzerá takto:

```
kubectl [príkaz] [typ-zdroja] [názov] [prepínače]
```

Napríklad:
- `kubectl get pods` — vypíše všetky Pody
- `kubectl describe pod my-nginx` — zobrazí detaily konkrétneho Podu
- `kubectl delete pod my-nginx` — zmaže konkrétny Pod

## Informácie o klastri

Najprv zistite, akú verziu `kubectl` a klastra používate:

```terminal:execute
command: kubectl version --output=yaml
```

Zobrazte podrobnejšie informácie o klastri:

```terminal:execute
command: kubectl cluster-info
```

## Preskúmanie API zdrojov

Kubernetes má mnoho typov zdrojov. Vypíšte všetky, ktoré klaster pozná:

```terminal:execute
command: kubectl api-resources --sort-by=name | head -30
```

Uvidíte skratky, API skupinu, či je zdroj namespaced, a jeho kind. Niektoré bežne
používané skratky:

| Skratka | Celý názov |
|---------|------------|
| `po`  | pods |
| `deploy` | deployments |
| `svc` | services |
| `cm`  | configmaps |
| `ns`  | namespaces |
| `no`  | nodes |
| `rs`  | replicasets |

Skratky fungujú v ľubovoľnom príkaze `kubectl`. Napríklad `kubectl get po` je to
isté ako `kubectl get pods`.

## Príkaz explain

Jeden z najužitočnejších príkazov pri učení Kubernetes je `explain`. Zobrazí
dokumentáciu k akémukoľvek typu zdroja alebo poľu — priamo v termináli.

Dokumentácia k Podu:

```terminal:execute
command: kubectl explain pod
```

Ponorte sa do konkrétneho poľa (bodková notácia):

```terminal:execute
command: kubectl explain pod.spec.containers
```

A ešte hlbšie:

```terminal:execute
command: kubectl explain pod.spec.containers.ports
```

> **Tip**: Prepínačom `--recursive` si zobrazíte celú štruktúru naraz:
> `kubectl explain pod.spec --recursive | head -50`

## Príkaz get

`kubectl get` vypisuje zdroje. Poďme si pozrieť aktuálny stav klastra.

Vypíšte všetky namespaces:

```terminal:execute
command: kubectl get namespaces
```

Vypíšte Pody vo vašom namespace (zatiaľ by mal byť prázdny):

```terminal:execute
command: kubectl get pods
```

## Bežné formáty výstupu

| Prepínač | Popis |
|----------|-------|
| (predvolené) | Čitateľná tabuľka |
| `-o wide` | Tabuľka s ďalšími stĺpcami |
| `-o yaml` | Kompletná YAML reprezentácia |
| `-o json` | Kompletná JSON reprezentácia |
| `-o name` | Iba názov zdroja |
| `--no-headers` | Tabuľka bez hlavičky |

## Kde hľadať pomoc

Každý príkaz `kubectl` má vstavanú nápovedu:

```terminal:execute
command: kubectl --help | head -30
```

Nápoveda ku konkrétnemu príkazu:

```terminal:execute
command: kubectl get --help | head -20
```

## Prehľad príkazov

Rýchly prehľad príkazov, ktoré na workshope použijete najčastejšie:

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl get` | Vypíše zdroje |
| `kubectl describe` | Zobrazí podrobnosti o zdroji |
| `kubectl create` | Vytvorí zdroj |
| `kubectl apply` | Vytvorí alebo aktualizuje zdroj zo súboru |
| `kubectl delete` | Zmaže zdroj |
| `kubectl logs` | Zobrazí logy containera |
| `kubectl exec` | Spustí príkaz v containeri |
| `kubectl explain` | Zobrazí dokumentáciu k zdroju |
| `kubectl scale` | Zmení počet replík |
| `kubectl rollout` | Spravuje deployments (status, history, undo) |

Teraz, keď poznáte základné príkazy `kubectl`, poďme ich použiť a spustiť váš
prvý Pod!
