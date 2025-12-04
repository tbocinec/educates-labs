# SecretApp - Educates Workshop Success Page

A simple Node.js application that displays a success message for the Educates workshop.

## Build

```bash
docker build -t bocak95/secretapp:latest .
```

## Run locally

```bash
docker run -p 8080:8080 bocak95/secretapp:latest
```

Then open http://localhost:8080

## Push to registry

```bash
docker push bocak95/secretapp:latest
```
