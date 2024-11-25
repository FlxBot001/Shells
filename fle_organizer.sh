#!/bin/bash

# CONFIGURATION
TARGET_DIR=${1:-"$HOME/Downloads"}  # Default target directory is Downloads if not specified
ORGANIZED_DIR="$TARGET_DIR/Organized"  # Directory to store organized files

# FILE TYPE CATEGORIES
declare -A FILE_CATEGORIES=(
    ["Images"]="jpg jpeg png gif bmp svg"
    ["Documents"]="txt pdf doc docx odt rtf"
    ["Videos"]="mp4 mkv avi mov wmv"
    ["Audio"]="mp3 wav flac aac ogg"
    ["Archives"]="zip tar gz bz2 7z rar"
    ["Code"]="py js html css cpp java php rb sh"
    ["Misc"]="*"
)

# FUNCTIONS

# Create directories for file types
create_directories() {
    mkdir -p "$ORGANIZED_DIR"
    for category in "${!FILE_CATEGORIES[@]}"; do
        mkdir -p "$ORGANIZED_DIR/$category"
    done
    echo "Directories created in $ORGANIZED_DIR."
}

# Move files to their respective directories
organize_files() {
    echo "Organizing files in $TARGET_DIR..."
    for category in "${!FILE_CATEGORIES[@]}"; do
        extensions=${FILE_CATEGORIES[$category]}
        for ext in $extensions; do
            if [[ $ext == "*" ]]; then
                find "$TARGET_DIR" -maxdepth 1 -type f ! -name "*.*" -exec mv {} "$ORGANIZED_DIR/$category/" \; 2>/dev/null
            else
                find "$TARGET_DIR" -maxdepth 1 -type f -iname "*.$ext" -exec mv {} "$ORGANIZED_DIR/$category/" \; 2>/dev/null
            fi
        done
    done
    echo "Files have been organized."
}

# Handle duplicate files
handle_duplicates() {
    echo "Checking for duplicate files..."
    for dir in "$ORGANIZED_DIR"/*; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*; do
                basename=$(basename "$file")
                if [[ -f "$dir/$basename" ]]; then
                    timestamp=$(date +"%Y%m%d%H%M%S")
                    mv "$file" "$dir/${basename%.*}_$timestamp.${basename##*.}"
                fi
            done
        fi
    done
    echo "Duplicate files have been renamed."
}

# Display usage information
usage() {
    echo "Usage: $0 [TARGET_DIRECTORY]"
    echo "If no directory is specified, the default is $HOME/Downloads."
}

# MAIN SCRIPT

# Ensure the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Target directory $TARGET_DIR does not exist."
    usage
    exit 1
fi

# Run the script
create_directories
organize_files
handle_duplicates
echo "File organization complete. Organized files are in $ORGANIZED_DIR."
