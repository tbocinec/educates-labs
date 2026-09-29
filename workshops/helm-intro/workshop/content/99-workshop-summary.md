---
title: Zhrnutie workshopu
---

# Zhrnutie workshopu

Gratulujeme! Nainštalovali ste cudzí chart, nakonfigurovali ho, rozbili, vrátili
späť — a potom si napísali vlastný. 🎉

---

# Časť 1 — Používanie Helmu

## Úroveň 1: Nájsť a nainštalovať

- **Chart** = balíček, **release** = jedna jeho inštalácia, **repozitár** = index
- Ten istý chart sa dá nainštalovať viackrát pod rôznymi názvami releasov
- `helm show values` je verejné API chartu — čítajte ho ako prvé
- Objekty majú predponu podľa releasu a label `managed-by=Helm`; Pody ten label nemajú, lebo ich vytvára ReplicaSet

```
helm repo add <názov> <url>
helm repo update
helm search repo <výraz>
helm show values <chart>
helm install <release> <chart> --wait
helm list
helm status <release>
helm uninstall <release>
```

## Úroveň 2: Zmena values

Poradie prednosti, od najnižšej po najvyššiu:

```
predvolené chartu  →  -f values.yaml  →  --set
```

- `--set` na jednu-dve hodnoty, pre čokoľvek reálne použite súbor
- `helm get values` ukáže vaše prebitia
- `--dry-run=client` ukáže výsledok bez toho, aby sa čokoľvek zmenilo
- `helm upgrade` zabudne prebitia z minula — odovzdávajte svoj values súbor vždy

```
helm upgrade <release> <chart> --set kľúč=hodnota
helm upgrade <release> <chart> -f values.yaml
helm get values <release>
helm upgrade ... --dry-run=client
```

## Úroveň 3: Návrat po zlom nasadení

- Každá inštalácia a upgrade je očíslovaná revízia
- Zaznamenávajú sa aj neúspešné upgrady
- Rollback históriu **dopĺňa**, nikdy nič nemaže
- Rollback obnoví aj values danej revízie, nielen images

```
helm history <release>
helm rollback <release>            # o jednu späť
helm rollback <release> <revízia>  # na konkrétnu
```

## Úroveň 4: Reálna aplikácia — Grafana

- Reálne charty často chcú **cluster-scoped objekty** (ClusterRole, CRD) — to je najčastejší dôvod chyby `Forbidden`
- `helm template ... | grep '^kind:'` ukáže, čo chart vytvorí, **pred** inštaláciou
- `helm show chart` prezradí verziu aj to, či je chart ešte udržiavaný
- Vygenerované heslá končia v **Secretoch**, nie vo výstupe príkazu

```
helm show chart <chart>
helm template g <chart> -f values.yaml | grep '^kind:'
kubectl get secret <názov> -o jsonpath='{.data.admin-password}' | base64 -d
```

---

# Časť 2 — Tvorba vlastného chartu

## Úroveň 5: Vlastný chart

- `helm create` vygeneruje kompletný chart
- `values.yaml` je rovnako dokumentácia ako konfigurácia
- `{{-` orezáva biele znaky a odsadenie YAML na tom závisí
- `helm lint` kontroluje štruktúru, `helm template` ukáže realitu
- Charty sa inštalujú priamo z adresára

```
helm create <názov>
helm lint <adresár>
helm template <release> <adresár> -f values.yaml
helm install <release> <adresár> -f values.yaml
helm test <release> --logs
helm package <adresár>
```

---

## Návyky, ktoré sa oplatí si nechať

| Návyk | Prečo |
|-------|-------|
| `--dry-run=client` alebo `helm template` pred aplikovaním | Zmenu uvidíte skôr než klaster |
| Values v commitnutom súbore, nie cez `--set` | Prehľadné, reprodukovateľné, nič sa nestratí |
| Prečítať `helm show values` ako prvé | API chartu — aj to, či sa zmestí do vašich práv |
| `helm lint` + `helm template` pred vydaním vlastného chartu | Lacné a zachytí väčšinu chýb |

---

## Poznámka k oprávneniam

Všetko tu ostalo v rámci vášho namespace. Mnohé reálne charty (ingress
controllery, operátory, monitorovacie stacky) inštalujú CRD, ClusterRoles a
webhooky a potrebujú cluster-scoped práva. Keď inde narazíte na `Forbidden`, býva
to zvyčajne práve toto — chart je v poriadku, vaša rola nie je dosť široká.

---

## Čo ďalej

Voliteľná **úroveň 6** je rozcestník na pokročilé témy: `--atomic` a pripínanie
verzií v CI, závislosti a subcharty, hooks, library charts, OCI registry,
Helmfile a GitOps, a práca s citlivými údajmi. Sú to samé odkazy — zabehnite tam,
keď na niektorú z tých vecí narazíte.

---

## Oficiálna dokumentácia

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Helm command reference](https://helm.sh/docs/helm/)

Ďakujeme za absolvovanie workshopu! 🚀
