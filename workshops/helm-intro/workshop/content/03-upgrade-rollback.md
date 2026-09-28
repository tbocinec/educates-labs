---
title: Návrat po zlom nasadení
---

# Úroveň 3: Návrat po zlom nasadení

Toto je vlastnosť, ktorá ospravedlňuje existenciu Helmu. Obyčajný `kubectl apply`
si nepamätá, aký bol predchádzajúci stav. Helm si drží každú revíziu a návrat
späť je jeden príkaz.

## História releasu

```terminal:execute
command: helm history my-app
```

Každá inštalácia a upgrade je očíslovaná **revízia**. Jedna je `deployed`,
ostatné `superseded`.

> **Dokumentácia**: [Helm Rollback](https://helm.sh/docs/helm/helm_rollback/)

## Zámerné rozbitie

Poďme vydať zlý release tak, ako sa to stáva v praxi — preklep v tagu image:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --set image.tag=6.99-does-not-exist --wait --timeout 90s
```

Príkaz chvíľu čaká a nakoniec zlyhá, lebo `--wait` sa nevráti, kým nie sú Pody
pripravené — a tie pripravené nikdy nebudú.

Pozrite si škody:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

`ImagePullBackOff`. A release:

```terminal:execute
command: helm history my-app
```

Najnovšia revízia je označená ako `failed`.

> **Neúspešný upgrade aj tak vytvorí revíziu.** Helm ten pokus zaznamená —
> história má byť poctivá v tom, čo sa skúšalo.

## Rollback

Jeden príkaz a ste späť:

```terminal:execute
command: helm rollback my-app --wait
```

Bez čísla revízie sa Helm vráti o jednu späť. Overte:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

```terminal:execute
command: helm history my-app
```

Všimnite si, čo história ukazuje: rollback je sám o sebe **novou revíziou**
s popisom „Rollback to N". Helm históriu nikdy neprepisuje — iba dopĺňa.

Vrátiť sa dá aj na konkrétnu revíziu, napríklad na úplne prvú inštaláciu:

```terminal:execute
command: helm rollback my-app 1 --wait
```

```terminal:execute
command: helm get values my-app
```

Prázdno — revízia 1 bola holá inštalácia bez prebitých values. Rollback teda
obnoví **aj values** tej revízie, nielen jej images.

Vráťte sa do nakonfigurovaného stavu:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --wait
```

## Upratanie

```terminal:execute
command: helm uninstall my-app
```

```terminal:execute
command: kubectl get all -l app.kubernetes.io/managed-by=Helm
```

Všetko je preč, vrátane histórie.

## Zhrnutie

V tejto kapitole ste sa naučili:
- Každá inštalácia a upgrade je očíslovaná revízia
- Zaznamenávajú sa aj neúspešné upgrady
- `helm rollback` bez čísla sa vráti o jednu revíziu späť
- Rollback históriu **dopĺňa**, nikdy nič nemaže
- Rollback obnoví aj **values** danej revízie, nielen images

Tým končí prvá časť — vedeli by ste teraz nasadiť a prevádzkovať cudzí chart.
Druhá časť je o tom, ako si napísať vlastný.
