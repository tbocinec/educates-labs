#!/bin/bash

echo "🔍 Verifying Workshop Setup..."
echo ""

# Check Docker
echo "1️⃣  Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   ✅ Docker is installed"
else
    echo "   ❌ Docker not found"
    exit 1
fi

# Check Docker Compose
echo "2️⃣  Checking Docker Compose..."
if docker compose version &> /dev/null; then
    echo "   ✅ Docker Compose is available"
else
    echo "   ❌ Docker Compose not found"
    exit 1
fi

# Check running containers
echo "3️⃣  Checking running containers..."
CONTAINERS=$(docker compose ps --services --filter "status=running" 2>/dev/null | wc -l)
if [ "$CONTAINERS" -ge 4 ]; then
    echo "   ✅ All services are running ($CONTAINERS/5)"
else
    echo "   ⚠️  Only $CONTAINERS services running (expected 5)"
    echo "   💡 Run: docker compose up -d"
fi

# Check Kafka
echo "4️⃣  Checking Kafka..."
if docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 &> /dev/null; then
    echo "   ✅ Kafka is accessible"
else
    echo "   ❌ Kafka not accessible"
fi

# Check Kafka Connect
echo "5️⃣  Checking Kafka Connect..."
if curl -s http://localhost:8083/ > /dev/null; then
    echo "   ✅ Kafka Connect is ready"
else
    echo "   ⚠️  Kafka Connect not ready yet"
fi

# Check Flink JobManager
echo "6️⃣  Checking Flink JobManager..."
if curl -s http://localhost:8081/overview > /dev/null; then
    echo "   ✅ Flink JobManager is ready"
else
    echo "   ⚠️  Flink not ready yet"
fi

# Check Kafka UI
echo "7️⃣  Checking Kafka UI..."
if curl -s http://localhost:8080/actuator/health > /dev/null; then
    echo "   ✅ Kafka UI is accessible"
else
    echo "   ⚠️  Kafka UI not ready yet"
fi

# Check Maven
echo "8️⃣  Checking Maven..."
if command -v mvn &> /dev/null; then
    echo "   ✅ Maven is installed ($(mvn -version | head -n 1))"
else
    echo "   ❌ Maven not found"
fi

# Check Java
echo "9️⃣  Checking Java..."
if command -v java &> /dev/null; then
    echo "   ✅ Java is installed ($(java -version 2>&1 | head -n 1))"
else
    echo "   ❌ Java not found"
fi

echo ""
echo "✅ Setup verification complete!"

