---
title: Jobs & CronJobs
---

# Level 4B: Jobs & CronJobs

So far we've worked with Pods and Deployments — workloads that run **continuously**. But what about tasks that need to run **once** and complete? Or tasks that should run on a **schedule**?

That's what **Jobs** and **CronJobs** are for.

> **Docs**: [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) | [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Pods vs Jobs vs Deployments

| Resource | Behavior | Use Case |
|----------|----------|----------|
| **Pod** | Runs until completion or failure | One-off testing, debugging |
| **Deployment** | Keeps N replicas running forever | Web servers, APIs, services |
| **Job** | Runs to **completion**, then stops | Data processing, migrations, backups |
| **CronJob** | Creates Jobs on a **schedule** | Periodic reports, cleanup tasks |

## Creating a Simple Job

Let's create a Job that computes digits of Pi. Open the exercise file:

```editor:open-file
file: exercises/jobs/job.yaml
```

Key configuration:

```editor:select-matching-text
file: exercises/jobs/job.yaml
text: backoffLimit
```

- `backoffLimit: 4` — retry up to 4 times on failure
- `restartPolicy: Never` — don't restart the container in the same Pod (create a new Pod instead)
- The container uses Perl to calculate 2000 digits of Pi

Apply the Job:

```terminal:execute
command: cp -r ~/exercises/jobs ~/jobs && kubectl apply -f ~/jobs/job.yaml
```

Watch the Job progress:

```terminal:execute
command: kubectl get jobs -w
```

Wait until `COMPLETIONS` shows `1/1`, then press Ctrl+C:

```terminal:interrupt
```

View the Job result:

```terminal:execute
command: kubectl logs job/pi-calculator
```

## Parallel Jobs

Jobs can run multiple tasks in parallel. Open the exercise file:

```editor:open-file
file: exercises/jobs/job-parallel.yaml
```

Key configuration:

```editor:select-matching-text
file: exercises/jobs/job-parallel.yaml
text: completions
```

- `completions: 4` — the Job needs to complete **4 times**
- `parallelism: 2` — run **2 Pods at a time**

This means: run 4 tasks total, 2 at a time, in parallel batches.

Apply and observe:

```terminal:execute
command: kubectl apply -f ~/jobs/job-parallel.yaml
```

Watch the Pods:

```terminal:execute
command: kubectl get pods -l job-name=parallel-job -w
```

You should see 2 Pods start first, and when they complete, 2 more start. Stop watching after all 4 complete:

```terminal:interrupt
```

Check the Job status:

```terminal:execute
command: kubectl get job parallel-job
```

`4/4` completions — all tasks completed successfully!

## Job Failure Handling

What happens when a Job fails? The `backoffLimit` controls how many retries Kubernetes attempts before marking the Job as failed.

Let's test with a quick failing Job:

```terminal:execute
command: kubectl create job fail-test --image=busybox -- sh -c "exit 1"
```

Watch the retry behavior:

```terminal:execute
command: kubectl get pods -l job-name=fail-test -w
```

You'll see Kubernetes creating new Pods with increasing backoff delays. After the `backoffLimit` (default 6) is reached, the Job is marked as Failed. Stop watching:

```terminal:interrupt
```

```terminal:execute
command: kubectl get job fail-test
```

Clean up the failed Job:

```terminal:execute
command: kubectl delete job fail-test
```

## CronJobs — Scheduled Execution

A **CronJob** creates Jobs on a schedule, using the standard cron format.

### Cron Format Refresher

```
┌───────────── minute (0–59)
│ ┌───────────── hour (0–23)
│ │ ┌───────────── day of month (1–31)
│ │ │ ┌───────────── month (1–12)
│ │ │ │ ┌───────────── day of week (0–6, Sun=0)
│ │ │ │ │
* * * * *
```

| Expression | Meaning |
|-----------|---------|
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour |
| `0 2 * * *` | Daily at 2:00 AM |
| `0 0 * * 0` | Weekly on Sunday |

Open the CronJob exercise file:

```editor:open-file
file: exercises/jobs/cronjob.yaml
```

```editor:select-matching-text
file: exercises/jobs/cronjob.yaml
text: schedule
```

This CronJob runs **every minute** and prints the current time.

Apply it:

```terminal:execute
command: kubectl apply -f ~/jobs/cronjob.yaml
```

Check the CronJob:

```terminal:execute
command: kubectl get cronjobs
```

Wait about 60–90 seconds, then check if a Job was created:

```terminal:execute
command: sleep 70 && kubectl get jobs -l app=time-reporter
```

View the output from the most recent Job:

```terminal:execute
command: kubectl logs job/$(kubectl get jobs -l app=time-reporter -o name | tail -1 | cut -d/ -f2)
```

Wait another minute to see a second Job created:

```terminal:execute
command: sleep 65 && kubectl get jobs -l app=time-reporter
```

Multiple Jobs! Each one was created on schedule by the CronJob.

## Managing CronJobs

Suspend a CronJob (stop scheduling new Jobs):

```terminal:execute
command: kubectl patch cronjob time-reporter -p '{"spec":{"suspend":true}}'
```

```terminal:execute
command: kubectl get cronjob time-reporter
```

The `SUSPEND` column shows `True` — no new Jobs will be created.

Resume it:

```terminal:execute
command: kubectl patch cronjob time-reporter -p '{"spec":{"suspend":false}}'
```

## Cleanup

```terminal:execute
command: kubectl delete -f ~/jobs/ 2>/dev/null; kubectl delete job fail-test 2>/dev/null; echo "Cleanup done"
```

## Level 4B Summary

In this chapter you learned:
- **Jobs** run tasks to **completion** — ideal for batch processing
- `completions` and `parallelism` control how many tasks run and how many at a time
- `backoffLimit` controls retry behavior on failure
- **CronJobs** create Jobs on a cron **schedule** (e.g., `*/5 * * * *` = every 5 min)
- CronJobs can be **suspended** and **resumed**

| Command | Purpose |
|---------|---------|
| `kubectl get jobs` | List Jobs and their completion status |
| `kubectl logs job/<name>` | View Job output |
| `kubectl get cronjobs` | List CronJobs and next schedule |
| `kubectl create job <name> --image=<img> -- <cmd>` | Create a Job imperatively |
| `kubectl patch cronjob <name> -p '{"spec":{"suspend":true}}'` | Suspend a CronJob |

That wraps up all four levels! Head to the summary for a complete recap.
