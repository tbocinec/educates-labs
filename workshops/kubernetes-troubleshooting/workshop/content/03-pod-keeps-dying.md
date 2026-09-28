---
title: Pod naštartuje a zomrie
---

# Úroveň 3: Pod naštartuje a zomrie

Príznak: počítadlo reštartov stále rastie. Pod bliká medzi `Running` a `Error` a
nakoniec sa ustáli na `CrashLoopBackOff`.

Dobrá správa: container **bežal**, takže tentoraz logy *existujú*. Trik je
vypýtať si tie správne.

## Scenár 3: CrashLoopBackOff

```editor:open-file
file: broken/03-crashloop/pod-crashloop.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/03-crashloop/pod-crashloop.yaml
```

### Pozorovanie

Sledujte, ako rastie počet reštartov. Spustite to v **druhom termináli** a
nechajte bežať:

```terminal:execute
command: kubectl get pod worker -w
session: 2
```

Medzitým si tu skontrolujte stav:

```terminal:execute
command: kubectl get pod worker
```

Pod sa točí dokola: `Running` → `Error` → `CrashLoopBackOff` → `Running` → … Každý
reštart čaká dlhšie než predošlý (10 s, 20 s, 40 s… strop je 5 minút).

### Diagnostika

Vypýtajte si logy tým zrejmým spôsobom:

```terminal:execute
command: kubectl logs worker
```

Podľa načasovania dostanete výstup aktuálneho pokusu — alebo vôbec nič, ak je
container práve medzi reštartmi. To je tá pasca. Vypýtajte si radšej
**predchádzajúci** container:

```terminal:execute
command: kubectl logs worker --previous
```

A je to tu: `FATAL: cannot open /etc/worker/config.yaml`. Aplikácia vám presne
povedala, čo potrebovala.

> **Ak uvidíte `unable to retrieve container logs for containerd://...`**, trafili
> ste Pod uprostred reštartu — starý container je preč a nový ešte nič
> nezalogoval. Počkajte pár sekúnd a príkaz zopakujte. Je to súboj s časovaním,
> nie pokazený klaster.

Overte, ako sa ukončil:

```terminal:execute
command: kubectl get pod worker -o jsonpath='reason={.status.containerStatuses[0].lastState.terminated.reason} exit={.status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}'
```

`Error` s návratovým kódom `1` — aplikácia sa ukončila sama. Porovnajte to
s nasledujúcim scenárom, kde návratový kód rozpráva úplne iný príbeh.

Zastavte sledovanie v druhom termináli:

```terminal:interrupt
session: 2
```

### Príčina

Aplikácia potrebuje konfiguračný súbor, ktorý jej nikto nenamountoval.
V produkcii je to takmer vždy jedno z tohto:

| Návratový kód | Zvyčajne znamená |
|---------------|------------------|
| `1` | Chyba aplikácie — prečítajte si logy, povedala vám to |
| `137` | `SIGKILL` — takmer vždy OOMKilled (nižšie) |
| `143` | `SIGTERM` — ukončenie na požiadanie, často zlyhávajúca liveness probe |
| `127` | Príkaz sa nenašiel — zlý `command`/`args` alebo zlý image |

### Oprava a overenie

Skutočnou opravou je namountovať konfiguráciu. Zmažte rozbitý Pod:

```terminal:execute
command: kubectl delete pod worker --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/03-crashloop/pod-fixed.yaml
```

```terminal:execute
command: kubectl get pod worker-fixed
```

```terminal:execute
command: kubectl logs worker-fixed
```

Worker si konfiguráciu nájde a ďalej beží.

```terminal:execute
command: kubectl delete -f ~/broken/03-crashloop/pod-fixed.yaml --ignore-not-found
```

## Scenár 4: OOMKilled

Rovnaký príznak „stále zomiera", ale aplikácia sa ani nestihne posťažovať.

```editor:open-file
file: broken/04-oom/pod-oom.yaml
```

Tento Pod zapisuje 200 MB do volume v pamäti, pričom má limit pamäte **64 Mi**.

```terminal:execute
command: kubectl apply -f ~/broken/04-oom/pod-oom.yaml
```

### Pozorovanie

```terminal:execute
command: kubectl get pod memory-hog
```

### Diagnostika

Počkajte pár sekúnd a prečítajte si dôvod ukončenia:

```terminal:execute
command: kubectl get pod memory-hog -o jsonpath='reason={.status.containerStatuses[0].state.terminated.reason} exit={.status.containerStatuses[0].state.terminated.exitCode}{"\n"}'
```

`OOMKilled`, návratový kód `137`. Teraz si pozrite logy:

```terminal:execute
command: kubectl logs memory-hog
```

Všimnite si, čo **chýba**: žiadna chyba, žiadny stack trace, žiadna rozlúčka.
Jadro proces zabilo okamžite — aplikácia nemala šancu čokoľvek zalogovať. Prázdny
log plus návratový kód 137 je podpis OOM killu.

Vidieť to aj cez `describe`:

```terminal:execute
command: kubectl describe pod memory-hog | grep -A6 "Last State"
```

A porovnajte, o čo si Pod pýtal:

```terminal:execute
command: kubectl get pod memory-hog -o jsonpath='limits={.spec.containers[0].resources.limits}{"\n"}'
```

### Príčina

Container prekročil svoj `resources.limits.memory`. Limit vynucuje OOM killer
v jadre — Kubernetes sa nepýta pekne.

> **Limity pamäte sú tvrdé, limity CPU nie.** Pri prekročení limitu CPU sa
> container len *spomalí* (throttling). Pri prekročení limitu pamäte sa *zabije*.
> Táto asymetria ľudí prekvapuje.

### Oprava a overenie

Sú dve poctivé opravy: dať mu viac pamäte, alebo aplikáciu naučiť spotrebovať
menej. Tu workload naozaj potrebuje ~200 MB, takže zdvihneme limit:

```terminal:execute
command: kubectl delete pod memory-hog --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/04-oom/pod-oom-fixed.yaml
```

```terminal:execute
command: kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/memory-hog-fixed --timeout=120s
```

```terminal:execute
command: kubectl logs memory-hog-fixed
```

Dokončí sa a vypíše `done`.

> **Zdvihnúť limit nie je vždy správne.** Ak aplikácii uniká pamäť, väčší limit
> len oddiali pád. Predtým, než si zvolíte číslo, pozrite si reálnu spotrebu cez
> `kubectl top pod` (tam, kde je dostupný metrics-server).

Upracte:

```terminal:execute
command: kubectl delete -f ~/broken/04-oom/pod-oom-fixed.yaml --ignore-not-found
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- `CrashLoopBackOff` znamená, že bežal a skončil — čítajte `kubectl logs --previous`
- Odstupy medzi reštartmi rastú až na 5 minút, takže oprava sa môže zdať pomalá
- Kód `1` = aplikácia zlyhala a zalogovala prečo; kód `137` = OOMKilled a nezalogovala nič
- **Prázdny log s kódom 137** je odtlačok prsta limitu pamäte
- Limity pamäte zabíjajú, limity CPU len spomaľujú

Ďalej: Pody, ktoré sa ani nedostanú na node.
