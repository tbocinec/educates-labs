#!/bin/bash

# Register a schema with Schema Registry

SCHEMA_REGISTRY_URL="http://localhost:8081"

if [ $# -lt 2 ]; then
    echo "Usage: ./register-schema.sh <subject-name> <schema-file>"
    echo "Example: ./register-schema.sh orders-value ../schemas/order-v1.avsc"
    exit 1
fi

SUBJECT=$1
SCHEMA_FILE=$2

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Schema file not found: $SCHEMA_FILE"
    exit 1
fi

echo "📤 Registering schema for subject: $SUBJECT"
echo "📄 Schema file: $SCHEMA_FILE"
echo ""

# Read and compact the schema
SCHEMA=$(cat "$SCHEMA_FILE" | jq -c .)

# Create payload and register
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  "$SCHEMA_REGISTRY_URL/subjects/$SUBJECT/versions" \
  -d "{\"schema\": $(echo "$SCHEMA" | jq -Rs .)}")

# Check if successful
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    SCHEMA_ID=$(echo "$RESPONSE" | jq -r '.id')
    echo "✅ Schema registered successfully!"
    echo "   Schema ID: $SCHEMA_ID"
    echo "   Subject: $SUBJECT"
else
    echo "❌ Failed to register schema"
    echo "$RESPONSE" | jq .
    exit 1
fi

