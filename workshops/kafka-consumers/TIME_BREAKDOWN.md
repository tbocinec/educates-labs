# Kafka Consumers Workshop - Detailed Time Breakdown

## ⏱️ Total Workshop Duration

**Recommended Time: 2.5 - 3 hours**

**Breakdown:**
- **Instructor-led:** 2 hours 30 minutes
- **Self-paced:** 3 - 4 hours (with exploration time)
- **Fast track (experienced):** 1.5 - 2 hours

---

## 📊 Module-by-Module Timing

### Module 01: Environment Setup (15 minutes)

| Activity | Time | Type |
|----------|------|------|
| Start Docker Compose | 2 min | Hands-on |
| Wait for services to be healthy | 3 min | Wait time |
| Create topic | 1 min | Hands-on |
| Build all applications (Maven) | 5 min | Build time |
| Start producer & verify | 2 min | Hands-on |
| Verify messages flowing | 2 min | Verification |

**Tips to reduce time:**
- Pre-download Docker images (done during setup)
- Pre-download Maven dependencies (optional)
- Can overlap building with explanations

---

### Module 02: Consumer Basics (25 minutes)

| Activity | Time | Type |
|----------|------|------|
| Explain consumer architecture | 5 min | Theory |
| Review basic consumer code | 5 min | Code walkthrough |
| Run basic consumer | 2 min | Hands-on |
| Observe output (let it run) | 5 min | Observation |
| Check consumer group status | 3 min | CLI commands |
| Discuss auto-commit behavior | 3 min | Discussion |
| Stop consumer & review | 2 min | Wrap-up |

**Key learning:** Understanding consumer groups and poll loop

---

### Module 03: Understanding ConsumerRecords (20 minutes)

| Activity | Time | Type |
|----------|------|------|
| Explain ConsumerRecord structure | 4 min | Theory |
| Inspect message metadata | 3 min | Hands-on |
| Analyze partition distribution | 5 min | Hands-on |
| Verify key-based partitioning | 4 min | Hands-on |
| Examine offset patterns | 2 min | Hands-on |
| Discussion of findings | 2 min | Discussion |

**Key learning:** Understanding message metadata and partitioning

---

### Module 04: Manual Offset Management (30 minutes)

| Activity | Time | Type |
|----------|------|------|
| Explain auto vs manual commit | 5 min | Theory |
| Review manual consumer code | 5 min | Code walkthrough |
| Run manual commit consumer | 2 min | Hands-on |
| Observe batch processing | 5 min | Observation |
| Stop and restart (test reprocessing) | 3 min | Hands-on |
| Check committed offsets | 2 min | CLI commands |
| Reset offsets experiment | 5 min | Hands-on |
| Discuss delivery semantics | 3 min | Discussion |

**Key learning:** At-least-once semantics and offset control

---

### Module 05: Partition Rebalancing (25 minutes)

| Activity | Time | Type |
|----------|------|------|
| Explain rebalancing triggers | 4 min | Theory |
| Start single consumer | 2 min | Hands-on |
| Check partition assignment | 2 min | Verification |
| Start second consumer | 2 min | Hands-on |
| Observe rebalance | 3 min | Observation |
| Check new assignments | 2 min | Verification |
| Stop second consumer | 2 min | Hands-on |
| Observe second rebalance | 3 min | Observation |
| Discuss assignment strategies | 3 min | Discussion |
| Cleanup | 2 min | Cleanup |

**Key learning:** How rebalancing works in practice

---

### Module 06: Consumer Configuration (25 minutes)

| Activity | Time | Type |
|----------|------|------|
| Review configuration categories | 5 min | Theory |
| Explain reliability configs | 5 min | Theory |
| Discuss performance tuning | 5 min | Theory |
| Review timeout configurations | 4 min | Theory |
| Show configuration profiles | 4 min | Examples |
| Q&A and discussion | 2 min | Discussion |

**Key learning:** Tuning consumers for different use cases

**Note:** This module is more theoretical with less hands-on time

---

### Module 07: Multithreaded Consumer (30 minutes)

| Activity | Time | Type |
|----------|------|------|
| Explain thread-safety issues | 4 min | Theory |
| Review worker pool pattern | 6 min | Code walkthrough |
| Run multithreaded consumer | 2 min | Hands-on |
| Observe parallel processing | 6 min | Observation |
| Monitor worker threads | 3 min | Monitoring |
| Compare with single-threaded | 4 min | Comparison |
| Discuss backpressure | 3 min | Discussion |
| Stop and review | 2 min | Wrap-up |

**Key learning:** Scaling consumer processing safely

---

### Module 08: Error Handling (25 minutes)

