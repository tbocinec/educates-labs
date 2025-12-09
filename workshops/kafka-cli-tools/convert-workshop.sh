#!/bin/bash
# Batch conversion script for Kafka CLI workshop files
# Converts Slovak to English and removes docker exec patterns

WORKSHOP_DIR="/home/bocinec/repo/educates-labs/workshops/kafka-cli-tools/workshop/content"

# Common replacements
declare -A REPLACEMENTS=(
    # Docker exec removal
    ["docker exec kafka-1 kafka-"]="kafka-"
    ["docker exec -i kafka-1 kafka-"]="kafka-"
    ["kafka-1:19092"]="localhost:19092"
    ["kafka-1:9092,kafka-2:9093,kafka-3:9094"]="\$BOOTSTRAP"
    ["localhost:9092,localhost:9093,localhost:9094"]="\$BOOTSTRAP"
    
    # Common Slovak to English translations
    ["Čo je"]="What is"
    ["Základná syntax"]="Basic Syntax"
    ["Vytvorenie témy"]="Create Topic"
    ["Posielanie správ"]="Send Messages"
    ["Čítanie správ"]="Read Messages"
    ["Zhrnutie"]="Summary"
    ["Ďalej"]="Next Steps"
    ["Use case"]="Use Case"
    ["Príklad"]="Example"
    ["Poznámka"]="Note"
    ["Dôležité"]="Important"
    ["Chyba"]="Error"
    ["Riešenie"]="Fix"
    ["Verifikácia"]="Verification"
    
    # Technical terms
    ["téma"]="topic"
    ["správa"]="message"
    ["partícia"]="partition"
    ["broker"]="broker"
    ["klaster"]="cluster"
    ["konfigurácia"]="configuration"
)

echo "Kafka CLI Workshop - Batch Conversion Tool"
echo "=========================================="
echo ""

# List files to convert
echo "Files to convert:"
ls -1 $WORKSHOP_DIR/*.md | grep -v "\-new.md"
echo ""

read -p "Do you want to proceed with conversion? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Conversion cancelled."
    exit 1
fi

# Process each file
for file in $WORKSHOP_DIR/*.md; do
    # Skip if already converted
    if [[ $file == *"-new.md" ]]; then
        continue
    fi
    
    filename=$(basename "$file")
    newfile="${file%.md}-new.md"
    
    echo "Processing: $filename"
    
    # Copy file
    cp "$file" "$newfile"
    
    # Apply replacements
    for search in "${!REPLACEMENTS[@]}"; do
        replace="${REPLACEMENTS[$search]}"
        sed -i "s|$search|$replace|g" "$newfile"
    done
    
    echo "  ✓ Created: $(basename $newfile)"
done

echo ""
echo "Conversion complete!"
echo ""
echo "Next steps:"
echo "1. Review each *-new.md file"
echo "2. Manually translate remaining Slovak text to English"
echo "3. Test each level in Educates"
echo "4. When satisfied, replace original files:"
echo "   for f in $WORKSHOP_DIR/*-new.md; do mv \"\$f\" \"\${f%-new.md}.md\"; done"
