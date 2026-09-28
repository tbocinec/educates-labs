---
title: Deployments a škálovanie
---

# Úroveň 3: Deployments

V predchádzajúcich kapitolách ste vytvárali samostatné Pody. Tie však majú svoje
obmedzenia:

- **Žiadne self-healing** — keď Pod zomrie, ostane mŕtvy
- **Žiadne škálovanie** — nedá sa jednoducho spustiť viac identických Podov
- **Žiadne rolling updates** — pri zmene image musíte Pod ručne zmazať a vytvoriť znova

**Deployment** rieši všetky tri. Je to štandardný spôsob, ako prevádzkovať
bezstavové (stateless) aplikácie v Kubernetes.

> **Dokumentácia**: [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Čo je Deployment?

Deployment spravuje **ReplicaSet**, ktorý zase spravuje sadu identických
**Podov**.

```
Deployment
  └── ReplicaSet
        ├── Pod 1
        ├── Pod 2
        └── Pod 3
```

Controller Deploymentu nepretržite dbá na to, aby skutočný stav zodpovedal tomu
požadovanému:
- Chcete 3 repliky? Vytvorí a udržiava presne 3 Pody.
- Pod spadne? Controller automaticky vytvorí náhradu.
- Treba zmeniť image? Vykoná rolling update bez výpadku.

## Vytvorenie Deploymentu imperatívne

Najrýchlejšia cesta k Deploymentu:

```terminal:execute
command: kubectl create deployment my-nginx --image=nginx:1.26 --replicas=2
```

Pozrite si výsledok:

```terminal:execute
command: kubectl get deployments
```

A Pody, ktoré Deployment vytvoril:

```terminal:execute
command: kubectl get pods
```

Všimnite si vzor v názvoch Podov: `{názov-deploymentu}-{hash-replicasetu}-{hash-podu}`.

## Preskúmanie Deploymentu

Zobrazte podrobné informácie o Deploymente:

```terminal:execute
command: kubectl describe deployment my-nginx
```

Pozrite si kľúčové sekcie:
- **Replicas** — požadované vs. aktuálne vs. dostupné
- **StrategyType** — ako sa aplikujú updaty (predvolene RollingUpdate)
- **Pod Template** — šablóna, z ktorej vznikajú Pody
- **Events** — čo Kubernetes urobil

Zobrazte podkladový ReplicaSet:

```terminal:execute
command: kubectl get replicasets
```

ReplicaSet je objekt, ktorý reálne stráži počet Podov. S ReplicaSetmi priamo
pracujete len zriedka — spravuje ich za vás Deployment.

## Vytvorenie Deploymentu z YAML

Zmažme imperatívne vytvorený Deployment a použime radšej YAML manifest:

```terminal:execute
command: kubectl delete deployment my-nginx
```

Otvorte cvičný súbor v editore:

```editor:open-file
file: exercises/deployment/deployment.yaml
```

Prejdite si kľúčové sekcie:

```editor:select-matching-text
file: exercises/deployment/deployment.yaml
text: replicas: 3
```

- `replicas: 3` — bežať budú 3 identické Pody
- `selector.matchLabels` — podľa čoho si Deployment nájde svoje Pody
- `template` — šablóna Podu (metadata + spec)

> **Dôležité**: `selector.matchLabels` sa musí zhodovať s
> `template.metadata.labels`. Práve takto Deployment vie, ktoré Pody sú jeho.

Skopírujte a aplikujte manifest:

```terminal:execute
command: cp -r ~/exercises/deployment ~/deployment && kubectl apply -f ~/deployment/deployment.yaml
```

Sledujte, ako Pody nabiehajú (zastavíte cez Ctrl+C):

```terminal:execute
command: kubectl get pods -w
session: 2
```

Skontrolujte stav Deploymentu:

```terminal:execute
command: kubectl get deployment nginx-deployment
```

## Škálovanie Deploymentu

Naškálujte Deployment na 5 replík:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=5
```

Sledujte, ako pribúdajú nové Pody:

```terminal:execute
command: kubectl get pods
```

Zmenšite späť na 2:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=2
```

Skontrolujte, že prebytočné Pody sa ukončujú:

```terminal:execute
command: kubectl get pods
```

> **Tip**: Škálovať sa dá aj úpravou Deploymentu:
> `kubectl edit deployment nginx-deployment` a zmenou poľa `replicas`.

## Self-healing naživo

Poďme si ukázať self-healing. Najprv si zistite aktuálne názvy Podov:

```terminal:execute
command: kubectl get pods -o name
```

Teraz jeden z Podov ručne zmažte:

```terminal:execute
command: POD=$(kubectl get pods -l app=nginx -o name | head -1) && kubectl delete $POD
```

Hneď potom sa pozrite na Pody:

```terminal:execute
command: kubectl get pods
```

Všimnite si, že Kubernetes už začal vytvárať **náhradný Pod**, aby dodržal
požadovaný počet 2 replík. To je self-healing v praxi!

## Stav rolloutu

Skontrolujte stav rolloutu Deploymentu:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment
```

Ukáže vám, či Deployment dokončil nasadenie všetkých svojich Podov.

## Rozhranie Headlamp

Prepnite sa na záložku **Headlamp** a pozrite si svoj namespace vo webovom UI.
Deployment, jeho ReplicaSet aj jednotlivé Pody uvidíte graficky.

Headlamp ponúka:
- Prehľad zdrojov a ich zdravotný stav
- Udalosti a logy naživo
- Detaily zdrojov v YAML/JSON, aj s editorom

Otvorte **Workloads → Deployments** a kliknite na `nginx-deployment`. Detail
stránky ukazuje to isté čo `kubectl describe`, plus živý pohľad na Pody, ktoré
Deployment vlastní.

## Zhrnutie

V tejto kapitole ste sa naučili:
- **Deployments** spravujú ReplicaSety, ktoré spravujú Pody
- `kubectl create deployment` — vytvorenie imperatívne
- `kubectl apply -f` — vytvorenie z YAML manifestu
- `kubectl scale deployment` — zmena počtu replík
- `kubectl describe deployment` — detaily Deploymentu
- `kubectl rollout status` — kontrola priebehu rolloutu
- Self-healing: Kubernetes automaticky nahrádza spadnuté Pody

V ďalšej kapitole sa naučíte aktualizovať aplikácie a robiť rollbacky bez
výpadku!
