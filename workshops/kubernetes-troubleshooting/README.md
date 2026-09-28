# Workshop: Kubernetes — Troubleshooting

Praktický workshop o diagnostike rozbitých workloadov v Kubernetes. Osem reálnych
porúch, jedna opakovateľná metóda.

## Dĺžka

~60 minút

## Predpoklady

- Absolvovanie workshopov **Základy Kubernetes** a ideálne **Kubernetes:
  Services, Secrets a úložisko** (alebo rovnocenná znalosť kubectl, Podov,
  Deploymentov, Services a ConfigMáp)

## Obsah

### Úroveň 1 — Metóda, ktorá funguje
- Poradie, ktoré rieši väčšinu problémov: stav → describe → udalosti → logy
- Čítanie stĺpca STATUS ako prvá diagnóza
- `kubectl get events --sort-by` a filtrovanie na varovania

### Úroveň 2 — Pod nikdy nenaštartuje
- `ImagePullBackOff` — zlý tag, privátny registry, limity sťahovania
- `CreateContainerConfigError` — nerozlíšiteľné odkazy na ConfigMap/Secret

### Úroveň 3 — Pod naštartuje a zomrie
- `CrashLoopBackOff` a prečo je `kubectl logs --previous` celý ten trik
- `OOMKilled` — kód 137 s prázdnymi logmi a čo tento odtlačok znamená

### Úroveň 4 — Pod ostáva v Pending
- `FailedScheduling` — nevyhovujúci `nodeSelector`, nedostatok zdrojov, tainty
- Odmietnutia pri admission cez `LimitRange` a `ResourceQuota`

### Úroveň 5 — Aplikácia je nedostupná
- `kubectl get endpoints` ako prvý príkaz pri problémoch s dostupnosťou
- Nesúlad label selektora — legitímny, tichý a veľmi častý
- Zámena `port` a `targetPort`

## Vlastnosti

- Osem rozbitých manifestov s komentármi vysvetľujúcimi pascu
- Každý scenár má rovnaký priebeh: rozbi → pozoruj → diagnostikuj → oprav → over
- Zodpovedajúce `-fixed` manifesty na porovnanie pred a po
- Webové UI Headlamp na vizuálne čítanie udalostí a logov
- Rozdelený terminál na sledovanie zdrojov počas práce

## Jazyk

Workshop je v slovenčine, technické pojmy a príkazy sú ponechané v angličtine.

## Poznámky k návrhu

Všetky scenáre bežia v rámci jedného session namespace a nepotrebujú žiadne
cluster-scoped oprávnenia. Ich reprodukovateľnosť bola overená na lokálnom kind
klastri aj v session prostredí Educates:

| Scenár | Overený výsledok |
|--------|------------------|
| Zlý tag image | `ErrImagePull` → `ImagePullBackOff` |
| Chýbajúci kľúč v ConfigMape | `CreateContainerConfigError`, „couldn't find key mode" |
| Padajúci worker | `CrashLoopBackOff`, hláška viditeľná cez `logs --previous` |
| Žrút pamäte | `OOMKilled`, návratový kód 137, prázdne logy |
| Nesplniteľný nodeSelector | `Pending`, udalosť `FailedScheduling` |
| Predimenzovaná požiadavka | Odmietnutie pri admission cez `LimitRange` |
| Nesúlad selektora | `endpoints` ukazuje `<none>` |

## Odkazy na oficiálnu dokumentáciu

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
