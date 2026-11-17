#!/bin/bash

# Target folder to scan (defaults to current directory if none provided)
sourceFolder="${1:-.}"
foldername=$(basename "$(realpath "$sourceFolder")")

# Output folder
outputFolder="./AUDIT"
listFolder="$outputFolder/${foldername}_Lists"

# Create folder for output
mkdir -p "$listFolder"

# Prepare special files
noExtFile="$listFolder/noExt_Files.txt"
folderList="$listFolder/Folder_Paths.txt"

echo "Files with NO extension:" > "$noExtFile"
echo "Folder paths:" > "$folderList"

echo "Scanning folder: $sourceFolder"
echo ""

# Traverse the directory, excluding .git directories and Git files
while IFS= read -r item; do
    [[ "$item" == */LIB_LLMOUT || "$item" == */LIB_LLMOUT/* ]] && continue   # skip the done pile
    # Skip if inside a .git folder or matches git files
    if [[ "$item" == */.git* ]] || [[ "$(basename "$item")" == ".git" ]] || \
       [[ "$(basename "$item")" == ".gitignore" ]] || \
       [[ "$(basename "$item")" == ".gitattributes" ]] || \
       [[ "$(basename "$item")" == ".gitmodules" ]] || \
       [[ "$(basename "$item")" == ".gitkeep" ]]; then
        continue
    fi

    if [ -d "$item" ]; then
        echo "$item" >> "$folderList"
    elif [ -f "$item" ]; then
        filename=$(basename "$item")
        extension="${filename##*.}"

        # Check if file has no extension (and filename doesn't start with a dot like .bashrc)
        if [[ "$filename" != *.* ]] || [[ "$filename" == "."* && "$filename" != *.*.* ]]; then
            echo "$item" >> "$noExtFile"
        else
            extFile="$listFolder/${extension}_Files.txt"
            if [ ! -f "$extFile" ]; then
                echo "Files with extension .$extension:" > "$extFile"
            fi
            echo "$item" >> "$extFile"
        fi
    fi
done < <(find "$sourceFolder" -mindepth 1)

echo ""
echo "Output created in:"
echo "$listFolder"
echo ""

