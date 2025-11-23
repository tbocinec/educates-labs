# Grafana Intro Workshop

Welcome to the Grafana Intro Workshop. In this lab you will:

1. Launch an isolated Ubuntu Docker container (for security)
2. Install Grafana inside the container
3. Start the Grafana server process
4. Access Grafana through the embedded portal tab
5. Learn about Grafana CLI tools and install plugins
6. Explore Grafana's user interface
7. Build your first dashboard with various panels

> Tip: All shell command blocks are clickable – when you click, the command will be copied/executed in the terminal pane.

---
## Why Use a Container?

For security reasons, we'll work inside an isolated Ubuntu Docker container. This approach:
- **Keeps the workshop platform secure** - No root access needed on the host
- **Provides isolation** - Your work won't affect other workshop sessions
- **Gives you full control** - Root access inside the container to install packages
- **Easy to reset** - Just restart the container for a clean state

---
## Prerequisites
No prior Grafana or Docker knowledge required. Basic Linux command line familiarity is helpful.

---
## Command Usage Pattern
Code blocks use `bash`. Click a line or copy it manually. Multi-line commands should be executed together.

---
## Sections
| # | Topic |
|---|-------|
| 01 | Container Setup |
| 02 | Install Grafana |
| 03 | Start Grafana |
| 04 | Access & Configure Grafana |
| 05 | Grafana CLI Tools |
| 06 | Explore Grafana UI |
| 07 | Create Your First Dashboard |
| 99 | Summary |

Proceed to container setup.
