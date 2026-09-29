---
title: Sieťovanie Podov a DNS
---

# Sieťovanie Podov a DNS

Než sa pustíme do Services, poďme pochopiť, ako funguje sieť vnútri Kubernetes
klastra.

## Sieťový model Kubernetes

Kubernetes má jednoduchý, ale silný sieťový model. Tri základné pravidlá:

1. **Každý Pod dostane vlastnú IP adresu** — Pody nezdieľajú IP tak, ako to môžu robiť containery na jednom hostiteľovi
2. **Všetky Pody sa navzájom dovidia** — bez NAT, bez ohľadu na to, na ktorom node bežia
3. **Agenti na node dovidia na všetky Pody na tom node** — kubelet a kube-proxy sa dostanú ku ktorémukoľvek Podu

Na úrovni siete sa teda Pody správajú ako virtuálne stroje v plochej sieti —
každý Pod dosiahne na každý iný podľa IP.

## Vytvorenie testovacích Podov

Poďme si to ukázať. Najprv vytvorte Deployment s tromi backend Podmi:

```terminal:execute
command: cp -r ~/exercises/services ~/services
```

Otvorte manifest Deploymentu:

```editor:open-file
file: exercises/services/backend-deployment.yaml
```

```terminal:execute
command: kubectl apply -f ~/services/backend-deployment.yaml
```

Počkajte, kým budú všetky Pody pripravené:

```terminal:execute
command: kubectl get pods -l app=backend -o wide
```

Všimnite si stĺpec `IP` — každý Pod má vlastnú adresu v rámci klastra.

## Komunikácia medzi Podmi

Vytvorte klientský Pod na otestovanie spojenia:

```editor:open-file
file: exercises/services/client-pod.yaml
```

```terminal:execute
command: kubectl apply -f ~/services/client-pod.yaml
```

Počkajte, kým bude pripravený:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/client --timeout=60s
```

Teraz sa z klientského Podu skúsme dostať na backend Pod **priamo cez IP**.
Najprv si zistite IP jedného backend Podu:

```terminal:execute
command: |
  BACKEND_IP=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].status.podIP}') && echo "Backend Pod IP: $BACKEND_IP"
```

Otestujte spojenie z klientského Podu:

```terminal:execute
command: |
  BACKEND_IP=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].status.podIP}') && kubectl exec client -- wget -qO- http://$BACKEND_IP:9898/api/info | grep -o '"hostname": "[^"]*"'
```

Funguje! Pody na seba priamo dosiahnu cez IP adresu — a v odpovedi vidíte
hostname toho Podu, ktorý ju obslúžil.

## Problém s IP adresami Podov

Lenže je tu háčik. IP adresy Podov sú **pominuteľné** — menia sa vždy, keď Pod
vznikne nanovo.

Ukážme si to. Zmažte jeden z backend Podov:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend -o name | head -1) && kubectl delete $POD
```

Keďže ide o Deployment, náhradný Pod vznikne automaticky. Pozrite si IP adresy
znova:

```terminal:execute
command: kubectl get pods -l app=backend -o wide
```

Nový Pod má **inú IP adresu**! Keby sa váš klient pripájal na tú starú, teraz by
to spadlo.

Presne toto rieši **Service** — poskytuje **stabilný koncový bod** pred
premenlivou sadou Podov.

## DNS v klastri

V klastri beží DNS server (zvyčajne CoreDNS). Automaticky vytvára DNS záznamy pre
zdroje Kubernetes.

Pozrime sa, ako vyzerá rozlišovanie mien zvnútra Podu:

```terminal:execute
command: kubectl exec client -- cat /etc/resolv.conf
```

Všimnite si riadok `nameserver` ukazujúci na DNS službu klastra a domény v
`search`. Práve vďaka nim môžete používať krátke názvy (napríklad `backend-svc`)
namiesto plného (`backend-svc.<váš-namespace>.svc.cluster.local`).

> **Dokumentácia**: [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

## Zhrnutie

V tejto kapitole ste sa naučili:
- Každý Pod dostane v rámci klastra vlastnú IP adresu
- Pody spolu vedia komunikovať priamo cez IP
- IP adresy Podov sú **pominuteľné** — pri opätovnom vytvorení Podu sa menia
- Kubernetes má vstavané **DNS klastra** na rozlišovanie mien
- **Services** riešia problém pominuteľných IP adries (na to sa pozrieme hneď teraz!)

Poďme vytvoriť Service, ktorá dá našim backend Podom stabilný koncový bod.
