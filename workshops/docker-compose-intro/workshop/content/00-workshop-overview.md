# Prehľad workshopu

Vitajte na workshope **Introduction to Docker Compose**! Docker Compose je štandardný nástroj na definovanie a spúšťanie viackontajnerových Docker aplikácií. Namiesto samostatnej správy každého kontajnera pomocou dlhých príkazov `docker run` opíšete celý stack svojej aplikácie v jedinom YAML súbore a spustíte ho jediným príkazom.

---

## Čo sa naučíte

Na konci tohto workshopu budete vedieť:

- **Pochopiť**, čo je Docker Compose a kedy ho použiť
- **Napísať** súbor `compose.yaml` na definovanie services, networks a volumes
- **Spustiť** viackontajnerové aplikácie jediným príkazom
- **Spravovať** životný cyklus services pomocou Compose CLI príkazov
- **Nakonfigurovať** services pomocou environment variables a env súborov
- **Zachovať** dáta pomocou named volumes v Compose
- **Využiť** automatické service discovery a DNS-based networking
- **Naškálovať** services a použiť profiles pre voliteľné komponenty

---

## Predpoklady

Tento workshop predpokladá, že poznáte:

- Spúšťanie kontajnerov pomocou `docker run`
- Základný životný cyklus kontajnera (`docker stop`, `start`, `rm`)
- Environment variables (`-e`)
- Docker images a tagy

Ak ste ešte neabsolvovali workshop **Introduction to Docker**, odporúčame začať ním.

---

## Prostredie workshopu

Vaše prostredie workshopu je vopred nakonfigurované s:

- **Docker Engine** a **Docker Compose** — pripravené na použitie
- **Terminal** — terminál s rozdelenou obrazovkou na spúšťanie príkazov
- **Editor** — prístupný cez záložku **Editor** na vytváranie a úpravu súborov
- **Web App** — záložka prehliadača na zobrazenie services vystavených na porte 8080

---

**Poďme na to!**
