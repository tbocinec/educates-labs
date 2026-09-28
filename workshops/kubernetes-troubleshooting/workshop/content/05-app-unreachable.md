---
title: Aplikácia je nedostupná
---

# Úroveň 5: Aplikácia je nedostupná

Príznak: každý Pod je `1/1 Running`. Žiadne reštarty, žiadne chyby, žiadne
varovania. A aplikácia aj tak neodpovedá.

Toto je najfrustrujúcejšia kategória, lebo `kubectl get pods` vyzerá dokonale.
Porucha je v prepojení medzi Service a Podmi — a má vlastný diagnostický príkaz.

## Jeden príkaz na problémy so Service

Service nesmeruje na Pody priamo. Vyberá ich podľa labelu a výsledkom je
**EndpointSlice**: zoznam IP adries Podov, ktoré za Service naozaj stoja.

```
Service  --(label selektor)-->  Pody  --(ich IP)-->  Endpoints
```

Ak sú `Endpoints` prázdne, Service je slepá ulička bez ohľadu na to, aké zdravé
sú Pody. Preto je `kubectl get endpoints` prvá vec, ktorú treba spustiť.

> **Dokumentácia**: [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)

## Scenár 7: Service bez endpointov

```editor:open-file
file: broken/06-service/web-deployment.yaml
```

```editor:open-file
file: broken/06-service/web-service-broken.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-deployment.yaml -f ~/broken/06-service/web-service-broken.yaml
```

### Pozorovanie

Všetko vyzerá zdravo:

```terminal:execute
command: kubectl get pods,svc -l app=web
```

Teraz sa tam skúste naozaj dostať. Spustite jednorazový klientský Pod:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 http://web-service
```

Zasekne sa a zlyhá. Vo výpise Podov to nič nenaznačovalo.

### Diagnostika

```terminal:execute
command: kubectl get endpoints web-service
```

`<none>`. Service nemá žiadny backend — a to je vaša odpoveď.

> **Uvidíte varovanie o zastaranosti** `v1 Endpoints` na Kubernetes 1.33+. Tu ho
> ignorujte — príkaz funguje a píše sa kratšie. Moderný ekvivalent je
> `kubectl get endpointslices -l kubernetes.io/service-name=web-service`.

Teraz zistite prečo. Porovnajte, čo Service hľadá:

```terminal:execute
command: kubectl get service web-service -o jsonpath='selector={.spec.selector}{"\n"}'
```

…s labelmi, ktoré Pody naozaj nesú:

```terminal:execute
command: kubectl get pods --show-labels -l app=web
```

Service vyberá `app=webapp`. Pody majú `app=web`. Jedno písmeno.

`describe` hovorí to isté slovami:

```terminal:execute
command: kubectl describe service web-service | grep -E "Selector|Endpoints"
```

### Príčina

Nesúlad label selektora. Je to úplne najčastejšia chyba pri Service a
neprodukuje **žiadne** varovanie — prázdny výber je z pohľadu Kubernetes úplne
legitímny stav.

### Oprava a overenie

Opravte selektor v manifeste:

```editor:select-matching-text
file: broken/06-service/web-service-broken.yaml
text: "app: webapp"
```

Zmeňte `webapp` na `web`, uložte a aplikujte znova:

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-service-broken.yaml
```

```terminal:execute
command: kubectl get endpoints web-service
```

Teraz tam sú dve IP adresy Podov. Skúste to znova:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "HTTP %{http_code}\n" http://web-service
```

`HTTP 200`.

## Scenár 8: Endpointy sú, prevádzka aj tak zlyháva

Jemnejší variant: selektor je správny, takže endpointy sa objavia — a požiadavky
aj tak končia odmietnutím.

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-service-badport.yaml
```

```terminal:execute
command: kubectl get endpoints web-badport
```

Endpointy tam sú. A predsa:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 http://web-badport
```

Spojenie odmietnuté.

### Diagnostika

Keď endpointy existujú, ale prevádzka zlyháva, problém sa posunul o úroveň
nižšie: na **port**. Pozrite sa, kam Service preposiela:

```terminal:execute
command: kubectl get service web-badport -o jsonpath='port={.spec.ports[0].port} targetPort={.spec.ports[0].targetPort}{"\n"}'
```

A na čom container naozaj počúva:

```terminal:execute
command: kubectl get deployment web -o jsonpath='containerPort={.spec.template.spec.containers[0].ports[0].containerPort}{"\n"}'
```

Service preposiela na port `8080`, nginx počúva na `80`.

Dokážte si to komunikáciou priamo s Podom, mimo Service:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "direct to pod: HTTP %{http_code}\n" http://$(kubectl get endpoints web-service -o jsonpath='{.subsets[0].addresses[0].ip}')
```

Pod na porte 80 odpovedá bez problémov. Service len klope na zlé dvere.

> **`port` vs. `targetPort`.** `port` je to, na čo volajú klienti Service.
> `targetPort` je port containera, kam sa prevádzka preposiela. Smú sa líšiť —
> a práve preto sa táto chyba robí ľahko a vo výpise Podov nie je vidieť.

### Oprava a overenie

```terminal:execute
command: kubectl patch service web-badport -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
```

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "HTTP %{http_code}\n" http://web-badport
```

## Kontrolný zoznam pre „neodpovedá to"

Prejdite tento zoznam — každý krok vylúči jednu vrstvu:

1. `kubectl get endpoints <svc>` — prázdne? → nesúlad selektora
2. Endpointy sú? → porovnajte `targetPort` s portom containera
3. Port sedí? → je Pod `READY`? Zlyhávajúca readiness probe ho vyradí z endpointov
4. Stále zle? → cez `kubectl exec` v klientskom Pode otestujte priamo IP Podu
5. IP Podu funguje, Service nie? → skontrolujte názov Service a namespace v DNS dopyte

## Upratanie

```terminal:execute
command: kubectl delete -f ~/broken/06-service/ --ignore-not-found
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- Zdravé Pody nehovoria nič o tom, či Service funguje
- `kubectl get endpoints` je prvý príkaz pri akomkoľvek probléme s dostupnosťou
- Prázdne endpointy = **nesúlad label selektora** — legitímne, tiché a veľmi časté
- Endpointy sú, ale spojenie je odmietnuté = zlý **`targetPort`**
- Endpointy vyprázdni aj zlyhávajúca readiness probe, bez toho, aby sa stav Podu zmenil na niečo alarmujúce
- Otestujte IP Podu priamo, aby ste rozlíšili chybu aplikácie od chyby prepojenia

Ostáva posledná kapitola — zhrnutie a ťahák, ktorý sa oplatí si nechať.
