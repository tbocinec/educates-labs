# Workshop Delivery Guide

This guide is for instructors delivering the Kafka Schema Registry workshop.

## Workshop Overview

**Title:** Kafka Schema Registry & Data Governance  
**Duration:** 90 minutes  
**Level:** Intermediate  
**Prerequisites:** Basic Kafka knowledge (producers, consumers, topics)  
**Max Participants:** 30 (with proper infrastructure)

## Learning Objectives

By the end of this workshop, participants will be able to:

1. ✅ Explain why schema governance prevents production outages
2. ✅ Register and evolve Avro schemas using Schema Registry
3. ✅ Implement schema-based producers and consumers in Java
4. ✅ Differentiate between BACKWARD, FORWARD, and FULL compatibility
5. ✅ Prevent breaking changes using compatibility checks
6. ✅ Integrate schema validation into CI/CD pipelines
7. ✅ Troubleshoot schema-related issues using REST API

## Pre-Workshop Checklist

### 1 Week Before

- [ ] Send prerequisites email to participants
- [ ] Share Docker installation instructions
- [ ] Provide GitHub repo URL for materials
- [ ] Ask participants to pre-pull Docker images:
  ```bash
  docker pull confluentinc/cp-kafka:7.7.1
  docker pull confluentinc/cp-schema-registry:7.7.1
  docker pull provectuslabs/kafka-ui:v0.7.2
  ```

### 1 Day Before

- [ ] Test all scripts on a clean machine
- [ ] Verify all Docker images are accessible
- [ ] Test build process (Maven dependencies)
- [ ] Prepare backup USB drives with materials
- [ ] Set up instructor environment (dual monitors recommended)

### 1 Hour Before

- [ ] Test projector/screen sharing
- [ ] Verify network bandwidth (for Maven downloads)
- [ ] Start your demo environment
- [ ] Prepare troubleshooting terminal
- [ ] Have backup plan if internet fails

## Module-by-Module Guide

### Module 1: Introduction to Data Governance (15 min)

**Objectives:**
- Hook participants with real-world horror stories
- Explain the cost of uncontrolled schema evolution
- Introduce Schema Registry as the solution

**Delivery Tips:**
- Start with the "2 AM production outage" story
- Ask: "Who has experienced schema-related bugs?" (hands up)
- Draw the architecture diagram on whiteboard
- Emphasize the wire format (magic byte + schema ID)

**Interactive Elements:**
- Poll: "What's worse - downtime or data corruption?"
- Quick quiz: "What happens without schema governance?"

**Common Questions:**
- Q: "Can't we just use JSON?"
  - A: Yes, but no enforcement, larger size, no evolution rules
- Q: "Is Schema Registry only for Avro?"
  - A: No - supports JSON Schema and Protobuf too

**Timing Breakdown:**
- Horror stories: 3 min
- Architecture overview: 5 min
- Wire format explanation: 4 min
- Q&A: 3 min

---

### Module 2: Register and Produce with Schemas (20 min)

**Objectives:**
- Understand Avro schema structure
- Register schemas using REST API
- Produce schema-validated messages

**Delivery Tips:**
- Live code the schema registration
- Show both script and manual curl approach
- Demonstrate auto-registration during first producer run
- Use Kafka UI to visualize the wire format

**Interactive Elements:**
- Hands-on: Participants register their first schema
- Challenge: "Find the schema ID in the message bytes"

**Common Issues:**
- Maven build failures → pre-cache dependencies
- Schema Registry not ready → add health check wait
- jq not installed → provide Windows/Mac alternatives

**Timing Breakdown:**
- Avro schema anatomy: 5 min
- Registration demo: 5 min
- Hands-on exercise: 7 min
- Q&A: 3 min

**Troubleshooting:**
```bash
# If build fails
mvn dependency:resolve -U

# If Registry unreachable
docker logs schema-registry
```

---

### Module 3: Consume with Schema Registry (15 min)

**Objectives:**
- Understand consumer schema resolution
- See schema caching in action
- Experience backward compatibility

**Delivery Tips:**
- Start consumer first, then producer (show waiting)
- Highlight the schema fetch in logs
- Stop and restart consumer (show cache reuse)
- Live demo: upgrade producer to v2, old consumer still works

**Interactive Elements:**
- Hands-on: Participants run consumer
- Observation: Count schema registry calls (should be 1)

