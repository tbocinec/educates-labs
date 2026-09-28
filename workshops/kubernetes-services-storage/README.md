# Workshop: Kubernetes — Services, Secrets a úložisko

Nadväzujúci praktický workshop o sieťovaní v Kubernetes, práci s citlivými
údajmi, trvalom úložisku, kontrolách zdravia a dávkových úlohách.

## Dĺžka

~105 minút

## Predpoklady

- Absolvovanie workshopu **Základy Kubernetes** (alebo rovnocenná znalosť
  kubectl, Podov, Deploymentov, škálovania, rolling updates a ConfigMáp)

## Obsah

### Úroveň 1 — Organizácia a prepojenie
- Labels a selektory do hĺbky (rovnosť, množinové, `kubectl label`)
- Namespaces
- Sieťový model Podov a DNS klastra
- Services (ClusterIP) — sprístupnenie a objavovanie aplikácií

### Úroveň 2 — Konfigurácia a Secrets
- Secrets — práca s citlivými údajmi (premenné prostredia, volume mount)
- Porovnanie s ConfigMapami

### Úroveň 3 — Úložisko
- PersistentVolumeClaims (PVC) — požiadavka o trvalé úložisko a jeho mountovanie
- Pretrvanie dát naprieč reštartmi Podov

### Úroveň 4 — Spoľahlivosť a dávkové úlohy
- Liveness a readiness probes — automatické kontroly zdravia
- Jobs a CronJobs — jednorazové a plánované dávkové úlohy

## Vlastnosti

- Webové UI na vizuálnu správu klastra
- Pripravené cvičné YAML súbory s komentármi
- Integrovaný editor kódu na prezeranie a úpravu manifestov
- Rozdelený terminál na paralelné spúšťanie príkazov

## Jazyk

Workshop je v slovenčine, technické pojmy a príkazy sú ponechané v angličtine.

## Odkazy na oficiálnu dokumentáciu

- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
