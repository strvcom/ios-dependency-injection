#!/bin/bash

original=STRVTemplate
# Used for Keychain
keysOriginal=strv_template
updated=`echo $1 | sed 's/ /_/g'`
updated_lowercase=`echo $updated | tr '[:upper:]' '[:lower:]'`

echo "Starting renaming of STRVTemplate -> $1"

# Replace strings in all files (except specific directories)
echo "Replacing STRVTemplate in all files..."
find . -type f -not -path "./.git/*" -not -path "./.githooks*" -not -path "./Pods*" -not -path "./scripts*" -not -path "./vendor*" -not -path "./.bundle*"  -not -path "./Tuist/.build/*" -print0 | while IFS= read -r -d '' file; do
    # First, copy the file with its permissions
    cp "$file" "$file.tmp"
    sed "s/$original/$updated/g; s/$keysOriginal/$updated_lowercase/g" "$file" 2> /dev/null 1> "$file.tmp"
    size=`stat -f%z "$file.tmp"`
    if [ "$size" = "0" ]; then
        rm "$file.tmp"
    else
        rm "$file"
        mv "$file.tmp" "$file"
    fi
done

# Rename directories
echo "Renaming directories..."
find . -type d -name "*$original*" -print0 | while IFS= read -r -d '' file; do
    new=`echo "$file" | sed "s/$original/$updated/g"`
    mv "$file" "$new"
done

# Rename files
echo "Renaming files..."
find . -type f -name "*$original*" -print0 | while IFS= read -r -d '' file; do
    new=`echo "$file" | sed "s/$original/$updated/g"`
    mv "$file" "$new"
done

echo "Renaming process completed."