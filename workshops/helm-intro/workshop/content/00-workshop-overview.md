---
title: Prehľad workshopu
---

# Základy Helmu

Vitajte! Doteraz ste písali YAML ručne — tu Deployment, tam Service, a ConfigMap,
ktorá to spája. Funguje to, kým nepotrebujete tú istú aplikáciu v dev, staging a
produkcii s tromi rôznymi konfiguráciami.

**Helm** je balíčkovací systém pre Kubernetes. Z kopy manifestov spraví
verzovanú, konfigurovateľnú a inštalovateľnú jednotku — a pridá tlačidlo späť.

## Ako je workshop rozdelený

Workshop má dve časti, ktoré zodpovedajú dvom pohľadom na Helm.

### Časť 1 — Používanie Helmu

Najčastejšia práca: niekto už chart napísal a vy ho chcete nasadiť.

| Úroveň | Čo preberieme |
|--------|---------------|
| **1 — Nájsť a nainštalovať** | Repozitáre, hľadanie chartov, `helm install` |
| **2 — Zmena values** | `--set`, values súbory, `--dry-run` |
| **3 — Návrat po zlom nasadení** | História revízií, `helm rollback` |
| **4 — Reálna aplikácia** | Grafana: cluster-scoped objekty, heslo v Secrete, prihlásenie cez záložku |

### Časť 2 — Tvorba vlastného chartu

| Úroveň | Čo preberieme |
|--------|---------------|
| **5 — Vlastný chart** | `helm create`, šablóny, `lint`, `test`, `package` |

### Voliteľné

| Úroveň | Čo preberieme |
|--------|---------------|
| **6 — Čo Helm ešte vie** | Prehľad pokročilých tém s odkazmi, bez cvičení |

Šiesta úroveň je naozaj **voliteľná** — workshop je hotový po piatej. Je to
rozcestník na to, keď neskôr narazíte na závislosti, hooks, GitOps alebo OCI
registry.

## Predpoklady

Mali by ste ovládať:
- Základy `kubectl` (`get`, `describe`, `apply`, `delete`)
- Deployments, Services a ConfigMaps

Pokrývali to workshopy *Základy Kubernetes* a *Kubernetes: Services, Secrets a
úložisko*.

## Prostredie workshopu

Vaše prostredie obsahuje:

- **Dva terminály** (rozdelený layout) — príkazy môžete púšťať vedľa seba
- **Editor kódu** — na čítanie a úpravu chartov a values súborov
- **Headlamp** — uvidíte, čo Helm vo vašom namespace naozaj vytvoril
- **Grafana** — záložka na aplikáciu, ktorú si v úrovni 4 sami nasadíte (dovtedy hlási chybu)
- **Helm už nainštalovaný** — netreba nič pripravovať

Pracujete vo vlastnom namespace — jeho názov zistíte cez
`kubectl config view --minify -o jsonpath='{..namespace}'`.

Overte si verziu, s ktorou pracujete:

```terminal:execute
command: helm version
```

> **Tento workshop používa Helm 4.** Takmer všetko tu funguje rovnako aj na Helme
> 3.

## Poznámka k oprávneniam

Ste administrátorom **vo vlastnom namespace** a nikde inde. Pri Helme to má
dôsledky: mnohé verejné charty inštalujú cluster-scoped objekty (ClusterRoles,
CRD, webhooky) a tu by boli odmietnuté.

Charty použité na tomto workshope sú zámerne iba namespaced. Keď neskôr skúsite
vlastný chart a uvidíte chyby `Forbidden`, býva to zvyčajne práve toto — nie
pokazený chart.

## Oficiálna dokumentácia

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)

## Časový odhad

Časti 1 a 2 trvajú spolu približne **55 minút**. Voliteľná piata úroveň je
čítanie na ďalších ~10 minút.

Poďme niečo nainštalovať!
