---
title: Prehľad workshopu
---

# Kubernetes: Services, Secrets a úložisko

Vitajte na praktickom workshope! Toto je **pokračovanie** workshopu *Základy
Kubernetes*, ktorý pokrýval kubectl, Pody, Deployments a ConfigMapy.

Tam ste sa naučili aplikáciu **spustiť**. Tu sa naučíte všetko ostatné, čo
potrebuje, aby sa dala prevádzkovať: ako ju **nájsť a prepojiť**, ako jej podať
**citlivé údaje**, ako jej **zachovať dáta**, ako Kubernetes sleduje jej
**zdravie** a ako spúšťať **dávkové úlohy**.

## Čo sa naučíte

Workshop má sedem kapitol rozdelených do štyroch úrovní.

| Úroveň | Kapitola | Čo preberieme |
|--------|----------|---------------|
| **1 — Organizácia a prepojenie** | Labels, selektory a namespaces | Labels, selektory na rovnosť aj množinové, `kubectl label`, namespaces a práca naprieč nimi |
| | Sieťovanie Podov a DNS | Sieťový model, IP adresy Podov a ich pominuteľnosť, DNS klastra |
| | Services | Typy Services, vytvorenie imperatívne aj z YAML, endpointy, DNS formáty, rozklad záťaže, vyradenie Podu zmenou labelu |
| **2 — Secrets** | Secrets | Porovnanie s ConfigMap, vytvorenie imperatívne aj cez `stringData`, konzumácia ako premenné prostredia aj ako súbory, správanie pri zmene |
| **3 — Úložisko** | Trvalé úložisko | PV, PVC a StorageClass, prístupové režimy, dôkaz, že dáta prežijú Pod, reclaim policy |
| **4 — Spoľahlivosť** | Liveness a readiness probes | Tri druhy probes, metódy HTTP/TCP/exec, zlyhávajúca probe naživo, časové parametre |
| | Jobs a CronJobs | Jobs do dokončenia, `completions` a `parallelism`, `backoffLimit`, CronJobs, cron formát, pozastavenie a obnovenie |

> **Názov workshopu je užší než jeho obsah.** Okrem Services, Secretov a
> úložiska sa tu naučíte aj labels a namespaces, kontroly zdravia a dávkové
> úlohy. Je to zámer — sú to veci, ktoré pri prevádzke aplikácie potrebujete
> spolu.

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
- **Headlamp** — webové UI na vizuálny prehľad klastra (záložka Headlamp)
- **Pripravené cvičné súbory** — YAML manifesty v `~/exercises/`

Pracujete vo vlastnom namespace — jeho názov zistíte cez
`kubectl config view --minify -o jsonpath='{..namespace}'`.

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
