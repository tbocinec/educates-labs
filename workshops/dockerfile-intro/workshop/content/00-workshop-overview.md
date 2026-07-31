# Prehľad workshopu

Vitajte na workshope **Vytváranie Docker images pomocou Dockerfile**!

Na tomto workshope sa naučíte vytvárať vlastné Docker images pomocou súborov Dockerfile — štandardného spôsobu, ako definovať, zostaviť (build) a distribuovať kontajnerizované aplikácie.

---

## Čo sa naučíte

- Čo je to Dockerfile a ako funguje proces zostavenia (build)
- Základné inštrukcie Dockerfile: `FROM`, `RUN`, `COPY`, `CMD` a ďalšie
- Ako fungujú **vrstvy (layers)** image a ako optimalizovať **caching** pri builde
- Pokročilé inštrukcie: `WORKDIR`, `EXPOSE`, `ENTRYPOINT`, `ARG`, `ENV`
- **Osvedčené postupy (best practices)** pre Dockerfile a images pripravené do produkcie
- **Multi-stage builds** na vytvorenie minimálnych a bezpečných images

---

## Predpoklady

Pred začatím tohto workshopu by ste mali ovládať:

- Spúšťanie a správu Docker kontajnerov (`docker run`, `docker ps`, `docker stop`)
- Základné operácie v príkazovom riadku

> Ak ste ešte neabsolvovali workshop **Introduction to Docker**, odporúčame začať ním.

---

## Prostredie workshopu

Vaše prostredie obsahuje:

- **Terminal** — na spúšťanie Docker príkazov (rozdelený do dvoch panelov)
- **Editor** — na prezeranie a úpravu súborov Dockerfile a kódu aplikácie
- **App Preview** — záložku prehliadača na testovanie zostavených images cez port 8080

Všetky súbory cvičení sú predpripravené v adresári `~/exercises/`. Počas workshopu ich budete kopírovať do pracovných adresárov.

---

## Trvanie

Absolvovanie tohto workshopu trvá približne **60 minút**.

Poďme začať vytvárať Docker images!
