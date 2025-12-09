#!/bin/bash
# Get schema by ID

SCHEMA_REGISTRY_URL="http://localhost:8081"

if [ $# -lt 1 ]; then
    echo "Usage: ./get-schema.sh <schema-id>"
    echo "Example: ./get-schema.sh 1"
    exit 1
fi

SCHEMA_ID=$1

echo "📖 Fetching schema ID: $SCHEMA_ID"
echo ""

RESPONSE=$(curl -s "$SCHEMA_REGISTRY_URL/schemas/ids/$SCHEMA_ID")

if echo "$RESPONSE" | jq -e '.schema' > /dev/null 2>&1; then
    echo "$RESPONSE" | jq -r '.schema' | jq .
else
    echo "❌ Schema not found or error occurred"
    echo "$RESPONSE" | jq .
    exit 1
fi

