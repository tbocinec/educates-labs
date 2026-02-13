---
title: ConfigMaps
---

# Level 4: ConfigMaps

Applications often need configuration — database URLs, feature flags, log levels, etc. Hard-coding these values in container images is a bad practice because the same image should work in different environments (dev, staging, production).

**ConfigMaps** solve this problem. They store non-sensitive configuration data as key-value pairs, and Pods can consume them as environment variables or mounted files.

> **Docs**: [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

## Creating a ConfigMap Imperatively

Create a ConfigMap from literal key-value pairs:

```terminal:execute
command: kubectl create configmap simple-config --from-literal=APP_COLOR=red --from-literal=APP_MODE=debug
```

View the ConfigMap:

```terminal:execute
command: kubectl get configmap simple-config
```

See its full contents:

```terminal:execute
command: kubectl get configmap simple-config -o yaml
```

Describe it for a cleaner view:

```terminal:execute
command: kubectl describe configmap simple-config
```

## Creating a ConfigMap from YAML

Open the exercise file that defines a ConfigMap in YAML:

```editor:open-file
file: exercises/configmap/configmap.yaml
```

Notice the `data` section with three key-value pairs:

```editor:select-matching-text
file: exercises/configmap/configmap.yaml
text: APP_COLOR: "blue"
```

Copy and apply the ConfigMap:

```terminal:execute
command: cp -r ~/exercises/configmap ~/configmap && kubectl apply -f ~/configmap/configmap.yaml
```

List all ConfigMaps in your namespace:

```terminal:execute
command: kubectl get configmaps
```

## Creating a ConfigMap from a File

You can also create a ConfigMap from a file. Open the properties file:

```editor:open-file
file: exercises/configmap/app-config.properties
```

This is a typical application configuration file with database settings and logging.

Create a ConfigMap from this file:

```terminal:execute
command: kubectl create configmap file-config --from-file=app-config.properties=~/exercises/configmap/app-config.properties
```

View the result:

```terminal:execute
command: kubectl describe configmap file-config
```

Notice how the entire file content is stored as a single key (`app-config.properties`), with the file content as the value.

## Using ConfigMap as Environment Variables

Now let's create a Pod that consumes the `app-config` ConfigMap as environment variables.

Open the exercise file:

```editor:open-file
file: exercises/configmap/pod-configmap-env.yaml
```

Notice the `envFrom` section:

```editor:select-matching-text
file: exercises/configmap/pod-configmap-env.yaml
text: envFrom:
```

The `envFrom` with `configMapRef` loads **all** key-value pairs from the ConfigMap as environment variables in the Pod.

Apply the Pod:

```terminal:execute
command: kubectl apply -f ~/configmap/pod-configmap-env.yaml
```

Wait for the Pod to start, then check the logs:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/configmap-env-demo --timeout=60s && kubectl logs configmap-env-demo
```

You should see the environment variables printed:
```
APP_COLOR=blue
APP_MODE=production
LOG_LEVEL=INFO
```

Verify by executing a command inside the Pod:

```terminal:execute
command: kubectl exec configmap-env-demo -- env | grep -E "APP_|LOG_"
```

## Using ConfigMap as a Mounted Volume

Instead of environment variables, you can mount a ConfigMap as files in a volume. This is ideal for configuration files.

Open the exercise file:

```editor:open-file
file: exercises/configmap/pod-configmap-volume.yaml
```

Notice the `volumes` and `volumeMounts` sections:

```editor:select-matching-text
file: exercises/configmap/pod-configmap-volume.yaml
text: mountPath: /etc/config
```

The ConfigMap `file-config` will be mounted at `/etc/config/` in the container. Each key becomes a file.

Apply the Pod:

```terminal:execute
command: kubectl apply -f ~/configmap/pod-configmap-volume.yaml
```

Wait for the Pod and check its logs:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/configmap-volume-demo --timeout=60s && kubectl logs configmap-volume-demo
```

You should see the listing of `/etc/config/` and the content of the configuration file.

Verify by listing the mounted files:

```terminal:execute
command: kubectl exec configmap-volume-demo -- ls -la /etc/config/
```

Read the mounted configuration file:

```terminal:execute
command: kubectl exec configmap-volume-demo -- cat /etc/config/app-config.properties
```

## Updating ConfigMaps

ConfigMaps can be updated, and Pods using volume mounts will eventually receive the updated values (within a few minutes). However, Pods using environment variables will **not** see changes — they must be restarted.

Update the ConfigMap:

```terminal:execute
command: kubectl patch configmap app-config -p '{"data":{"APP_COLOR":"green"}}'
```

Verify the change:

```terminal:execute
command: kubectl get configmap app-config -o yaml | grep APP_COLOR
```

## Cleanup

Remove the ConfigMaps and Pods:

```terminal:execute
command: kubectl delete pod configmap-env-demo configmap-volume-demo
```

```terminal:execute
command: kubectl delete configmap simple-config app-config file-config
```

Verify:

```terminal:execute
command: kubectl get pods,configmaps
```

## Summary

In this chapter you learned:
- **ConfigMaps** store non-sensitive configuration as key-value pairs
- `kubectl create configmap --from-literal` — create from command line values
- `kubectl create configmap --from-file` — create from a file
- ConfigMaps can be defined in YAML and applied with `kubectl apply -f`
- Pods consume ConfigMaps as:
  - **Environment variables** (`envFrom` / `configMapRef`)
  - **Mounted files** (`volumes` / `volumeMounts`)
- Volume-mounted ConfigMaps can be updated live; env-var ConfigMaps require Pod restart

Next, let's learn about **Labels, Selectors, and Namespaces** — key concepts for organizing resources!
