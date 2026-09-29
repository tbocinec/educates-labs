---
title: Nájsť a nainštalovať
---

# Úroveň 1: Nájsť a nainštalovať

# ČASŤ 1 — Používanie Helmu

Začneme z pohľadu používateľa: niekto už chart napísal a vy ho chcete nasadiť.
Toto je zďaleka najčastejšia práca s Helmom.

## Tri pojmy a ideme

| Pojem | Čo to je |
|-------|----------|
| **Chart** | Balíček — šablónované manifesty plus predvolené hodnoty |
| **Release** | Jedna inštalácia chartu, so svojím názvom |
| **Repozitár** | Index chartov, z ktorého sa dajú sťahovať |

Ten istý chart viete nainštalovať aj päťkrát pod piatimi názvami a Helm každú
inštaláciu sleduje samostatne. To je celý rozdiel medzi *chartom* a *releasom*.

> **Dokumentácia**: [Three Big Concepts](https://helm.sh/docs/intro/using_helm/#three-big-concepts)

## Pridanie repozitára

Helm prichádza bez nastavených repozitárov. Pridajte si jeden:

```terminal:execute
command: helm repo add podinfo https://stefanprodan.github.io/podinfo
```

`podinfo` je malá demo webová aplikácia, postavená presne na takéto cvičenia.

```terminal:execute
command: helm repo update
```

## Nájdenie chartu

```terminal:execute
command: helm search repo podinfo
```

Sú tam dve čísla verzií a znamenajú rôzne veci: **CHART VERSION** je verzia
zabalenia, **APP VERSION** verzia softvéru vnútri.

## Čo sa dá nastaviť?

Než niečo nainštalujete, pozrite sa, aké má chart gombíky:

```terminal:execute
command: helm show values podinfo/podinfo | head -30
```

Každý riadok je niečo, čo viete prebiť. Toto je **verejné API chartu** a je to
prvá vec, ktorú si pri akomkoľvek charte oplatí prečítať.

## Inštalácia

```terminal:execute
command: helm install my-app podinfo/podinfo --wait
```

`--wait` spôsobí, že Helm počká, kým sú zdroje naozaj pripravené, namiesto toho,
aby sa vrátil hneď.

Vo výstupe si všimnite názov releasu, stav `deployed`, číslo revízie `1` a
poznámky chartu (`NOTES.txt`), ktoré hovoria, ako sa k aplikácii dostať.

## Čo vzniklo?

```terminal:execute
command: helm list
```

A ten istý pohľad z pohľadu Kubernetes:

```terminal:execute
command: kubectl get deploy,svc -l app.kubernetes.io/managed-by=Helm
```

> **Filtrujte podľa `managed-by=Helm`, nie podľa názvu chartu.** Helm dáva
> objektom predponu podľa názvu releasu — váš Deployment sa volá
> `my-app-podinfo`, nie `podinfo`.

Pody v tom výpise ale nie sú. Skúste to:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

Nič. **Pody totiž nevytvára Helm** — vytvára ich ReplicaSet zo šablóny
v Deploymente, takže nesú labels z tej šablóny, nie Helmove. Filtrujte ich podľa
názvu:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/name=my-app-podinfo
```

Je to drobnosť, ktorá mätie prekvapivo často: `managed-by=Helm` funguje na
objekty, ktoré Helm sám vytvoril (Deployment, Service, Secret, ConfigMap), nie na
to, čo z nich následne vzniklo.

Stav releasu:

```terminal:execute
command: helm status my-app
```

## Funguje to?

Podinfo počúva na porte 9898. Overte to zvnútra klastra:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 10 http://my-app-podinfo:9898/version
```

Aplikácia odpovie svojou verziou.

## Odinštalovanie

Zatiaľ si to len ukážme na druhom releasi — nainštalujte ten istý chart ešte raz
pod iným názvom:

```terminal:execute
command: helm install my-second-app podinfo/podinfo --wait
```

```terminal:execute
command: helm list
```

Dva releasy, dva Deploymenty, žiadna kolízia. Ten druhý odstráňte:

```terminal:execute
command: helm uninstall my-second-app
```

```terminal:execute
command: helm list
```

`helm uninstall` odstráni všetko, čo release vytvoril. Žiadne dohľadávanie
zvyškov.

**`my-app` nechajte bežať** — budete s ním pracovať v ďalšej kapitole.

## Zhrnutie

V tejto kapitole ste sa naučili:
- **Chart** = balíček, **release** = jedna jeho inštalácia, **repozitár** = index
- `helm repo add` a `helm repo update` — sprístupnenie chartov
- `helm show values` — verejné API chartu, čítajte ho ako prvé
- `helm install --wait` — inštalácia, ktorá počká na pripravenosť
- Objekty majú predponu podľa releasu a label `managed-by=Helm` — ale Pody nie, tie vyrába ReplicaSet
- `helm uninstall` upratuje po sebe

Ďalej: ako chart prinútiť robiť to, čo chcete vy.
