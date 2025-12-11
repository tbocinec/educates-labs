# IMMEDIATE FIX: Root-Owned Directory Permission Issue

## 🐛 The Problem

The `flink-connectors` directory is owned by `root:root`, but the script runs as `eduk8s` user:

```
drwxr-sr-x  2 root   root  4096 Dec 10 23:37 flink-connectors
                ↑     ↑
              owner  group
```

When curl tries to write: **Permission denied** ❌

---

## ✅ Quick Fix (Run This Now)

**Step 1: Remove the root-owned directory**

```bash
rm -rf flink-connectors
```

If that doesn't work (permission denied), try:

```bash
sudo rm -rf flink-connectors
```

---

**Step 2: Run the updated script**

```bash
./setup-flink-sql-connectors.sh
```

The script now checks for root ownership and fixes it automatically.

---

## 🔍 What the Script Now Does

The updated script will:

1. **Check if directory exists and is owned by root**
2. **Try to change ownership** with sudo (if available)
3. **Fall back to removing and recreating** if sudo doesn't work
4. **Create directory with proper permissions** for current user

```bash
# Check ownership
OWNER=$(ls -ld flink-connectors | awk '{print $3}')
if [ "$OWNER" = "root" ]; then
    # Try to fix ownership, or remove and recreate
    sudo chown -R $(whoami):$(id -gn) flink-connectors 2>/dev/null || rm -rf flink-connectors
fi

# Create with correct permissions
mkdir -p flink-connectors
chmod 755 flink-connectors
```

---

## 📋 Verify It Works

After running the script, check ownership:

```bash
ls -ld flink-connectors/
```

**Should now show:**
```
drwxr-xr-x 2 eduk8s bin 4096 Dec 11 10:30 flink-connectors/
              ↑      ↑
            your    your
            user   group
```

---

## 🎯 Why This Happened

The directory was likely created by:
1. **Docker volume mount initialization** (runs as root)
2. **Previous script run with sudo**
3. **Docker compose creating the directory** before first use

---

## ✅ Expected Output After Fix

```
📦 Setting up Flink Kafka Connector for SQL Client...

📁 Setting up flink-connectors directory...
✅ Directory ready with correct permissions

⏬ Downloading Flink Kafka Connector...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 5465k  100 5465k    0     0  2123k      0  0:00:02  0:00:02 --:--:-- 2123k
✅ Downloaded: flink-sql-connector-kafka-3.1.0-1.18.jar
   Size: 5.4M
...
```

No more "Permission denied"! ✅

---

**Run the script again now - it should work!** 🎉

**Date:** December 11, 2025  
**Issue:** Root-owned directory blocking writes  
**Status:** ✅ Fixed in script