| Activity | Time | Type |
|----------|------|------|
| Discuss common error scenarios | 5 min | Theory |
| Explain retry strategies | 5 min | Theory |
| Show DLQ pattern | 4 min | Code walkthrough |
| Create DLQ topic | 1 min | Hands-on |
| Discuss circuit breaker | 4 min | Theory |
| Review error handling code | 4 min | Code review |
| Q&A on error handling | 2 min | Discussion |

**Key learning:** Building robust, production-ready consumers

**Note:** Mostly code review and discussion, less running

---

### Module 09: Kafka UI Exploration (20 minutes)

| Activity | Time | Type |
|----------|------|------|
| Navigate Kafka UI dashboard | 3 min | Hands-on |
| Explore topic details | 3 min | Hands-on |
| Inspect messages | 3 min | Hands-on |
| Monitor consumer groups | 4 min | Hands-on |
| View consumer lag | 2 min | Hands-on |
| Troubleshooting exercise | 3 min | Hands-on |
| Review monitoring features | 2 min | Wrap-up |

**Key learning:** Visual monitoring and troubleshooting

---

### Module 10: Summary and Best Practices (15 minutes)

| Activity | Time | Type |
|----------|------|------|
| Review key concepts | 5 min | Review |
| Production best practices | 5 min | Discussion |
| Configuration checklist | 2 min | Review |
| Q&A and wrap-up | 3 min | Discussion |

**Key learning:** Production deployment patterns

---

## 🎯 Alternative Time Formats

### Option A: Half-Day Workshop (3 hours with breaks)

**Schedule:**
```
09:00 - 09:15  Module 01: Environment Setup (15 min)
09:15 - 09:40  Module 02: Consumer Basics (25 min)
09:40 - 10:00  Module 03: ConsumerRecords (20 min)
10:00 - 10:15  ☕ BREAK (15 min)
10:15 - 10:45  Module 04: Manual Offset Management (30 min)
10:45 - 11:10  Module 05: Rebalancing (25 min)
11:10 - 11:35  Module 06: Configuration (25 min)
11:35 - 11:45  ☕ BREAK (10 min)
11:45 - 12:15  Module 07: Multithreaded Consumer (30 min)
12:15 - 12:40  Module 08: Error Handling (25 min)
12:40 - 13:00  Module 09: Kafka UI (20 min)
13:00 - 13:15  Module 10: Summary (15 min)

Total: 3 hours 15 minutes (including 25 min breaks)
```

### Option B: Full-Day Workshop (6 hours with lunch)

**Extended version with more hands-on time and exercises:**

```
09:00 - 09:20  Module 01: Environment Setup (20 min) - more exploration
09:20 - 09:50  Module 02: Consumer Basics (30 min) - more experiments
09:50 - 10:20  Module 03: ConsumerRecords (30 min) - deeper analysis
10:20 - 10:35  ☕ BREAK (15 min)

10:35 - 11:15  Module 04: Manual Offset Management (40 min) - more experiments
11:15 - 11:45  Module 05: Rebalancing (30 min) - extended demo
11:45 - 12:15  Module 06: Configuration (30 min) - tuning exercises
12:15 - 13:00  🍽️ LUNCH BREAK (45 min)

13:00 - 13:45  Module 07: Multithreaded Consumer (45 min) - build from scratch
13:45 - 14:30  Module 08: Error Handling (45 min) - implement DLQ
14:30 - 14:45  ☕ BREAK (15 min)

14:45 - 15:15  Module 09: Kafka UI (30 min) - extended exploration
15:15 - 15:45  Module 10: Summary + Advanced Topics (30 min)
15:45 - 16:00  Q&A and Wrap-up (15 min)

Total: 6 hours (including 1h 15min breaks)
```

### Option C: Fast Track (1.5 - 2 hours)

**For experienced developers who know messaging basics:**

```
Skip or speed through:
- Module 01: 10 min (quick setup)
- Module 02: 15 min (review only)
- Module 03: 10 min (quick demo)
- Module 06: 10 min (show configs, no deep dive)
- Module 08: 10 min (concepts only)
- Module 09: 10 min (quick tour)

Focus on:
- Module 04: 25 min (manual commit - critical)
- Module 05: 20 min (rebalancing - see it in action)
- Module 07: 25 min (multithreading - advanced pattern)
- Module 10: 10 min (best practices)

Total: ~1.5 - 2 hours
```

### Option D: Self-Paced (3 - 4 hours)

**Participants work at their own pace:**

- Initial setup: 20 min
- Core modules (1-7): 2.5 hours
- Advanced modules (8-9): 45 min
- Review & experiments: 45 min

**Total: 3-4 hours** depending on exploration and experimentation

---

## 📅 Recommended Formats by Audience

### 1. Corporate Training (Half-Day)
**Duration:** 3 hours  
**Audience:** Developers learning Kafka  
**Format:** Instructor-led with live demos  
**Breaks:** 2 breaks (15 min + 10 min)

