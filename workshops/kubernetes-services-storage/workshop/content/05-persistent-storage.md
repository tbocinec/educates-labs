---
title: Trvalé úložisko
---

# Úroveň 3: Trvalé úložisko

Všetky dáta vnútri Podu sú predvolene **pominuteľné** — zmiznú, keď sa Pod zmaže
alebo reštartuje. Pre databázy, logy a akúkoľvek stavovú aplikáciu potrebujete
**trvalé úložisko**.

> **Dokumentácia**: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

## Pojmy okolo úložiska

Úložisko v Kubernetes stojí na troch objektoch:

| Objekt | Čo robí | Kto ho vytvára |
|--------|---------|----------------|
| **PersistentVolume (PV)** | Predstavuje kus úložiska v klastri | Správca klastra alebo dynamický provisioner |
| **PersistentVolumeClaim (PVC)** | Požiadavka používateľa o úložisko | Vy (vývojár) |
| **StorageClass** | Určuje, ako sa úložisko dynamicky vytvára | Správca klastra |

Typický postup:
1. Vytvoríte **PVC** s požiadavkou na konkrétne úložisko (napr. „potrebujem 1Gi")
2. Kubernetes **dynamicky vytvorí** PV, ktorý požiadavke vyhovuje
3. PVC **namountujete** vo svojom Pode
4. Úložisko pretrvá, aj keď Pod zmažete

```
Vy → PVC ("potrebujem 1Gi") → StorageClass → PV (skutočné úložisko)
                                                  ↓
                                           Pod (namountované v /data)
```

## Dostupné StorageClasses

Najprv sa pozrime, aké StorageClasses sú k dispozícii:

```terminal:execute
command: kubectl get storageclasses
```

Označenie `(default)` hovorí, ktorá sa použije, keď žiadnu neurčíte.

## Vytvorenie PersistentVolumeClaim

Otvorte cvičný súbor s PVC:

```editor:open-file
file: exercises/storage/pvc.yaml
```

Kľúčové polia:
- `accessModes: [ReadWriteOnce]` — volume sa dá pripojiť na čítanie aj zápis z **jedného** nodu
- `resources.requests.storage: 1Gi` — žiadame 1 GiB úložiska

> **Prečo práve 1Gi?** Váš namespace má `LimitRange`, ktorý určuje **minimálnu**
> veľkosť jedného PVC na 1Gi. Menšia požiadavka by bola odmietnutá pri admission
> s hláškou `minimum storage usage per PersistentVolumeClaim is 1Gi`. Pravidlá
> namespace si pozriete cez `kubectl describe limitrange`.

Bežné prístupové režimy:

| Režim | Skratka | Popis |
|-------|---------|-------|
| `ReadWriteOnce` | RWO | Čítanie aj zápis z jedného nodu |
| `ReadOnlyMany` | ROX | Len čítanie z viacerých nodov |
| `ReadWriteMany` | RWX | Čítanie aj zápis z viacerých nodov |

Vytvorte PVC:

```terminal:execute
command: cp -r ~/exercises/storage ~/storage && kubectl apply -f ~/storage/pvc.yaml
```

Skontrolujte stav PVC:

```terminal:execute
command: kubectl get pvc my-data
```

Stav je `Pending` — a **tak to má byť**. Nie je to chyba a nemá zmysel čakať, kým
sa to zmení samo.

### Prečo Pending?

Pozrite sa na StorageClass, ktorá sa použije:

```terminal:execute
command: kubectl get storageclass -o custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner,BINDING:.volumeBindingMode
```

V stĺpci `BINDING` je **`WaitForFirstConsumer`**. Znamená to, že úložisko sa
nevytvorí v okamihu, keď oň požiadate, ale až keď sa objaví **prvý Pod**, ktorý
ho chce pripojiť.

Dôvod je praktický: až podľa Podu vie Kubernetes povedať, na ktorý node úložisko
patrí. Keby zväzok vznikol skôr, mohol by skončiť na nodee, kam sa Pod nikdy
nenaplánuje — a Pod by potom ostal navždy v `Pending`.

> **Druhý režim sa volá `Immediate`** a vytvorí zväzok hneď. Používa sa pri
> sieťovom úložisku, ktoré je dostupné zo všetkých nodov. Predvolené triedy
> v kind aj v AKS sú `WaitForFirstConsumer`.

Zatiaľ teda neexistuje ani žiadny PV:

```terminal:execute
command: kubectl get pv
```

Prázdno. V ďalšom kroku vytvoríte Pod — a potom sa sem vrátime.

## Použitie PVC v Pode

Poďme vytvoriť Pod, ktorý toto úložisko použije. Otvorte cvičný súbor:

```editor:open-file
file: exercises/storage/pod-with-pvc.yaml
```

Kľúčová konfigurácia:

```editor:select-matching-text
file: exercises/storage/pod-with-pvc.yaml
text: claimName
```

- `volumes` — odkazuje na PVC podľa názvu (`my-data`)
- `volumeMounts` — mountuje volume do `/data` vnútri containera
- Container každých 5 sekúnd zapisuje aktuálny čas do `/data/log.txt`

Aplikujte Pod:

```terminal:execute
command: kubectl apply -f ~/storage/pod-with-pvc.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/writer-pod --timeout=120s
```

### A teraz späť k tomu PVC

Spomeňte si, že pred chvíľou bolo `Pending`. Pozrite sa naň znova:

```terminal:execute
command: kubectl get pvc my-data
```

Teraz je **`Bound`**. Objavil sa prvý konzument — writer-pod — a až tým sa
spustilo vytvorenie zväzku.

A existuje aj PV, ktorý predtým nebol:

```terminal:execute
command: kubectl get pv
```

Všimnite si, že PV ste nevytvárali. Vyrobil ho **provisioner** StorageClass
automaticky, presne na mieru vašej požiadavke. To je dynamické vytváranie
úložiska.

Chvíľu počkajte, nech sa niečo zapíše, a pozrite si súbor:

```terminal:execute
command: sleep 10 && kubectl exec writer-pod -- cat /data/log.txt
```

Pod zapisuje dáta do trvalého volume.

## Dôkaz, že dáta prežijú

Teraz si dokážme, že dáta prežijú aj zmazanie Podu.

**Krok 1**: Zistite, koľko dát máme:

```terminal:execute
command: kubectl exec writer-pod -- wc -l /data/log.txt
```

**Krok 2**: Zmažte zapisujúci Pod:

```terminal:execute
command: kubectl delete pod writer-pod
```

**Krok 3**: Overte, že je preč:

```terminal:execute
command: kubectl get pods
```

**Krok 4**: Vytvorte nový Pod, ktorý číta to isté PVC:

```editor:open-file
file: exercises/storage/pod-with-pvc-reader.yaml
```

```terminal:execute
command: kubectl apply -f ~/storage/pod-with-pvc-reader.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/reader-pod --timeout=60s
```

**Krok 5**: Prečítajte dáta — stále tam sú!

```terminal:execute
command: kubectl exec reader-pod -- cat /data/log.txt
```

Dáta prežili zmazanie Podu! To je sila trvalého úložiska — životný cyklus dát je
**oddelený** od životného cyklu Podu.

## Detaily PVC a PV

Cez describe si pozrite podrobnosti:

```terminal:execute
command: kubectl describe pvc my-data
```

Kľúčové údaje:
- **Status**: `Bound` — úložisko je pridelené
- **Volume**: názov PV
- **Capacity**: koľko úložiska bolo skutočne pridelené
- **Access Modes**: RWO
- **Used By**: ktoré Pody toto PVC práve používajú

## Reclaim policy

Čo sa stane s dátami, keď PVC zmažete? Závisí to od **reclaim policy**:

| Policy | Čo sa stane | Typické použitie |
|--------|-------------|------------------|
| **Delete** | PV aj dáta sa zmažú | Dynamické vytváranie (predvolené) |
| **Retain** | PV ostane, dáta sa zachovajú | Ručná obnova dát |

Pozrite si policy na svojom PV:

```terminal:execute
command: kubectl get pv -o custom-columns='NAME:.metadata.name,RECLAIM-POLICY:.spec.persistentVolumeReclaimPolicy,STATUS:.status.phase'
```

## Upratanie

```terminal:execute
command: kubectl delete -f ~/storage/ 2>/dev/null; echo "Cleanup done"
```

Zmažte PVC:

```terminal:execute
command: kubectl delete pvc my-data 2>/dev/null; echo "PVC deleted"
```

## Zhrnutie úrovne 3

V tejto kapitole ste sa naučili:
- Úložisko Podu je predvolene **pominuteľné** — pri zmazaní Podu sa dáta stratia
- **PersistentVolumeClaim (PVC)** je požiadavka o úložisko z klastra
- **PersistentVolume (PV)** je samotný zdroj úložiska
- PVC sa v Podoch **mountuje** cez `volumes` a `volumeMounts`
- Dáta v PVC prežijú **zmazanie Podu** — nové Pody sa k nim dostanú
- **StorageClasses** umožňujú dynamické vytváranie PV
- **Reclaim policy** určuje, čo sa stane s dátami pri zmazaní PVC

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl get pvc` | Výpis PersistentVolumeClaims |
| `kubectl get pv` | Výpis PersistentVolumes |
| `kubectl describe pvc <názov>` | Detaily PVC (kapacita, stav, kto používa) |
| `kubectl get storageclasses` | Výpis dostupných StorageClasses |

Ďalej sa pozrieme na **liveness a readiness probes** — ako Kubernetes sleduje
zdravie vašej aplikácie!
