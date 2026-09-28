# Workshop: Základy Kubernetes

Workshop prvého kontaktu s Kubernetes — obhliadka klastra, spustenie prvého Podu,
prechod na Deployments so škálovaním a rolling updates, konfigurácia cez
ConfigMap a na záver prevádzka reálnej aplikácie od začiatku do konca.

Labels, selektory a namespaces sú v nadväzujúcom workshope *Kubernetes: Services,
Secrets a úložisko*, kde sa zo selektorov stáva nosná konštrukcia.

## Dĺžka

~90 minút

## Obsah

### Úroveň 1 — Začíname
- Prehľad architektúry Kubernetes (Control Plane, nodes, Pody)
- Základy `kubectl` (cluster-info, get, describe, explain, api-resources)

### Úroveň 2 — Práca s Podmi
- Spustenie prvého Podu imperatívne
- Definovanie Podov cez YAML manifesty (deklaratívny prístup)

### Úroveň 3 — Deployments
- Vytváranie a škálovanie Deploymentov
- Rolling updates a rollbacky

### Úroveň 4 — Konfigurácia
- ConfigMaps (premenné prostredia aj namountované volumes)

### Úroveň 5 — Všetko dokopy
- Riadený scenár na reálnej aplikácii (podinfo)
- Konfigurácia z ConfigMapy, prístup cez `kubectl port-forward`
- Škálovanie, self-healing, `rollout restart`, rolling update a rollback

## Predpoklady

- Základná práca s terminálom
- Žiadne predchádzajúce skúsenosti s Kubernetes nie sú potrebné

## Vlastnosti

- Webové UI Headlamp na vizuálnu správu klastra
- Pripravené cvičné YAML súbory s komentármi
- Integrovaný editor kódu na prezeranie a úpravu manifestov
- Rozdelený terminál na paralelné spúšťanie príkazov

## Jazyk

Workshop je v slovenčine, technické pojmy a príkazy sú ponechané v angličtine.
