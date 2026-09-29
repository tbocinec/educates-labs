---
title: Updaty a rollbacky
---

# Updaty a rollbacky

Jedna z najsilnejších vlastností Deploymentov v Kubernetes je schopnosť
**aktualizovať aplikáciu bez výpadku** a **vrátiť zmenu späť**, keď sa niečo
pokazí.

> **Dokumentácia**: [Rolling Update Strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment)

## Stratégia RollingUpdate

Deployments predvolene používajú stratégiu **RollingUpdate**:
- Postupne vznikajú nové Pody s aktualizovanou konfiguráciou
- Postupne sa ukončujú staré Pody
- V žiadnom okamihu nie sú nedostupné všetky Pody naraz

Správanie riadia dva kľúčové parametre:
- `maxSurge` — koľko Podov navyše smie počas updatu vzniknúť (predvolene 25 %)
- `maxUnavailable` — koľko Podov smie byť počas updatu nedostupných (predvolene 25 %)

## Aktuálny stav

Pozrime sa na stav Deploymentu z predchádzajúcej kapitoly:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

Všimnite si stĺpec `IMAGE` — mal by ukazovať `nginx:1.26`. Poďme ho aktualizovať
na `nginx:1.27`.

Najprv sa vráťte na 3 repliky, nech je ukážka názornejšia:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=3
```

## Update cez kubectl set image

Príkaz `kubectl set image` je najrýchlejší spôsob, ako zmeniť container image.

Spustite sledovanie Podov v druhom termináli:

```terminal:execute
command: kubectl get pods -w
session: 2
```

Teraz v prvom termináli spustite rolling update:

```terminal:execute
command: kubectl set image deployment nginx-deployment nginx=nginx:1.27
```

Sledujte výstup v druhom termináli — uvidíte, ako postupne vznikajú nové Pody a
ukončujú sa staré.

Keď je update hotový, stlačte v druhom termináli `Ctrl+C`.

Skontrolujte aktualizovaný Deployment:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

V stĺpci `IMAGE` by teraz malo byť `nginx:1.27`.

## Update cez YAML súbor

V praxi by ste upravili YAML manifest a aplikovali zmenu. Otvorte aktualizovaný
manifest:

```editor:open-file
file: exercises/deployment/deployment-v2.yaml
```

Všimnite si zmenený image:

```editor:select-matching-text
file: exercises/deployment/deployment-v2.yaml
text: 'image: nginx:1.27'
```

Tento súbor obsahuje `nginx:1.27` (ktorý sme už aplikovali). V reálnom
workflow by ste YAML upravili, commitli do Gitu a aplikovali.

## Stav rolloutu

Stav rolloutu si viete kedykoľvek overiť:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment
```

## História rolloutov

Každý update vytvorí novú revíziu. Zobrazte si históriu revízií:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

Detaily konkrétnej revízie:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment --revision=1
```

```terminal:execute
command: kubectl rollout history deployment nginx-deployment --revision=2
```

Všimnite si, že sa medzi revíziami líšia verzie image.

## Zaznamenávanie zmien

Stĺpec `CHANGE-CAUSE` v histórii rolloutov je predvolene prázdny. Kontext mu
doplníte prepínačom `--record` (zastaraný, ale funguje) alebo anotáciou
Deploymentu:

```terminal:execute
command: kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="Updated image to nginx:1.27"
```

Pozrite si históriu znova:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

## Simulácia zlého updatu

Nasimulujme neúspešný update tak, že nastavíme neexistujúci image:

```terminal:execute
command: kubectl set image deployment nginx-deployment nginx=nginx:99.99.99
```

```terminal:execute
command: kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="Updated to non-existent image nginx:99.99.99" --overwrite
```

Pozrite sa na Pody:

```terminal:execute
command: kubectl get pods
```

Uvidíte nové Pody zaseknuté v stave `ImagePullBackOff` alebo `ErrImagePull` —
Kubernetes nevie nájsť image `nginx:99.99.99`.

Skontrolujte stav rolloutu:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment --timeout=30s
```

Rollout sa nedokončí, lebo nové Pody nevedia naštartovať. Všimnite si však, že
časť **starých Podov** stále beží — stratégia rolling update chráni dostupnosť aj
počas prechodu.

## Rollback

Tu sa rollbacky ukážu v plnej kráse. Vráťte posledný update:

```terminal:execute
command: kubectl rollout undo deployment nginx-deployment
```

Pozrite sa na Pody:

```terminal:execute
command: kubectl get pods
```

Chybné Pody sa ukončia a obnoví sa predchádzajúca funkčná verzia.

Overte image:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

Mali by ste znova vidieť `nginx:1.27` (predchádzajúca funkčná revízia).

## Rollback na konkrétnu revíziu

Vrátiť sa dá aj na konkrétne číslo revízie:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

Návrat na revíziu 1 (pôvodný `nginx:1.26`):

```terminal:execute
command: kubectl rollout undo deployment nginx-deployment --to-revision=1
```

Skontrolujte výsledok:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

## ReplicaSety počas updatov

Každý update vytvorí nový ReplicaSet. Pozrime si ich všetky:

```terminal:execute
command: kubectl get replicasets
```

Všimnite si:
- Jeden ReplicaSet má aktuálny požadovaný počet Podov
- Predchádzajúce ReplicaSety majú `DESIRED` = 0, ale **ostávajú zachované** kvôli rollbackom

Presne takto si Kubernetes drží históriu revízií — každá revízia je jeden
ReplicaSet.

## Upratanie

Pred ďalšou kapitolou Deployment upracte:

```terminal:execute
command: kubectl delete deployment nginx-deployment
```

Overte, že je všetko upratané:

```terminal:execute
command: kubectl get pods
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- **Rolling updates** — zmena image bez výpadku cez `kubectl set image` alebo `kubectl apply -f`
- `kubectl rollout status` — sledovanie priebehu rolling updatu
- `kubectl rollout history` — história updatov a revízií
- `kubectl rollout undo` — návrat na predchádzajúcu verziu
- `kubectl rollout undo --to-revision=N` — návrat na konkrétnu revíziu
- Každý update vytvorí nový **ReplicaSet** (staré sa zachovávajú kvôli rollbacku)
- Rolling update chráni dostupnosť aj pri nepodarenom nasadení

Ďalej sa pozrieme na **ConfigMap** — spôsob, akým Kubernetes rieši konfiguráciu
aplikácií!
