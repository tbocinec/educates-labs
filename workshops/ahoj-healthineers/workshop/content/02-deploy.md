# Step 1: Deploy the Application

In this step, you'll deploy the application to the Kubernetes cluster.

## 1. Review the manifest

You have a prepared file `secretapp-deployment.yaml` that contains Kubernetes manifests.

Open it in the **Editor** tab, or view it in the terminal:

```terminal:execute
command: cat secretapp-deployment.yaml
background: false
```

The manifest contains:
- 📦 **Deployment** - defines how your application runs
- 🔌 **Service** - exposes the application on the network

## 2. Deploy the application

Use `kubectl apply` to deploy:

```terminal:execute
command: kubectl apply -f secretapp-deployment.yaml
background: false
session: 2
```

The output should confirm the creation of both resources:
```
deployment.apps/secretapp created
service/secretapp created
```

## 3. Check pod status

Verify that the pod is running:

```terminal:execute
command: kubectl get pods
background: false
session: 2
```

The pod should be in `Running` state.

## 4. Check the service

Verify that the service was created:

```terminal:execute
command: kubectl get service secretapp
background: false
session: 2
```

✅ Application deployed! Continue to the next step.

```terminal:execute
command: kubectl get svc secretapp
background: false
session: 2
```

---

✅ Aplikácia je nasadená! Pokračujte na ďalší krok.
