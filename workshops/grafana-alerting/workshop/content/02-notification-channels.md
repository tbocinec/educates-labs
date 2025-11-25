# Step 02 - Notification Channels

In this step, you'll configure how and where alert notifications are delivered using Grafana Unified Alerting.

---
## Grafana Unified Alerting Architecture

**Notification workflow:**
1. Alert rule triggers → 2. Evaluation → 3. Contact point → 4. Notification policy → 5. Delivery

You'll configure **Contact Points** (where to send) and **Notification Policies** (routing rules based on labels).

---
## Available Contact Point Types

Grafana Unified Alerting supports many notification channels:

**Communication platforms:**
- 📧 **Email** - Send alerts via SMTP
- 💬 **Slack** - Slack channel notifications
- 📱 **Microsoft Teams** - Teams channel notifications
- 💭 **Discord** - Discord channel webhooks

**Incident management:**
- 🚨 **PagerDuty** - On-call incident routing
- 📟 **Opsgenie** - Alert management and escalation
- 🔔 **VictorOps** - Incident response platform

**Monitoring systems:**
- 📊 **Prometheus Alertmanager** - Forward to Alertmanager
- 📈 **Grafana OnCall** - Grafana's own on-call platform

**Custom integrations:**
- 🔗 **Webhook** - Send HTTP POST to any URL (most flexible!)
- 📝 **Custom API endpoints** - Integrate with internal systems

**In this workshop, we'll focus on Webhooks** - the most flexible option for custom integrations and automation.

---
## Create Contact Point: Webhook

Webhooks are useful for integrating with external systems, incident management tools, or custom automation.

**In Grafana, go to: Alerting → Contact points**

**Click "+ Add contact point"**

### Configuration:

**Name:** `Webhook - API Monitoring`

**Integration:** Select `Webhook`

**URL:** You have two options for testing:

**Option 1: webhook.site (recommended for testing)**
1. Open https://webhook.site in a new browser tab
2. Copy your unique URL (e.g., `https://webhook.site/abc-123-def`)
3. Paste it in the URL field

**Option 2: httpbin.org**
```
https://httpbin.org/post
```

**HTTP Method:** `POST`

**Optional - Add custom HTTP headers:**

Click **Optional Webhook settings** to expand:
- Click **+ Add Header**
- **Header:** `Content-Type`, **Value:** `application/json`
- Click **+ Add Header** again  
- **Header:** `Authorization`, **Value:** `Bearer your-token-here`

### Test the Webhook

Click **Test** button at the bottom.

You should see:
- ✅ Green success message in Grafana
- Data appearing in webhook.site (if using that)

Click **Save contact point**

---
## Understanding Webhook Payload

When an alert fires, Grafana sends a JSON payload to your webhook. Here's what it looks like:

```json
{
  "receiver": "Webhook - API Monitoring",
  "status": "firing",
  "alerts": [
    {
      "status": "firing",
      "labels": {
        "alertname": "API Error Rate High",
        "severity": "warning",
        "service": "api",
        "endpoint": "/api/checkout"
      },
      "annotations": {
        "description": "API error rate has exceeded 10%...",
        "summary": "API error rate is 15.5%"
      },
      "startsAt": "2025-11-25T10:30:00Z",
      "endsAt": "0001-01-01T00:00:00Z",
      "generatorURL": "http://grafana:3000/alerting/...",
      "fingerprint": "abc123def456",
      "values": {
        "B": 15.5
      }
    }
  ],
  "groupLabels": {
    "alertname": "API Error Rate High"
  },
  "commonLabels": {
    "alertname": "API Error Rate High",
    "severity": "warning"
  },
  "commonAnnotations": {
    "description": "API error rate has exceeded 10%..."
  },
  "externalURL": "http://grafana:3000"
}
```

**Key fields for automation:**
- `status` - "firing" or "resolved"
- `labels.severity` - critical, warning, info
- `labels.service` - which service triggered the alert
- `labels.endpoint` - which API endpoint
- `annotations.description` - human-readable description
- `values` - actual metric values (error_rate, response_time, etc.)

**Use cases:**
- Create tickets in Jira/ServiceNow automatically
- Post to Slack/Teams via incoming webhooks
- Trigger automated remediation scripts
- Store alert history in a database
- Send to custom monitoring dashboards

---
## Configure Notification Policies

Notification policies route alerts to the right contact points based on labels.

**Go to: Alerting → Notification policies**

You'll see a **Default policy** that catches all unmatched alerts.

### Policy 1: Critical Alerts