### 2. University Course (Full-Day)
**Duration:** 6 hours  
**Audience:** Students with Java knowledge  
**Format:** Hands-on labs with guided exercises  
**Breaks:** 3 breaks + lunch

### 3. Conference Workshop (90 minutes)
**Duration:** 1.5 hours  
**Audience:** Conference attendees  
**Format:** Fast-paced overview with key demos  
**Focus:** Modules 2, 4, 5, 7 (core concepts)

### 4. Online Self-Paced
**Duration:** 3-4 hours  
**Audience:** Individual learners  
**Format:** Work through modules independently  
**Support:** Documentation + optional Q&A sessions

---

## ⚡ Time-Saving Tips

### Before Workshop

1. **Pre-download Docker images** (saves 5-10 min)
   ```bash
   docker pull confluentinc/cp-kafka:7.7.1
   docker pull provectuslabs/kafka-ui:v0.7.2
   ```

2. **Pre-download Maven dependencies** (saves 3-5 min)
   ```bash
   cd kafka-apps/producer && mvn dependency:go-offline
   cd ../consumer-basic && mvn dependency:go-offline
   # etc.
   ```

3. **Pre-build applications** (saves 5 min during workshop)
   ```bash
   ./build-apps.sh
   ```

4. **Have Kafka running** (saves 3 min startup time)
   ```bash
   docker compose up -d
   ```

### During Workshop

1. **Overlap activities:**
   - While Maven builds, explain consumer architecture
   - While messages accumulate, discuss theory
   - While rebalancing, explain what's happening

2. **Use prepared examples:**
   - Have CLI commands ready to copy/paste
   - Pre-select code sections to highlight
   - Bookmark Kafka UI pages

3. **Skip optional exercises:**
   - Fast track can skip some CLI verification
   - Experienced audiences can skip basic reviews

---

## 🎓 Time by Participant Experience Level

### Beginners (No Kafka Experience)
**Total: 3 - 3.5 hours**
- Need more explanation time
- More questions during modules
- More time experimenting
- Benefit from extended breaks

### Intermediate (Some Kafka Knowledge)
**Total: 2.5 - 3 hours**
- Standard pace as designed
- Good balance of theory and practice
- Can move faster through basics

### Advanced (Experienced with Kafka)
**Total: 1.5 - 2 hours**
- Fast track through basics
- Focus on advanced patterns
- More discussion, less demo time
- Can skip theory sections

---

## 📊 Activity Time Distribution

**Hands-on Activities:** 40% (1 hour)
- Running applications
- CLI commands
- Kafka UI exploration
- Experimentation

**Theory/Explanation:** 30% (45 minutes)
- Concepts explanation
- Architecture diagrams
- Configuration discussion

**Code Walkthrough:** 20% (30 minutes)
- Reviewing implementations
- Understanding patterns
- Discussing approaches

**Discussion/Q&A:** 10% (15 minutes)
- Questions throughout
- Group discussions
- Wrap-up sessions

---

## 🎯 Recommended Workshop Duration

### For Most Audiences: **3 hours (including breaks)**

This provides:
✅ Complete coverage of all modules  
✅ Time for hands-on exercises  
✅ Opportunity for questions  
✅ Two coffee breaks  
✅ Not too rushed, not too slow  

**Actual learning time:** 2 hours 35 minutes  
**Break time:** 25 minutes  
**Total:** 3 hours

---

## 📝 Time Tracking During Workshop

Use this checklist to stay on schedule:

```
□ 09:00 - Start, Module 01 begins
□ 09:15 - Module 02 begins (on time if here)
□ 09:40 - Module 03 begins
□ 10:00 - BREAK (must take break to stay on schedule)
□ 10:15 - Module 04 begins
□ 10:45 - Module 05 begins
□ 11:10 - Module 06 begins
□ 11:35 - BREAK (short break)
□ 11:45 - Module 07 begins
□ 12:15 - Module 08 begins
□ 12:40 - Module 09 begins
□ 13:00 - Module 10 begins
□ 13:15 - Complete!
```

---

## 💡 Summary

**Bottom Line:**
- **Minimum viable:** 1.5 hours (fast track, experienced audience)
- **Recommended:** 3 hours (complete workshop with breaks)
- **Extended:** 6 hours (full-day with deep dives)
- **Self-paced:** 3-4 hours (individual learning)

**The workshop is designed for 2.5-3 hours** which provides:
- Complete coverage of all concepts from your notes
- Hands-on experience with all three consumer types
- Time for experimentation and questions
- Comfortable pace for most audiences

Choose the format that best fits your:
- Audience experience level
- Available time slot
- Learning objectives
- Format (instructor-led vs self-paced)

