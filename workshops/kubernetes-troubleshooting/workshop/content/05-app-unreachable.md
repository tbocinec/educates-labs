---
title: The App Is Unreachable
---

# Level 5: The App Is Unreachable

Symptom: every Pod is `1/1 Running`. No restarts, no errors, no warnings. And
the application still doesn't answer.

This is the most frustrating category, because `kubectl get pods` looks perfect.
The failure is in the wiring between the Service and the Pods — and it has its
own diagnostic command.

## The One Command for Service Problems

A Service doesn't route to Pods directly. It selects them by label, and the
result is an **EndpointSlice**: the list of Pod IPs actually behind the Service.

```
Service  --(label selector)-->  Pods  --(their IPs)-->  Endpoints
```

If `Endpoints` is empty, the Service is a dead end no matter how healthy the
Pods are. That makes `kubectl get endpoints` the first thing to run.

> **Docs**: [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)

## Scenario 7: The Service With No Endpoints

```editor:open-file
file: broken/06-service/web-deployment.yaml
```

```editor:open-file
file: broken/06-service/web-service-broken.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-deployment.yaml -f ~/broken/06-service/web-service-broken.yaml
```

### Observe

Everything looks healthy:

```terminal:execute
command: kubectl get pods,svc -l app=web
```

Now try to actually reach it. Start a throwaway client Pod:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 http://web-service
```

It hangs and then fails. Nothing in the Pod list hinted at this.

### Diagnose

```terminal:execute
command: kubectl get endpoints web-service
```

`<none>`. The Service has no backends — that's your answer.

> **You'll see a deprecation warning** about `v1 Endpoints` on Kubernetes 1.33+.
> Ignore it here — the command still works and is shorter to type. The modern
> equivalent is `kubectl get endpointslices -l kubernetes.io/service-name=web-service`.

Now find out why. Compare what the Service is looking for:

```terminal:execute
command: kubectl get service web-service -o jsonpath='selector={.spec.selector}{"\n"}'
```

…with the labels the Pods actually carry:

```terminal:execute
command: kubectl get pods --show-labels -l app=web
```

The Service selects `app=webapp`. The Pods are labelled `app=web`. One letter.

`describe` says the same thing in words:

```terminal:execute
command: kubectl describe service web-service | grep -E "Selector|Endpoints"
```

### Root Cause

Label selector mismatch. This is the single most common Service bug, and it
produces **zero** warnings — an empty selection is a perfectly legal state as far
as Kubernetes is concerned.

### Fix and Verify

Fix the selector in the manifest:

```editor:select-matching-text
file: broken/06-service/web-service-broken.yaml
text: "app: webapp"
```

Change `webapp` to `web`, save, and re-apply:

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-service-broken.yaml
```

```terminal:execute
command: kubectl get endpoints web-service
```

Two Pod IPs now. Try again:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "HTTP %{http_code}\n" http://web-service
```

`HTTP 200`.

## Scenario 8: Endpoints Exist, Traffic Still Fails

A subtler variant: the selector is right, so endpoints appear — but requests are
still refused.

```terminal:execute
command: kubectl apply -f ~/broken/06-service/web-service-badport.yaml
```

```terminal:execute
command: kubectl get endpoints web-badport
```

Endpoints are there. And yet:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 http://web-badport
```

Connection refused.

### Diagnose

When endpoints exist but traffic fails, the problem has moved one level down: the
**port**. Check what the Service forwards to:

```terminal:execute
command: kubectl get service web-badport -o jsonpath='port={.spec.ports[0].port} targetPort={.spec.ports[0].targetPort}{"\n"}'
```

And what the container actually listens on:

```terminal:execute
command: kubectl get deployment web -o jsonpath='containerPort={.spec.template.spec.containers[0].ports[0].containerPort}{"\n"}'
```

The Service forwards to port `8080`; nginx listens on `80`.

Prove it by talking to the Pod directly, bypassing the Service:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "direct to pod: HTTP %{http_code}\n" http://$(kubectl get endpoints web-service -o jsonpath='{.subsets[0].addresses[0].ip}')
```

The Pod answers fine on port 80. The Service is pointing at the wrong door.

> **`port` vs `targetPort`.** `port` is what clients call on the Service.
> `targetPort` is the container port traffic is forwarded to. They are allowed
> to differ — which is exactly why this mistake is easy to make and invisible in
> the Pod list.

### Fix and Verify

```terminal:execute
command: kubectl patch service web-badport -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
```

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 5 -o /dev/null -w "HTTP %{http_code}\n" http://web-badport
```

## A Checklist for "It Doesn't Answer"

Work down this list — each step rules out a layer:

1. `kubectl get endpoints <svc>` — empty? → selector mismatch
2. Endpoints present? → compare `targetPort` with the container's port
3. Port right? → is the Pod `READY`? A failing readiness probe removes it from endpoints
4. Still failing? → `kubectl exec` into a client Pod and test the Pod IP directly
5. Pod IP works, Service doesn't? → check the Service name and namespace in your DNS lookup

## Clean Up

```terminal:execute
command: kubectl delete -f ~/broken/06-service/ --ignore-not-found
```

## Summary

In this chapter you learned:
- Healthy Pods tell you nothing about whether the Service works
- `kubectl get endpoints` is the first command for any connectivity problem
- Empty endpoints = **label selector mismatch** — legal, silent, and very common
- Endpoints present but refused = wrong **`targetPort`**
- A failing readiness probe also empties endpoints, without changing Pod status to anything alarming
- Test the Pod IP directly to prove whether the problem is the app or the wiring

One chapter left — the summary, and a cheat sheet worth keeping.
