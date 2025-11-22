# Step 01 - Install Grafana

In this step you download and unpack Grafana OSS (Linux AMD64). We avoid package managers for simplicity.

---
## Download Archive
```bash
curl -L -o grafana.tgz https://downloads.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
```

## Verify Size
```bash
ls -lh grafana.tgz
```

## Extract
```bash
tar -xzf grafana.tgz
```

## List Contents
```bash
ls -1 grafana-11.0.0/
```

## Create Runtime Directory
```bash
mkdir -p ~/grafana-data
```

> You now have the Grafana distribution extracted locally.

---
## (Optional) Remove Archive
```bash
rm grafana.tgz
```

Continue to starting Grafana.
