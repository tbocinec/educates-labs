# Step 02 - Configure Grafana Container

Now let's learn how to configure Grafana using environment variables and persist data with volumes.

---
## Stop the Current Container

First, stop and remove the basic container we created:

```terminal:execute
command: docker stop grafana && docker rm grafana
```

---
## Configuration Options

The Grafana Docker image supports configuration through:

1. **Environment Variables** - Easiest way to configure
2. **Configuration Files** - Mounted via volumes
3. **Command-line Arguments** - Passed to the container

**Documentation:** https://grafana.com/docs/grafana/latest/setup-grafana/configure-docker/

---
## Using Environment Variables

Environment variables follow the pattern: `GF_<SectionName>_<KeyName>`

**Common examples:**
- `GF_SECURITY_ADMIN_PASSWORD` - Set admin password
- `GF_SERVER_ROOT_URL` - Set root URL
- `GF_INSTALL_PLUGINS` - Install plugins on startup
- `GF_AUTH_ANONYMOUS_ENABLED` - Enable anonymous access

**Full reference:** https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/

---
## Run Grafana with Custom Configuration

Let's create a new Grafana container with custom settings:

```terminal:execute
command: docker run -d --name=grafana -p 3000:3000 -e "GF_SECURITY_ADMIN_PASSWORD=secret" -e "GF_USERS_ALLOW_SIGN_UP=true" -e "GF_USERS_DEFAULT_THEME=light" grafana/grafana
```

**What we configured:**
- Admin password set to "secret"
- Enabled user sign-up (users can create accounts)
- Default theme set to light

---
## Persist Data with Volumes

**Problem:** When you remove the container, all data (dashboards, users, settings) is lost!

**Solution:** Use Docker volumes to persist data.

**Stop and remove the current container:**

```terminal:execute
command: docker stop grafana && docker rm grafana
```

**Create a volume:**

```terminal:execute
command: docker volume create grafana-storage
```

**Run Grafana with persistent storage:**

```terminal:execute
command: docker run -d --name=grafana -p 3000:3000 -v grafana-storage:/var/lib/grafana -e "GF_SECURITY_ADMIN_PASSWORD=secret" -e "GF_USERS_ALLOW_SIGN_UP=true" -e "GF_USERS_DEFAULT_THEME=light" grafana/grafana
```

Now your data persists even if you remove the container!

---
## Exercise: Test Data Persistence

Let's verify that data persists:

**Step 1: Access Grafana**
- Switch to the Grafana tab
- Log in with username `admin` and password `secret`
- Create a new dashboard (just click Save)

**Step 2: Restart the container**

```terminal:execute
command: docker restart grafana
```

**Step 3: Verify**
- Refresh the Grafana tab
- Log in again
- Your dashboard should still be there! ✅

---
## Advanced: Custom Configuration File

You can also mount a custom `grafana.ini` file:

**Step 1: Create a configuration directory**

```terminal:execute
command: mkdir -p /tmp/grafana-config
```

**Step 2: Create a custom grafana.ini**

```terminal:
cat > /tmp/grafana-config/grafana.ini << 'EOF'
[server]
protocol = http
http_port = 3000

[users]
allow_sign_up = true
default_theme = light

[auth.anonymous]
enabled = true
org_role = Viewer
EOF
```

**Step 3: Stop current container**

```terminal:execute
command: docker stop grafana && docker rm grafana
```

**Step 4: Run with custom config**

**Note:** The Grafana Docker image needs the config directory mounted, not just the file:

```terminal:execute
command: docker run -d --name=grafana -p 3000:3000 -v grafana-storage:/var/lib/grafana -v /tmp/grafana-config:/etc/grafana grafana/grafana

---
## Key Takeaways

✅ **Environment variables** - Quick configuration without files  
✅ **Volumes** - Persist data across container restarts  
✅ **Custom config files** - Full control over Grafana settings  
✅ **Documentation** - Always check official docs for latest options

---

> You now know how to configure and persist Grafana data in Docker!

Proceed to install plugins.
