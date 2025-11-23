# Step 04 - Access Grafana

Now that Grafana is running inside the container, you can access it through your browser.

---
## How Port Forwarding Works

Remember when we started the container with `-p 3000:3000`? This forwards:
- **Container port 3000** (where Grafana runs) → **Host port 3000** (accessible from your browser)

This means Grafana running inside the isolated container is now accessible from outside!

---
## Access the Web Interface

Use the Grafana dashboard tab provided in this workshop, or navigate directly to the exposed port.

---
## Login Credentials

Default initial credentials:
```
Username: admin
Password: admin
```

You will be prompted to set a new password – choose something simple (e.g. `grafana123`).

---
## Understanding Grafana Configuration

Grafana's main configuration file is `/etc/grafana/grafana.ini`. This INI-style file controls all aspects of Grafana's behavior.

### Common Configuration Categories

**Server Settings** (`[server]` section)
- `http_port` - Web interface port (default: 3000)
- `domain` - Domain name for Grafana
- `root_url` - Full public URL of Grafana

**Security Settings** (`[security]` section)
- `admin_user` / `admin_password` - Default admin credentials
- `secret_key` - Used for encryption (important for production!)
- `disable_gravatar` - Disable Gravatar profile images

**Authentication** (`[auth.*]` sections)
- LDAP, OAuth, SAML integration
- Anonymous access settings
- Session management

**Branding & UI** (`[server]` section)
- Custom logo and application title
- Footer links and text
- Theme customization

**Database** (`[database]` section)
- SQLite (default), MySQL, or PostgreSQL
- Connection settings and credentials

**Alerting & Notifications** (`[alerting]`, `[smtp]` sections)
- Alert execution settings
- Email notification configuration

For complete configuration reference, see:
**[Grafana Configuration Documentation](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)**

---
## View Current Configuration

Examine the configuration file:

```terminal:execute
command: cat /etc/grafana/grafana.ini | head -50
```

Or search for specific settings:

```terminal:execute
command: cat /etc/grafana/grafana.ini | grep -A3 "app_mode\|http_port"
```

---
## Hands-On: Modify Grafana Configuration

Let's practice changing Grafana configuration! We'll modify some simple settings that work in the free/OSS version.

### Exercise 1: Explore Configuration Structure

Before making changes, let's understand how Grafana's configuration file is structured.

**Step 1: View current server settings**

```terminal:execute
command: cat /etc/grafana/grafana.ini | grep -A10 "\[server\]" | head -15
```

You'll see the `[server]` section with various settings. Notice:
- Lines starting with `;` are commented out (using default values)
- Lines without `;` are active settings
- Settings are grouped into sections like `[server]`, `[users]`, `[security]`, etc.

**Step 2: View the HTTP port setting**

Let's see how to change the port Grafana listens on. We'll view the setting but not change it to avoid breaking our setup:

```terminal:execute
command: cat /etc/grafana/grafana.ini | grep "http_port"
```

You can see it's set to `;http_port = 3000`. The `;` means it's commented out and uses the default value (3000).

**Understanding the pattern:**
- To activate a setting: Remove the `;`
- To change a value: Edit the part after `=`
- To disable a setting: Add `;` at the beginning

Now let's make some real changes!

### Exercise 2: Allow User Sign-Up

By default, Grafana doesn't allow users to self-register. Let's enable this feature:

**Step 1: Install a text editor**

```terminal:execute
command: apt-get install -y vim
```

**Step 2: Edit the configuration file**

```terminal:execute
command: vim /etc/grafana/grafana.ini
```

**Step 3: Find the `[users]` section**

In vim:
1. Press `/` to start search
2. Type: `[users]`
3. Press `Enter` to find it

**Step 4: Enable user sign-up**

1. Look for: `;allow_sign_up = false`
2. Press `i` to enter INSERT mode
3. Remove `;` and change `false` to `true`:
```ini
[users]
# Allow users to sign up / create user accounts
allow_sign_up = true
```
4. Press `Esc`, then type `:wq` and press `Enter` to save and quit

This allows new users to create their own accounts from the login page!

**Vim Quick Reference:**
- `i` - Enter INSERT mode (to edit)
- `Esc` - Exit INSERT mode
- `/text` - Search for text
- `n` - Next search result
- `:wq` - Save and quit
- `:q!` - Quit without saving

**Alternative: Quick command-line edit**

Or use this command to enable user sign-up automatically:

```terminal:execute
command: sed -i 's/;allow_sign_up = false/allow_sign_up = true/' /etc/grafana/grafana.ini
```

### Exercise 3: Change the Default Theme

**Edit the defaults section:**

```terminal:execute
command: vim /etc/grafana/grafana.ini
```

1. Press `/` and search for: `default_theme`
2. Press `Enter` to find it
3. Look for: `;default_theme = dark`
4. Press `i` to enter INSERT mode
5. Remove `;` and change `dark` to `light`:
```ini
# Default UI theme ("dark" or "light")
default_theme = light
```
6. Press `Esc`, then type `:wq` and press `Enter`

This will change new users' default theme to light mode!

**Or use command line:**

```terminal:execute
command: sed -i 's/;default_theme = dark/default_theme = light/' /etc/grafana/grafana.ini
```

### Exercise 4: Enable More Verbose Logging

For troubleshooting, let's enable more detailed logs:

```terminal:execute
command: cat /etc/grafana/grafana.ini | grep -A5 "\[log\]"
```

To change log level to debug:

```terminal:execute
command: sed -i 's/;level = info/level = debug/' /etc/grafana/grafana.ini
```

### Apply All Changes: Restart Grafana

After making configuration changes, restart Grafana to apply them:

**Step 1: Stop Grafana**

```terminal:execute
command: pgrep -f grafana | xargs kill -9
```

**Step 2: Start Grafana again**

```terminal:execute
command: /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana > /var/log/grafana/grafana.log 2>&1 &
```

Wait a few seconds for Grafana to fully restart.

---
## Verify Your Changes

Let's verify that our configuration changes took effect:

**Check user sign-up:**
1. Log out from Grafana (click user icon → Sign out)
2. On the login page, you should now see a **"Sign up"** link
3. This allows new users to create accounts

**Check theme:**
- New users will now default to light theme instead of dark
- You can test this by creating a new user account

**View debug logs:**

```terminal:execute
command: tail -30 /var/log/grafana/grafana.log
```

You should see more detailed debug information with timestamps and component details!

---
## Common Configuration Changes (Free Version)

Here are useful settings you can modify in Grafana OSS:

**Performance:**
- `[database]` - Switch from SQLite to PostgreSQL/MySQL for better performance
- `[dataproxy]` - Timeout settings for data source queries

**Security:**
- `[security]` - Admin password, cookie settings, content security policy
- `[auth.anonymous]` - Public dashboard access
- `[auth.basic]` - Enable/disable basic authentication

**UI/UX:**
- `[users]` - Default theme, allow signup, viewers can edit
- `[dashboards]` - Default home dashboard, versions to keep

**Networking:**
- `[server]` - Port, domain, root URL, certificate paths

**Plugins:**
- `[plugins]` - Plugin directory, allow loading unsigned plugins

For complete options, see: **[Grafana Configuration Documentation](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)**

**Note**: Some features like custom branding, white labeling, and enterprise plugins are only available in Grafana Enterprise. We focus on OSS features in this workshop.

---

> You've now practiced modifying Grafana configuration and understand common settings!

Proceed to Grafana CLI tools.
