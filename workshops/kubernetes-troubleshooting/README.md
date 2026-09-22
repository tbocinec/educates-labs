# Kubernetes Troubleshooting Workshop

A hands-on workshop on diagnosing broken Kubernetes workloads. Eight realistic
failures, one repeatable method.

## Duration

~60 minutes

## Prerequisites

- Completion of **Kubernetes Fundamentals** and ideally **Kubernetes Services,
  Secrets & Storage** (or equivalent knowledge of kubectl, Pods, Deployments,
  Services and ConfigMaps)

## Topics Covered

### Level 1 — A Method That Works
- The order that solves most problems: status → describe → events → logs
- Reading the STATUS column as a first diagnosis
- `kubectl get events --sort-by` and filtering to warnings

### Level 2 — The Pod Never Starts
- `ImagePullBackOff` — wrong tag, private registry, rate limits
- `CreateContainerConfigError` — unresolvable ConfigMap/Secret references

### Level 3 — The Pod Starts, Then Dies
- `CrashLoopBackOff` and why `kubectl logs --previous` is the whole trick
- `OOMKilled` — exit 137 with empty logs, and what that fingerprint means

### Level 4 — The Pod Stays Pending
- `FailedScheduling` — unmatched `nodeSelector`, insufficient resources, taints
- Admission rejections from `LimitRange` and `ResourceQuota`

### Level 5 — The App Is Unreachable
- `kubectl get endpoints` as the first command for connectivity problems
- Label selector mismatch — legal, silent, and very common
- `port` vs `targetPort` confusion

## Features

- Eight broken manifests with inline comments explaining the trap
- Every scenario follows: break → observe → diagnose → fix → verify
- Matching `-fixed` manifests so learners can compare before and after
- Headlamp web UI for reading events and logs visually
- Split terminal for watching resources while working

## Design Notes

All scenarios run inside a single session namespace and need no cluster-scoped
permissions. They were verified to reproduce on both a local kind cluster and
the Educates session environment:

| Scenario | Verified result |
|----------|-----------------|
| Bad image tag | `ErrImagePull` → `ImagePullBackOff` |
| Missing ConfigMap key | `CreateContainerConfigError`, "couldn't find key mode" |
| Crashing worker | `CrashLoopBackOff`, message visible via `logs --previous` |
| Memory hog | `OOMKilled`, exit code 137, empty logs |
| Impossible nodeSelector | `Pending`, `FailedScheduling` event |
| Oversized request | Rejected at admission by `LimitRange` |
| Selector mismatch | `endpoints` shows `<none>` |

## Official Documentation Links

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
