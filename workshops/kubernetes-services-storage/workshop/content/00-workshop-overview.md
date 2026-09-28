---
title: Prehľad workshopu
---

# Kubernetes: Services, Secrets a úložisko

Vitajte na praktickom workshope! Toto je **pokračovanie** workshopu *Základy
Kubernetes*, ktorý pokrýval kubectl, Pody, Deployments a ConfigMapy.

Tu sa naučíte, ako aplikácie v Kubernetes **prepojiť**, **zabezpečiť** a ako im
zachovať **dáta**.

## Čo sa naučíte

Workshop je rozdelený do štyroch postupných úrovní:

| Úroveň | Téma | Čo preberieme |
|--------|------|---------------|
| **1 — Organizácia a prepojenie** | Labels, DNS a Services | Labels a selektory do hĺbky, namespaces, sieťovanie Podov, ClusterIP Services |
| **2 — Secrets** | Citlivé údaje | Vytváranie Secrets, konzumácia ako env premenné aj ako súbory |
| **3 — Úložisko** | Trvalé dáta | PersistentVolumeClaims, dáta prežívajúce reštart Podu |
| **4 — Spoľahlivosť** | Probes a Jobs | Liveness/readiness kontroly, Jobs, CronJobs |

Úroveň 1 začína labelmi a selektormi zámerne. Service si nájde svoje Pody podľa
label selektora a podľa ničoho iného — takže práve selektor je to, vďaka čomu
všetko ďalšie funguje, alebo potichu zlyhá.

## Predpoklady

Mali by ste ovládať:
- Základy `kubectl` (`get`, `apply`, `describe`, `delete`, `logs`, `exec`)
- Pody, Deployments, škálovanie a rolling updates
- ConfigMaps

Všetko to pokrýval workshop *Základy Kubernetes*. Labels preberáme v prvej
kapitole od začiatku, takže stačí, ak ste o nich počuli.

## Prostredie workshopu

Vaše prostredie obsahuje:

- **Dva terminály** (rozdelený layout) — príkazy môžete púšťať vedľa seba
- **Editor kódu** — na prezeranie a úpravu YAML manifestov
- **Kubernetes Dashboard** — vizuálny prehľad klastra (záložka Console)
- **Pripravené cvičné súbory** — YAML manifesty v `~/exercises/`

Váš vlastný namespace je `{{ session_namespace }}`.

## Oficiálna dokumentácia Kubernetes

Počas workshopu budeme odkazovať na oficiálnu dokumentáciu. Kľúčové stránky:

- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Časový odhad

Workshop trvá približne **105 minút**.

Poďme na to!
