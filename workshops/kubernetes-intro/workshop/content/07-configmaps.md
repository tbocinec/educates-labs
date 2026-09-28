---
title: ConfigMaps
---

# Úroveň 4: ConfigMaps

Aplikácie potrebujú konfiguráciu — adresy databáz, feature flags, úrovne
logovania a podobne. Zadrôtovať tieto hodnoty priamo do container image je zlá
prax, lebo ten istý image by mal fungovať v rôznych prostrediach (dev, staging,
produkcia).

**ConfigMap** tento problém rieši. Uchováva necitlivú konfiguráciu ako dvojice
kľúč-hodnota a Pody ju vedia konzumovať ako premenné prostredia alebo ako
namountované súbory.

> **Dokumentácia**: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

## Vytvorenie ConfigMapy imperatívne

Vytvorte ConfigMapu z hodnôt zadaných priamo na príkazovom riadku:

```terminal:execute
command: kubectl create configmap simple-config --from-literal=APP_COLOR=red --from-literal=APP_MODE=debug
```

Zobrazte ConfigMapu:

```terminal:execute
command: kubectl get configmap simple-config
```

Pozrite si jej celý obsah:

```terminal:execute
command: kubectl get configmap simple-config -o yaml
```

Alebo prehľadnejšie cez describe:

```terminal:execute
command: kubectl describe configmap simple-config
```

## Vytvorenie ConfigMapy z YAML

Otvorte cvičný súbor, ktorý definuje ConfigMapu v YAML:

```editor:open-file
file: exercises/configmap/configmap.yaml
```

Všimnite si sekciu `data` s tromi dvojicami kľúč-hodnota:

```editor:select-matching-text
file: exercises/configmap/configmap.yaml
text: APP_COLOR: "blue"
```

Skopírujte a aplikujte ConfigMapu:

```terminal:execute
command: cp -r ~/exercises/configmap ~/configmap && kubectl apply -f ~/configmap/configmap.yaml
```

Vypíšte všetky ConfigMapy vo vašom namespace:

```terminal:execute
command: kubectl get configmaps
```

## Vytvorenie ConfigMapy zo súboru

ConfigMapu viete vytvoriť aj zo súboru. Otvorte properties súbor:

```editor:open-file
file: exercises/configmap/app-config.properties
```

Je to typický konfiguračný súbor aplikácie s nastaveniami databázy a logovania.

Vytvorte z neho ConfigMapu:

```terminal:execute
command: kubectl create configmap file-config --from-file=app-config.properties=/home/eduk8s/exercises/configmap/app-config.properties
```

Pozrite si výsledok:

```terminal:execute
command: kubectl describe configmap file-config
```

Všimnite si, že celý obsah súboru je uložený pod jedným kľúčom
(`app-config.properties`), ktorého hodnotou je obsah súboru.

## ConfigMap ako premenné prostredia

Poďme vytvoriť Pod, ktorý ConfigMapu `app-config` skonzumuje ako premenné
prostredia.

Otvorte cvičný súbor:

```editor:open-file
file: exercises/configmap/pod-configmap-env.yaml
```

Všimnite si sekciu `envFrom`:

```editor:select-matching-text
file: exercises/configmap/pod-configmap-env.yaml
text: envFrom:
```

`envFrom` s `configMapRef` načíta **všetky** dvojice kľúč-hodnota z ConfigMapy
ako premenné prostredia v Pode.

Aplikujte Pod:

```terminal:execute
command: kubectl apply -f ~/configmap/pod-configmap-env.yaml
```

Počkajte, kým Pod nabehne, a pozrite si logy:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/configmap-env-demo --timeout=60s && kubectl logs configmap-env-demo
```

Mali by ste vidieť vypísané premenné prostredia:
```
APP_COLOR=blue
APP_MODE=production
LOG_LEVEL=INFO
```

Overte to aj spustením príkazu vnútri Podu:

```terminal:execute
command: kubectl exec configmap-env-demo -- env | grep -E "APP_|LOG_"
```

## ConfigMap ako namountovaný volume

Namiesto premenných prostredia sa dá ConfigMap namountovať ako súbory vo volume.
To je ideálne pre konfiguračné súbory.

Otvorte cvičný súbor:

```editor:open-file
file: exercises/configmap/pod-configmap-volume.yaml
```

Všimnite si sekcie `volumes` a `volumeMounts`:

```editor:select-matching-text
file: exercises/configmap/pod-configmap-volume.yaml
text: mountPath: /etc/config
```

ConfigMap `file-config` sa v containeri namountuje do `/etc/config/`. Z každého
kľúča vznikne samostatný súbor.

Aplikujte Pod:

```terminal:execute
command: kubectl apply -f ~/configmap/pod-configmap-volume.yaml
```

Počkajte na Pod a pozrite si jeho logy:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/configmap-volume-demo --timeout=60s && kubectl logs configmap-volume-demo
```

Mali by ste vidieť výpis `/etc/config/` a obsah konfiguračného súboru.

Overte to výpisom namountovaných súborov:

```terminal:execute
command: kubectl exec configmap-volume-demo -- ls -la /etc/config/
```

Prečítajte namountovaný konfiguračný súbor:

```terminal:execute
command: kubectl exec configmap-volume-demo -- cat /etc/config/app-config.properties
```

## Aktualizácia ConfigMáp

ConfigMapy sa dajú meniť a Pody, ktoré ich majú namountované ako volume, novú
hodnotu po čase (v rámci niekoľkých minút) dostanú. Pody, ktoré ich používajú ako
premenné prostredia, však zmenu **neuvidia** — treba ich reštartovať.

Zmeňte ConfigMapu:

```terminal:execute
command: kubectl patch configmap app-config -p '{"data":{"APP_COLOR":"green"}}'
```

Overte zmenu:

```terminal:execute
command: kubectl get configmap app-config -o yaml | grep APP_COLOR
```

## Upratanie

Odstráňte ConfigMapy a Pody:

```terminal:execute
command: kubectl delete pod configmap-env-demo configmap-volume-demo
```

```terminal:execute
command: kubectl delete configmap simple-config app-config file-config
```

Overte:

```terminal:execute
command: kubectl get pods,configmaps
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- **ConfigMap** uchováva necitlivú konfiguráciu ako dvojice kľúč-hodnota
- `kubectl create configmap --from-literal` — vytvorenie z hodnôt na príkazovom riadku
- `kubectl create configmap --from-file` — vytvorenie zo súboru
- ConfigMapy sa dajú definovať v YAML a aplikovať cez `kubectl apply -f`
- Pody ich konzumujú ako:
  - **Premenné prostredia** (`envFrom` / `configMapRef`)
  - **Namountované súbory** (`volumes` / `volumeMounts`)
- ConfigMapy namountované ako volume sa aktualizujú za behu; tie cez premenné prostredia vyžadujú reštart Podu

Posledný bod je dôležitejší, než vyzerá, a nasledujúca kapitola vám to dá pocítiť.
Poďme všetko spojiť dokopy na reálnej aplikácii.
