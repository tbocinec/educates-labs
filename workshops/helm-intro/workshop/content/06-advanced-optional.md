---
title: Voliteľné — čo Helm ešte vie
---

# Voliteľné: Čo Helm ešte vie

> **Túto kapitolu môžete pokojne preskočiť.** Workshop ste absolvovali — viete
> nasadiť cudzí chart aj napísať vlastný, a to je v praxi 90 % práce s Helmom.
>
> Čo nasleduje, je **prehľad pojmov, na ktoré narazíte neskôr**. Nie sú tu
> cvičenia, ktoré musíte spraviť — skôr rozcestník s odkazmi, kam si zabehnúť,
> keď to naozaj budete potrebovať.

---

## Prevádzka v CI

### `--atomic` — všetko alebo nič

V úrovni 3 ste po zlom upgrade robili rollback ručne. V pipeline nikto nesedí a
nekontroluje. `--atomic` sa pri zlyhaní vráti späť **sám**:

```
helm upgrade my-app podinfo/podinfo -f values.yaml --atomic --timeout 5m
```

| Prepínač | Pri zlyhaní |
|----------|-------------|
| (žiadny) | Rozbitý stav ostane, všimnete si to neskôr |
| `--wait` | Príkaz zlyhá, rozbitý stav ostane |
| `--atomic` | Príkaz zlyhá **a** release sa automaticky vráti späť |

V CI by `--atomic` mal byť vaša predvoľba.

### Pripnutie verzie chartu

```
helm upgrade my-app podinfo/podinfo --version 6.14.0 -f values.yaml
```

Bez `--version` stiahne nasadenie o pol roka čokoľvek najnovšie. V produkcii
verziu pripnite.

### `--dry-run=server`

`--dry-run=client` z úrovne 2 vykresľuje lokálne. Serverový variant pošle
manifesty API serveru na validáciu bez uloženia — zachytí chyby schémy aj
odmietnutia pri admission (napríklad prekročenú kvótu namespace).

### Pasca `--reuse-values`

`helm upgrade` predvolene zabudne prebitia z minulého upgradu. `--reuse-values`
ich zlúči s novými. Odolnejší návyk je ale odovzdávať svoj values súbor pri
každom upgrade, tak ako ste to robili v úrovni 2.

📖 [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) ·
[helm rollback](https://helm.sh/docs/helm/helm_rollback/)

---

## Väčšie charty

### Závislosti a subcharty

Chart môže závisieť od iných chartov — napríklad vaša aplikácia od PostgreSQL.
Deklarujú sa v `Chart.yaml` a sťahujú cez `helm dependency update`.

📖 [Chart Dependencies](https://helm.sh/docs/topics/charts/#chart-dependencies)

### Hooks

Úlohy naviazané na fázu životného cyklu releasu — `pre-install`,
`post-upgrade`, `pre-delete`. Typicky databázové migrácie alebo zálohy pred
upgradom.

📖 [Chart Hooks](https://helm.sh/docs/topics/charts_hooks/)

### Library charts

Chart, ktorý sa neinštaluje sám, ale poskytuje zdieľané šablóny ostatným. Keď
máte dvadsať mikroslužieb s takmer rovnakým Deploymentom, toto je odpoveď.

📖 [Library Charts](https://helm.sh/docs/topics/library_charts/)

### Šablónovací jazyk do hĺbky

`if`/`else`, `range`, `with`, funkcie ako `quote`, `default`, `toYaml`,
`required`. Plus `values.schema.json` na validáciu vstupov.

📖 [Chart Template Guide](https://helm.sh/docs/chart_template_guide/) ·
[Schema Files](https://helm.sh/docs/topics/charts/#schema-files)

---

## Distribúcia

### OCI registry

Moderná alternatíva k chart repozitárom — charty sa dajú ukladať do bežnej
container registry vedľa images:

```
helm push hello-app-0.1.0.tgz oci://registry.example.com/charts
helm install hello oci://registry.example.com/charts/hello-app --version 0.1.0
```

📖 [OCI Registries](https://helm.sh/docs/topics/registries/)

### Podpisovanie chartov

`helm package --sign` a `helm verify` na overenie, že chart pochádza od toho,
koho čakáte.

📖 [Provenance and Integrity](https://helm.sh/docs/topics/provenance/)

---

## Keď releasov pribudne

Helm spravuje jeden release naraz, z príkazového riadku. Akonáhle ich máte
desiatky naprieč prostrediami, chcete to popísať deklaratívne:

| Nástroj | Prístup |
|---------|---------|
| **Helmfile** | Deklaratívny popis mnohých releasov, stále nad Helmom |
| **Argo CD** | GitOps — stav v Gite, controller ho presadzuje do klastra |
| **Flux** | GitOps s vlastným Helm controllerom |

📖 [Helmfile](https://github.com/helmfile/helmfile) ·
[Argo CD](https://argo-cd.readthedocs.io/) ·
[Flux Helm Controller](https://fluxcd.io/flux/components/helm/)

---

## Citlivé údaje

Values súbory sa commitujú do Gitu, takže heslá do nich nepatria. Bežné
riešenia:

- **External Secrets Operator** — Secrets sa ťahajú z Vaultu, AWS/Azure key store
- **Sealed Secrets** — zašifrovaný Secret, ktorý je bezpečné commitnúť
- **helm-secrets** — plugin šifrujúci values súbory cez SOPS

📖 [External Secrets](https://external-secrets.io/) ·
[Sealed Secrets](https://sealed-secrets.netlify.app/) ·
[helm-secrets](https://github.com/jkroepke/helm-secrets)

---

## Kam ísť ďalej

Ak si máte z tejto kapitoly odniesť jednu vec: **`--atomic` v CI a pripnuté
verzie**. Zvyšok počká, kým naň naozaj narazíte.

📖 [Helm Best Practices](https://helm.sh/docs/chart_best_practices/) —
oplatí sa prečítať celé, je to krátke
