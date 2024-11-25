#!/bin/bash

# CONFIGURATION
ENCRYPTION_DIR="encrypted_files"
DECRYPTION_DIR="decrypted_files"
PASSWORD_FILE="password.txt"  # For securely storing the password (optional)

# Ensure directories exist
mkdir -p "$ENCRYPTION_DIR" "$DECRYPTION_DIR"

# FUNCTIONS

# Encrypt files using OpenSSL
encrypt_files() {
    echo "Enter a password for encryption (or leave blank to use default):"
    read -s PASSWORD
    PASSWORD=${PASSWORD:-$(cat $PASSWORD_FILE 2>/dev/null || echo "default_password")}
    echo "Using password: $PASSWORD"

    echo "Enter files to encrypt (space-separated):"
    read -a FILES

    for FILE in "${FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            openssl enc -aes-256-cbc -salt -in "$FILE" -out "$ENCRYPTION_DIR/${FILE}.enc" -pass pass:"$PASSWORD"
            echo "Encrypted: $FILE -> $ENCRYPTION_DIR/${FILE}.enc"
        else
            echo "File not found: $FILE"
        fi
    done
}

# Decrypt files using OpenSSL
decrypt_files() {
    echo "Enter the decryption password:"
    read -s PASSWORD
    echo "Enter files to decrypt (space-separated):"
    read -a FILES

    for FILE in "${FILES[@]}"; do
        if [[ -f "$FILE" ]]; then
            OUTPUT_FILE=$(basename "$FILE" .enc)
            openssl enc -aes-256-cbc -d -in "$FILE" -out "$DECRYPTION_DIR/$OUTPUT_FILE" -pass pass:"$PASSWORD"
            echo "Decrypted: $FILE -> $DECRYPTION_DIR/$OUTPUT_FILE"
        else
            echo "File not found: $FILE"
        fi
    done
}

# Compress and encrypt multiple files
compress_and_encrypt() {
    echo "Enter a password for encryption (or leave blank to use default):"
    read -s PASSWORD
    PASSWORD=${PASSWORD:-$(cat $PASSWORD_FILE 2>/dev/null || echo "default_password")}
    echo "Using password: $PASSWORD"

    echo "Enter files to compress and encrypt (space-separated):"
    read -a FILES

    ARCHIVE_NAME="archive_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$ARCHIVE_NAME" "${FILES[@]}"
    openssl enc -aes-256-cbc -salt -in "$ARCHIVE_NAME" -out "$ENCRYPTION_DIR/$ARCHIVE_NAME.enc" -pass pass:"$PASSWORD"
    rm -f "$ARCHIVE_NAME"
    echo "Compressed and encrypted: $ENCRYPTION_DIR/$ARCHIVE_NAME.enc"
}

# Display menu
display_menu() {
    echo "Choose an option:"
    echo "1) Encrypt files"
    echo "2) Decrypt files"
    echo "3) Compress and encrypt files"
    echo "4) Exit"
    read -p "Enter your choice: " CHOICE

    case $CHOICE in
        1) encrypt_files ;;
        2) decrypt_files ;;
        3) compress_and_encrypt ;;
        4) exit 0 ;;
        *) echo "Invalid option!"; display_menu ;;
    esac
}

# MAIN SCRIPT
while true; do
    display_menu
done
