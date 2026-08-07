# Educates Labs

A collection of interactive, hands-on workshops built for
**[Educates](https://educates.dev/)** — the open-source training platform that
gives every learner a browser-based terminal, editor and (per workshop) Docker,
Kubernetes or app dashboards, with no local setup.

- Educates project & docs: <https://educates.dev/> · <https://docs.educates.dev/>
- Educates on GitHub: <https://github.com/educates/educates-training-platform>

Each workshop is a self-contained module (instructions + setup + resource
definition) that can be deployed on its own or grouped into a training portal.

> **Note:** the Docker workshops are written in **Slovak** (technical terms kept
> in English); the Kubernetes, Kafka and Grafana workshops are in **English**.

## Available workshops

### 🐳 Docker (SK)
| Workshop | Description |
|----------|-------------|
| `docker-intro` | Docker fundamentals — pulling images, running containers, exec, lifecycle, logs, env variables. |
| `dockerfile-intro` | Writing Dockerfiles — layers & caching, key instructions, best practices, multi-stage builds. |
| `docker-compose-intro` | Multi-container apps with Compose — services, networking, env & `.env`, volumes, scaling & profiles. |
| `docker-networking-storage` | Port mapping, volumes & persistent data, `docker cp`, bind mounts, user-defined networks & isolation. |

### ☸️ Kubernetes
| Workshop | Description |
|----------|-------------|
| `kubernetes-intro` | Kubernetes basics — `kubectl`, Pods, Deployments, rollouts/rollbacks, ConfigMaps, labels & selectors. |
| `kubernetes-services-storage` | Services & networking, Secrets, persistent storage with PV/PVC. |

### 📨 Apache Kafka
| Workshop | Description |
|----------|-------------|
| `kafka-base` | Kafka sandbox with auto-start, JDK 21 and editor — a base for experimenting. |
| `kafka-linux-install` | Install & configure Kafka in KRaft mode on Ubuntu, then scale to a multi-broker cluster. |
| `kafka-cli-tools` | Master the essential Kafka CLI tools on a 3-node cluster, basics → production scenarios. |
| `kafka-intro-java` | Kafka with Java producer/consumer applications. |
| `kafka-producers-essentials` | Producer fundamentals — `ProducerRecord`, keys, partitioning, sync/async, acks. |
| `kafka-consumers-essentials` | Producer & consumer essentials with hands-on Java exercises. |
| `kafka-consumers` | Consumer deep dive — consumer-group patterns using humidity-sensor data. |
| `kafka-connect` | Stream data from PostgreSQL into Kafka with the Kafka Connect JDBC source connector. |
| `kafka-schema-registry` | Data governance — Avro schemas, evolution, compatibility modes, contract-based messaging. |
| `kafka-monitoring` | Monitoring & observability with JMX/Kafka Exporter, Prometheus and Grafana. |
| `kafka-flink-mold-alert` | Stream processing with Flink + Kafka — a real-time humidity/mold alerting system. |

### 📊 Grafana
| Workshop | Description |
|----------|-------------|
| `grafana-intro` | Install, start and access Grafana; build a first dashboard. |
| `grafana-intro-docker` | Run Grafana via official Docker images and Docker Compose. |
| `grafana-data-sources` | Connect Grafana to Prometheus, InfluxDB and ClickHouse. |
| `grafana-alerting` | End-to-end alerting with Grafana Unified Alerting and ClickHouse. |
| `grafana-loki` | Log aggregation with Loki + Promtail, visualised in Grafana. |

### 👋 Misc
| Workshop | Description |
|----------|-------------|
| `ahoj-healthineers` | A minimal welcome workshop demonstrating the Educates basics. |

## How workshops are published & deployed

### Publishing (CI)
Pushing a version tag (`X.Y`, e.g. `0.31`) triggers the
[`publish-workshops`](.github/workflows/publish-workshops.yaml) GitHub Action
([educates/educates-github-actions](https://github.com/educates/educates-github-actions)),
which for every workshop:

1. builds the workshop **content image** and pushes it to GHCR
   (`ghcr.io/<owner>/<workshop>-files:<tag>`), and
2. attaches a self-contained **`<workshop>.yaml`** to the GitHub
   [Release](../../releases) for that tag.

```bash
git tag 0.32 && git push origin 0.32     # CI publishes images + release YAMLs
```

### Deploying to an Educates cluster
You need an Educates platform running on a Kubernetes cluster
([installation guide](https://docs.educates.dev/en/stable/installation-guides/)).

**A single workshop** (from a published release) — the CLI creates a portal and
deploys it:
```bash
educates deploy-workshop -f https://github.com/<owner>/educates-labs/releases/download/0.31/docker-intro.yaml
```

**A portal with several workshops** — apply the Workshop definitions, then a
`TrainingPortal` that lists them **by name** (Educates 3.7+):
```bash
REL=https://github.com/<owner>/educates-labs/releases/download/0.31
kubectl apply -f $REL/docker-intro.yaml -f $REL/kubernetes-intro.yaml
```
```yaml
apiVersion: training.educates.dev/v1beta1
kind: TrainingPortal
metadata:
  name: my-portal
spec:
  portal:
    sessions: { maximum: 20 }
    registration: { type: anonymous }
  workshops:
    - name: docker-intro
    - name: kubernetes-intro
```

**Locally, while authoring** — build and serve straight from the source tree:
```bash
educates deploy-workshop -f workshops/docker-intro/resources/workshop.yaml
```

## Repository structure

```
workshops/<name>/
  resources/workshop.yaml   # Workshop resource: title, session apps, resources, content image
  workshop/config.yaml      # pathway: modules, order, durations
  workshop/content/*.md     # lesson content (clickable terminal/editor actions)
  workshop/setup.d/*.sh     # optional per-session setup scripts
  exercises/                # optional starter files used by the workshop
```

## Contributing

Contributions are very welcome — **if you'd like to add or improve a workshop,
open a PR and we'll be happy to review it!** 🎉

1. Start from the template: `educates new-workshop -n my-workshop` (or copy an
   existing workshop directory).
2. Keep the standard layout above; put clickable commands in `terminal:execute`
   blocks and make each step clean up after itself.
3. Test locally: `educates deploy-workshop -f workshops/<name>/resources/workshop.yaml`.
4. Open a pull request describing the workshop and what it teaches.

Bug reports and fixes (typos, broken steps, clearer explanations) are just as
welcome as new workshops.

## Useful links

- Educates — <https://educates.dev/>
- Educates documentation — <https://docs.educates.dev/>
- Educates platform (GitHub) — <https://github.com/educates/educates-training-platform>
- Educates GitHub Actions — <https://github.com/educates/educates-github-actions>
- Installing the Educates CLI — <https://docs.educates.dev/en/stable/getting-started/installing-cli.html>
- Workshop configuration reference — <https://docs.educates.dev/en/stable/custom-resources/workshop-definition.html>
