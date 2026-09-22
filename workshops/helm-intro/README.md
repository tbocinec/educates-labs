# Helm Fundamentals Workshop

A hands-on introduction to Helm — the package manager for Kubernetes.

## Duration

~60 minutes

## Prerequisites

- Completion of **Kubernetes Fundamentals** (or equivalent knowledge of kubectl,
  Deployments, Services and ConfigMaps)

## Topics Covered

### Level 1 — Charts, Releases & Repositories
- The three core concepts and how they relate
- Adding repositories, searching, reading a chart before installing it
- Where Helm keeps release state (Secrets, not a server)

### Level 2 — Your First Release
- `--dry-run` and `--wait`
- Inspecting a release: `status`, `get values`, `get manifest`
- Installing the same chart twice to show releases are independent

### Level 3 — Configuring with Values
- The precedence chain: chart defaults → values files → `--set`
- `helm template` for local rendering
- The `--reuse-values` trap that loses overrides on upgrade

### Level 4 — Upgrades & Rollbacks
- Release history and revisions
- Shipping a deliberately broken release, then rolling it back
- `--atomic` for automatic rollback on failure
- Pinning chart versions

### Level 5 — Building Your Own Chart
- `helm create`, template syntax, whitespace trimming
- `helm lint` and `helm template` as a pre-flight check
- `helm test` and `helm package`

## Features

- Helm is already installed in the workshop image — no setup step
- Uses [podinfo](https://github.com/stefanprodan/podinfo), a small demo app
  whose chart creates only namespaced objects
- Commented values files learners apply and modify
- Headlamp web UI for seeing what Helm created

## Design Notes

Learners are namespace administrators, not cluster administrators. Every chart
used here was chosen because it creates **only namespaced objects** — no CRDs,
ClusterRoles or webhooks, which would be refused.

The full lifecycle was verified in an Educates session with those permissions:

| Command | Verified |
|---------|----------|
| `helm repo add` / `search` | Works, chart podinfo 6.15.0 found |
| `helm install --wait` | Release created, objects healthy |
| `helm upgrade` | Replica count change applied |
| `helm history` | Revisions recorded |
| `helm rollback` | Returned to the previous revision |

Note that Helm objects are named `<release>-podinfo`, so content filters on the
`app.kubernetes.io/managed-by=Helm` label rather than a chart name.

## Official Documentation Links

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
