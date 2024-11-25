#!/bin/bash

# CONFIGURATION
BACKUP_SOURCE="/path/to/source/directory"  # Directory to back up
BACKUP_DESTINATION="/path/to/backup/destination"  # Local or mounted remote storage
REMOTE_SERVER="user@remote-server:/remote/backup/path"  # Remote server (optional)
MAX_BACKUPS=5  # Number of backups to keep
LOG_FILE="/var/log/backup_restore.log"  # Log file location
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")  # Current timestamp for versioning

# FUNCTIONS

# Log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $message" | tee -a "$LOG_FILE"
}

# Perform backup
backup() {
    log_message "Starting backup process..."

    # Create compressed backup
    local backup_file="$BACKUP_DESTINATION/backup_$TIMESTAMP.tar.gz"
    tar -czf "$backup_file" -C "$BACKUP_SOURCE" . && log_message "Backup created: $backup_file"

    # Optional: Sync to remote server
    if [[ -n "$REMOTE_SERVER" ]]; then
        log_message "Syncing backup to remote server..."
        rsync -avz "$backup_file" "$REMOTE_SERVER" && log_message "Backup synced to remote server."
    fi

    # Clean up old backups
    log_message "Cleaning up old backups..."
    local backup_count=$(ls -1 "$BACKUP_DESTINATION"/backup_*.tar.gz 2>/dev/null | wc -l)
    if (( backup_count > MAX_BACKUPS )); then
        ls -1t "$BACKUP_DESTINATION"/backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -d '\n' rm -f
        log_message "Old backups removed."
    fi

    log_message "Backup process completed."
}

# Restore from backup
restore() {
    log_message "Starting restore process..."

    # Prompt for backup file to restore
    echo "Available backups:"
    ls -1t "$BACKUP_DESTINATION"/backup_*.tar.gz
    read -p "Enter the backup file to restore (e.g., backup_YYYY-MM-DD_HH-MM-SS.tar.gz): " backup_file

    if [[ -f "$BACKUP_DESTINATION/$backup_file" ]]; then
        tar -xzf "$BACKUP_DESTINATION/$backup_file" -C "$BACKUP_SOURCE" && log_message "Restore completed from $backup_file"
    else
        log_message "Error: Backup file not found."
    fi
}

# MENU OPTIONS
menu() {
    echo "Backup and Restore Automation"
    echo "1. Perform Backup"
    echo "2. Restore from Backup"
    echo "3. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) backup ;;
        2) restore ;;
        3) exit 0 ;;
        *) echo "Invalid choice, please try again." ;;
    esac
}

# MAIN SCRIPT
while true; do
    menu
done
