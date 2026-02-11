# Executing Commands Inside Containers

One of Docker's most powerful features is the ability to run commands inside a running container. The `docker exec` command lets you interact with a container's filesystem, debug issues, and inspect the runtime environment.

---

## Running a Background Container for Practice

Let's start a fresh Nginx container that we'll use throughout this section:

```terminal:execute
command: docker run -d --name exec-demo nginx:latest
```

---

## Running a Single Command

Use `docker exec` to execute a one-off command inside a running container:

```terminal:execute
command: docker exec exec-demo hostname
```

This runs the `hostname` command inside the `exec-demo` container and prints the result. The container's hostname defaults to its container ID.

**Check the operating system inside the container:**

```terminal:execute
command: docker exec exec-demo cat /etc/os-release
```

**List files in the Nginx default web root:**

```terminal:execute
command: docker exec exec-demo ls -la /usr/share/nginx/html/
```

---

## Interactive Shell Access

The `-it` flags combine two options:
- `-i` (**interactive**) — Keeps standard input open
- `-t` (**tty**) — Allocates a pseudo-TTY (terminal)

Together, they give you a fully interactive shell session inside the container:

```terminal:execute
command: docker exec -it exec-demo /bin/bash
```

You are now **inside the container**. The prompt changes to reflect the container's hostname. Try these commands inside the container:

**Check the current user:**

```terminal:execute
command: whoami
```

**Explore the filesystem:**

```terminal:execute
command: ls /
```

**Check the container's IP address:**

```terminal:execute
command: hostname -i
```

**Exit the interactive shell:**

```terminal:execute
command: exit
```

> **Important:** Exiting the `exec` shell does **not** stop the container. The container's main process (Nginx) continues running. Only the shell session is terminated.

---

## Running Commands as a Different User

By default, `docker exec` runs commands as the container's default user (often `root`). You can specify a different user with the `-u` flag:

```terminal:execute
command: docker exec -u nobody exec-demo whoami
```

This executes the command as the `nobody` user instead of `root`.

---

## Setting Environment Variables in Exec

You can inject environment variables into the exec session using the `-e` flag:

```terminal:execute
command: docker exec -e MY_VAR="Hello Workshop" exec-demo env | grep MY_VAR
```

This is useful for passing temporary configuration to a debugging session without affecting the container's main process.

---

## Working Directory

Use the `-w` flag to set the working directory for the executed command:

```terminal:execute
command: docker exec -w /usr/share/nginx/html exec-demo ls -la
```

This lists the contents of the Nginx web root directory without having to specify the full path in the command.

---

## Modifying Files Inside a Container

You can use `exec` to modify files inside a running container. Let's replace the default Nginx welcome page:

```terminal:execute
command: docker exec exec-demo bash -c 'echo "<h1>Hello from Docker Workshop!</h1>" > /usr/share/nginx/html/index.html'
```

**Verify the change:**

```terminal:execute
command: docker exec exec-demo cat /usr/share/nginx/html/index.html
```

> **Note:** Changes made inside a container are stored in the container's **writable layer**. They are lost when the container is removed. To persist data, Docker provides **volumes** — covered in the **Docker: Networking, Ports & Storage** workshop.

---

## Practical Debugging Example

Let's simulate a common debugging workflow — checking why an Nginx configuration might not be working:

**View the Nginx configuration:**

```terminal:execute
command: docker exec exec-demo cat /etc/nginx/nginx.conf
```

**Test the Nginx configuration syntax:**

```terminal:execute
command: docker exec exec-demo nginx -t
```

**Check which ports Nginx is listening on:**

```terminal:execute
command: docker exec exec-demo bash -c 'apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq net-tools > /dev/null 2>&1 && netstat -tlnp'
```

This installs `net-tools` inside the container and shows all listening TCP ports — a common debugging technique.

---

## Cleanup

```terminal:execute
command: docker rm -f exec-demo
```
