---
title: Zhrnutie workshopu
---

# Zhrnutie workshopu

Gratulujeme k dokončeniu workshopu **Základy Kubernetes**! Tu je prehľad všetkého,
čo ste sa naučili.

## Úroveň 1 — Začíname

**Architektúra Kubernetes:**
- Control Plane (API Server, etcd, Scheduler, Controller Manager) riadi klaster
- Worker nodes (kubelet, kube-proxy, container runtime) spúšťajú vaše workloady

**Základy kubectl:**
- `kubectl cluster-info` — informácie o klastri
- `kubectl get` — výpis zdrojov
- `kubectl describe` — podrobnosti o zdroji
- `kubectl explain` — dokumentácia k typom zdrojov
- `kubectl api-resources` — výpis všetkých dostupných typov zdrojov

## Úroveň 2 — Pody

**Imperatívna práca s Podmi:**
- `kubectl run <názov> --image=<image>` — vytvorenie Podu
- `kubectl logs <pod>` — logy containera
- `kubectl exec -it <pod> -- <príkaz>` — spustenie príkazu v containeri
- `kubectl port-forward <pod> <lokálny>:<vzdialený>` — lokálny prístup k Podu
- `kubectl delete pod <názov>` — zmazanie Podu

**Deklaratívne YAML manifesty:**
- Štyri povinné polia: `apiVersion`, `kind`, `metadata`, `spec`
- `kubectl apply -f <súbor>` — vytvorenie alebo aktualizácia z YAML (idempotentné)
- `kubectl delete -f <súbor>` — zmazanie zdrojov definovaných v súbore
- `--dry-run=client -o yaml` — generovanie YAML šablón

## Úroveň 3 — Deployments

**Vytvorenie a škálovanie:**
- `kubectl create deployment` — vytvorenie imperatívne
- `kubectl scale deployment <názov> --replicas=N` — zväčšenie/zmenšenie
- Deployments vytvárajú a spravujú ReplicaSety, tie spravujú Pody
- Self-healing: Kubernetes automaticky nahrádza spadnuté Pody

**Updaty a rollbacky:**
- `kubectl set image deployment <názov> <container>=<image>` — rolling update
- `kubectl rollout status deployment <názov>` — sledovanie priebehu updatu
- `kubectl rollout history deployment <názov>` — história revízií
- `kubectl rollout undo deployment <názov>` — návrat na predchádzajúcu verziu
- `kubectl rollout undo --to-revision=N` — návrat na konkrétnu revíziu

## Úroveň 4 — Konfigurácia

**ConfigMaps:**
- Uchovávajú necitlivú konfiguráciu ako dvojice kľúč-hodnota
- Vytvorenie z hodnôt (`--from-literal`), zo súborov (`--from-file`) alebo z YAML
- Konzumujú sa ako premenné prostredia (`envFrom` / `configMapRef`)
- Alebo sa mountujú ako súbory vo volume (`volumes` / `volumeMounts`)

## Úroveň 5 — Všetko dokopy

Prevádzkovali ste reálnu aplikáciu a použili pritom všetko vyššie naraz:

- **ConfigMap** dodala konfiguráciu, vloženú cez `envFrom`
- **`kubectl port-forward`** sprístupnil Pod bez toho, aby pred ním bola Service
- Naškálovanie na tri repliky a zmazanie jednej ukázalo **self-healing** naživo
- Zmena ConfigMapy dokázala, že **premenné prostredia sa neobnovujú** — bežiace
  containery si držia hodnoty, s ktorými naštartovali
- **`kubectl rollout restart`** vymenil Pody, takže si načítali novú konfiguráciu
- **Rolling update** prešiel na novú verziu image a `rollout undo` sa vrátil späť

**Myšlienka, ktorá je pod tým všetkým:** vy deklarujete, čo má platiť, a
controller nepretržite zmenšuje rozdiel medzi tým a realitou. Nič nereštartujete
ručne.

## Rýchly prehľad kubectl

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl get <zdroj>` | Výpis zdrojov |
| `kubectl describe <zdroj> <názov>` | Podrobnosti |
| `kubectl apply -f <súbor>` | Vytvorenie/aktualizácia z YAML |
| `kubectl delete -f <súbor>` | Zmazanie podľa YAML |
| `kubectl logs <pod>` | Logy |
| `kubectl exec -it <pod> -- <príkaz>` | Príkaz v containeri |
| `kubectl scale deployment <názov> --replicas=N` | Škálovanie |
| `kubectl set image deployment <názov> <c>=<img>` | Zmena image |
| `kubectl rollout undo deployment <názov>` | Rollback |
| `kubectl get <zdroj> -l <kľúč>=<hodnota>` | Filtrovanie podľa labelu |
| `kubectl rollout restart deployment <názov>` | Výmena Podov (načítanie novej konfigurácie) |
| `kubectl port-forward deployment/<názov> <lokálny>:<vzdialený>` | Lokálny prístup k Podu |
| `kubectl explain <zdroj>` | Dokumentácia |

## Čo ďalej?

Vaša aplikácia stále nemá stabilnú adresu — to je prvá vec, ktorú rieši
nasledujúci workshop.

**Ďalej: *Kubernetes: Services, Secrets a úložisko***
- **Labels a selektory do hĺbky** — a namespaces
- **Services** — stabilná adresa a load balancing pre vaše Pody
- **Secrets** — citlivé údaje, riešené oddelene od ConfigMáp
- **Trvalé úložisko** — dáta, ktoré prežijú Pod
- **Probes, Jobs a CronJobs** — kontroly zdravia a dávkové úlohy

**Potom: *Kubernetes: Troubleshooting*** — čo robiť, keď sa čokoľvek z toho
pokazí.

Ďalej za obzorom: Ingress, StatefulSets, Helm a RBAC.

## Dokumentácia

- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Port Forwarding to a Pod](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Ďakujeme za absolvovanie workshopu!
