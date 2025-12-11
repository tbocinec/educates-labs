# Fix: Permission Denied Error When Downloading JARs

## 🐛 The Error

```
Warning: Failed to open the file flink-sql-connector-kafka-3.1.0-1.18.jar: Permission denied
curl: (23) client returned ERROR on write of 1360 bytes
❌ Failed to download Kafka connector
```

---

## 🔍 Root Cause

The script was doing `cd flink-connectors` before downloading, which caused two issues:

1. **Directory might not exist** when script first runs
2. **Wrong permissions** on the directory
3. **Current directory context** affected the download path

---

## ✅ The Fix

The script has been updated to:

1. ✅ **Stay in root directory** (don't `cd` into flink-connectors)
2. ✅ **Create directory with proper permissions** (`chmod 755`)
3. ✅ **Use full paths** for all file operations
4. ✅ **Set file permissions** after download (`chmod 644`)

---

## 🚀 What to Do Now

### Step 1: Make sure you're in the workshop root directory

```bash
cd ~/  # or wherever your workshop is
pwd    # Should show workshop root, not flink-connectors/
```

---

### Step 2: Remove the flink-connectors directory if it exists with wrong permissions

```bash
rm -rf flink-connectors
```

---

### Step 3: Run the updated script

```bash
chmod +x setup-flink-sql-connectors.sh
./setup-flink-sql-connectors.sh
```

---

## 📋 Expected Output

```
📦 Setting up Flink Kafka Connector for SQL Client...

📁 Creating flink-connectors directory...

⏬ Downloading Flink Kafka Connector...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 5465k  100 5465k    0     0  2123k      0  0:00:02  0:00:02 --:--:-- 2123k
✅ Downloaded: flink-sql-connector-kafka-3.1.0-1.18.jar
   Size: 5.4M

⏬ Downloading Flink Kafka base connector...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  950k  100  950k    0     0   456k      0  0:00:02  0:00:02 --:--:--  456k
✅ Downloaded: flink-connector-kafka-3.1.0-1.18.jar
   Size: 950K

🔍 Verifying JARs are accessible from container...
-rw-r--r-- 1 root root 5.4M Dec 11 10:30 flink-sql-connector-kafka-3.1.0-1.18.jar
-rw-r--r-- 1 root root 950K Dec 11 10:30 flink-connector-kafka-3.1.0-1.18.jar

📤 Creating symlinks in Flink lib directory...
✅ Symlinks created successfully!

📋 Verifying symlinks in container:
lrwxrwxrwx 1 root root 62 Dec 11 10:30 flink-sql-connector-kafka-3.1.0-1.18.jar -> /opt/flink/connectors/flink-sql-connector-kafka-3.1.0-1.18.jar
lrwxrwxrwx 1 root root 58 Dec 11 10:30 flink-connector-kafka-3.1.0-1.18.jar -> /opt/flink/connectors/flink-connector-kafka-3.1.0-1.18.jar

📋 Verifying target files exist:
-rw-r--r-- 1 root root 5.4M Dec 11 10:30 flink-sql-connector-kafka-3.1.0-1.18.jar
-rw-r--r-- 1 root root 950K Dec 11 10:30 flink-connector-kafka-3.1.0-1.18.jar

🧪 Testing symlinks are readable...
✅ Symlinks are working correctly!

✅ Setup complete!

🔄 Now restart Flink JobManager to load the connectors:
   docker restart flink-jobmanager

   Wait 15-20 seconds, then start the SQL client.

💡 The JARs are now persisted in the ./flink-connectors directory
   and will survive container restarts!
```

---

## 🔍 Verify the Fix Worked

### Check local files were created

```bash
ls -lh flink-connectors/
```

**Expected:**
```
-rw-r--r-- 1 user user 5.4M Dec 11 10:30 flink-sql-connector-kafka-3.1.0-1.18.jar
-rw-r--r-- 1 user user 950K Dec 11 10:30 flink-connector-kafka-3.1.0-1.18.jar
```

---

### Check directory permissions

```bash
ls -ld flink-connectors/
```

**Expected:**
```
drwxr-xr-x 2 user user 4096 Dec 11 10:30 flink-connectors/
```

The `drwxr-xr-x` shows correct permissions (755).

---

## 🛠️ What Changed in the Script

### Before (❌ Broken)

```bash
#!/bin/bash
mkdir -p flink-connectors
cd flink-connectors  # ❌ Changes directory

curl -L -o "flink-sql-connector-kafka-3.1.0-1.18.jar" "..."
#          ↑ Tries to write in current directory (which might have permission issues)
```

---

### After (✅ Fixed)

```bash
#!/bin/bash
mkdir -p flink-connectors
chmod 755 flink-connectors  # ✅ Set proper permissions

CONNECTOR_DIR="flink-connectors"
KAFKA_CONNECTOR_PATH="${CONNECTOR_DIR}/flink-sql-connector-kafka-3.1.0-1.18.jar"

curl -L -o "${KAFKA_CONNECTOR_PATH}" "..."
#          ↑ Uses full path from root directory

chmod 644 "${KAFKA_CONNECTOR_PATH}"  # ✅ Set file permissions
```

---

## 🚨 Common Issues

### Issue 1: Still getting permission denied

**Check current directory:**
```bash
pwd
```

Should be workshop root, NOT inside flink-connectors/.

**Solution:** Go back to workshop root:
```bash
cd ~/  # Or wherever workshop is
./setup-flink-sql-connectors.sh
```

---

### Issue 2: Directory exists with wrong permissions

**Check permissions:**
```bash
ls -ld flink-connectors/
```

If permissions look wrong (e.g., `drwx------`), remove and recreate:
```bash
rm -rf flink-connectors
./setup-flink-sql-connectors.sh
```

---

### Issue 3: Running in Windows/WSL

If you're in Windows with WSL, permissions might behave differently.

**Solution:** Ensure you're in a WSL-native directory:
```bash
cd ~
pwd  # Should show /home/username, not /mnt/c/...
```

---

### Issue 4: Docker volume mount permissions

The volume mount needs to be accessible from the container.

**Check docker-compose.yml has:**
```yaml
volumes:
  - ./flink-connectors:/opt/flink/connectors
```

**Test volume accessibility:**
```bash
docker exec flink-jobmanager ls -lh /opt/flink/connectors/
```

Should show the files, not "Permission denied".

---

## ✅ Summary

**Problem:** Permission denied when downloading JARs  
**Root Cause:** Script was `cd`'ing into directory before creating it properly  
**Solution:** Stay in root directory, use full paths, set proper permissions  
**Status:** ✅ Fixed in updated script  

---

**Now you can proceed with:**

1. ✅ Run the fixed script: `./setup-flink-sql-connectors.sh`
2. ✅ Restart Flink: `docker restart flink-jobmanager`
3. ✅ Start SQL client: `docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh`
4. ✅ Verify: `SHOW JARS;` should show Kafka connectors

---

**Date:** December 11, 2025  
**Issue:** Permission denied downloading JARs  
**Status:** ✅ Fixed

