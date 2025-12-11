# Workshop Timing Breakdown

Detailed time estimates for each module of the Kafka + Flink Mold Alert workshop.

## Total Duration: 75 minutes
**Core Workshop:** 60 minutes  
**Bonus SQL Module:** 15 minutes (optional)

---

## Module Breakdown

### Module 1: Quick Start - Setup Environment
**Duration:** 10 minutes

| Task | Time | Notes |
|------|------|-------|
| Make scripts executable | 30 sec | One command |
| Start Docker services | 2 min | docker compose up -d |
| Inspect docker-compose.yml | 1 min | Review configuration |
| Verify services health | 1 min | Wait for healthchecks |
| Create Kafka topics | 1 min | Two topic creation commands |
| Access Kafka UI | 1 min | Open browser, explore |
| Access Flink UI | 1 min | Open browser, verify cluster |
| Start data generator | 1 min | Register Datagen connector |
| Verify data flow | 1.5 min | Console consumer test |

**Buffer:** 30 seconds for any delays

---

### Module 2: Understanding the Logic
**Duration:** 5 minutes

| Task | Time | Notes |
|------|------|-------|
| Read mold science explanation | 1 min | Why 70% threshold |
| Review data flow diagram | 1 min | Architecture overview |
| Compare input/output samples | 1 min | JSON examples |
| Understand Flink components | 1.5 min | Source, Transform, Sink |
| Review success criteria | 30 sec | What defines "working" |

**Note:** Mostly reading and conceptual understanding

---

### Module 3: Build the Flink Job
**Duration:** 15 minutes

| Task | Time | Notes |
|------|------|-------|
| Open and examine MoldAlertJob.java | 3 min | Code walkthrough |
| Review filter logic | 2 min | Core algorithm |
| Review map transformation | 1.5 min | Enrichment logic |
| Examine pom.xml dependencies | 1.5 min | Maven configuration |
| Run build script | 5 min | Maven package (first time) |
| Verify JAR created | 30 sec | ls command |
| Review build process | 1.5 min | Understanding what happened |

**Note:** First Maven build downloads ~100MB of dependencies (5 min). Subsequent builds: ~30 seconds.

---

### Module 4: Deploy and Monitor
**Duration:** 15 minutes

| Task | Time | Notes |
|------|------|-------|
| Submit job to Flink | 1 min | Run script |
| View job in Flink UI | 2 min | Explore dashboard |
| Monitor job logs | 2 min | docker logs command |
| Check output topic | 1.5 min | Console consumer |
| View in Kafka UI | 2 min | Browse topics and messages |
| Compare input vs output rates | 2 min | Message count comparison |
| Real-time streaming demo | 3 min | Watch both topics live |
| Test scenario verification | 1.5 min | Logic validation |

**Key Learning:** Participants see the pipeline working end-to-end

---

### Module 5: Experimentation
**Duration:** 10 minutes

| Task | Time | Notes |
|------|------|-------|
| **Experiment 1: Change Threshold** | 4 min | |
| - Cancel running job | 30 sec | Flink UI |
| - Modify threshold value | 30 sec | Edit Java file |
| - Rebuild | 30 sec | Fast rebuild |
| - Redeploy | 30 sec | Submit script |
| - Observe differences | 2 min | Check output |
| **Experiment 2: Location Filter** | 3 min | |
| - Cancel job | 15 sec | |
| - Modify filter logic | 1 min | Add location check |
| - Rebuild and redeploy | 1 min | |
| - Test new logic | 45 sec | Verify only basement/bathroom |
| **Experiment 3: Severity Levels** | 3 min | |
| - Cancel job | 15 sec | |
| - Modify map function | 1 min | Add severity field |
| - Rebuild and redeploy | 1 min | |
| - Verify severity in output | 45 sec | |

**Note:** Participants choose 1-2 experiments based on interest and time

---

### Module 6: Flink SQL (Optional/Bonus)
**Duration:** 15 minutes

| Task | Time | Notes |
|------|------|-------|
| Introduction to Flink SQL | 1.5 min | Why SQL vs Java |
| Cancel Java job | 30 sec | Via Flink UI |
| Start SQL client | 30 sec | docker exec command |
| Create source table definition | 1.5 min | Copy DDL statement |
| Create sink table definition | 1 min | Copy DDL statement |
| Query sample data (SELECT) | 1.5 min | Interactive exploration |
| Filter high humidity (SELECT WHERE) | 1 min | See filtered results |
| Deploy continuous INSERT query | 1.5 min | Submit streaming job |
| Verify in Flink UI | 1 min | See SQL job running |
| Verify output topic | 1 min | Console consumer |
| Try aggregation query | 1.5 min | COUNT, AVG per location |
| Try windowed query | 1.5 min | 5-minute tumbling windows |
| Comparison discussion | 1 min | Java vs SQL trade-offs |

