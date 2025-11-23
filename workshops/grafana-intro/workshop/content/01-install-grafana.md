# Step 02 - Install Grafana

Now that you're inside the Ubuntu container with root access, let's install Grafana.

**Note**: You're running as root in the container, so no `sudo` is needed!

---
## Update Package Index

First, refresh the list of available packages to ensure we get the latest versions:

```terminal:execute
command: apt-get update
```

---
## Install Prerequisites

Install essential tools recommended by Grafana for repository management and secure package downloads:
- **software-properties-common** - Manages software repositories
- **wget** - Downloads files from the web
- **curl** - Alternative tool for data transfers
- **gnupg** - Handles GPG key verification for package authenticity

```terminal:execute
command: apt-get install -y software-properties-common wget curl gnupg
```

---
## Add Grafana APT Repository

To install the latest official Grafana release, we need to add Grafana's package repository to our system.

Create keyrings directory for storing GPG keys:
```terminal:execute
command: mkdir -p /etc/apt/keyrings/
```

Download and add Grafana's GPG key (verifies package authenticity):
```terminal:execute
command: wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
```

Add Grafana repository to APT sources:
```terminal:execute
command: echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
```

---
## Update Package Index Again

Refresh package list to include packages from the newly added Grafana repository:

```terminal:execute
command: apt-get update
```

---
## Install Grafana OSS

Install Grafana Open Source edition:

```terminal:execute
command: apt-get install -y grafana
```

---
## Verify Installation

Check that Grafana was installed successfully:

```terminal:execute
command: grafana-server --version
```

> Grafana is now installed in the container!

Proceed to starting Grafana.
