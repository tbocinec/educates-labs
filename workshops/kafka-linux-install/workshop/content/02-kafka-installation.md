# Installing Apache Kafka

Now that you're inside the Ubuntu container with root access, let's install Java and Apache Kafka.

**Note**: You're running as root in the container, so no `sudo` is needed!

---
## Update Package Index

First, refresh the list of available packages:

```terminal:execute
command: apt-get update
```

---
## Install Java

Kafka requires Java 11 or later. Let's install OpenJDK 21:

```terminal:execute
command: apt-get install -y openjdk-21-jdk-headless
```

Verify Java installation:

```terminal:execute
command: java -version
```

You should see Java version 21.

---
## Install Required Tools

Install wget for downloading Kafka and other useful tools:

```terminal:execute
command: apt-get install -y wget curl net-tools iproute2 nano procps
```

---
## Download Kafka

Download the latest Kafka binary distribution to `/opt`:

```terminal:execute
command: |
  cd /opt
  wget https://archive.apache.org/dist/kafka/4.0.1/kafka_2.13-4.0.1.tgz
```

Extract the archive:

```terminal:execute
command: |
  cd /opt
  tar -xzf kafka_2.13-4.0.1.tgz
  ln -s kafka_2.13-4.0.1 kafka
```

---
## Verify Installation

Check that Kafka was extracted correctly:

```terminal:execute
command: ls -la /opt/kafka
```

You should see directories like:
- `bin/` - Kafka executables and scripts
- `config/` - Configuration files
- `libs/` - Java libraries

## Understanding the Directory Structure

- **bin/** - Contains Kafka command-line tools:
  - `kafka-server-start.sh` - Starts Kafka broker
  - `kafka-topics.sh` - Topic management
  - `kafka-console-producer.sh` - CLI producer
  - `kafka-console-consumer.sh` - CLI consumer

- **config/** - Configuration files:
  - `server.properties` - Broker configuration
  - `kraft/` - KRaft mode configurations

- **logs/** - Log files (created when broker starts)

## Set Environment Variable

For convenience, let's set the KAFKA_HOME environment variable:

```terminal:execute
command: |
  echo 'export KAFKA_HOME=/opt/kafka' >> ~/.bashrc
  echo 'export PATH=$PATH:$KAFKA_HOME/bin' >> ~/.bashrc
  export KAFKA_HOME=/opt/kafka
  export PATH=$PATH:$KAFKA_HOME/bin
```

Now you can run Kafka commands from any directory!

## Next Steps

In the next section, we'll configure and start a single Kafka broker in KRaft mode.