**Note:** This module can be optional for time-constrained sessions

---

### Module 7: Wrap-Up
**Duration:** 5 minutes

| Task | Time | Notes |
|------|------|-------|
| Review accomplishments | 1 min | What we built |
| Key concepts recap | 1.5 min | Patterns learned |
| Real-world applications | 1 min | Industry use cases |
| Best practices summary | 1 min | Production tips |
| Next steps and resources | 30 sec | Further learning |

**Purpose:** Consolidate learning and provide direction

---

## Timing by Activity Type

### Core Workshop (60 min)

| Activity Type | Total Time | Percentage |
|---------------|------------|------------|
| Hands-on commands | 18 min | 30% |
| Reading/Understanding | 12 min | 20% |
| Building/Compiling | 7 min | 12% |
| Monitoring/Verification | 13 min | 22% |
| Experimentation | 10 min | 16% |

### Including SQL Module (75 min)

| Activity Type | Total Time | Percentage |
|---------------|------------|------------|
| Hands-on commands | 25 min | 33% |
| Reading/Understanding | 15 min | 20% |
| Building/Compiling | 7 min | 9% |
| Monitoring/Verification | 16 min | 21% |
| Experimentation | 10 min | 13% |
| SQL Interactive Queries | 7 min | 9% |

---

## Critical Path Items

These are the tasks that cannot be parallelized and determine minimum duration:

1. **Docker services startup:** 2 minutes (actual time, with healthchecks)
2. **First Maven build:** 5 minutes (network-dependent)
3. **Data generation startup:** 30 seconds (Kafka Connect initialization)
4. **Job deployment:** 15 seconds (Flink job submission)

**Minimum possible time:** ~45 minutes (for experienced users)

---

## Time Savers

To complete the workshop faster:

1. **Pre-pull Docker images** before workshop
   ```bash
   docker compose pull
   ```
   Saves: 5-10 minutes

2. **Pre-build Maven dependencies** (if local environment)
   ```bash
   cd flink-app && mvn dependency:resolve
   ```
   Saves: 3-4 minutes

3. **Skip optional experiments** in Module 5
   Saves: 5-7 minutes

---

## Extended Workshop Option (90 minutes)

If you have extra time, add these optional modules:

### Optional Module A: Windowed Aggregations
**Duration:** 15 minutes
- Calculate 5-minute average humidity
- Implement tumbling windows
- Compare aggregated vs raw alerts

### Optional Module B: Stateful Processing
**Duration:** 10 minutes
- Track consecutive high readings
- Use Flink's ValueState
- Alert only after 3 consecutive violations

### Optional Module C: Advanced Patterns
**Duration:** 5 minutes
- Side outputs for routing
- Late data handling
- Backpressure demonstration

---

## Workshop Pace Recommendations

### For Beginners (60-75 min)
- Follow all modules at comfortable pace
- Allow extra time for questions
- Complete 1-2 experiments

### For Intermediate (45-55 min)
- Move quickly through setup
- Focus on experimentation
- Complete all 3 experiments

### For Advanced (30-40 min)
- Rapid setup and deployment
- Jump to advanced patterns
- Add custom extensions

---

## Instructor Notes

### Key Milestones

**10 minutes:** Services running, data flowing
**25 minutes:** Job built and deployed
**40 minutes:** First experiment complete
**55 minutes:** All experiments done
**60 minutes:** Wrap-up complete

### Where Students Get Stuck

1. **Maven build failures** (5-10 min)
   - Solution: Provide pre-built JAR as backup
   
2. **Services not healthy** (3-5 min)
   - Solution: Increase healthcheck timeouts for slow systems
   
3. **Understanding filter logic** (2-3 min)
   - Solution: Use whiteboard to draw flow diagram

4. **JSON parsing errors** (2-3 min)
   - Solution: Provide working code snippets to copy

### Engagement Tips

- **Checkpoints:** Ask "Is everyone seeing the output topic?" at key moments
- **Variations:** "What happens if we set threshold to 50? To 90?"
- **Real-world:** "Where would you use this in your organization?"

---

## Buffer Time Allocation

- **Setup delays:** 2 minutes
- **Network/download issues:** 3 minutes
- **Questions and discussion:** 5 minutes
- **Troubleshooting:** 3 minutes

**Total buffer:** ~13 minutes (included in 60-minute total)

---

## Success Metrics

By the end of 60 minutes, participants should:
- ✅ Have a working Flink job processing live data
- ✅ Understand the Filter + Transform + Route pattern
- ✅ Successfully modify and redeploy at least once
- ✅ Be able to monitor jobs using Flink UI
- ✅ Understand real-world applications

---

**Last Updated:** December 2025

