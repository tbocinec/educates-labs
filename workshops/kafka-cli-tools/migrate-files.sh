#!/bin/bash
# Script to finalize workshop migration
# Run this after manual review of all -new.md files

CONTENT_DIR="/home/bocinec/repo/educates-labs/workshops/kafka-cli-tools/workshop/content"

echo "Kafka CLI Workshop - File Migration Script"
echo "==========================================="
echo ""

# Step 1: Backup originals
echo "Step 1: Creating backups..."
mkdir -p "$CONTENT_DIR/backup-$(date +%Y%m%d)"
cp $CONTENT_DIR/*.md "$CONTENT_DIR/backup-$(date +%Y%m%d)/"
echo "✓ Backed up to backup-$(date +%Y%m%d)/"
echo ""

# Step 2: Replace files
echo "Step 2: Replacing old files with new versions..."

# Map new files to their final names
declare -A FILE_MAP=(
    ["02-kafka-topics-new.md"]="02-kafka-topics.md"
    ["03-new.md"]="03-kafka-console-producer.md"
    ["04-new.md"]="04-kafka-console-consumer.md"
    ["05-new.md"]="05-kafka-consumer-groups.md"
)

for newfile in "${!FILE_MAP[@]}"; do
    oldfile="${FILE_MAP[$newfile]}"
    if [ -f "$CONTENT_DIR/$newfile" ]; then
        mv "$CONTENT_DIR/$newfile" "$CONTENT_DIR/$oldfile"
        echo "✓ $newfile → $oldfile"
    else
        echo "⚠ $newfile not found"
    fi
done

echo ""

# Step 3: Clean up duplicate -new.md files
echo "Step 3: Cleaning up duplicate files..."
rm -f $CONTENT_DIR/*-new.md
echo "✓ Removed all -new.md files"
echo ""

# Step 4: Verify structure
echo "Step 4: Verifying workshop structure..."
EXPECTED_FILES=(
    "00-workshop-overview.md"
    "01-cli-introduction.md"
    "02-kafka-topics.md"
    "03-kafka-console-producer.md"
    "04-kafka-console-consumer.md"
    "05-kafka-consumer-groups.md"
    "06-kafka-reassign-partitions.md"
    "07-kafka-log-dirs.md"
    "08-kafka-configs.md"
    "09-kafka-acls.md"
    "10-kafka-replication.md"
    "11-kafka-advanced-tools.md"
    "99-workshop-summary.md"
)

MISSING=0
for file in "${EXPECTED_FILES[@]}"; do
    if [ ! -f "$CONTENT_DIR/$file" ]; then
        echo "✗ Missing: $file"
        MISSING=$((MISSING+1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo "✓ All 13 workshop files present"
else
    echo "⚠ $MISSING files missing - workshop incomplete"
fi

echo ""
echo "Migration Status:"
echo "  Backups: $CONTENT_DIR/backup-$(date +%Y%m%d)/"
echo "  Files migrated: $(ls -1 $CONTENT_DIR/0*.md $CONTENT_DIR/99*.md 2>/dev/null | wc -l)/13"
echo ""
echo "Next steps:"
echo "1. Review remaining untranslated files (06-11)"
echo "2. Test workshop in Educates"
echo "3. If issues, restore from backup directory"
