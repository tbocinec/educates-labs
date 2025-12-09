#!/bin/bash

# Verify Kafka Schema Registry workshop setup

echo "🔍 Verifying Kafka Schema Registry workshop setup..."
echo ""

FAILED=0

# Check Docker
echo "1️⃣  Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   ✅ Docker is installed"
else
    echo "   ❌ Docker is not installed"
    FAILED=1
fi

# Check Docker Compose
echo ""
echo "2️⃣  Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    echo "   ✅ Docker Compose is installed"
else
    echo "   ❌ Docker Compose is not installed"
    FAILED=1
fi

# Check if containers are running
echo ""
echo "3️⃣  Checking Docker containers..."
if docker ps | grep -q kafka; then
    echo "   ✅ Kafka container is running"
else
    echo "   ⚠️  Kafka container is not running"
    echo "      Run: docker-compose up -d"
fi

if docker ps | grep -q schema-registry; then
    echo "   ✅ Schema Registry container is running"
else
    echo "   ⚠️  Schema Registry container is not running"
    echo "      Run: docker-compose up -d"
fi

if docker ps | grep -q kafka-ui; then
    echo "   ✅ Kafka UI container is running"
else
    echo "   ⚠️  Kafka UI container is not running"
    echo "      Run: docker-compose up -d"
fi

# Check Kafka connectivity
echo ""
echo "4️⃣  Checking Kafka connectivity..."
if docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 &> /dev/null; then
    echo "   ✅ Kafka is accessible on port 9092"
else
    echo "   ⚠️  Kafka is not accessible"
    echo "      Wait for containers to be healthy: docker-compose ps"
fi

# Check Schema Registry
echo ""
echo "5️⃣  Checking Schema Registry..."
if curl -s http://localhost:8081/subjects &> /dev/null; then
    echo "   ✅ Schema Registry is accessible on port 8081"
    SUBJECTS=$(curl -s http://localhost:8081/subjects)
    echo "      Registered subjects: $SUBJECTS"
else
    echo "   ⚠️  Schema Registry is not accessible"
    echo "      Wait for containers to be healthy: docker-compose ps"
fi

# Check Kafka UI
echo ""
echo "6️⃣  Checking Kafka UI..."
if curl -s http://localhost:8080/actuator/health &> /dev/null; then
    echo "   ✅ Kafka UI is accessible on port 8080"
    echo "      Open: http://localhost:8080"
else
    echo "   ⚠️  Kafka UI is not accessible"
fi

# Check Java
echo ""
echo "7️⃣  Checking Java..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "   ✅ Java is installed: $JAVA_VERSION"
else
    echo "   ❌ Java is not installed"
    FAILED=1
fi

# Check Maven
echo ""
echo "8️⃣  Checking Maven..."
if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -version | head -n 1)
    echo "   ✅ Maven is installed: $MVN_VERSION"
else
    echo "   ❌ Maven is not installed"
    FAILED=1
fi

# Check applications are built
echo ""
echo "9️⃣  Checking built applications..."
if [ -f "kafka-apps/producer-avro/target/producer-avro-1.0-SNAPSHOT.jar" ]; then
    echo "   ✅ Producer application is built"
else
    echo "   ⚠️  Producer application not built"
    echo "      Run: ./build-apps.sh"
fi

if [ -f "kafka-apps/consumer-avro/target/consumer-avro-1.0-SNAPSHOT.jar" ]; then
    echo "   ✅ Consumer application is built"
else
    echo "   ⚠️  Consumer application not built"
    echo "      Run: ./build-apps.sh"
fi

# Check schemas exist
echo ""
echo "🔟 Checking schema files..."
if [ -f "schemas/order-v1.avsc" ]; then
    echo "   ✅ order-v1.avsc exists"
else
    echo "   ⚠️  order-v1.avsc not found"
fi

if [ -f "schemas/order-v2-compatible.avsc" ]; then
    echo "   ✅ order-v2-compatible.avsc exists"
else
    echo "   ⚠️  order-v2-compatible.avsc not found"
fi

if [ -f "schemas/order-v3-breaking.avsc" ]; then
    echo "   ✅ order-v3-breaking.avsc exists"
else
    echo "   ⚠️  order-v3-breaking.avsc not found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo "✅ Setup verification complete!"
    echo ""
    echo "🚀 You're ready to start the workshop!"
    echo ""
    echo "Next steps:"
    echo "   1. Start services: docker-compose up -d"
    echo "   2. Build apps: ./build-apps.sh"
    echo "   3. Start learning! 📚"
else
    echo "❌ Some required tools are missing"
    echo ""
    echo "Please install missing dependencies before continuing."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

