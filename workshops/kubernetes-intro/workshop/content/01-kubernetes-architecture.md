---
title: Architektúra Kubernetes
---

# Úroveň 1: Architektúra Kubernetes

Než začneme s Kubernetes pracovať prakticky, poďme si povedať, čo to vlastne je
a ako je to poskladané.

## Čo je Kubernetes?

**Kubernetes** (často skracovaný na **K8s**) je open-source platforma na
orchestráciu containerov. Automatizuje nasadzovanie, škálovanie a správu
containerizovaných aplikácií.

Kľúčové schopnosti:
- **Self-healing** — reštartuje spadnuté containery, nahrádza ich a preplánuje
- **Škálovanie** — aplikácie sa dajú zväčšovať a zmenšovať podľa záťaže
- **Rolling updates** — aktualizácia aplikácie bez výpadku
- **Service discovery** — automatické DNS a load balancing pre služby
- **Správa konfigurácie** — konfigurácia aplikácie oddelene od kódu

> **Dokumentácia**: [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

## Architektúra klastra

Kubernetes klaster sa skladá z dvoch hlavných častí:

### Control Plane (riadiaca vrstva)

Control plane riadi celý klaster. Jeho kľúčové komponenty sú:

| Komponent | Úloha |
|-----------|-------|
| **API Server** | Vstupný bod do Kubernetes. Všetky príkazy `kubectl` komunikujú s ním. |
| **etcd** | Key-value úložisko so všetkými dátami a stavom klastra. |
| **Scheduler** | Rozhoduje, na ktorom node pobeží nový Pod. |
| **Controller Manager** | Beží v ňom sada controllerov riešiacich rutinné úlohy (napr. dodržanie požadovaného počtu replík). |

### Worker nodes (pracovné uzly)

Na worker nodes bežia vaše skutočné aplikácie:

| Komponent | Úloha |
|-----------|-------|
| **kubelet** | Agent na každom node. Stará sa o to, aby containery v Podoch bežali. |
| **kube-proxy** | Rieši sieťovanie — smeruje prevádzku na správne Pody. |
| **Container Runtime** | Spúšťa samotné containery (napr. containerd, CRI-O). |

## Základné objekty

Toto sú základné objekty Kubernetes, s ktorými budete na workshope pracovať:

| Objekt | Na čo slúži |
|--------|-------------|
| **Pod** | Najmenšia nasaditeľná jednotka. Obaľuje jeden alebo viac containerov. |
| **Deployment** | Spravuje sadu identických Podov. Rieši škálovanie, updaty a rollbacky. |
| **ConfigMap** | Uchováva necitlivú konfiguráciu ako dvojice kľúč-hodnota. |
| **Namespace** | Virtuálne rozdelenie klastra kvôli izolácii zdrojov. |
| **Label** | Metadáta typu kľúč-hodnota na objektoch, slúžia na organizáciu a výber. |

## Deklaratívny model

Kubernetes používa **deklaratívny** prístup: vy popíšete **požadovaný stav**
(napr. „chcem 3 repliky nginxu") a Kubernetes sa nepretržite snaží dostať
**skutočný stav** do súladu s ním.

```
Vy deklarujete:  "Chcem 3 nginx Pody"
    ↓
Kubernetes:      Vytvorí a udržiava presne 3 Pody
    ↓
Pod zomrie:      Kubernetes automaticky vytvorí náhradu
```

Je to zásadne odlišné od imperatívnych príkazov typu „spusti tento container na
tomto serveri".

## Rýchla kontrola klastra

Overme si, že klaster funguje. Zistite informácie o klastri:

```terminal:execute
command: kubectl cluster-info
```

A pozrite si nodes v klastri:

```terminal:execute
command: kubectl get nodes
```

Mali by ste vidieť bežiace komponenty klastra a aspoň jeden node v stave `Ready`.

V nasledujúcej kapitole sa naučíte základné príkazy `kubectl`, ktorými sa s
klastrom rozpráva.