**Common Issues:**
- Consumer group conflicts → use unique group IDs
- Messages not appearing → check from-beginning offset
- Schema cache not working → verify config

**Timing Breakdown:**
- Consumer architecture: 3 min
- Live demo: 5 min
- Hands-on exercise: 5 min
- Q&A: 2 min

---

### Module 4: Schema Evolution & Compatibility (20 min)

**Objectives:**
- Master compatibility modes
- Distinguish compatible vs breaking changes
- Test schema evolution safely

**Delivery Tips:**
- Draw compatibility matrix on whiteboard
- Live demo: Try to register breaking change (watch it fail!)
- Show compatibility check before registration
- Explain transitive compatibility with timeline diagram

**Interactive Elements:**
- Exercise: Participants evolve their schema
- Quiz: "Is this change compatible?" (multiple scenarios)
- Challenge: "Break Schema Registry" (try to register bad schema)

**Common Questions:**
- Q: "When should I use FULL vs BACKWARD?"
  - A: FULL = max flexibility, BACKWARD = most common/safer
- Q: "Can I rename a field?"
  - A: No - always breaking. Add new field, deprecate old one

**Timing Breakdown:**
- Compatibility modes: 5 min
- Breaking change demo: 5 min
- Hands-on evolution: 8 min
- Q&A: 2 min

**Key Demo Moments:**
```bash
# This WILL FAIL - show it!
./check-compatibility.sh orders-value schemas/order-v3-breaking.avsc

# This WILL SUCCEED
./check-compatibility.sh orders-value schemas/order-v2-compatible.avsc
```

---

### Module 5: Governance in Action (15 min)

**Objectives:**
- Experience governance preventing disasters
- Explore REST API thoroughly
- Learn CI/CD integration patterns

**Delivery Tips:**
- Simulate the "midnight deployment" scenario
- Show complete REST API exploration
- Demonstrate CI/CD pipeline example (GitHub Actions)
- Discuss monitoring and observability

**Interactive Elements:**
- Hands-on: Explore REST API endpoints
- Discussion: "How would you integrate this in your org?"

**Common Questions:**
- Q: "What if Schema Registry goes down?"
  - A: Cached schemas still work, only new IDs fail
- Q: "How do we backup schemas?"
  - A: Export via API, store in Git

**Timing Breakdown:**
- Breaking change prevention: 4 min
- REST API exploration: 6 min
- CI/CD patterns: 3 min
- Q&A: 2 min

---

### Module 6: Wrap-Up (5 min)

**Objectives:**
- Review key concepts
- Provide next learning steps
- Gather feedback

**Delivery Tips:**
- Quick rapid-fire review of main points
- Share resources for further learning
- Encourage questions
- Collect feedback

**Key Messages:**
- Schema governance is essential, not optional
- Start with BACKWARD compatibility
- Automate validation in CI/CD
- Monitor schema evolution

**Timing Breakdown:**
- Recap: 2 min
- Resources: 1 min
- Q&A: 2 min

## Workshop Timing Matrix

| Module | Topic | Duration | Cumulative |
|--------|-------|----------|------------|
| 1 | Introduction | 15 min | 0:15 |
| 2 | Register & Produce | 20 min | 0:35 |
| 3 | Consume | 15 min | 0:50 |
| 4 | Schema Evolution | 20 min | 1:10 |
| 5 | Governance | 15 min | 1:25 |
| 6 | Wrap-Up | 5 min | 1:30 |

**Buffer:** 10-15 minutes built in for Q&A and troubleshooting

## Common Participant Questions

### Technical Questions

**Q: Why not just use JSON?**
A: JSON works, but lacks enforcement, type safety, and governance. Schema Registry adds contract validation.

**Q: What's the performance impact?**
A: Initial overhead for schema fetch (~10ms), then cached. Avro is faster than JSON parsing.

**Q: Can I use this with Kafka Streams?**
A: Yes! Streams fully supports Avro with Schema Registry.

**Q: What about polyglot environments?**
A: Avro has libraries for Java, Python, Go, C#, etc. Schema Registry is language-agnostic.

**Q: How do I handle schema migrations?**
A: Dual-write phase → add new fields as optional → migrate consumers → remove old fields.

### Organizational Questions

