# Prehľad workshopu

Vitajte na workshope **Docker: Networking, Ports & Storage**! Toto praktické cvičenie pokrýva tri základné oblasti Dockeru, ktoré presahujú úplné základy — mapovanie portov, perzistentné úložisko a sieťovanie kontajnerov.

---

## Čo sa naučíte

Na konci tohto workshopu budete vedieť:

- **Sprístupniť** služby v kontajneri hostiteľskej sieti pomocou port mappingu (`-p`)
- **Spustiť** viacero inštancií tej istej služby na rôznych host portoch
- **Uchovať** dáta naprieč reštartmi kontajnera pomocou Docker volumes
- **Kopírovať** súbory do kontajnerov a z nich pomocou `docker cp`
- **Pochopiť** bind mounts a kedy ich použiť
- **Vytvoriť** používateľom definované bridge networks s automatickým DNS resolution
- **Izolovať** kontajnery na oddelených sieťach kvôli bezpečnosti
- **Pripojiť** kontajner k viacerým sieťam súčasne
- **Upratať** nepoužívané Docker prostriedky efektívne

---

## Predpoklady

Tento workshop predpokladá, že sa vyznáte v nasledujúcom:

- Spúšťanie kontajnerov (`docker run`, `-d`, `--name`, `--rm`)
- Správa životného cyklu kontajnera (`docker stop`, `start`, `rm`)
- Spúšťanie príkazov vnútri kontajnerov (`docker exec -it`)
- Logy kontajnerov (`docker logs`)
- Premenné prostredia (`-e`)

Ak ste ešte neabsolvovali workshop **Introduction to Docker**, odporúčame začať ním.

---

## Prostredie workshopu

Vaše prostredie workshopu je vopred nakonfigurované a obsahuje:

- **Docker Engine** — pripravený na použitie z terminálu
- **Terminál** — terminál s rozdelenými panelmi na spúšťanie príkazov
- **Editor** — prístupný cez záložku **Editor** na prezeranie súborov
- **Záložka Nginx** — záložka v prehliadači na zobrazenie služieb sprístupnených na porte 8080

---

## Ako používať tento workshop

Počas workshopu budete narážať na spustiteľné bloky príkazov. Stačí na ne kliknúť a príkaz sa vykoná v termináli.

**Poďme na to!**
