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
  
  # Try home directory as fallback
  echo "Trying home directory..." >> /tmp/kafka-setup.log
  cd ~
  echo "Changed to: $(pwd)" >> /tmp/kafka-setup.log
  echo "Directory contents:" >> /tmp/kafka-setup.log
  ls -la >> /tmp/kafka-setup.log 2>&1
  
  if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found in home directory either" | tee -a /tmp/kafka-setup.log
    exit 1
  fi
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH" | tee -a /tmp/kafka-setup.log
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running" | tee -a /tmp/kafka-setup.log
    exit 1
fi

echo "✅ Docker is available" | tee -a /tmp/kafka-setup.log

# Start services
echo "🚀 Starting Kafka and Kafka UI..." | tee -a /tmp/kafka-setup.log
if docker compose up -d >> /tmp/kafka-setup.log 2>&1; then
    echo "✅ Services started successfully" | tee -a /tmp/kafka-setup.log
    
    # Wait a bit for services to initialize
    sleep 5
    
    # Check service status
    echo "📊 Service status:" | tee -a /tmp/kafka-setup.log
    docker compose ps >> /tmp/kafka-setup.log 2>&1
    
    echo "🎉 Kafka setup completed!" | tee -a /tmp/kafka-setup.log
else
    echo "❌ Failed to start services" | tee -a /tmp/kafka-setup.log
    echo "📜 Error details:" | tee -a /tmp/kafka-setup.log
    docker compose logs >> /tmp/kafka-setup.log 2>&1
    exit 1
fi

echo "✅ Setup script completed at $(date)" | tee -a /tmp/kafka-setup.log