Click **+ New specific policy**

**Matching labels:**
- **Label:** `severity`
- **Operator:** `=`
- **Value:** `critical`

**Contact point:** `Webhook - API Monitoring`

**Continue matching subsequent sibling nodes:** ✅ Enabled

> **Čo to znamená:** Alert môže byť spracovaný viacerými policies naraz. Ak má alert `severity=critical` A `service=api`, pošle sa do oboch policies.

Click **Save policy**

### Policy 2: API Service Alerts  

Click **+ New specific policy**

**Matching labels:**
- **Label:** `service`
- **Operator:** `=`
- **Value:** `api`

**Contact point:** `Webhook - API Monitoring`

**Continue matching:** ✅ Enabled (umožní spracovanie ďalšími policies)

Click **Save policy**

---
## Understanding Notification Routing

**Your current routing logic:**

```
Alert fires → Check labels

├─ severity=critical → Webhook ✓ Continue
├─ service=api → Webhook ✓ Continue  
└─ No match → Default webhook
```

**Example routing:**
- Alert with `severity=critical` → Webhook  
- Alert with `service=api` → Webhook
- Alert with `severity=critical` + `service=api` → Webhook (2x - raz pre každú policy)
- Alert with no matching labels → Default webhook

---
## Configure Timing Settings

Timing settings control how often notifications are sent and repeated.

**Edit the Default policy** (click pencil icon on "Default policy")

Click to  to **Override general timings ** section:

**Group wait:** `30s`  
> Počká 30 sekúnd pred poslaním prvej notifikácie (aby sa zoskupili podobné alerty)

**Group interval:** `5m`  
> Počká 5 minút pred poslaním notifikácie o nových alertoch v tej istej skupine

**Repeat interval:** `4h`  
> Zopakuje notifikáciu každé 4 hodiny, ak alert stále beží

Click **Update default policy**

> **Poznámka:** V novej verzii Grafana sa timing nastavenia dajú konfigurovať cez tab **Alerting → Notification policies → Timing options** pri editácii policy.

---
## Create Silences (Temporary Muting)

Silence specific alerts temporarily without changing rules.

**Go to: Alerting → Silences**

**Click "+ Create silence"**

### Configuration:

**Silence start:** `Now`

**Silence end:** Select `Duration` → `1 hour`

**Name:** `Testing - Deployment in Progress`

**Matchers:**
- Click **+ Add matcher**
- **Label:** `alertname`
- **Operator:** `=`
- **Value:** `API Error Rate High`

**Comment:** `Deploying new API version - expecting temporary errors`

**Created by:** `Your Name`

Click **Submit**

### What Happens:
- ✅ Alert continues to evaluate (still runs)
- ✅ State transitions still occur (Normal → Alerting)
- ❌ Notifications are suppressed (no webhook calls)
- ⏰ After 1 hour, notifications resume automatically

### View Active Silences:
Go to **Alerting → Silences** to see all active silences and expire them early if needed.

---
## Test Notification Delivery

### Test from Contact Point

**Go to: Alerting → Contact points**

1. Find `Webhook - API Monitoring`
2. Click **Edit**
3. Click **Test** button
4. Check webhook.site to see the test payload

### Verify Real Alert Notifications

After creating alerts in previous steps:

1. **Trigger an alert** (we'll do this in next step)
2. **Go to webhook.site**
3. **Look for the incoming POST request**
4. **Inspect the JSON payload** - you should see:
   - Alert name
   - Labels (severity, service, endpoint)
   - Annotations (description, summary)
   - Metric values

---
## Notification Best Practices

### Do:
- ✅ Test webhooks before deploying to production
- ✅ Set appropriate repeat intervals (4-6 hours)
- ✅ Use silences during deployments
- ✅ Include useful labels (severity, service, endpoint)
- ✅ Document alert responses in descriptions

### Don't:
- ❌ Set repeat interval too low (causes spam)
- ❌ Forget to test notification delivery
- ❌ Use production webhooks for testing
- ❌ Create too many complex policies

---
## Key Takeaways

✅ Learned about available contact point types (Email, Slack, PagerDuty, Webhook, etc.)  
✅ Created webhook contact point for custom integrations  
✅ Configured 2 simple notification policies with label-based routing  
✅ Set up timing options (group wait, group interval, repeat interval)  
✅ Learned to create temporary silences for deployments  
✅ Tested webhook delivery and inspected JSON payloads  

---

Next, you'll trigger real alerts and watch the complete notification workflow in action!
