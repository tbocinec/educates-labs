---
title: Jobs a CronJobs
---

# Úroveň 4B: Jobs a CronJobs

Doteraz sme pracovali s Podmi a Deploymentmi — workloadmi, ktoré bežia
**nepretržite**. Čo ale s úlohami, ktoré majú prebehnúť **raz** a skončiť? Alebo
s úlohami, ktoré sa majú spúšťať **podľa plánu**?

Na to sú **Jobs** a **CronJobs**.

> **Dokumentácia**: [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) | [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Pody vs. Jobs vs. Deployments

| Zdroj | Správanie | Použitie |
|-------|-----------|----------|
| **Pod** | Beží do dokončenia alebo zlyhania | Jednorazové testovanie, ladenie |
| **Deployment** | Udržiava N replík navždy | Webové servery, API, služby |
| **Job** | Beží **do dokončenia**, potom skončí | Spracovanie dát, migrácie, zálohy |
| **CronJob** | Vytvára Jobs **podľa plánu** | Pravidelné reporty, upratovacie úlohy |

## Vytvorenie jednoduchého Jobu

Poďme vytvoriť Job, ktorý počíta číslice čísla Pi. Otvorte cvičný súbor:

```editor:open-file
file: exercises/jobs/job.yaml
```

Kľúčová konfigurácia:

```editor:select-matching-text
file: exercises/jobs/job.yaml
text: backoffLimit
```

- `backoffLimit: 4` — pri zlyhaní skúsi až 4-krát
- `restartPolicy: Never` — container v tom istom Pode sa nereštartuje (vytvorí sa nový Pod)
- Container počíta cez Perl 2000 číslic čísla Pi

Aplikujte Job:

```terminal:execute
command: cp -r ~/exercises/jobs ~/jobs && kubectl apply -f ~/jobs/job.yaml
```

Sledujte priebeh Jobu:

```terminal:execute
command: kubectl get jobs -w
```

Počkajte, kým `COMPLETIONS` ukáže `1/1`, a potom stlačte Ctrl+C:

```terminal:interrupt
```

Pozrite si výsledok:

```terminal:execute
command: kubectl logs job/pi-calculator
```

## Paralelné Jobs

Job vie spustiť viac úloh naraz. Otvorte cvičný súbor:

```editor:open-file
file: exercises/jobs/job-parallel.yaml
```

Kľúčová konfigurácia:

```editor:select-matching-text
file: exercises/jobs/job-parallel.yaml
text: completions
```

- `completions: 4` — Job sa musí dokončiť **4-krát**
- `parallelism: 2` — naraz bežia **2 Pody**

Teda: spolu 4 úlohy, po dvoch naraz, v paralelných dávkach.

Aplikujte a pozorujte:

```terminal:execute
command: kubectl apply -f ~/jobs/job-parallel.yaml
```

Sledujte Pody:

```terminal:execute
command: kubectl get pods -l job-name=parallel-job -w
```

Mali by ste vidieť, ako najprv naštartujú 2 Pody a po ich dokončení ďalšie 2. Keď
sa dokončia všetky 4, sledovanie zastavte:

```terminal:interrupt
```

Skontrolujte stav Jobu:

```terminal:execute
command: kubectl get job parallel-job
```

`4/4` dokončení — všetky úlohy prebehli úspešne!

## Ako Job rieši zlyhanie

Čo sa stane, keď Job zlyhá? `backoffLimit` určuje, koľkokrát to Kubernetes skúsi
znova, než Job označí ako neúspešný.

Otestujme to rýchlym zlyhávajúcim Jobom:

```terminal:execute
command: kubectl create job fail-test --image=busybox -- sh -c "exit 1"
```

Sledujte správanie pri opakovaní:

```terminal:execute
command: kubectl get pods -l job-name=fail-test -w
```

Uvidíte, ako Kubernetes vytvára nové Pody s narastajúcimi odstupmi. Po dosiahnutí
`backoffLimit` (predvolene 6) sa Job označí ako Failed. Zastavte sledovanie:

```terminal:interrupt
```

```terminal:execute
command: kubectl get job fail-test
```

Upracte neúspešný Job:

```terminal:execute
command: kubectl delete job fail-test
```

## CronJobs — spúšťanie podľa plánu

**CronJob** vytvára Jobs podľa plánu, v štandardnom cron formáte.

### Pripomenutie cron formátu

```
┌───────────── minúta (0–59)
│ ┌───────────── hodina (0–23)
│ │ ┌───────────── deň v mesiaci (1–31)
│ │ │ ┌───────────── mesiac (1–12)
│ │ │ │ ┌───────────── deň v týždni (0–6, nedeľa=0)
│ │ │ │ │
* * * * *
```

| Výraz | Význam |
|-------|--------|
| `*/5 * * * *` | Každých 5 minút |
| `0 * * * *` | Každú hodinu |
| `0 2 * * *` | Denne o 2:00 |
| `0 0 * * 0` | Týždenne v nedeľu |

Otvorte cvičný súbor s CronJobom:

```editor:open-file
file: exercises/jobs/cronjob.yaml
```

```editor:select-matching-text
file: exercises/jobs/cronjob.yaml
text: schedule
```

Tento CronJob beží **každú minútu** a vypíše aktuálny čas.

Aplikujte ho:

```terminal:execute
command: kubectl apply -f ~/jobs/cronjob.yaml
```

Skontrolujte CronJob:

```terminal:execute
command: kubectl get cronjobs
```

Počkajte asi 60–90 sekúnd a pozrite sa, či vznikol Job:

```terminal:execute
command: sleep 70 && kubectl get jobs -l app=time-reporter
```

Pozrite si výstup z posledného Jobu:

```terminal:execute
command: kubectl logs job/$(kubectl get jobs -l app=time-reporter -o name | tail -1 | cut -d/ -f2)
```

Počkajte ďalšiu minútu, nech vznikne druhý Job:

```terminal:execute
command: sleep 65 && kubectl get jobs -l app=time-reporter
```

Viac Jobov! Každý z nich vytvoril CronJob podľa plánu.

## Správa CronJobov

Pozastavenie CronJobu (nové Jobs sa prestanú plánovať):

```terminal:execute
command: kubectl patch cronjob time-reporter -p '{"spec":{"suspend":true}}'
```

```terminal:execute
command: kubectl get cronjob time-reporter
```

Stĺpec `SUSPEND` ukazuje `True` — nové Jobs nevzniknú.

Obnovenie:

```terminal:execute
command: kubectl patch cronjob time-reporter -p '{"spec":{"suspend":false}}'
```

## Upratanie

```terminal:execute
command: kubectl delete -f ~/jobs/ 2>/dev/null; kubectl delete job fail-test 2>/dev/null; echo "Cleanup done"
```

## Zhrnutie úrovne 4B

V tejto kapitole ste sa naučili:
- **Jobs** vykonajú úlohu **do dokončenia** — ideálne na dávkové spracovanie
- `completions` a `parallelism` riadia, koľko úloh prebehne a koľko naraz
- `backoffLimit` určuje správanie pri opakovaní po zlyhaní
- **CronJobs** vytvárajú Jobs podľa cron **plánu** (napr. `*/5 * * * *` = každých 5 min)
- CronJobs sa dajú **pozastaviť** a **obnoviť**

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl get jobs` | Výpis Jobov a stavu dokončenia |
| `kubectl logs job/<názov>` | Výstup Jobu |
| `kubectl get cronjobs` | Výpis CronJobov a ďalšieho spustenia |
| `kubectl create job <názov> --image=<img> -- <príkaz>` | Vytvorenie Jobu imperatívne |
| `kubectl patch cronjob <názov> -p '{"spec":{"suspend":true}}'` | Pozastavenie CronJobu |

Tým sme uzavreli všetky štyri úrovne! Prejdite na zhrnutie pre kompletný prehľad.
