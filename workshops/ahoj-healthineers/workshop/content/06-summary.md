# Summary

Congratulations! 🎉 You've successfully completed the troubleshooting workshop.

## What you learned:

✅ **Application deployment** - You used `kubectl apply` to deploy Kubernetes manifests

✅ **Problem diagnostics** - You learned to use:
- `kubectl get endpoints` - check connection between service and pods
- `kubectl describe service` - display selectors
- `kubectl get pods --show-labels` - display labels on pods

✅ **Kubernetes labels** - You understood how:
- Service uses **selectors** to find pods
- Labels on Pods must **exactly match** selectors in the Service
- One wrong character can cause the application to fail

✅ **Problem resolution** - You successfully:
- Identified the difference in labels
- Modified the YAML manifest
- Applied the fix
- Verified that the application works

## Key takeaways

```
Service Selector ──┐
                   ├─→ MUST BE THE SAME
Pod Labels     ────┘
```

This principle also applies to:
- ReplicaSets and their Pods
- Deployments and their ReplicaSets
- NetworkPolicies and their target Pods

## Next steps

In production environments, we recommend:
- 📝 Use consistent label naming
- 🔍 Automated tests for manifest validation
- 🛡️ Policy engines like Kyverno or OPA Gatekeeper

---

**Thank you for participating! Happy Kubernetes troubleshooting! 🚀**
