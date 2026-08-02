# Sieťovanie kontajnerov

Docker poskytuje zabudované sieťové možnosti, ktoré umožňujú kontajnerom komunikovať navzájom, s hostiteľom aj s externými sieťami. Pochopenie sieťovania je nevyhnutné pri budovaní viackontajnerových aplikácií.

---

## Predvolené Docker siete

Docker automaticky vytvára tri siete:

```terminal:execute
command: docker network ls
```

| Sieť | Driver | Účel |
|---------|--------|---------|
| **bridge** | bridge | Predvolená sieť pre kontajnery. Poskytuje izoláciu založenú na NAT. |
| **host** | host | Kontajner priamo zdieľa sieťový stack hostiteľa. |
| **none** | null | Žiadne sieťovanie — úplná izolácia. |

---

## Predvolená bridge sieť

Keď spustíte kontajner bez zadania siete, pripojí sa k predvolenej sieti **bridge**:

```terminal:execute
command: docker run -d --name net-demo1 alpine:latest sleep 3600
```

```terminal:execute
command: docker run -d --name net-demo2 alpine:latest sleep 3600
```

**Preskúmajte IP adresy:**

```terminal:execute
command: docker inspect net-demo1 --format '{{.NetworkSettings.IPAddress}}'
```

```terminal:execute
command: docker inspect net-demo2 --format '{{.NetworkSettings.IPAddress}}'
```

**Otestujte konektivitu medzi kontajnermi cez IP adresu:**

```terminal:execute
command: docker exec net-demo1 ping -c 3 $(docker inspect net-demo2 --format '{{.NetworkSettings.IPAddress}}')
```

Kontajnery na predvolenom bridge dokážu komunikovať cez IP adresy, ale **DNS rozlíšenie mien nefunguje** na predvolenom bridge.

```terminal:execute
command: docker exec net-demo1 ping -c 1 net-demo2 2>&1 || echo "DNS resolution failed on default bridge — this is expected!"
```

---

## Používateľom definované bridge siete

Používateľom definované bridge siete poskytujú **automatické DNS rozlíšenie** medzi kontajnermi — kľúčová vlastnosť pre viackontajnerové aplikácie:

**Vytvorte vlastnú sieť:**

```terminal:execute
command: docker network create workshop-net
```

**Preskúmajte sieť:**

```terminal:execute
command: docker network inspect workshop-net
```

---

## Spúšťanie kontajnerov na vlastnej sieti

```terminal:execute
command: docker rm -f net-demo1 net-demo2
```

```terminal:execute
command: docker run -d --name web-app --network workshop-net nginx:latest
```

```terminal:execute
command: docker run -d --name test-client --network workshop-net alpine:latest sleep 3600
```

**Otestujte DNS rozlíšenie — kontajnery sa teraz dokážu navzájom dosiahnuť podľa mena:**

```terminal:execute
command: docker exec test-client ping -c 3 web-app
```

**Pristúpte k službe Nginx podľa mena kontajnera:**

```terminal:execute
command: docker exec test-client wget -qO- http://web-app:80 | head -5
```

Takto komunikujú viackontajnerové aplikácie v Dockeri — služby sa navzájom referencujú podľa mena kontajnera, nie podľa IP adresy.

---

## Pripojenie kontajnera k viacerým sieťam

Kontajner môže byť pripojený k viacerým sieťam súčasne:

**Vytvorte druhú sieť:**

```terminal:execute
command: docker network create backend-net
```

**Pripojte kontajner web-app k obom sieťam:**

```terminal:execute
command: docker network connect backend-net web-app
```

**Overte, že kontajner má rozhrania na oboch sieťach:**

```terminal:execute
command: docker inspect web-app --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} = {{$conf.IPAddress}}{{println}}{{end}}'
```

Kontajner má teraz IP adresu na `workshop-net` aj `backend-net`.

---

## Izolácia sietí

Kontajnery na rôznych sieťach spolu **nemôžu** komunikovať, pokiaľ nie sú explicitne prepojené:

```terminal:execute
command: docker run -d --name isolated-app --network backend-net alpine:latest sleep 3600
```

**Test: `isolated-app` (backend-net) nedokáže dosiahnuť `test-client` (workshop-net):**

```terminal:execute
command: docker exec isolated-app ping -c 1 -W 2 test-client 2>&1 || echo "Cannot reach test-client across networks — this is expected!"
```

**Ale `isolated-app` dokáže dosiahnuť `web-app` (ktorý je na oboch sieťach):**

```terminal:execute
command: docker exec isolated-app ping -c 3 web-app
```

Táto segmentácia sietí je mocná bezpečnostná vlastnosť — databázové kontajnery môžete izolovať od verejne prístupných webových serverov, pričom aplikačné kontajnery sa stále môžu pripojiť k obom.

---

## Odpojenie od siete

```terminal:execute
command: docker network disconnect backend-net web-app
```

**Overte, že kontajner už nie je na sieti backend-net:**

```terminal:execute
command: docker inspect web-app --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} = {{$conf.IPAddress}}{{println}}{{end}}'
```

---

## Režim host network

V režime **host** kontajner priamo zdieľa sieťový namespace hostiteľa — nie je potrebné žiadne mapovanie portov:

```terminal:execute
command: docker rm -f web-app
```

```terminal:execute
command: docker run -d --name host-net-demo --network host nginx:latest
```

**Nginx je teraz prístupný priamo na porte 80 hostiteľa:**

```terminal:execute
command: curl -s http://localhost:80 | head -3
```

> **Poznámka:** Host networking odstraňuje sieťovú izoláciu. Kontajner má plný prístup k sieťovým rozhraniam hostiteľa. Používajte ho iba vtedy, keď je výkonnostná réžia bridge sieťovania neprijateľná.

---

## Upratanie

```terminal:execute
command: docker rm -f test-client isolated-app host-net-demo
```

```terminal:execute
command: docker network rm workshop-net backend-net
```
