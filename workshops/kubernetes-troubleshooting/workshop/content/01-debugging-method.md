---
title: Metóda, ktorá funguje
---

# Úroveň 1: Metóda, ktorá funguje

Než sa dotkneme čohokoľvek rozbitého, dohodnime sa na metóde. Takmer každý
problém s Podom vyrieši rovnaká štvorica krokov, v tomto poradí:

| Krok | Príkaz | Odpovedá na |
|------|--------|-------------|
| **1. Stav** | `kubectl get pods` | V akom je stave? Koľko reštartov? |
| **2. Popis** | `kubectl describe pod <názov>` | Prečo sa Kubernetes rozhodol takto? |
| **3. Udalosti** | `kubectl get events --sort-by=.lastTimestamp` | Čo sa dialo a v akom poradí? |
| **4. Logy** | `kubectl logs <názov>` | Čo povedala *samotná aplikácia*? |

Najčastejšia chyba je skočiť rovno na krok 4. Ak container nikdy nenaštartoval,
**nemá žiadne logy** — a vy budete civieť na prázdny výstup a rozmýšľať, čo je
zle. Kroky 1–3 vám povedia, či logy vôbec existujú.

> **Dokumentácia**: [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

## Čítanie stĺpca STATUS

`kubectl get pods` ukazuje STATUS, ktorý problém zúži už sám o sebe:

| STATUS | Význam | Kam sa pozrieť ďalej |
|--------|--------|----------------------|
| `Pending` | Ešte nie je naplánovaný na node | `describe` → Events (scheduler) |
| `ContainerCreating` | Naplánovaný, kubelet ho pripravuje | `describe` → Events (kubelet) |
| `ImagePullBackOff` | Image sa nepodarilo stiahnuť | `describe` → Events, skontrolovať názov image |
| `CreateContainerConfigError` | Zlý odkaz na ConfigMap/Secret | `describe` → Events |
| `CrashLoopBackOff` | Naštartoval, skončil a reštartuje sa | `logs --previous` |
| `Running`, ale `0/1` ready | Zlyháva readiness probe | `describe` → konfigurácia probe, `logs` |
| `OOMKilled` | Prekročil limit pamäte | `describe` → Last State, zvýšiť limit alebo opraviť únik |

Túto tabuľku si nechajte otvorenú. Na workshope použijete každý jej riadok.

## Príprava

Skopírujte si rozbité manifesty do domovského adresára, nech sa dajú voľne
upravovať:

```terminal:execute
command: cp -r ~/exercises ~/broken && ls ~/broken
```

## Zdravý východiskový bod

Začnime niečím, čo funguje, aby ste vedeli, ako vyzerá „normálne".

```terminal:execute
command: kubectl create deployment healthy --image=nginx:1.27 --replicas=1
```

```terminal:execute
command: kubectl get pods -l app=healthy
```

Zdravý Pod ukazuje `1/1  Running  0` — jeden z jedného containera pripravený,
beží, nula reštartov. Čokoľvek iné je príbeh, ktorý stojí za prečítanie.

Pozrite sa, čo o funkčnom Pode hovorí `describe`, nech máte s čím porovnávať tie
rozbité:

```terminal:execute
command: kubectl describe deployment healthy | tail -12
```

Sekcia **Events** na konci je tá, ktorú ľudia preskakujú. Je to klaster
rozprávajúci o vlastných rozhodnutiach, v chronologickom poradí.

## Udalosti sú denník klastra

Udalosti sú samostatné objekty s krátkou životnosťou (predvolene asi hodina).
Vypíšte ich pre celý namespace, od najstarších:

```terminal:execute
command: kubectl get events --sort-by=.lastTimestamp
```

Tento jediný príkaz často stačí na odhalenie problému bez toho, aby ste čokoľvek
popisovali. Dva varianty, ktoré sa oplatí pamätať:

```terminal:execute
command: kubectl get events --field-selector type=Warning
```

Len varovania — signál bez šumu z každého úspešného stiahnutia a naplánovania.

## Štyri príkazy, ktoré sa oplatí mať poruke

```terminal:execute
command: kubectl get pods -o wide
```

`-o wide` pridá node a IP Podu — užitočné, keď zlobí len časť replík.

```terminal:execute
command: kubectl describe pod -l app=healthy | grep -A10 Events:
```

Skok rovno na sekciu Events konkrétneho Podu.

```terminal:execute
command: kubectl logs -l app=healthy --tail=20
```

Logy podľa labelu, takže nepotrebujete vygenerovaný názov Podu.

```terminal:execute
command: kubectl exec deploy/healthy -- nginx -v
```

Spustenie príkazu *vnútri* containera — posledná záchrana, keď klaster vyzerá
v poriadku, ale aplikácia s tým nesúhlasí.

## Upratanie

```terminal:execute
command: kubectl delete deployment healthy
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- Poradie, ktoré funguje: **stav → describe → udalosti → logy**
- Container, ktorý nikdy nenaštartoval, **nemá logy** — nezačínajte tam
- Stĺpec STATUS zúži príčinu na hŕstku možností
- `kubectl get events --sort-by=.lastTimestamp` je najrýchlejší prvý pohľad
- `--field-selector type=Warning` odfiltruje udalosti na samotné problémy

Poďme to použiť. V ďalšej kapitole Pod, ktorý vôbec nenaštartuje.
