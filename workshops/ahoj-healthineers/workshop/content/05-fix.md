# Step 4: Fix the Problem

Now we know what's wrong - **the label selector in the Service doesn't match the labels on the Pod**!

## Solution

We need to edit `secretapp-deployment.yaml` so the labels match.

### 1. Open the file in the Editor

Switch to the Editor tab:

```dashboard:open-dashboard
name: Editor
```

Open the file `secretapp-deployment.yaml`.

### 2. Find the Service section

Look at the end of the file where the Service is defined:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: secretapp
spec:
  selector:
    app: secret-application  # ← THIS IS THE PROBLEM!
```

### 3. Fix the label selector

The label selector in the Service must match the label on the Pod. The pod has label `app: secretapp`, so change the selector in the Service to:

```yaml
  selector:
    app: secretapp  # ← FIXED!
```

**Specifically:** Change the line `app: secret-application` to `app: secretapp`.

### 4. Save the file

In the Editor, press **Ctrl+S** (or Cmd+S on Mac) to save the changes.

### 5. Apply the fix

Redeploy the manifest with the fix:

```terminal:execute
command: kubectl apply -f secretapp-deployment.yaml
background: false
```

### 6. Verify endpoints

Now the service should find the pod:

```terminal:execute
command: kubectl get endpoints secretapp
background: false
```

**✅ You should see an IP address!**

### 7. Open the SecretApp tab

Click on the **SecretApp** tab - the application should work! 🎉

---

Congratulations! You've successfully resolved the Kubernetes labels problem. 🏆
