---
title: Services
---

# Services

**Service** je abstrakcia v Kubernetes, ktorá poskytuje **stabilný sieťový
koncový bod** pre sadu Podov. Rieši problém pominuteľných IP adries
z predchádzajúcej kapitoly.

> **Dokumentácia**: [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

## Ako Service funguje

Service pracuje takto:
1. **Vyberá Pody** podľa labelu — nájde všetky Pody zodpovedajúce jej `selector`
2. **Poskytuje stabilnú IP** — dostane vlastnú ClusterIP, ktorá sa nemení
3. **Rozkladá záťaž** — požiadavky rozdeľuje medzi všetky vyhovujúce Pody
4. **Vytvára DNS názov** — automaticky sa zaregistruje v DNS klastra

```
Klient → Service (stabilná IP + DNS) → rozklad záťaže → Pod 1
                                                      → Pod 2
                                                      → Pod 3
```

## Typy Services

Kubernetes podporuje niekoľko typov:

| Typ | Popis | Dostupné odkiaľ |
|-----|-------|-----------------|
| **ClusterIP** | Predvolený. Stabilná interná IP. | Len zvnútra klastra |
| **NodePort** | Vystaví službu na IP každého nodu na pevnom porte. | Zvonku klastra |
| **LoadBalancer** | Vytvorí externý load balancer (v cloude). | Zvonku klastra |
| **ExternalName** | Namapuje na DNS názov (bez proxy). | Zvnútra klastra |

Na tomto workshope sa sústredíme na **ClusterIP** — najbežnejší typ a základ pre
všetky ostatné.

## Vytvorenie Service imperatívne

Najrýchlejšia cesta k Service je `kubectl expose`:

```terminal:execute
command: kubectl expose deployment backend --name=backend-quick --port=9898 --target-port=9898
```

Pozrite si Service:

```terminal:execute
command: kubectl get services
```

Všimnite si:
- **CLUSTER-IP** — stabilná interná IP adresa
- **PORT(S)** — port, na ktorom Service počúva

Otestujte ju z klientského Podu:

```terminal:execute
command: |
  kubectl exec client -- wget -qO- http://backend-quick:9898/api/info | grep -o '"hostname": "[^"]*"'
```

Funguje! Service sa rozlíši cez DNS klastra a nasmeruje požiadavku na jeden z
backend Podov.

Upracte imperatívne vytvorenú Service:

```terminal:execute
command: kubectl delete service backend-quick
```

## Vytvorenie Service z YAML

Poďme vytvoriť Service cez YAML manifest. Otvorte cvičný súbor:

```editor:open-file
file: exercises/services/backend-service.yaml
```

Kľúčové polia:

```editor:select-matching-text
file: exercises/services/backend-service.yaml
text: 'type: ClusterIP'
```

- `type: ClusterIP` — dostupná len v rámci klastra
- `selector.app: backend` — vyberá Pody s labelom `app=backend`
- `port: 9898` — port, na ktorom Service počúva
- `targetPort: 9898` — port na cieľových Podoch

Aplikujte Service:

```terminal:execute
command: kubectl apply -f ~/services/backend-service.yaml
```

## Detaily Service

Cez describe si pozrite konfiguráciu a endpointy:

```terminal:execute
command: kubectl describe service backend-svc
```

Pozrite sa na riadok **Endpoints** — obsahuje IP adresy všetkých Podov, ktoré
vyhoveli selektoru. Na tieto adresy sa prevádzka reálne smeruje.

Endpointy si viete zobraziť aj priamo:

```terminal:execute
command: kubectl get endpoints backend-svc
```

## Service discovery cez DNS

Z klientského Podu otestujte prístup cez názov Service:

```terminal:execute
command: |
  kubectl exec client -- wget -qO- http://backend-svc:9898/api/info | grep -o '"hostname": "[^"]*"'
```

Názov funguje preto, lebo DNS v Kubernetes rozloží `backend-svc` na ClusterIP
tejto Service.

### DNS formáty

Na Service sa dá dostať viacerými DNS formátmi:

| Formát | Príklad |
|--------|---------|
| `<service>` | `backend-svc` (rovnaký namespace) |
| `<service>.<namespace>` | `backend-svc.<váš-namespace>` |
| `<service>.<namespace>.svc.cluster.local` | `backend-svc.<váš-namespace>.svc.cluster.local` |

Otestujte plne kvalifikovaný názov:

```terminal:execute
command: |
  NS=$(kubectl config view --minify -o jsonpath='{..namespace}') && kubectl exec client -- wget -qO- http://backend-svc.$NS.svc.cluster.local:9898/api/info | grep -o '"hostname": "[^"]*"'
```

## Load balancing naživo

Toto je tá časť, kvôli ktorej sme si za backend zvolili podinfo: na endpointe
`/api/info` každý Pod vráti okrem iného aj **svoj vlastný hostname**, čo je
presne názov Podu, ktorý požiadavku obslúžil.

Najprv si pripomeňte, ako sa tie tri Pody volajú:

```terminal:execute
command: kubectl get pods -l app=backend
```

Teraz pošlite šesť požiadaviek za sebou a sledujte iba hostname v odpovedi:

```terminal:execute
command: |
  for i in 1 2 3 4 5 6; do kubectl exec client -- wget -qO- http://backend-svc:9898/api/info | grep -o '"hostname": "[^"]*"'; done
```

Názvy sa striedajú — každá požiadavka skončila na inom Pode. Presne to robí
Service: jedna adresa, za ňou tri Pody.

Porovnajte to s prístupom priamo na jeden Pod, kde sa hostname nemení:

```terminal:execute
command: |
  BACKEND_IP=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].status.podIP}') && for i in 1 2 3; do kubectl exec client -- wget -qO- http://$BACKEND_IP:9898/api/info | grep -o '"hostname": "[^"]*"'; done
```

> **Nie je to presné striedanie dokola.** `kube-proxy` v režime iptables vyberá
> cieľový Pod pre každé nové spojenie **náhodne** s rovnakou pravdepodobnosťou.
> Pri šiestich požiadavkách preto pokojne môžete uvidieť jeden Pod dvakrát a iný
> ani raz — dôležité je, že sa názvy menia. Ak by ste chceli rovnomernejšie
> rozloženie, spustite ten cyklus na viac opakovaní.

## Services a labels — to spojenie

Services si hľadajú svoje Pody cez **label selektory**. Overme si to:

```terminal:execute
command: echo "--- Service selector ---" && kubectl get service backend-svc -o jsonpath='{.spec.selector}' && echo && echo "--- Pod labels ---" && kubectl get pods -l app=backend --show-labels
```

Selektor Service (`app=backend`) sa zhoduje s labelmi na backend Podoch. Ak Pod
zodpovedajúci label nemá, Service naň prevádzku smerovať nebude.

## Odstránenie Podu zo Service

Pod viete zo Service vyradiť bez toho, aby ste ho mazali — stačí mu zmeniť label:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend -o name | head -1) && kubectl label $POD app=backend-debug --overwrite && echo "Relabeled $POD"
```

Pozrite si endpointy:

```terminal:execute
command: kubectl get endpoints backend-svc
```

O jeden endpoint menej! Prelabelovaný Pod ďalej beží, ale už nie je súčasťou
Service. Hodí sa to na ladenie jedného konkrétneho Podu v izolácii.

Vráťte label späť:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend-debug -o name | head -1) && kubectl label $POD app=backend --overwrite && echo "Restored $POD"
```

## Upratanie

Upracte všetky zdroje z úrovne 1:

```terminal:execute
command: kubectl delete -f ~/services/
```

Overte, že je všetko upratané:

```terminal:execute
command: kubectl get pods,services
```

## Zhrnutie úrovne 1

V tejto kapitole ste sa naučili:
- **Services** poskytujú stabilnú IP a DNS názov pre premenlivú sadu Podov
- **ClusterIP** je predvolený typ — dostupný v rámci klastra
- Services si cez **label selektory** hľadajú svoje cieľové Pody
- **DNS** v Kubernetes automaticky rozlišuje názvy Services (napr. `backend-svc` → ClusterIP)
- Services **rozkladajú záťaž** medzi všetky vyhovujúce Pody
- Pod sa dá zo Service vyradiť zmenou labelov (užitočné pri ladení)

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl expose deployment <názov>` | Vytvorenie Service imperatívne |
| `kubectl get services` | Výpis Services |
| `kubectl describe service <názov>` | Detaily Service a jej endpointy |
| `kubectl get endpoints <názov>` | IP adresy Podov za Service |

Ďalej sa pozrieme na **Secrets** — bezpečný spôsob, ako v Kubernetes narábať
s citlivými údajmi!
