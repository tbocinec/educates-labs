---
title: Všetko dokopy
---

# Úroveň 5: Všetko dokopy

Doteraz prichádzal každý pojem samostatne. Táto kapitola je iná: vezmete
**reálnu aplikáciu**, nakonfigurujete ju, spustíte, naškálujete, rozbijete a
zaktualizujete — a to len tým, čo už viete.

Aplikáciou je [podinfo](https://github.com/stefanprodan/podinfo), malá webová
služba postavená presne na takéto ukážky. Konfiguráciu číta z premenných
prostredia a hlási späť, čo dostala.

## Plán

| Krok | Čo urobíte | Čo to ukáže |
|------|-----------|-------------|
| 1 | Nasadíte aplikáciu s konfiguráciou z ConfigMapy | ConfigMap a Deployment spolu |
| 2 | Pripojíte sa cez `port-forward` | Ako sa dostať k Podu bez Service |
| 3 | Naškálujete na tri repliky | Deployment stráži počet |
| 4 | Zmažete Pod | Self-healing naživo |
| 5 | Zmeníte ConfigMapu | Prekvapenie — a jeho riešenie |
| 6 | Nasadíte novú verziu | Rolling update na reálnej aplikácii |

## Krok 1: Nasadenie aplikácie

Najprv konfigurácia. Otvorte ConfigMapu:

```editor:open-file
file: exercises/scenario/app-config.yaml
```

Z každého kľúča sa vnútri containera stane premenná prostredia.

```terminal:execute
command: cp -r ~/exercises/scenario ~/scenario && kubectl apply -f ~/scenario/app-config.yaml
```

Teraz Deployment:

```editor:open-file
file: exercises/scenario/app-deployment.yaml
```

Všimnite si blok `envFrom` — načíta **celú** ConfigMapu naraz, namiesto
vymenúvania jednotlivých kľúčov:

```editor:select-matching-text
file: exercises/scenario/app-deployment.yaml
text: envFrom
```

```terminal:execute
command: kubectl apply -f ~/scenario/app-deployment.yaml
```

```terminal:execute
command: kubectl rollout status deployment/podinfo --timeout=120s
```

```terminal:execute
command: kubectl get deployment,pods
```

Jeden Pod, beží. Overte, že naštartoval čisto:

```terminal:execute
command: kubectl logs deployment/podinfo --tail=10
```

## Krok 2: Komunikácia s aplikáciou

Service zatiaľ žiadna nie je — tá príde v ďalšom workshope. K Podu sa však viete
dostať priamo cez **port-forward**, ktorý pretuneluje lokálny port do klastra.

Spustite tunel v **druhom termináli**, nech tam ostane bežať:

```terminal:execute
command: kubectl port-forward deployment/podinfo 8080:9898
session: 2
```

Teraz sa v tomto termináli aplikácie spýtajte na jej vlastný stav:

```terminal:execute
command: curl -s http://localhost:8080/api/info | head -20
```

Pozrite sa na pole `message`. Tento reťazec prešiel z vašej ConfigMapy cez
`envFrom` do prostredia containera a späť von cez HTTP. Zapamätajte si ho —
o chvíľu ho budete meniť.

> **`port-forward` je nástroj na debugovanie, nie spôsob nasadenia.** Beží na
> *vašom* počítači, zomrie po zavretí a obslúži presne jedného používateľa.
> Skutočná prevádzka sa k Podom dostáva cez **Service**, čím začína ďalší
> workshop.

## Krok 3: Škálovanie

```terminal:execute
command: kubectl scale deployment podinfo --replicas=3
```

```terminal:execute
command: kubectl get pods
```

Tri Pody, každý s vlastným názvom a IP. Overte, že Deployment súhlasí:

```terminal:execute
command: kubectl get deployment podinfo
```

`READY 3/3`. Pýtali ste si tri, controller vyrobil tri.

## Krok 4: Sledujte self-healing

Toto je tá časť, pre ktorú sa Kubernetes oplatí. Zmažte Pod a sledujte, čo sa
stane.

Spustite sledovanie v druhom termináli — najprv zastavte port-forward:

```terminal:interrupt
session: 2
```

```terminal:execute
command: kubectl get pods -w
session: 2
```

Teraz z tohto terminálu zmažte jeden Pod:

```terminal:execute
command: kubectl delete pod $(kubectl get pods -l app=podinfo -o name | head -1 | cut -d/ -f2)
```

Sledujte druhý terminál: jeden Pod prejde do stavu `Terminating` a v priebehu
sekúnd sa objaví náhrada. Nikto o nový Pod nežiadal — ReplicaSet si všimol, že
skutočnosť sa odchýlila od trojky, a opravil to.

```terminal:execute
command: kubectl get deployment podinfo
```

Stále `3/3`. Zastavte sledovanie:

```terminal:interrupt
session: 2
```

> **Nikto nič nereštartoval.** Deployment deklaruje, *čo* má platiť. Celá úloha
> controllera je zmenšovať rozdiel medzi tým a realitou — nepretržite a bez
> vyzvania.

## Krok 5: Zmena konfigurácie (a prekvapenie)

Upravte ConfigMapu a zmeňte správu:

```terminal:execute
command: kubectl patch configmap podinfo-config --type=merge -p '{"data":{"PODINFO_UI_MESSAGE":"Configuration changed!"}}'
```

Overte, že sa ConfigMap naozaj zmenila:

```terminal:execute
command: kubectl get configmap podinfo-config -o jsonpath='{.data.PODINFO_UI_MESSAGE}{"\n"}'
```

Teraz znova spustite tunel a spýtajte sa aplikácie:

```terminal:execute
command: kubectl port-forward deployment/podinfo 8080:9898
session: 2
```

```terminal:execute
command: curl -s http://localhost:8080/api/info | grep message
```

**Stále ukazuje pôvodnú správu.** ConfigMap sa zmenila, aplikácia si to
nevšimla.

### Prečo

Premenné prostredia dostane proces **raz, pri štarte containera**. Nič ich potom
znovu nenačíta. Bežiace containery stále držia hodnoty, ktoré dostali pri
spustení.

V produkcii na to ľudia narážajú pravidelne: konfigurácia je zmenená, nič
nespadne, nič nezaloguje chybu — a staré správanie potichu pokračuje.

### Riešenie

Vymeňte Pody, nech nové containery naštartujú s novými hodnotami:

```terminal:execute
command: kubectl rollout restart deployment/podinfo
```

```terminal:execute
command: kubectl rollout status deployment/podinfo --timeout=120s
```

Port-forward zomrel spolu so svojím Podom, tak ho spustite znova:

```terminal:interrupt
session: 2
```

```terminal:execute
command: kubectl port-forward deployment/podinfo 8080:9898
session: 2
```

```terminal:execute
command: curl -s http://localhost:8080/api/info | grep message
```

`Configuration changed!` — nové Pody si pri štarte načítali novú ConfigMapu.

> **ConfigMapy namountované ako *volume* sa správajú inak** — tie súbory sa
> aktualizujú za behu, bez reštartu. Obe formy ste videli v kapitole o
> ConfigMapách. Presne v tomto je medzi nimi rozdiel.

## Krok 6: Nasadenie novej verzie

Posledný krok: aktualizujte samotnú aplikáciu, spôsobom z kapitoly 6.

```terminal:execute
command: kubectl set image deployment/podinfo app=ghcr.io/stefanprodan/podinfo:6.14.0
```

```terminal:execute
command: kubectl rollout status deployment/podinfo --timeout=120s
```

Overte, že sa bežiaca verzia zmenila:

```terminal:execute
command: kubectl get deployment podinfo -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Pozrite si históriu rolloutov:

```terminal:execute
command: kubectl rollout history deployment/podinfo
```

A ak sa vám to nepáčilo:

```terminal:execute
command: kubectl rollout undo deployment/podinfo
```

```terminal:execute
command: kubectl rollout status deployment/podinfo --timeout=120s
```

```terminal:execute
command: kubectl get deployment podinfo -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Späť tam, kde ste boli — bez výpadku a bez ručného zasahovania do Podov.

## Upratanie

Zastavte port-forward:

```terminal:interrupt
session: 2
```

```terminal:execute
command: kubectl delete -f ~/scenario/
```

```terminal:execute
command: kubectl get all
```

## Zhrnutie

V tejto kapitole ste spojili celý workshop dokopy:

- **ConfigMap** dodala konfiguráciu, vloženú cez `envFrom`
- **Deployment** spustil aplikáciu a strážil počet replík
- **`kubectl port-forward`** sprístupnil Pod bez toho, aby pred ním bola Service
- **Self-healing** nahradil zmazaný Pod bez toho, aby o to niekto žiadal
- **Premenné prostredia sa neobnovujú** — po zmene ConfigMapy treba `kubectl rollout restart`
- **Rolling update** prešiel na nový image a `rollout undo` sa vrátil späť

Jediné, čo aplikácii ešte chýba, je stabilná adresa: **Service**. Tam začína
workshop *Kubernetes: Services, Secrets a úložisko*.
