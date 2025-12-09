#!/bin/bash
# List all subjects in Schema Registry

SCHEMA_REGISTRY_URL="http://localhost:8081"

echo "📋 Listing all subjects in Schema Registry..."
echo ""

SUBJECTS=$(curl -s "$SCHEMA_REGISTRY_URL/subjects")

if [ "$(echo "$SUBJECTS" | jq '. | length')" -eq 0 ]; then
    echo "No subjects found."
else
    echo "Subjects:"
    echo "$SUBJECTS" | jq -r '.[]' | while read subject; do
        # Get latest version
        LATEST=$(curl -s "$SCHEMA_REGISTRY_URL/subjects/$subject/versions/latest")
        VERSION=$(echo "$LATEST" | jq -r '.version')
        SCHEMA_ID=$(echo "$LATEST" | jq -r '.id')

        echo "  📦 $subject"
        echo "      Version: $VERSION"
        echo "      Schema ID: $SCHEMA_ID"
        echo ""
    done
fi

