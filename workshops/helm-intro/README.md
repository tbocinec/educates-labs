# Workshop: Základy Helmu

Praktický úvod do Helmu — balíčkovacieho systému pre Kubernetes. Rozdelený na dve
časti podľa dvoch pohľadov na Helm: najprv ako hotový chart použiť, potom ako si
napísať vlastný.

## Dĺžka

~55 minút (plus ~10 minút voliteľného čítania)

## Predpoklady

- Absolvovanie workshopu **Základy Kubernetes** (alebo rovnocenná znalosť
  kubectl, Deploymentov, Services a ConfigMáp)

## Obsah

### Časť 1 — Používanie Helmu

Najčastejšia práca: chart už niekto napísal a vy ho nasadzujete.

**Úroveň 1 — Nájsť a nainštalovať**
- Chart, release, repozitár v troch vetách
- `helm repo add`, `helm search`, `helm show values`
- `helm install --wait`, `helm list`, `helm status`, `helm uninstall`

**Úroveň 2 — Zmena values**
- Poradie prednosti: predvolené chartu → values súbor → `--set`
- Values súbor a overenie, že zmena dorazila až do bežiacej aplikácie
- `--dry-run=client` ako návyk

**Úroveň 3 — Návrat po zlom nasadení**
- História revízií
- Zámerne rozbitý release a `helm rollback`

**Úroveň 4 — Reálna aplikácia (Grafana)**
- Prečo reálne charty narážajú na `Forbidden` (cluster-scoped objekty)
- `helm show chart` a `helm template | grep kind:` ako kontrola pred inštaláciou
- Heslo administrátora zo Secretu a prihlásenie cez vlastnú záložku v lište

### Časť 2 — Tvorba vlastného chartu

**Úroveň 5 — Vlastný chart**
- `helm create`, štruktúra chartu, syntax šablón
- `helm lint` a `helm template` ako kontrola pred nasadením
- Inštalácia z adresára, `helm test`, `helm package`

### Voliteľné

**Úroveň 6 — Čo Helm ešte vie**

Bez cvičení, samé odkazy. `--atomic` a pripínanie verzií v CI, závislosti a
subcharty, hooks, library charts, šablónovací jazyk, OCI registry, podpisovanie,
Helmfile/Argo CD/Flux a práca s citlivými údajmi.

## Poznámky k návrhu

Prvé úrovne sú zámerne jednoduché a krátke — cieľom je, aby účastník vedel po
troch kapitolách reálne nasadiť a prevádzkovať cudzí chart. Pokročilé veci
(`--atomic`, `--reuse-values`, `--dry-run=server`, verzie chartov, interné
uloženie stavu v Secretoch) sú vytiahnuté do voliteľnej piatej úrovne, aby
nezdržiavali.

Študenti sú administrátormi namespace, nie klastra. Každý použitý chart bol
zvolený preto, že vytvára **iba namespaced objekty** — žiadne CRD, ClusterRoles
ani webhooky, ktoré by boli odmietnuté.

## Vlastnosti

- Helm je už v image workshopu — žiadny inštalačný krok
- Používa [podinfo](https://github.com/stefanprodan/podinfo) ako ľahkú demo aplikáciu
- V úrovni 4 inštaluje oficiálny chart **Grafany**, dostupnej cez záložku v lište
- Komentované values súbory, ktoré študenti aplikujú a upravujú
- Webové UI Headlamp na prehľad toho, čo Helm vytvoril

## Jazyk

Workshop je v slovenčine, technické pojmy a príkazy sú ponechané v angličtine.

## Odkazy na oficiálnu dokumentáciu

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
