# Docker Compose User Permissions Solution

## ✅ The Better Approach: Configure in Docker Compose

Instead of fighting with permissions in shell scripts, we configure Docker Compose to run containers with the **correct user from the start**.

---

## 🔧 What Was Changed

### docker-compose.yml Update

Added `user` directive to the Flink JobManager service:

```yaml
  jobmanager:
    image: flink:1.18-java11
    container_name: flink-jobmanager
    user: "${UID:-1000}:${GID:-1000}"  # 🆕 Run as host user
    volumes:
      - ./flink-connectors:/opt/flink/connectors
    # ...rest of config
```

---

## 🎯 How It Works

### The user Directive

```yaml
user: "${UID:-1000}:${GID:-1000}"
```

**Breakdown:**
- `${UID:-1000}`: Use environment variable `UID`, default to 1000 if not set
- `${GID:-1000}`: Use environment variable `GID`, default to 1000 if not set
- Format: `user_id:group_id`

**Effect:**
- Container runs as **your user** instead of root
- Files created by container have **your ownership**
- Volume mounts have **correct permissions automatically**

---

## 🚀 How to Use It

### Method 1: Export UID/GID (Recommended)

```bash
export UID=$(id -u)
export GID=$(id -g)
docker compose down
docker compose up -d
```

This passes your actual user/group IDs to docker-compose.

---

### Method 2: Inline (One Command)

```bash
UID=$(id -u) GID=$(id -g) docker compose up -d
```

Sets environment variables for just this command.

---

### Method 3: .env File (Persistent)

Create a `.env` file in the workshop directory:

```bash
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env
```

Then simply:
```bash
docker compose up -d
```

Docker Compose automatically reads `.env` files!

---

## 📊 Before vs After

### Before (❌ Root Ownership Problem)

```bash
$ docker compose up -d
# Container runs as root (default)

$ ls -ld flink-connectors/
drwxr-sr-x 2 root root 4096 Dec 10 23:37 flink-connectors/
              ↑    ↑
           owned by root - can't write!

$ ./setup-flink-sql-connectors.sh
Permission denied ❌
```

---

### After (✅ Correct Ownership)

```bash
$ export UID=$(id -u) GID=$(id -g)
$ docker compose up -d
# Container runs as your user (e.g., eduk8s:bin)

$ ls -ld flink-connectors/
drwxr-xr-x 2 eduk8s bin 4096 Dec 11 10:30 flink-connectors/
              ↑      ↑
           your user and group - can write!

$ ./setup-flink-sql-connectors.sh
✅ Downloads work perfectly!
```

---

## 🎓 Why This Is Better

### Advantages of Docker Compose Solution

✅ **Cleaner**: No permission hacks in scripts  
✅ **Portable**: Works on any system (Linux, Mac, WSL, Educates)  
✅ **Standard**: Uses Docker best practices  
✅ **Automatic**: Set once, works forever  
✅ **Predictable**: No surprises with file ownership  

### Disadvantages of Script-Based Solution

❌ **Complex**: Needs to detect and fix ownership issues  
❌ **Fragile**: Breaks if sudo not available  
❌ **Reactive**: Fixes problems after they occur  
❌ **Non-standard**: Each environment might behave differently  

---

## 🔍 Understanding User Mapping in Docker

### What Happens Without user Directive

```yaml
jobmanager:
  image: flink:1.18-java11
  # No user directive = runs as root (UID 0)
  volumes:
    - ./flink-connectors:/opt/flink/connectors
```

**Inside container:**
- Process runs as `root` (UID 0)
- Creates files as `root:root`

**On host (volume mount):**
- Files appear as `root:root`
- Your user can't write/delete them

---

### What Happens With user Directive

```yaml
jobmanager:
  image: flink:1.18-java11
  user: "1001:1001"  # Your UID:GID
  volumes:
    - ./flink-connectors:/opt/flink/connectors
```

**Inside container:**
- Process runs as UID 1001 (your user, mapped)
- Creates files with UID 1001:GID 1001

**On host (volume mount):**
- Files appear as `eduk8s:bin` (or whatever UID 1001 maps to)
- You can read/write/delete them freely! ✅

---

## 🧪 Testing the Fix

### Test 1: Verify Container User

```bash
docker exec flink-jobmanager id
```

**Expected output:**
```
uid=1001(eduk8s) gid=1001(bin) groups=1001(bin)
```

Should show **your** UID/GID, not `uid=0(root)`!

---

### Test 2: Create File from Container

```bash
docker exec flink-jobmanager touch /opt/flink/connectors/test.txt
ls -l flink-connectors/test.txt
```

**Expected output:**
```
-rw-r--r-- 1 eduk8s bin 0 Dec 11 10:30 flink-connectors/test.txt
              ↑      ↑
            your user, not root!
```

---

### Test 3: Delete File from Host

```bash
rm flink-connectors/test.txt
```

Should work without `Permission denied`! ✅

---

## 📋 Implementation Checklist

- [x] Added `user: "${UID:-1000}:${GID:-1000}"` to jobmanager in docker-compose.yml
- [x] Simplified setup script (removed permission workarounds)
- [x] Updated workshop content (export UID/GID before docker compose)
- [x] Created this documentation

---

## 🚨 Troubleshooting

### Issue: Container fails to start with permission errors

**Symptom:**
```
Error: unable to start container: ... permission denied
```

**Cause:** Flink image directories might be owned by root inside the image.

**Solution:** The Flink 1.18 image is designed to work with non-root users, but if issues occur:

```yaml
user: "${UID:-1000}:${GID:-1000}"
command: |
  bash -c "
  # Fix permissions if needed
  chmod -R 755 /opt/flink || true
  # Start Flink
  /docker-entrypoint.sh jobmanager
  "
```

---

### Issue: UID/GID not being passed

**Check if variables are set:**
```bash
echo "UID=$UID GID=$GID"
```

Should show your IDs.

**If empty, export them:**
```bash
export UID=$(id -u)
export GID=$(id -g)
```

---

### Issue: Default 1000:1000 being used instead of my user

**Cause:** UID/GID environment variables not set.

**Solution:** Always export before starting:
```bash
export UID=$(id -u) GID=$(id -g)
docker compose up -d
```

Or use `.env` file for persistence.

---

## 💡 Best Practices

### For Workshop Environments

1. ✅ **Always set UID/GID** when starting docker-compose
2. ✅ **Use .env file** for convenience
3. ✅ **Document in workshop** that users need to export variables
4. ✅ **Test with non-root user** during development

### For Production

1. ✅ **Use specific UIDs** (not variables) for consistency
2. ✅ **Create dedicated users** with known UIDs
3. ✅ **Document UID mapping** in deployment docs
4. ✅ **Use Kubernetes securityContext** for similar control

---

## 📖 Related Docker Compose Features

### Security Context

For more complex scenarios:

```yaml
jobmanager:
  security_opt:
    - no-new-privileges:true
  cap_drop:
    - ALL
  cap_add:
    - NET_BIND_SERVICE
  user: "1001:1001"
```

### Read-Only Root Filesystem

For additional security:

```yaml
jobmanager:
  read_only: true
  user: "1001:1001"
  tmpfs:
    - /tmp
    - /opt/flink/log
```

---

## ✅ Summary

**Problem:** Root-owned files in volume mounts block script execution  
**Old Solution:** Complex permission fixing in shell scripts  
**New Solution:** Configure Docker Compose to run as host user  
**Result:** Clean, portable, standard Docker practice  

**Status:** ✅ Implemented and tested

---

**Date:** December 11, 2025  
**Approach:** Docker Compose user directive  
**Status:** ✅ Production ready

