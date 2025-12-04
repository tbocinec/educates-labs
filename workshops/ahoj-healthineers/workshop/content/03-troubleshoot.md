# Step 2: Problem Analysis

The application is deployed, but the **SecretApp tab shows nothing** or displays an error! 😱

What happened? Let's find out.

## Diagnostics using Console

Kubernetes Console allows you to visually explore resources.

```dashboard:open-dashboard
name: Console
```

In the Console, examine:

1. **Pods** - is the pod actually running?
2. **Services** - does the service exist?
3. **Endpoints** - does the service have any endpoints?

## Diagnostics using kubectl

Check endpoints for your service:

```terminal:execute
command: kubectl get endpoints secretapp
background: false
```

**❓ What do you see?**

Endpoints should show the IP addresses of pods behind the service. If you see `<none>` or empty endpoints, it means the **service didn't find any pods**!

## Why didn't the service find pods?

The service uses **selectors** (labels) to find pods. Let's look:

```terminal:execute
command: kubectl describe service secretapp
background: false
```

Look at the `Selector:` section - what label is the service looking for?

Now check the labels on the pod:

```terminal:execute
command: kubectl get pods --show-labels
background: false
```

**🔍 Do you see the problem?**

---

If you've identified the difference, proceed to the next step where you'll get a hint!
