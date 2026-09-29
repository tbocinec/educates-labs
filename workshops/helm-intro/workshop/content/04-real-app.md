---
title: Reálna aplikácia — Grafana
---

# Úroveň 4: Reálna aplikácia — Grafana

Podinfo bola hračka na ukážku. Teraz nainštalujete **skutočnú aplikáciu**,
prihlásite sa do nej a budete ju mať otvorenú vedľa tohto textu.

Hore v lište máte záložku **Grafana**. Zatiaľ hlási chybu — nič tam ešte nebeží.
Do konca tejto kapitoly sa cez ňu prihlásite.

## Prečo je to iné než podinfo

Chart Grafany je poriadny balík. Pozrite sa, čo všetko by vytvoril:

```terminal:execute
command: |
  helm repo add grafana https://grafana.github.io/helm-charts >/dev/null && helm repo update >/dev/null && helm template g grafana/grafana | grep '^kind:' | sort | uniq -c
```

Sú medzi nimi **ClusterRole** a **ClusterRoleBinding** — cluster-scoped objekty.
Vy ste administrátor jedného namespace, takže na tie práva nemáte a inštalácia by
skončila chybou `Forbidden`.

Toto je najčastejší dôvod, prečo cudzí chart „nejde": nie je pokazený, len chce
viac práv, než máte.

## Najprv si chart prečítajte

```terminal:execute
command: helm show chart grafana/grafana
```

Všimnite si riadok **`deprecated: true`**. Chart síce funguje a balí aktuálnu
Grafanu, ale je označený ako neudržiavaný. Pred nasadením do produkcie je to
presne tá informácia, ktorú chcete vedieť **skôr**, než na ňom postavíte
infraštruktúru.

> **Zvyk, ktorý sa oplatí:** `helm show chart` pred `helm install`. Trvá to dve
> sekundy a povie vám verziu, appVersion aj to, či chart ešte niekto udržiava.

## Values, ktoré to umožnia

```editor:open-file
file: exercises/grafana-values.yaml
```

Kľúčový je `rbac.create: false` — tým chart prestane vytvárať cluster-scoped
objekty. Overte, že to zabralo:

```terminal:execute
command: |
  helm template g grafana/grafana -f ~/exercises/grafana-values.yaml | grep '^kind:' | sort | uniq -c
```

Žiadny ClusterRole ani ClusterRoleBinding — ostali len namespaced objekty.

## Inštalácia

```terminal:execute
command: helm install grafana grafana/grafana -f ~/exercises/grafana-values.yaml --wait --timeout 10m
```

Chvíľu to potrvá — image Grafany je výrazne väčší než podinfo.

```terminal:execute
command: kubectl get deploy,svc,pods -l app.kubernetes.io/name=grafana
```

## Heslo je v Secrete

Chart si vygeneroval náhodné heslo administrátora a uložil ho do Secretu. Pozrite
sa naň:

```terminal:execute
command: kubectl get secret grafana -o jsonpath='{.data}' | head -c 200; echo
```

Hodnoty sú v base64. Vytiahnite si heslo v čitateľnej podobe:

```terminal:execute
command: |
  echo "meno:  admin" && echo "heslo: $(kubectl get secret grafana -o jsonpath='{.data.admin-password}' | base64 -d)"
```

Heslo si skopírujte — o chvíľu ho zadáte.

> **Takto to robia charty bežne.** Namiesto toho, aby vám heslo vypísali do
> terminálu, uložia ho do Secretu a v `NOTES.txt` vám povedia, ako ho získať.
> Skúste si `helm status grafana` a nájdite tam ten istý postup.

## Prihláste sa

Otvorte záložku **Grafana** hore v lište. Ak ste ju mali otvorenú predtým,
obnovte ju — teraz už za ňou niečo beží.

Prihláste sa ako **admin** a heslom z predchádzajúceho kroku.

Ste vnútri reálnej aplikácie, ktorú ste nasadili jedným príkazom Helmu.

## Zmena cez values

Skúste zmeniť niečo, čo hneď uvidíte — napríklad nastavte Grafane vlastný názov
inštancie:

```terminal:execute
command: |
  helm upgrade grafana grafana/grafana -f ~/exercises/grafana-values.yaml --set "grafana\.ini.server.domain=workshop.local" --wait --timeout 5m
```

```terminal:execute
command: helm get values grafana | head -20
```

Rovnaký vzor ako pri podinfe — values súbor ako základ, `--set` na jednu
konkrétnu zmenu.

## Upratanie

Grafana zaberá v namespace dosť miesta, takže ju pred ďalšou kapitolou odstráňte:

```terminal:execute
command: helm uninstall grafana
```

```terminal:execute
command: kubectl get all -l app.kubernetes.io/name=grafana
```

Prázdno — jeden príkaz odstránil Deployment, Service, Secret, ConfigMap aj
ServiceAccount. Záložka Grafana bude znova hlásiť chybu, čo je v poriadku.

## Zhrnutie

V tejto kapitole ste sa naučili:
- Reálne charty často chcú **cluster-scoped objekty** — to je najčastejší dôvod chyby `Forbidden`
- `helm template ... | grep '^kind:'` ukáže, čo chart vytvorí, **pred** inštaláciou
- `helm show chart` prezradí aj to, či je chart ešte udržiavaný (`deprecated: true`)
- Charty ukladajú vygenerované heslá do **Secretov**, nie do výstupu
- `helm uninstall` odstráni celý balík naraz

Ďalej: ako si napísať vlastný chart.