**Q: How do we get buy-in from management?**
A: Show cost of production outages vs cost of Schema Registry (free/open source).

**Q: Who owns the schemas?**
A: Typically the team producing the events, with a review process for breaking changes.

**Q: How do we enforce naming conventions?**
A: Custom tooling, CI validation, or Confluent Schema Validation (commercial).

## Troubleshooting Guide

### Issue: Docker Services Won't Start

**Symptoms:** `docker-compose up` fails

**Solutions:**
1. Check port conflicts: `netstat -ano | findstr :9092`
2. Increase Docker memory: Settings → Resources → Memory (4GB+)
3. Restart Docker daemon

### Issue: Maven Build Hangs

**Symptoms:** Build stuck on dependency resolution

**Solutions:**
1. Pre-cache dependencies: `mvn dependency:go-offline`
2. Use local Maven mirror if available
3. Increase Maven heap: `export MAVEN_OPTS="-Xmx2g"`

### Issue: Schema Registry Not Accessible

**Symptoms:** `curl http://localhost:8081` fails

**Solutions:**
1. Check if Kafka is healthy first (Registry depends on it)
2. Wait 60 seconds after Kafka starts
3. Check logs: `docker logs schema-registry`

### Issue: Consumer Not Receiving Messages

**Symptoms:** Consumer polls return empty

**Solutions:**
1. Check topic exists: `docker exec kafka kafka-topics --list --bootstrap-server localhost:9092`
2. Verify consumer group: `docker exec kafka kafka-consumer-groups --describe --group order-processor-group --bootstrap-server localhost:9092`
3. Reset offset to beginning: `--auto-offset-reset earliest`

## Instructor Setup Recommendations

### Hardware
- **CPU:** 4+ cores
- **RAM:** 16GB minimum (8GB for Docker, 8GB for IDE/tools)
- **Disk:** 20GB free space
- **Network:** Stable connection for Maven downloads

### Software
- Docker Desktop (latest)
- Java 17 (not 21 - compatibility issues)
- Maven 3.8+
- IDE with terminal (VS Code, IntelliJ)
- Screen recording tool (for async delivery)

### Display Setup
- **Primary screen:** Presentation slides / terminal
- **Secondary screen:** Notes, troubleshooting commands
- **Projector:** Mirrored or extended (test beforehand)

## Advanced Delivery Options

### Virtual Delivery

**Challenges:**
- Participants may have slow internet (Maven downloads)
- Hard to see individual progress

**Solutions:**
- Pre-record complex demos as backup
- Use breakout rooms for hands-on exercises
- Provide pre-built JAR files as fallback
- Have teaching assistants monitor chat

### Hybrid Delivery

**Challenges:**
- In-person and remote participants
- Different experience levels

**Solutions:**
- Pair remote with in-person participants
- Use collaborative tools (Google Docs for notes)
- Record session for async review

## Post-Workshop Follow-Up

### Immediate (Same Day)
- [ ] Share recording/slides
- [ ] Send workshop materials repo link
- [ ] Collect feedback survey

### Within 1 Week
- [ ] Send "Next Steps" email with resources
- [ ] Share additional examples/use cases
- [ ] Invite to community Slack/forum

### Within 1 Month
- [ ] Send advanced topics article
- [ ] Offer office hours for questions
- [ ] Share success stories from participants

## Feedback Collection

**Quick Survey (2 minutes):**
1. Content clarity (1-5)
2. Pacing (too fast / just right / too slow)
3. Most valuable topic?
4. Least clear topic?
5. Would recommend? (Yes/No)

**Follow-up Interview (Optional):**
- What are you planning to implement?
- What blockers do you foresee?
- What additional support do you need?

## Resources for Continuous Improvement

- Record each delivery and review your pacing
- Collect common questions → add to FAQ
- Update examples based on participant feedback
- Stay current with Schema Registry releases

## Contact & Support

**During Workshop:**
- Instructor handles conceptual questions
- Teaching assistants help with technical issues
- Use "parking lot" for deep-dive questions

**After Workshop:**
- GitHub issues for workshop materials
- Slack/Discord for community support
- Office hours (weekly/monthly)

---

**Good luck with your workshop delivery!** 🎓

Remember: The goal isn't to make everyone an expert - it's to give them the foundation and confidence to start using Schema Registry safely in their own systems.

