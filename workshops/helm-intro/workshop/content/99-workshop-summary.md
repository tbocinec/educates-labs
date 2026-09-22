---
title: Workshop Summary
---

# Workshop Summary

Congratulations! You've installed, configured, broken, rolled back and authored
Helm charts. 🎉

---

## Level 1: Charts, Releases & Repositories

- **Chart** = package, **release** = one installation, **repository** = index
- The same chart installs many times under different release names
- `helm show values` is the chart's API — read it before installing anything
- Helm 3+ has no server; release state lives in Secrets in your namespace

```
helm repo add <name> <url>
helm repo update
helm search repo <term> --versions
helm show chart|values <chart>
helm pull <chart> --untar
```

---

## Level 2: Your First Release

- `--dry-run=client` renders locally; `--dry-run=server` validates against the cluster
- `--wait` blocks until resources are genuinely ready
- Object names are prefixed with the release name; all carry `managed-by=Helm`
- `helm get manifest` shows exactly what was applied

```
helm install <release> <chart> --wait
helm list
helm status <release>
helm get values|manifest <release>
helm uninstall <release>
```

---

## Level 3: Configuring with Values

Precedence, lowest to highest:

```
chart defaults  →  -f file1  →  -f file2  →  --set
```

- `--set` for one or two values; a file for anything real
- `helm template` renders locally with no cluster
- **`helm upgrade` forgets previous overrides** unless you re-pass them or use `--reuse-values`

```
helm upgrade <release> <chart> --set key=value
helm upgrade <release> <chart> -f values.yaml
helm template <release> <chart> -f values.yaml
helm get values <release> --all
```

---

## Level 4: Upgrades & Rollbacks

- Every install and upgrade is a numbered revision, stored as a Secret
- Failed upgrades are recorded too
- A rollback **appends** a revision — history is never rewritten
- Rolling back restores that revision's values, not just its images
- `--atomic` rolls back automatically on failure

```
helm history <release>
helm rollback <release> [revision] --wait
helm upgrade <release> <chart> --atomic --timeout 5m
helm upgrade <release> <chart> --version 6.14.0
helm uninstall <release> --keep-history
```

---

## Level 5: Building Your Own Chart

- `helm create` scaffolds a complete chart
- `values.yaml` is documentation as much as configuration
- `helm lint` checks structure, `helm template` shows reality — use both
- Charts install straight from a directory; `helm package` makes them shippable

```
helm create <name>
helm lint <dir>
helm template <release> <dir> -f values.yaml
helm install <release> <dir>
helm test <release> --logs
helm package <dir>
```

---

## Habits Worth Keeping

| Habit | Why |
|-------|-----|
| `--dry-run=server` or `helm template` before applying | See the change before the cluster does |
| Values in a committed file, not `--set` | Reviewable, reproducible, no lost state |
| `--atomic` in pipelines | Never leave a half-broken release behind |
| Pin `--version` | A deploy months from now behaves the same |
| Read `helm show values` first | The chart's API, and whether it fits your permissions |

---

## A Note on Permissions

Everything here stayed inside your namespace. Many real-world charts
(ingress controllers, operators, monitoring stacks) install CRDs, ClusterRoles
and webhooks, and need cluster-scoped rights. If you hit `Forbidden` when trying
a chart elsewhere, that's usually the reason — the chart is fine, your role
isn't wide enough.

---

## What Wasn't Covered

- **Dependencies / subcharts** — `Chart.yaml` `dependencies:` and `helm dependency update`
- **Hooks** — `pre-install`, `post-upgrade` jobs for migrations
- **Library charts** — shared templates across many charts
- **OCI registries** — `helm push` to a container registry instead of a chart repo
- **Helmfile / ArgoCD / Flux** — managing many releases declaratively

---

## Official Documentation

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Helm command reference](https://helm.sh/docs/helm/)

Thank you for completing this workshop! 🚀
