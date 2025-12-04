# Step 3: Hint - Labels Must Match!

Did you identify the problem? If not, here's a **hint**! 💡

## How does a Service work in Kubernetes?

A Kubernetes **Service** uses **label selectors** to identify which pods it should serve.

```
┌─────────────┐
│   Service   │
│             │  Selector:
│  selector:  │    app: secretapp  ←── This label MUST
│    app: ???  │                        match the label
└─────────────┘                        on the pod!
       ↓
       ↓ Looking for pods with this label...
       ↓
┌─────────────┐
│     Pod     │
│             │  Labels:
│   labels:   │    app: secretapp  ←── Label on the pod
│    app: ???  │
└─────────────┘
```

## 🔍 Compare labels

Display the selector in the Service:

```terminal:execute
command: kubectl get service secretapp -o jsonpath='{.spec.selector}' | jq
background: false
```

Display labels on the Deployment/Pod:

```terminal:execute
command: kubectl get deployment secretapp -o jsonpath='{.spec.template.metadata.labels}' | jq
background: false
```

**❓ Are they the same?**

If NOT, that's your problem! The service is looking for pods with one label, but the pods have a different label.

---

Proceed to the next step, where you'll learn how to fix it!
