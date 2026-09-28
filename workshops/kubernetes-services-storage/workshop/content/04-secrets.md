---
title: Secrets
---

# Úroveň 2: Secrets

V predchádzajúcom workshope ste spoznali **ConfigMap** pre necitlivú
konfiguráciu. Čo ale s heslami, API kľúčmi alebo TLS certifikátmi? Na to sú
**Secrets**.

> **Dokumentácia**: [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

## Čo sú Secrets?

**Secret** je objekt v Kubernetes, ktorý uchováva citlivé údaje, napríklad:
- Heslá k databázam
- API tokeny
- SSH kľúče
- TLS certifikáty

Secrets sú podobné ConfigMapám, ale s dôležitými rozdielmi:

| Vlastnosť | ConfigMap | Secret |
|-----------|-----------|--------|
| Určenie | Necitlivá konfigurácia | Citlivé údaje |
| Uloženie dát | Čistý text | Kódované cez base64 |
| V pamäti | Nie | Voliteľne (`tmpfs`) |
| Limit veľkosti | 1 MiB | 1 MiB |

> **Dôležité**: Secrets v Kubernetes sú kódované cez base64, **nie šifrované**.
> Pre produkciu zvážte zapnutie
> [šifrovania dát v etcd](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).

## Vytvorenie Secretu imperatívne

Najrýchlejšia cesta:

```terminal:execute
command: kubectl create secret generic my-quick-secret --from-literal=username=admin --from-literal=password=s3cretP@ss
```

Zobrazte Secret:

```terminal:execute
command: kubectl get secret my-quick-secret -o yaml
```

Všimnite si, že hodnoty sú **kódované cez base64**. Dajú sa dekódovať:

```terminal:execute
command: kubectl get secret my-quick-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

Upracte:

```terminal:execute
command: kubectl delete secret my-quick-secret
```

## Vytvorenie Secretu z YAML

Poďme vytvoriť Secret cez YAML manifest s poľom `stringData` (to prijíma čistý
text):

```editor:open-file
file: exercises/secrets/secret.yaml
```

```terminal:execute
command: cp -r ~/exercises/secrets ~/secrets && kubectl apply -f ~/secrets/secret.yaml
```

Všimnite si pole `stringData` — umožňuje zapísať hodnoty v čitateľnej podobe.
Kubernetes ich sám zakóduje do base64.

Overte Secret:

```terminal:execute
command: kubectl describe secret db-credentials
```

Výstup `describe` ukáže kľúče a veľkosť hodnôt, ale **nie samotné hodnoty** — to
je bezpečnostná poistka.

## Secrets ako premenné prostredia

Najbežnejší spôsob použitia Secretov sú premenné prostredia. Otvorte cvičný
súbor:

```editor:open-file
file: exercises/secrets/pod-secret-env.yaml
```

Kľúčová konfigurácia:

```editor:select-matching-text
file: exercises/secrets/pod-secret-env.yaml
text: envFrom
```

`envFrom` so `secretRef` vloží **všetky** kľúče zo Secretu ako premenné
prostredia.

Aplikujte a otestujte:

```terminal:execute
command: kubectl apply -f ~/secrets/pod-secret-env.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/secret-env-pod --timeout=60s
```

```terminal:execute
command: kubectl exec secret-env-pod -- env | grep -E 'DB_USERNAME|DB_PASSWORD|DB_HOST'
```

Hodnoty zo Secretu sú vnútri Podu dostupné ako premenné prostredia.

## Secrets ako súbory (volume mount)

Niekedy potrebujete údaje zo Secretu ako súbory — napríklad TLS certifikáty alebo
konfiguračné súbory. Otvorte cvičný súbor:

```editor:open-file
file: exercises/secrets/pod-secret-volume.yaml
```

Kľúčová konfigurácia — Secret sa mountuje ako volume:

```editor:select-matching-text
file: exercises/secrets/pod-secret-volume.yaml
text: mountPath
```

Aplikujte a otestujte:

```terminal:execute
command: kubectl apply -f ~/secrets/pod-secret-volume.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/secret-volume-pod --timeout=60s
```

Vypíšte súbory v mountpointe:

```terminal:execute
command: kubectl exec secret-volume-pod -- ls /etc/secrets
```

Z každého kľúča v Secrete sa stane **súbor** a jeho obsahom je **hodnota**:

```terminal:execute
command: kubectl exec secret-volume-pod -- cat /etc/secrets/DB_USERNAME && echo
```

```terminal:execute
command: kubectl exec secret-volume-pod -- cat /etc/secrets/DB_PASSWORD && echo
```

## Premenné prostredia vs. volume — čo kedy?

| Prístup | Hodí sa na | Obmedzenie |
|---------|-----------|------------|
| **Premenné prostredia** | Jednoduchá konfigurácia kľúč-hodnota (heslá, API kľúče) | Pri zmene Secretu sa neaktualizujú |
| **Volume mount** | Súbory (TLS certifikáty, konfiguračné súbory) | Aplikácia musí sledovať zmeny súborov |

> **Tip**: Secrets namountované ako volume sa pri zmene automaticky aktualizujú
> (s malým oneskorením). Premenné prostredia **nie** — Pod treba reštartovať.

## Zmena Secretu

Poďme Secret zmeniť a pozrieť sa, ako to ovplyvní volume mount:

```terminal:execute
command: kubectl patch secret db-credentials -p '{"stringData":{"DB_PASSWORD":"newP@ssw0rd!"}}'
```

Chvíľu počkajte, kým sa zmena rozšíri (až ~60 sekúnd), a pozrite si volume:

```terminal:execute
command: sleep 10 && kubectl exec secret-volume-pod -- cat /etc/secrets/DB_PASSWORD && echo
```

Obsah súboru je aktualizovaný! Premenná prostredia v druhom Pode však stále drží
starú hodnotu:

```terminal:execute
command: kubectl exec secret-env-pod -- printenv DB_PASSWORD
```

Presne v tomto je kľúčový rozdiel medzi Secretmi cez volume a cez premenné
prostredia.

## Upratanie

```terminal:execute
command: kubectl delete -f ~/secrets/ 2>/dev/null; echo "Cleanup done"
```

## Zhrnutie úrovne 2

V tejto kapitole ste sa naučili:
- **Secrets** uchovávajú citlivé údaje ako heslá, tokeny a certifikáty
- Hodnoty sú v etcd **kódované cez base64** (nie šifrované!)
- Secrets sa dajú vytvoriť **imperatívne** (`kubectl create secret`) alebo z **YAML** (`stringData`)
- Konzumujú sa ako **premenné prostredia** (`envFrom`) alebo ako **volume mount**
- Secrets cez **volume** sa aktualizujú automaticky, cez **premenné prostredia** NIE
- `kubectl describe secret` hodnoty kvôli bezpečnosti skrýva

| Príkaz | Na čo slúži |
|--------|-------------|
| `kubectl create secret generic <názov> --from-literal=kľúč=hodnota` | Vytvorenie Secretu imperatívne |
| `kubectl get secret <názov> -o yaml` | Zobrazenie Secretu (v base64) |
| `kubectl get secret <názov> -o jsonpath='{.data.kľúč}' \| base64 -d` | Dekódovanie hodnoty |
| `kubectl describe secret <názov>` | Metadáta Secretu (hodnoty skryté) |

Ďalej sa pozrieme na **trvalé úložisko** — ako udržať dáta nažive aj po zmazaní
Podu!
