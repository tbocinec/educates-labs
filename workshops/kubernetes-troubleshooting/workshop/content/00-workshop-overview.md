---
title: Prehľad workshopu
---

# Kubernetes: Troubleshooting

Vitajte! Všetky ostatné workshopy vám ukazujú Kubernetes, keď **funguje**. Tento
ukazuje Kubernetes, keď **nefunguje** — a presne tým strávite v praxi väčšinu
času.

Dostanete šesť rozbitých workloadov. Pri každom uvidíte príznak, cez `kubectl`
nájdete príčinu, opravíte ju a opravu overíte. Na konci nebudete memorovať chybové
hlášky — budete mať **metódu**, ktorá funguje aj na chyby, ktoré ste nikdy
nevideli.

## Čo sa naučíte

| Úroveň | Príznak | Poruchy, ktoré budete diagnostikovať |
|--------|---------|--------------------------------------|
| **1 — Metóda** | — | `get` → `describe` → events → logs, a kedy čo použiť |
| **2 — Nikdy nenaštartuje** | večné `0/1` | `ImagePullBackOff`, `CreateContainerConfigError` |
| **3 — Naštartuje a zomrie** | rastúci počet reštartov | `CrashLoopBackOff`, `OOMKilled` |
| **4 — Ostáva v Pending** | žiadny pridelený node | nenaplánovateľný Pod, odmietnutie pri admission |
| **5 — Nedostupná aplikácia** | appka neodpovedá | Service bez endpointov, zlý `targetPort` |

## Predpoklady

Mali by ste sa cítiť pohodlne s:
- `kubectl get`, `describe`, `logs`, `apply`, `delete`
- Podmi, Deploymentmi, Services a ConfigMapami

Pokrývali to workshopy *Základy Kubernetes* a *Kubernetes: Services, Secrets a
úložisko*.

## Prostredie workshopu

Vaše prostredie obsahuje:

- **Dva terminály** (rozdelený layout) — v jednom nechajte bežať `watch`, v druhom pracujte
- **Editor kódu** — na čítanie a opravu rozbitých manifestov
- **Headlamp** — webové UI, kde sú udalosti a logy na jeden klik
- **Pripravené rozbité manifesty** — v `~/exercises/`

Pracujete vo vlastnom namespace — jeho názov zistíte cez
`kubectl config view --minify -o jsonpath='{..namespace}'`.

## Ako každý scenár prebieha

Každý scenár má rovnaké štyri fázy:

1. **Rozbi to** — aplikujete manifest, ktorý vám niekto podal
2. **Pozoruj** — čo na to klaster vlastne hovorí?
3. **Diagnostikuj** — zúžte to na jednu príčinu
4. **Oprav a over** — zmeňte jednu vec a dokážte, že to zabralo

Odolajte pokušeniu preskočiť rovno na opravu. Tou zručnosťou je diagnostika.

## Oficiálna dokumentácia Kubernetes

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Časový odhad

Workshop trvá približne **60 minút**.

Poďme niečo rozbiť!
