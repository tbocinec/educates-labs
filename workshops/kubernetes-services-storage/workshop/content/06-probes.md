---
title: Liveness a readiness probes
---

# Úroveň 4A: Liveness a readiness probes

Ako Kubernetes zistí, či je vaša aplikácia zdravá? Predvolene kontroluje len to,
či **proces containera beží**. Bežiaci proces však neznamená, že aplikácia naozaj
funguje — môže byť zaseknutá v deadlocku, dochádzať jej pamäť alebo sa nevedieť
pripojiť k databáze.

**Probes** vám umožňujú definovať vlastné kontroly zdravia, takže Kubernetes tieto
situácie zistí a automaticky z nich vyjde.

> **Dokumentácia**: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

## Typy probes

| Probe | Na čo slúži | Pri zlyhaní |
|-------|-------------|-------------|
| **Liveness** | Žije container ešte? | **Reštartuje** container |
| **Readiness** | Je container pripravený obsluhovať? | **Vyradí** ho z endpointov Service |
| **Startup** | Naštartoval už container? | Blokuje ostatné probes, kým neuspeje |

### Metódy kontroly

| Metóda | Ako funguje | Príklad |
|--------|-------------|---------|
| **HTTP GET** | Pošle HTTP požiadavku, úspech = 2xx/3xx | `httpGet: {path: /health, port: 8080}` |
| **TCP Socket** | Otvorí TCP spojenie | `tcpSocket: {port: 3306}` |
| **Exec** | Spustí príkaz, úspech = návratový kód 0 | `exec: {command: [cat, /tmp/healthy]}` |

## Zdravý Pod s probes

Začnime niečím, čo je nastavené správne. Otvorte cvičný súbor:

```editor:open-file
file: exercises/probes/pod-probes.yaml
```

Kľúčová konfigurácia:

```editor:select-matching-text
file: exercises/probes/pod-probes.yaml
text: livenessProbe
```

- **livenessProbe**: HTTP GET na `/` na porte 80, kontrola každých 10 s, štart po 5 s
- **readinessProbe**: HTTP GET na `/` na porte 80, kontrola každých 5 s, štart po 3 s

Aplikujte a sledujte:

```terminal:execute
command: cp -r ~/exercises/probes ~/probes && kubectl apply -f ~/probes/pod-probes.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/healthy-app --timeout=60s
```

Skontrolujte stav Podu — všimnite si stĺpec `READY`:

```terminal:execute
command: kubectl get pod healthy-app
```

`1/1` znamená, že readiness probe prešla a Pod je pripravený prijímať prevádzku.

Cez describe si pozrite konfiguráciu probes:

```terminal:execute
command: kubectl describe pod healthy-app | grep -A5 -E "Liveness|Readiness"
```

## Zlyhávajúca liveness probe

Teraz si ukážme, čo sa stane, keď liveness probe **zlyhá**. Otvorte cvičný súbor:

```editor:open-file
file: exercises/probes/pod-liveness-fail.yaml
```

Tento Pod má šikovné nastavenie:
1. Pri štarte vytvorí súbor `/tmp/healthy`
2. Po **15 sekundách** ho zmaže
3. Liveness probe kontroluje, či súbor existuje
4. Keď súbor zmizne, probe **zlyhá** a Kubernetes container **reštartuje**

Aplikujte a sledujte naživo. Na sledovanie použite druhý terminál:

```terminal:execute
command: kubectl apply -f ~/probes/pod-liveness-fail.yaml
```

Teraz v druhom termináli sledujte stav Podu cez `-w`:

```terminal:execute
command: kubectl get pod liveness-fail -w
session: 2
```

Počkajte asi **minútu**. Mali by ste vidieť, ako narastie počítadlo `RESTARTS`
na 1.

> **Prečo to trvá tak dlho?** Aplikácia zmaže súbor po 15 sekundách, probe beží
> každých 5 sekúnd a `failureThreshold: 2` znamená, že Kubernetes potrebuje dve
> zlyhania po sebe. K tomu treba prirátať čas na stiahnutie image a naplánovanie
> Podu. Prvý reštart preto reálne uvidíte okolo 60. sekundy.

Keď uvidíte aspoň jeden reštart, sledovanie zastavte:

```terminal:interrupt
session: 2
```

Pozrite si udalosti a zistite, čo presne sa stalo:

```terminal:execute
command: kubectl describe pod liveness-fail | tail -15
```

Mali by ste vidieť udalosti ako:
- `Liveness probe failed: cat: /tmp/healthy: No such file or directory`
- `Container liveness-fail failed liveness probe, will be restarted`

Toto je **self-healing** v Kubernetes — automaticky rozpozná nezdravé containery
a reštartuje ich.

## Readiness vs liveness — prečo obe?

Predstavte si webovú aplikáciu, ktorej štart trvá 30 sekúnd:

- Bez probes: Kubernetes pošle prevádzku okamžite → používatelia uvidia chyby
- **Readiness probe**: hovorí Kubernetes „neposielaj mi prevádzku, kým nie som pripravený"
- **Liveness probe**: hovorí Kubernetes „reštartuj ma, keď sa zaseknem"

```
Pod štartuje → readiness probe zlyháva (ešte nie je pripravený)
               → žiadna prevádzka do Podu
               → aplikácia dokončí načítanie
               → readiness probe prejde
               → prevádzka začne prúdiť
               → neskôr sa aplikácia zasekne v deadlocku
               → liveness probe zlyhá
               → Kubernetes container reštartuje
```

## Časové parametre probes

Správanie probes doladíte týmito parametrami:

| Parameter | Predvolené | Popis |
|-----------|-----------|-------|
| `initialDelaySeconds` | 0 | Čakanie pred prvou kontrolou |
| `periodSeconds` | 10 | Čas medzi kontrolami |
| `timeoutSeconds` | 1 | Maximálne čakanie na odpoveď |
| `successThreshold` | 1 | Koľko úspechov po sebe znamená úspech |
| `failureThreshold` | 3 | Koľko zlyhaní po sebe znamená zlyhanie |

> **Tip**: `initialDelaySeconds` nastavte dosť vysoko, aby stihla aplikácia
> naštartovať. Príliš nízka hodnota = zbytočné reštarty.

## Upratanie

```terminal:execute
command: kubectl delete -f ~/probes/ 2>/dev/null; echo "Cleanup done"
```

## Zhrnutie úrovne 4A

V tejto kapitole ste sa naučili:
- **Liveness probes** odhaľujú zaseknuté containery → Kubernetes ich **reštartuje**
- **Readiness probes** odhaľujú nepripravené containery → Kubernetes im **prestane posielať prevádzku**
- Metódy kontroly: **HTTP GET**, **TCP Socket**, **Exec** (príkaz)
- Probes sú základom **self-healingu** — automatické zistenie problému a zotavenie
- Časové parametre umožňujú správanie probes doladiť

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl describe pod <názov>` | Konfigurácia probes a udalosti |
| `kubectl get pod <názov> -w` | Sledovanie reštartov naživo |
| `kubectl get events --sort-by=.lastTimestamp` | Chronologický výpis udalostí |

Ďalej sa pozrieme na **Jobs a CronJobs** — dávkové a plánované úlohy!
