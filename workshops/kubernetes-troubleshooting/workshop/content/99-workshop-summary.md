---
title: Zhrnutie workshopu
---

# Zhrnutie workshopu

Gratulujeme! Zdiagnostikovali ste osem rozbitých workloadov v piatich
kategóriách. 🎉

Nešlo však o tých osem chybových hlášok — išlo o metódu, ktorá je pod nimi.

---

## Metóda

```
1. kubectl get pods              → v akom stave, koľko reštartov?
2. kubectl describe pod <názov>  → prečo sa Kubernetes rozhodol takto?
3. kubectl get events            → čo sa dialo a v akom poradí?
4. kubectl logs <názov>          → čo povedala samotná aplikácia?
```

Dve pravidlá, ktoré ušetria najviac času:

- **Ak container nikdy nenaštartoval, logy neexistujú.** Kroky 1–3 vám povedia, či má krok 4 vôbec zmysel.
- **Ak `kubectl apply` vypísal chybu, objekt neexistuje.** Prestaňte hľadať Pod na popísanie.

---

## Diagnóza podľa príznaku

| Príznak | Pravdepodobná príčina | Príkaz, ktorý to dokáže |
|---------|----------------------|--------------------------|
| `ImagePullBackOff` | Zlý tag, privátny registry, limit sťahovania | `describe` → Events |
| `CreateContainerConfigError` | Chýbajúci kľúč v ConfigMape/Secrete | `describe` → Events |
| `CrashLoopBackOff` | Aplikácia padá pri štarte | `logs --previous` |
| `OOMKilled` / kód 137 | Prekročený limit pamäte | `describe` → Last State |
| `Pending` | Scheduler nenašiel vhodný node | `describe` → `FailedScheduling` |
| Chyba pri `apply` | Admission (LimitRange/kvóta) | samotný text chyby |
| Beží, ale je nedostupná | Nesúlad selektora alebo portu | `kubectl get endpoints` |

---

## Návratové kódy, ktoré sa oplatí pamätať

| Kód | Význam |
|-----|--------|
| `0` | Čisté ukončenie — pri dlhobežiacej aplikácii aj tak zvyčajne chyba |
| `1` | Chyba aplikácie — logy povedia prečo |
| `127` | Príkaz sa nenašiel — zlý `command`/`args` alebo zlý image |
| `137` | `SIGKILL` — takmer vždy OOMKilled |
| `143` | `SIGTERM` — ukončenie na požiadanie, často zlyhávajúca liveness probe |

---

## Kde poruchy vznikajú

Keď viete, *ktorý* subsystém vás odmietol, viete aj kam sa pozrieť:

| Fáza | Kto rozhoduje | Príznak | Dôkaz |
|------|---------------|---------|-------|
| **Admission** | API server, LimitRange, kvóta | `apply` zlyhá | Text chyby |
| **Scheduling** | Scheduler | `Pending` | Udalosť `FailedScheduling` |
| **Štart** | kubelet | `ImagePullBackOff`, chyby konfigurácie | Udalosti Podu |
| **Runtime** | Container / jadro | `CrashLoopBackOff`, `OOMKilled` | `logs --previous`, Last State |
| **Sieť** | Service / EndpointSlice | Beží, ale nedostupné | `get endpoints` |

---

## Ťahák na príkazy

### Prvý pohľad

```
kubectl get pods -o wide                        # stav, reštarty, node, IP
kubectl get events --sort-by=.lastTimestamp     # chronologický príbeh
kubectl get events --field-selector type=Warning
```

### Zúženie problému

```
kubectl describe pod <názov>                    # udalosti + konfigurácia + posledný stav
kubectl describe pod <názov> | grep -A10 Events:
kubectl logs <názov>                            # aktuálny container
kubectl logs <názov> --previous                 # ten, ktorý zomrel
kubectl logs -l app=<label> --tail=50           # podľa labelu, všetky repliky
```

### Pohľad dovnútra

```
kubectl exec -it <pod> -- sh                    # shell v containeri
kubectl exec <pod> -- printenv                  # aké premenné naozaj dostal?
kubectl debug <pod> -it --image=busybox         # efemérny container, netreba shell
```

### Sieť

```
kubectl get endpoints <service>                 # jediný príkaz, na ktorom záleží
kubectl describe service <service>
kubectl get pods --show-labels                  # porovnanie so selektorom
```

### Limity a kvóty

```
kubectl describe limitrange
kubectl describe resourcequota
kubectl top pod                                 # reálna spotreba (treba metrics-server)
```

---

## Čo sme nepokryli

Tento workshop ostal v rámci jedného namespace, kde žije väčšina porúch. S čím sa
stretnete neskôr:

- **Zlyhávajúce probes** — readiness probe, ktorá nikdy neprejde, potichu vyprázdni endpointy
- **Problémy s nodmi** — nody v stave `NotReady`, tlak na disk, evikcie
- **Odmietnutia z RBAC** — chyby `Forbidden` od ServiceAccountu s malými právami
- **Zlyhania DNS** — `nslookup` vnútri Podu, keď prestane fungovať rozlišovanie mien
- **Init containery** — zaseknuté `Init:0/1`, samostatná kategória porúch

---

## Oficiálna dokumentácia Kubernetes

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Debug Running Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)
- [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Ďakujeme za absolvovanie workshopu! 🚀
