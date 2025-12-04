# Ahoj Healthineers Workshop

Jednoduchý uvítací workshop pre Healthineers tím, ktorý demonštruje základné možnosti Educates platformy.

## Prehľad

Workshop obsahuje jeden level s krátkym pozdravom a ukážkami dostupných nástrojov:
- Terminal s kubectl prístupom
- Editor pre úpravu súborov  
- Kubernetes Console pre správu clusteru

## Štruktúra

```
├── resources/workshop.yaml    # Workshop definícia
├── workshop/
│   ├── config.yaml           # Konfigurácia modulov
│   └── content/
│       └── 01-intro.md       # Hlavný obsah
└── README.md
```

## Použitie

```bash
educates publish-workshop
educates deploy-workshop
```

---

**Ahoj a víta vás Educates! 🎓**