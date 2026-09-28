---
title: Zhrnutie workshopu
---

# Zhrnutie workshopu

Gratulujeme! Dokončili ste workshop **Kubernetes: Services, Secrets a úložisko**. 🎉

Tu je prehľad všetkého, čo ste prešli naprieč štyrmi úrovňami.

---

## Úroveň 1: Labels, selektory a namespaces

Naučili ste sa, ako si Kubernetes hľadá veci.

**Kľúčové pojmy:**
- **Labels** sú dvojice kľúč-hodnota, **selektory** podľa nich filtrujú
- Selektory na rovnosť (`app=web`), nerovnosť (`tier!=frontend`) a množinové (`version in (1.0, 2.0)`)
- `kubectl label` pridáva, prepisuje (`--overwrite`) a odoberá (`kľúč-`) labels
- **Namespaces** rozdeľujú klaster; `-n <ns>` mieri na jeden, `-A` na všetky
- Controllery stoja na selektoroch — takto si Deployment nájde svoje Pody, a rovnako aj Service

**Kľúčové príkazy:**
```
kubectl get pods --show-labels
kubectl get pods -l app=web
kubectl label pod <názov> kľúč=hodnota --overwrite
kubectl get namespaces
```

---

## Úroveň 1: Sieťovanie a Services

Naučili ste sa, ako Pody komunikujú a ako im **Services** dávajú stabilné
koncové body.

**Kľúčové pojmy:**
- Každý Pod má vlastnú IP, ale IP adresy Podov sú **pominuteľné**
- **Services** poskytujú **stabilnú IP a DNS názov** pre sadu Podov
- **ClusterIP** je predvolený typ Service (len interne)
- Services si hľadajú cieľové Pody cez **label selektory**
- **DNS** klastra automaticky rozlišuje názvy Services
- Services **rozkladajú záťaž** medzi vyhovujúce Pody

**Kľúčové príkazy:**
```
kubectl expose deployment <názov> --port=<port>   # Vytvorenie Service
kubectl get services                               # Výpis Services
kubectl get endpoints <názov>                      # IP Podov za Service
kubectl describe service <názov>                   # Detaily Service
```

---

## Úroveň 2: Secrets

Naučili ste sa bezpečne narábať s **citlivými údajmi**.

**Kľúčové pojmy:**
- **Secrets** uchovávajú heslá, tokeny, certifikáty (kódované cez base64)
- Vytvorenie cez `kubectl create secret` alebo z YAML (`stringData` pre čistý text)
- Konzumácia ako **premenné prostredia** (`envFrom`) alebo ako **volume mount**
- Secrets cez volume sa **aktualizujú samy**, cez premenné prostredia **nie**

**Kľúčové príkazy:**
```
kubectl create secret generic <názov> --from-literal=kľúč=hodnota
kubectl get secret <názov> -o jsonpath='{.data.kľúč}' | base64 -d
kubectl describe secret <názov>
```

---

## Úroveň 3: Trvalé úložisko

Naučili ste sa, ako **udržať dáta** aj po zániku Podu.

**Kľúčové pojmy:**
- Úložisko Podu je predvolene pominuteľné
- **PersistentVolumeClaim (PVC)** je požiadavka o úložisko z klastra
- **PersistentVolume (PV)** je samotný zdroj úložiska
- Dáta v PVC prežijú **zmazanie Podu**
- **StorageClasses** umožňujú dynamické vytváranie úložiska
- **Reclaim policy** rozhoduje o osude dát pri zmazaní PVC

**Kľúčové príkazy:**
```
kubectl get pvc                    # Výpis PVC
kubectl get pv                     # Výpis PV
kubectl describe pvc <názov>       # Detaily PVC
kubectl get storageclasses         # Dostupné StorageClasses
```

---

## Úroveň 4: Probes, Jobs a CronJobs

Naučili ste sa, ako Kubernetes rieši **self-healing** a **dávkové spracovanie**.

**Probes:**
- **Liveness probe** → reštartuje container, keď je nezdravý
- **Readiness probe** → prestane naň smerovať prevádzku, keď nie je pripravený
- Metódy: HTTP GET, TCP Socket, Exec (príkaz)

**Jobs a CronJobs:**
- **Jobs** bežia do dokončenia (dávkové úlohy, spracovanie dát)
- `completions` + `parallelism` na paralelné vykonávanie
- **CronJobs** vytvárajú Jobs podľa plánu (cron syntax)

**Kľúčové príkazy:**
```
kubectl get jobs                                   # Výpis Jobov
kubectl logs job/<názov>                           # Výstup Jobu
kubectl get cronjobs                               # Výpis CronJobov
kubectl create job <názov> --image=<img> -- cmd    # Rýchly Job
```

---

## Kompletný prehľad kubectl

### Zdroje preberané na tomto workshope

| Zdroj | Výpis | Detaily | Vytvorenie | Zmazanie |
|-------|-------|---------|------------|----------|
| Service | `kubectl get svc` | `kubectl describe svc <názov>` | `kubectl expose` | `kubectl delete svc <názov>` |
| Secret | `kubectl get secret` | `kubectl describe secret <názov>` | `kubectl create secret` | `kubectl delete secret <názov>` |
| PVC | `kubectl get pvc` | `kubectl describe pvc <názov>` | `kubectl apply -f` | `kubectl delete pvc <názov>` |
| Job | `kubectl get jobs` | `kubectl describe job <názov>` | `kubectl create job` | `kubectl delete job <názov>` |
| CronJob | `kubectl get cronjob` | `kubectl describe cronjob <názov>` | `kubectl apply -f` | `kubectl delete cronjob <názov>` |

### Bežné vzory

```
kubectl get <zdroj> -o wide          # Viac stĺpcov
kubectl get <zdroj> -o yaml          # Kompletný YAML výstup
kubectl get <zdroj> -w               # Sledovanie zmien
kubectl describe <zdroj> <názov>     # Podrobnosti + udalosti
kubectl logs <pod>                   # Logy containera
kubectl exec <pod> -- <príkaz>       # Príkaz v Pode
kubectl apply -f <súbor>             # Vytvorenie/aktualizácia z YAML
kubectl delete -f <súbor>            # Zmazanie zdrojov podľa YAML
```

---

## Oficiálna dokumentácia Kubernetes

Oplatí sa uložiť do záložiek:

- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## Čo ďalej?

S dvoma dokončenými workshopmi máte solídny základ. Ďalšie témy na preskúmanie:

**Hneď nadväzuje: *Kubernetes: Troubleshooting*** — čo robiť, keď sa čokoľvek
z tohto pokazí.

- **Ingress** — sprístupnenie HTTP/HTTPS ciest k Services
- **NetworkPolicies** — riadenie prevádzky medzi Podmi
- **RBAC** — riadenie prístupu podľa rolí
- **Helm** — balíčkovací systém pre Kubernetes
- **StatefulSets** — pre stavové aplikácie (databázy)
- **Operators** — automatizácia správy zložitých aplikácií

Ďakujeme za absolvovanie workshopu! 🚀
