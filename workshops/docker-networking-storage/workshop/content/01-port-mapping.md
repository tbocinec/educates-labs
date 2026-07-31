# Mapovanie portov a sprístupnenie služieb

Kontajnery bežia predvolene v izolovanej sieti. Aby bola služba v kontajneri prístupná z hostiteľského stroja (alebo z vonkajšieho sveta), musíte **namapovať** porty kontajnera na porty hostiteľa.

---

## Ako funguje mapovanie portov

Keď v kontajneri beží služba (napr. webový server na porte 80), tento port je prístupný iba **vnútri** sieťového namespace kontajnera. Port mapping vytvorí mostík medzi sieťou hostiteľa a sieťou kontajnera:

```
Host Machine                    Container
┌──────────────────────┐       ┌──────────────────┐
│                      │       │                  │
│  localhost:8080 ─────────────►  container:80    │
│                      │       │  (Nginx)         │
│  localhost:5432 ─────────────►  container:5432  │
│                      │       │  (PostgreSQL)    │
└──────────────────────┘       └──────────────────┘
```

---

## Základné mapovanie portov pomocou `-p`

Prepínač `-p` mapuje **host port** na **container port**:

```
-p HOST_PORT:CONTAINER_PORT
```

**Spustite Nginx a namapujte host port 8080 na container port 80:**

```terminal:execute
command: docker run -d --name web-port-demo -p 8080:80 nginx:latest
```

**Otestujte službu z hostiteľa:**

```terminal:execute
command: curl -s http://localhost:8080 | head -5
```

Mali by ste vidieť uvítacie HTML Nginxu. Požiadavka putuje z `localhost:8080` na hostiteľovi na port `80` vnútri kontajnera.

Môžete tiež otvoriť záložku **Nginx** v hornej časti workshopu a zobraziť si uvítaciu stránku Nginxu priamo v prehliadači.

---

## Mapovanie viacerých portov

Viacero portov namapujete zadaním prepínača `-p` viackrát. Najprv odstráňme predchádzajúci kontajner, aby sa uvoľnil host port 8080:

```terminal:execute
command: docker rm -f web-port-demo
```

```terminal:execute
command: docker run -d --name multi-port-demo -p 8080:80 -p 8443:443 nginx:latest
```

**Overte obidve mapovania:**

```terminal:execute
command: docker port multi-port-demo
```

---

## Priradenie náhodného host portu

Ak host port neuvediete, Docker priradí **náhodný voľný port** — prepínaču `-p` zadáte iba container port:

```terminal:execute
command: docker run -d --name random-port-demo -p 80 nginx:latest
```

**Zistite priradený port:**

```terminal:execute
command: docker port random-port-demo
```

**Alebo použite `docker ps` a pozrite si stĺpec PORTS:**

```terminal:execute
command: docker ps --filter "name=random-port-demo"
```

Toto je užitočné, keď spúšťate viacero inštancií tej istej služby a chcete, aby Docker riešil konflikty portov automaticky.

---

## Naviazanie na konkrétne rozhranie

Predvolene sa mapovania portov naviažu na **všetky rozhrania** (`0.0.0.0`). Naviazanie môžete obmedziť na konkrétnu IP adresu:

```
docker run -d -p 127.0.0.1:8080:80 nginx:latest
```

Vďaka tomu je služba prístupná iba cez `localhost` — nie z externých strojov. Ide o dobrý bezpečnostný postup pre služby, ktoré by nemali byť verejne prístupné.

---

## Praktický príklad: spustenie viacerých webových serverov

Spustime tri inštancie Nginxu na rôznych host portoch, aby sme ukázali, že container port 80 sa dá namapovať na rôzne host porty:

```terminal:execute
command: docker run -d --name web1 -p 8081:80 nginx:latest && docker run -d --name web2 -p 8082:80 nginx:latest && docker run -d --name web3 -p 8083:80 nginx:latest
```

**Prispôsobte obsah každého webového servera:**

```terminal:execute
command: docker exec web1 bash -c 'echo "<h1>Server 1</h1>" > /usr/share/nginx/html/index.html'
```

```terminal:execute
command: docker exec web2 bash -c 'echo "<h1>Server 2</h1>" > /usr/share/nginx/html/index.html'
```

```terminal:execute
command: docker exec web3 bash -c 'echo "<h1>Server 3</h1>" > /usr/share/nginx/html/index.html'
```

**Overte, že každý server vracia iný obsah:**

```terminal:execute
command: echo "--- Server 1 ---" && curl -s http://localhost:8081 && echo "--- Server 2 ---" && curl -s http://localhost:8082 && echo "--- Server 3 ---" && curl -s http://localhost:8083
```

Všetky tri kontajnery používajú ten istý interný port (80), ale sú prístupné na rôznych host portoch.

---


## Upratanie

```terminal:execute
command: docker rm -f multi-port-demo random-port-demo web1 web2 web3
```
