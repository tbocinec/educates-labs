#!/bin/bash
# Check schema compatibility

SCHEMA_REGISTRY_URL="http://localhost:8081"

if [ $# -lt 2 ]; then
    echo "Usage: ./check-compatibility.sh <subject-name> <schema-file>"
    echo "Example: ./check-compatibility.sh orders-value ../schemas/order-v2-compatible.avsc"
    exit 1
fi

SUBJECT=$1
SCHEMA_FILE=$2

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Schema file not found: $SCHEMA_FILE"
    exit 1
fi

echo "🔍 Checking compatibility for subject: $SUBJECT"
echo "📄 Schema file: $SCHEMA_FILE"
echo ""

# Read and compact the schema
SCHEMA=$(cat "$SCHEMA_FILE" | jq -c .)

# Check compatibility
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  "$SCHEMA_REGISTRY_URL/compatibility/subjects/$SUBJECT/versions/latest" \
  -d "{\"schema\": $(echo "$SCHEMA" | jq -Rs .)}")

# Parse result
IS_COMPATIBLE=$(echo "$RESPONSE" | jq -r '.is_compatible // empty')

if [ "$IS_COMPATIBLE" = "true" ]; then
    echo "✅ Schema is COMPATIBLE"
    echo ""
    echo "You can safely register this schema evolution."
elif [ "$IS_COMPATIBLE" = "false" ]; then
    echo "❌ Schema is NOT COMPATIBLE"
    echo ""
    echo "Messages:"
    echo "$RESPONSE" | jq -r '.messages[]? // "No detailed error message"'
    echo ""
    echo "This schema would break existing consumers!"
    exit 1
else
    echo "⚠️  Could not determine compatibility"
    echo "$RESPONSE" | jq .
    exit 1
fi

