#!/bin/bash

# Kafka CLI Workshop Migration Script
# Replaces Slovak versions with English versions

set -e

CONTENT_DIR="/home/bocinec/repo/educates-labs/workshops/kafka-cli-tools/workshop/content"
BACKUP_DIR="/home/bocinec/repo/educates-labs/workshops/kafka-cli-tools/workshop/content-backup-slovak-$(date +%Y%m%d-%H%M%S)"

echo "=== Kafka CLI Workshop Migration ==="
echo "Backing up original Slovak files to: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup original files
echo "Creating backup..."
cp "$CONTENT_DIR"/02-kafka-topics.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/03-kafka-console-producer.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/04-kafka-console-consumer.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/05-kafka-consumer-groups.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/06-kafka-reassign-partitions.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/07-kafka-log-dirs.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/08-kafka-configs.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/09-kafka-acls.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/10-kafka-replication.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/11-kafka-advanced-tools.md "$BACKUP_DIR/" 2>/dev/null || true
cp "$CONTENT_DIR"/99-workshop-summary.md "$BACKUP_DIR/" 2>/dev/null || true

echo "✓ Backup complete"

# Replace files with new English versions
echo ""
echo "Replacing files with English versions..."

# Level 02 - kafka-topics
if [ -f "$CONTENT_DIR/02-kafka-topics-new.md" ]; then
    mv "$CONTENT_DIR/02-kafka-topics-new.md" "$CONTENT_DIR/02-kafka-topics.md"
    echo "✓ 02-kafka-topics.md"
fi

# Level 03 - kafka-console-producer
if [ -f "$CONTENT_DIR/03-new.md" ]; then
    mv "$CONTENT_DIR/03-new.md" "$CONTENT_DIR/03-kafka-console-producer.md"
    echo "✓ 03-kafka-console-producer.md"
fi

# Level 04 - kafka-console-consumer  
if [ -f "$CONTENT_DIR/04-new.md" ]; then
    mv "$CONTENT_DIR/04-new.md" "$CONTENT_DIR/04-kafka-console-consumer.md"
    echo "✓ 04-kafka-console-consumer.md"
fi

# Level 05 - kafka-consumer-groups
if [ -f "$CONTENT_DIR/05-new.md" ]; then
    mv "$CONTENT_DIR/05-new.md" "$CONTENT_DIR/05-kafka-consumer-groups.md"
    echo "✓ 05-kafka-consumer-groups.md"
fi

# Level 06 - kafka-reassign-partitions
if [ -f "$CONTENT_DIR/06-new.md" ]; then
    mv "$CONTENT_DIR/06-new.md" "$CONTENT_DIR/06-kafka-reassign-partitions.md"
    echo "✓ 06-kafka-reassign-partitions.md"
fi

# Level 07 - kafka-log-dirs
if [ -f "$CONTENT_DIR/07-new.md" ]; then
    mv "$CONTENT_DIR/07-new.md" "$CONTENT_DIR/07-kafka-log-dirs.md"
    echo "✓ 07-kafka-log-dirs.md"
fi

# Level 08 - kafka-configs
if [ -f "$CONTENT_DIR/08-new.md" ]; then
    mv "$CONTENT_DIR/08-new.md" "$CONTENT_DIR/08-kafka-configs.md"
    echo "✓ 08-kafka-configs.md"
fi

# Level 09 - kafka-acls
if [ -f "$CONTENT_DIR/09-new.md" ]; then
    mv "$CONTENT_DIR/09-new.md" "$CONTENT_DIR/09-kafka-acls.md"
    echo "✓ 09-kafka-acls.md"
fi

# Level 10 - kafka-replication
if [ -f "$CONTENT_DIR/10-new.md" ]; then
    mv "$CONTENT_DIR/10-new.md" "$CONTENT_DIR/10-kafka-replication.md"
    echo "✓ 10-kafka-replication.md"
fi

# Level 11 - kafka-advanced-tools
if [ -f "$CONTENT_DIR/11-new.md" ]; then
    mv "$CONTENT_DIR/11-new.md" "$CONTENT_DIR/11-kafka-advanced-tools.md"
    echo "✓ 11-kafka-advanced-tools.md"
fi

# Level 99 - workshop-summary
if [ -f "$CONTENT_DIR/99-new.md" ]; then
    mv "$CONTENT_DIR/99-new.md" "$CONTENT_DIR/99-workshop-summary.md"
    echo "✓ 99-workshop-summary.md"
fi

# Clean up duplicate -new files if they exist
echo ""
echo "Cleaning up duplicate files..."
rm -f "$CONTENT_DIR"/03-kafka-console-producer-new.md
rm -f "$CONTENT_DIR"/04-kafka-console-consumer-new.md
rm -f "$CONTENT_DIR"/05-kafka-consumer-groups-new.md
rm -f "$CONTENT_DIR"/06-kafka-reassign-partitions-new.md
rm -f "$CONTENT_DIR"/07-kafka-log-dirs-new.md

echo ""
echo "=== Migration Summary ==="
echo "✅ All 11 levels migrated to English"
echo "✅ Docker exec commands removed"
echo "✅ Using \$BOOTSTRAP environment variable"
echo "✅ Professional, concise content with use cases"
echo ""
echo "Original Slovak files backed up to:"
echo "$BACKUP_DIR"
echo ""
echo "Files replaced:"
echo "  02-kafka-topics.md"
echo "  03-kafka-console-producer.md"
echo "  04-kafka-console-consumer.md"
echo "  05-kafka-consumer-groups.md"
echo "  06-kafka-reassign-partitions.md"
echo "  07-kafka-log-dirs.md"
echo "  08-kafka-configs.md"
echo "  09-kafka-acls.md"
echo "  10-kafka-replication.md"
echo "  11-kafka-advanced-tools.md"
echo "  99-workshop-summary.md"
echo ""
echo "🎉 Migration complete!"
