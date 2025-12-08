# Apache Kafka on Linux - KRaft Mode Installation

Welcome to this hands-on workshop on installing and configuring Apache Kafka in KRaft mode!

## What You'll Learn

In this workshop, you'll learn how to:

- **Launch an isolated Ubuntu container** (for security and isolation)
- **Install Apache Kafka** inside the container
- **Configure Kafka in KRaft mode** (without Zookeeper)
- **Start a single Kafka broker** and perform basic operations
- **Scale to a multi-broker cluster** with replication
- **Use Kafka UI** for monitoring and management

## Why Use a Container?

For security and isolation, we'll work inside a Docker container. This approach:

- **Keeps the workshop platform secure** - No root access needed on the host
- **Provides isolation** - Your work won't affect other workshop sessions
- **Gives you full control** - Root access inside the container to install packages
- **Easy to reset** - Just restart the container for a clean state

## What is KRaft Mode?

KRaft (Kafka Raft) is a new consensus protocol that replaces Apache Zookeeper for managing Kafka metadata. Benefits include:

- **Simpler architecture** - no separate Zookeeper cluster needed
- **Better scalability** - supports more partitions
- **Faster operations** - quicker controller failover
- **Easier deployment** - fewer moving parts

## Workshop Structure

This workshop is divided into progressive levels:

### Level 0: Container Setup
- Launch Ubuntu Docker container
- Enter the container with root access
- Verify the environment

### Level 1: Kafka Installation
- Download and install Kafka binaries
- Install Java runtime
- Set up environment variables

### Level 2: Single Broker Setup
- Configure a single broker in KRaft mode
- Start the broker and verify it's running

### Level 3: Basic Operations
- Create topics
- Produce messages
- Consume messages
- Monitor with Kafka UI

### Level 4: Multi-Broker Cluster
- Configure a cluster with 2 brokers + 1 KRaft controller
- Set up topic replication
- Test cluster failover and recovery

## Available Tools

During this workshop, you have access to:

- 🖥️ **Terminal** - Command line interface for Kafka commands
- 📝 **Editor** - For editing configuration files
- 🐳 **Docker** - For running Kafka UI dashboard
- 📊 **Kafka UI** - Web interface for monitoring Kafka

## Prerequisites

Basic knowledge of:
- Linux command line
- Distributed systems concepts
- Kafka basics (producers, consumers, topics)

Let's get started!
