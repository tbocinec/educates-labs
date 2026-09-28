---
title: Vlastný chart
---

# Úroveň 4: Vlastný chart

# ČASŤ 2 — Tvorba vlastného chartu

Doteraz ste charty konzumovali. Druhá polovica Helmu je zabaliť vlastnú
aplikáciu tak, aby ju niekto iný — alebo vy o pol roka — nainštaloval jedným
príkazom.

## Vygenerovanie kostry

Helm vám funkčný chart vygeneruje:

```terminal:execute
command: cd ~ && helm create hello-app && find hello-app -type f | sort
```

To je kompletný, inštalovateľný chart. Pozrite sa, čo ste dostali:

| Cesta | Na čo slúži |
|-------|-------------|
| `Chart.yaml` | Názov, verzia, appVersion |
| `values.yaml` | Predvolené values — API vášho chartu |
| `templates/deployment.yaml` | Deployment, šablónovaný |
| `templates/service.yaml` | Service |
| `templates/_helpers.tpl` | Pomocníci na názvy a labels |
| `templates/NOTES.txt` | Vypíše sa po inštalácii |
| `templates/tests/` | Testovacie Pody, ktoré spúšťa `helm test` |
| `.helmignore` | Súbory vynechané z balíčka |

## Ako vyzerá šablóna

```editor:open-file
file: hello-app/templates/deployment.yaml
```

Objavujú sa tu tri druhy výrazov:

```
{{ .Values.replicaCount }}            → hodnota z values.yaml
{{ include "hello-app.fullname" . }}  → pomenovaná šablóna z _helpers.tpl
{{- if .Values.autoscaling.enabled }} → podmienka
```

`{{-` s pomlčkou oreže predchádzajúce biele znaky. Bez toho dostanete prázdne
riadky a rozbité odsadenie — a YAML je v tomto nemilosrdný.

```editor:open-file
file: hello-app/values.yaml
```

Toto je súbor, ktorý budú čítať používatelia vášho chartu. Berte ho ako
dokumentáciu, nielen ako konfiguráciu.

## Kontrola pred inštaláciou

Väčšinu chýb zachytia dva príkazy. Najprv statická analýza:

```terminal:execute
command: helm lint ~/hello-app
```

Potom vykreslite šablóny a prečítajte si YAML, ktorý sa chystáte aplikovať:

```terminal:execute
command: helm template hello ~/hello-app | head -40
```

> **Ak `helm lint` prejde, ale `helm template` vyprodukuje niečo čudné, verte
> `template`.** Lint kontroluje štruktúru; skutočný výstup s vašimi values ukáže
> až vykreslenie.

## Prispôsobenie

Kostra štandardne spúšťa nginx. Nasmerujeme ju na podinfo.

```editor:open-file
file: exercises/hello-app-values.yaml
```

Vykreslite to s týmito values a skontrolujte výsledok pred inštaláciou:

```terminal:execute
command: helm template hello ~/hello-app -f ~/exercises/hello-app-values.yaml | grep -E "image:|replicas:|containerPort:"
```

Všimnite si, že nastavenie `service.port` posunulo aj port **containera**. Kostra
oboje šablónuje z jednej hodnoty:

```terminal:execute
command: grep -n "containerPort" ~/hello-app/templates/deployment.yaml
```

Je to rozhodnutie autora chartu, nie pravidlo. Vždy si overte, ktorá hodnota čo
riadi, namiesto predpokladu, že nejaký gombík existuje.

## Inštalácia vlastného chartu

Inštalujte z lokálneho adresára — žiadny repozitár netreba:

```terminal:execute
command: helm install hello ~/hello-app -f ~/exercises/hello-app-values.yaml --wait
```

```terminal:execute
command: helm list
```

```terminal:execute
command: kubectl get deploy,svc -l app.kubernetes.io/instance=hello
```

Váš vlastný chart, nainštalovaný ako ktorýkoľvek iný.

## Testy chartu

Kostra obsahuje testovací Pod, ktorý overí, že Service odpovedá:

```terminal:execute
command: helm test hello --logs
```

`helm test` spustí Pody z `templates/tests/` a ohlási, či uspeli. Je to lacný
dymový test po nasadení.

## Úprava šablóny

Spravme viditeľnú zmenu — pridajme Deploymentu label.

```editor:open-file
file: hello-app/templates/deployment.yaml
```

Nájdite blok `metadata.labels` Deploymentu:

```editor:select-matching-text
file: hello-app/templates/deployment.yaml
text: "  labels:"
```

Pod neho pridajte riadok (pozor na odsadenie — o dve medzery hlbšie než
`labels:`):

```
    workshop: helm-intro
```

Vykreslite a overte, že je zmena platná, než ju aplikujete:

```terminal:execute
command: helm template hello ~/hello-app -f ~/exercises/hello-app-values.yaml | grep -B2 -A2 "workshop: helm-intro"
```

Teraz ju aplikujte:

```terminal:execute
command: helm upgrade hello ~/hello-app -f ~/exercises/hello-app-values.yaml --wait
```

```terminal:execute
command: kubectl get deploy -l workshop=helm-intro
```

## Zabalenie

Ak chcete chart odovzdať niekomu inému, zabaľte ho:

```terminal:execute
command: cd ~ && helm package hello-app
```

```terminal:execute
command: ls ~/hello-app-*.tgz
```

Ten `.tgz` je presne to, čo servíruje repozitár. Pred zabalením zmeny zdvihnite
verziu v `Chart.yaml` — repozitáre sa riadia verziou a znovupublikovanie tej
istej verzie s iným obsahom je spoľahlivý spôsob, ako zmiasť všetkých ďalej
v reťazci.

## Upratanie

```terminal:execute
command: helm uninstall hello
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- `helm create` vygeneruje kompletný, inštalovateľný chart
- `values.yaml` je verejné API vášho chartu — píšte ho ako dokumentáciu
- `{{-` orezáva biele znaky a odsadenie YAML na tom závisí
- `helm lint` kontroluje štruktúru, `helm template` ukáže skutočný výstup
- Charty sa inštalujú priamo z adresára, repozitár netreba
- `helm test` spustí vlastné dymové testy chartu
- `helm package` vyrobí `.tgz`; vždy zdvihnite verziu

Tým máte oba pohľady — používateľa aj autora. Nasledujúca kapitola je
**voliteľná**: prehľad toho, čo Helm ešte vie, keď to začnete potrebovať.
