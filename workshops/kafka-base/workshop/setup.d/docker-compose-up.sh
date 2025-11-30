#!/bin/bash

# Log execution for debugging
echo "🚀 Starting Kafka services automatically..." | tee /tmp/kafka-setup.log
echo "Executed at: $(date)" >> /tmp/kafka-setup.log
echo "Current directory: $(pwd)" >> /tmp/kafka-setup.log
echo "User: $(whoami)" >> /tmp/kafka-setup.log

# Go to workshop directory where docker-compose.yml is located
cd /opt/workshop
echo "Changed to: $(pwd)" >> /tmp/kafka-setup.log
echo "Directory contents:" >> /tmp/kafka-setup.log
ls -la >> /tmp/kafka-setup.log 2>&1

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "❌ docker-compose.yml not found in $(pwd)" | tee -a /tmp/kafka-setup.log
  echo "Available files:" >> /tmp/kafka-setup.log
  ls -la >> /tmp/kafka-setup.log 2>&1
  
  # Try home directory
  echo "Trying home directory..." >> /tmp/kafka-setup.log
  cd ~
  echo "Changed to: $(pwd)" >> /tmp/kafka-setup.log
  ls -la >> /tmp/kafka-setup.log 2>&1
  
  if [ -f "docker-compose.yml" ]; then
    echo "✅ Found docker-compose.yml in home directory" >> /tmp/kafka-setup.log
  else
    echo "❌ docker-compose.yml not found in home directory either" | tee -a /tmp/kafka-setup.log
    echo "⚠️ Skipping Docker Compose startup - file not found" | tee -a /tmp/kafka-setup.log
    exit 0
  fi
else
  echo "✅ docker-compose.yml found in /opt/workshop" >> /tmp/kafka-setup.log
fi

# Check if docker is available 
if ! docker info >/dev/null 2>&1; then
  echo "⚠️ Docker is not available, skipping automatic startup" | tee -a /tmp/kafka-setup.log
  exit 0
fi
echo "✅ Docker is available" >> /tmp/kafka-setup.log

# Check if services are already running
echo "Checking if services are running..." >> /tmp/kafka-setup.log
if docker compose ps --services --filter "status=running" 2>/dev/null | grep -q kafka; then
  echo "✅ Kafka services are already running" | tee -a /tmp/kafka-setup.log
else
  # Start docker compose in background
  echo "📦 Starting Kafka and Kafka UI..." | tee -a /tmp/kafka-setup.log
  docker compose up -d >> /tmp/kafka-setup.log 2>&1
  
  # Wait a bit for services to initialize
  echo "⏳ Waiting for services to start..." | tee -a /tmp/kafka-setup.log
  sleep 10
  
  # Check if services started successfully
  if docker compose ps --services --filter "status=running" 2>/dev/null | grep -q kafka; then
    echo "✅ Kafka services started successfully!" | tee -a /tmp/kafka-setup.log
  else
    echo "⚠️ Kafka services may still be starting. Check manually with: docker compose ps" | tee -a /tmp/kafka-setup.log
  fi
fi

echo "" 
echo "📊 Kafka UI will be available at: http://localhost:8080" | tee -a /tmp/kafka-setup.log
echo "🔧 Kafka broker is available at: localhost:9092" | tee -a /tmp/kafka-setup.log
echo ""
echo "✨ Setup complete! You can proceed with the workshop." | tee -a /tmp/kafka-setup.log
echo "Setup finished at: $(date)" >> /tmp/kafka-setup.log
# Educates runs setup scripts from home directory
cd /opt/workshop

# Check if docker is available and services are not already running
if ! docker info >/dev/null 2>&1; then
  echo "⚠️ Docker is not available, skipping automatic startup"
  exit 0
fi

# Check if services are already running
if docker compose ps --services --filter "status=running" 2>/dev/null | grep -q kafka; then
  echo "✅ Kafka services are already running"
else
  # Start docker compose in background
  echo "📦 Starting Kafka and Kafka UI..."
  docker compose up -d
  
  # Wait a bit for services to initialize
  echo "⏳ Waiting for services to start..."
  sleep 10
  
  # Check if services started successfully
  if docker compose ps --services --filter "status=running" 2>/dev/null | grep -q kafka; then
    echo "✅ Kafka services started successfully!"
  else
    echo "⚠️ Kafka services may still be starting. Check manually with: docker compose ps"
  fi
fi

echo "📊 Kafka UI will be available at: http://localhost:8080"
echo "🔧 Kafka broker is available at: localhost:9092"
echo ""
echo "Use 'docker compose ps' to check service status."