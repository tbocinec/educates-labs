# Zhrnutie a ďalšie kroky

Gratulujem 🎉  
Dokončil si základný Kafka intro workshop v prostredí Educates.

## Čo si sa naučil

V rámci jednotlivých modulov si:

1. **Pripravil prostredie v Educates**
   - pracoval si s Terminal a Editor aplikáciami,
   - overil si, že Docker v session funguje.

2. **Spustil Kafka stack pomocou Docker Compose**
   - vytvoril si súbor `docker-compose.yml`,
   - spustil si Zookeeper a Kafka broker kontajnery,
   - overil si bežiace kontajnery (`docker ps`, `docker logs`).

3. **Pracoval s Kafka CLI**
   - vytvoril si topic `demo-topic`,
   - spustil si konzolového producenta a konzumenta,
   - posielal a čítal si textové správy v reálnom čase.

## Nápady na rozšírenie workshopu

Ak chceš workshop rozšíriť (pre seba alebo pre účastníkov), môžeš pridať ďalšie moduly, napr.:

- **Viac partitions a consumer groups**
  - vytvoriť topic s viacerými partitions,
  - spustiť viac consumerov a sledovať rozdelenie správ.

- **Vlastný klient (Java, Python, ...)**
  - pridať modul, kde si účastník napíše jednoduchého Kafka producer/consumer klienta,
  - použiť oficiálny Kafka client alebo Spring Kafka / Quarkus.

- **Kafka UI / pozorovateľnosť**
  - pridať do `docker-compose.yml` nástroj typu Kafka UI alebo AKHQ,
  - ukázať topics, partitions, consumer groups vizuálne.

- **Automatické testy v Educates**
  - použiť examiner akcie, ktoré overia, či:
    - beží kontajner `kafka`,
    - existuje topic `demo-topic`,
    - Kafka prijala aspoň jednu správu.

Tento workshop môžeš brať ako základ, ktorý si postupne prispôsobíš podľa potreby – úroveň účastníkov, časový rozsah a to, čo chceš o Kafke ukázať.
