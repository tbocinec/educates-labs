#!/bin/bash
# Get or set compatibility mode for a subject

SCHEMA_REGISTRY_URL="http://localhost:8081"

if [ $# -lt 1 ]; then
    echo "Usage: ./compatibility-mode.sh <subject-name> [mode]"
    echo ""
    echo "Get mode: ./compatibility-mode.sh orders-value"
    echo "Set mode: ./compatibility-mode.sh orders-value BACKWARD"
    echo ""
    echo "Valid modes: BACKWARD, FORWARD, FULL, NONE"
    echo "             BACKWARD_TRANSITIVE, FORWARD_TRANSITIVE, FULL_TRANSITIVE"
    exit 1
fi

SUBJECT=$1
MODE=$2

if [ -z "$MODE" ]; then
    # Get current mode
    echo "🔍 Getting compatibility mode for subject: $SUBJECT"
    echo ""

    RESPONSE=$(curl -s "$SCHEMA_REGISTRY_URL/config/$SUBJECT")

    if echo "$RESPONSE" | jq -e '.compatibilityLevel' > /dev/null 2>&1; then
        LEVEL=$(echo "$RESPONSE" | jq -r '.compatibilityLevel')
        echo "Current mode: $LEVEL"
    else
        echo "Using global default mode"
        GLOBAL=$(curl -s "$SCHEMA_REGISTRY_URL/config")
        echo "$GLOBAL" | jq -r '.compatibilityLevel'
    fi
else
    # Set mode
    echo "⚙️  Setting compatibility mode for subject: $SUBJECT"
    echo "   New mode: $MODE"
    echo ""

    PAYLOAD=$(jq -n --arg mode "$MODE" '{compatibility: $mode}')

    RESPONSE=$(curl -s -X PUT \
      -H "Content-Type: application/vnd.schemaregistry.v1+json" \
      --data "$PAYLOAD" \
      "$SCHEMA_REGISTRY_URL/config/$SUBJECT")

    if echo "$RESPONSE" | jq -e '.compatibility' > /dev/null 2>&1; then
        echo "✅ Compatibility mode updated: $MODE"
    else
        echo "❌ Failed to set mode"
        echo "$RESPONSE" | jq .
        exit 1
    fi
fi

