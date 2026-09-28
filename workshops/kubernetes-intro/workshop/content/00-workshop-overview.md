---
title: Prehľad workshopu
---

# Základy Kubernetes

Vitajte! Toto je váš **prvý kontakt s Kubernetes**. Nepredpokladáme žiadne
predchádzajúce skúsenosti — začnete obhliadkou klastra, ručne spustíte jeden Pod
a postupne sa prepracujete až k prevádzke reálnej aplikácie.

## Čo sa naučíte

Workshop sleduje jeden oblúk: od *čo to vlastne je* až po *viem na tom spustiť
a aktualizovať aplikáciu*.

| Úroveň | Téma | Čo preberieme |
|--------|------|---------------|
| **1 — Začíname** | Architektúra a kubectl | Z čoho sa klaster skladá, ako ho preskúmať cez `kubectl` |
| **2 — Pody** | Prvý workload | Spustenie Podu ručne, potom deklaratívne cez YAML |
| **3 — Deployments** | Ako to spustiť poriadne | Deployments, škálovanie, rolling updates, rollbacks |
| **4 — Konfigurácia** | Konfigurácia mimo image | ConfigMap ako premenné prostredia aj ako súbory |
| **5 — Scenár** | Všetko dokopy | Nasadenie reálnej aplikácie, škálovanie, self-healing, update |

Každá úroveň stavia na predchádzajúcej a posledná je jeden súvislý scenár, ktorý
použije všetky naraz.

## Predpoklady

Okrem terminálu žiadne. Ak ste pracovali s Dockerom, bude vám to povedomé, ale
ani to nie je podmienka.

## Prostredie workshopu

Vaše prostredie obsahuje:

- **Dva terminály** (rozdelený layout) — príkazy môžete púšťať vedľa seba
- **Editor kódu** — na prezeranie a úpravu YAML manifestov
- **Headlamp** — webové UI na vizuálny prehľad klastra (záložka Headlamp)
- **Pripravené cvičné súbory** — YAML manifesty v adresári `exercises/`

Terminály majú nakonfigurovaný `kubectl` a prístup do vášho vlastného namespace:
`{{ session_namespace }}`.

## Časový odhad

Workshop trvá približne **90 minút**.

## Oficiálna dokumentácia Kubernetes

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Poďme na to!
