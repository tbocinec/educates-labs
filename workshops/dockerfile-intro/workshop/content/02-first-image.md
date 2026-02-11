# Building Your First Image

Let's build your first custom Docker image — a personalized Nginx web server.

---

## Examining the Project

Copy the prepared exercise files:

```terminal:execute
command: cp -r ~/exercises/first-image ~/first-image && cd ~/first-image
```

**Open the Dockerfile in the Editor:**

```editor:open-file
file: ~/first-image/Dockerfile
```

This Dockerfile has just two instructions:

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

- `FROM nginx:latest` — starts from the official Nginx image
- `COPY index.html ...` — replaces the default welcome page with our custom HTML

**Take a look at the custom HTML page:**

```editor:open-file
file: ~/first-image/index.html
```

---

## Building the Image

```terminal:execute
command: cd ~/first-image && docker build -t my-nginx:v1 .
```

Let's break down the command:

| Part | Meaning |
|------|---------|
| `docker build` | Build an image from a Dockerfile |
| `-t my-nginx:v1` | Tag the image as `my-nginx` with version `v1` |
| `.` | Use the current directory as build context |

Watch the output — you can see Docker executing each instruction and creating layers.

---

## Running the Image

```terminal:execute
command: docker run -d --name my-web -p 8080:80 my-nginx:v1
```

Click the **App Preview** tab at the top to see your custom page in the browser.

**Or test with curl:**

```terminal:execute
command: curl -s http://localhost:8080 | head -10
```

---

## Listing Your Images

```terminal:execute
command: docker images my-nginx
```

You can see the image name, tag (`v1`), image ID, creation time, and size.

---

## Image Tags

Tags are version labels for your images. Let's build another version:

**Modify the HTML page — change the title:**

```terminal:execute
command: sed -i 's/My First Docker Image/My Improved Image v2/' ~/first-image/index.html && sed -i 's/Hello from Docker!/Hello from Docker v2!/' ~/first-image/index.html
```

**Build a new version:**

```terminal:execute
command: cd ~/first-image && docker build -t my-nginx:v2 .
```

**Now you have two versions:**

```terminal:execute
command: docker images my-nginx
```

Both `v1` and `v2` exist side by side. You can run either version at any time.

---

## Tagging Existing Images

You can add additional tags to an existing image without rebuilding:

```terminal:execute
command: docker tag my-nginx:v2 my-nginx:latest
```

```terminal:execute
command: docker images my-nginx
```

Notice that `v2` and `latest` have the **same image ID** — they point to the same image. Tags are just labels.

---

## Pushing to a Registry (Concept)

In a real workflow, you would push your image to a registry so others can use it:

```
docker tag my-nginx:v2 registry.example.com/my-nginx:v2
docker push registry.example.com/my-nginx:v2
```

Common registries include Docker Hub, GitHub Container Registry (ghcr.io), and private registries.

---

## Cleanup

```terminal:execute
command: docker stop my-web && docker rm my-web
```
