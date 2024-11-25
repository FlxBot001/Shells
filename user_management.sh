#!/bin/bash

# CONFIGURATION
REPORT_FILE="/path/to/user_report.txt"  # Path to save the user report

# FUNCTIONS

# Log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $1"
}

# Add a new user
add_user() {
    read -p "Enter username: " username
    if id "$username" &>/dev/null; then
        log_message "Error: User '$username' already exists."
        return
    fi
    read -p "Enter group (leave blank for default): " group
    if [[ -n "$group" && ! $(getent group "$group") ]]; then
        log_message "Error: Group '$group' does not exist."
        return
    fi
    read -s -p "Enter password: " password
    echo
    sudo useradd -m -G "$group" -s /bin/bash "$username"
    echo "$username:$password" | sudo chpasswd
    log_message "User '$username' created successfully."
}

# Remove a user
remove_user() {
    read -p "Enter username to remove: " username
    if ! id "$username" &>/dev/null; then
        log_message "Error: User '$username' does not exist."
        return
    fi
    read -p "Do you want to remove the user's home directory as well? (y/n): " remove_home
    if [[ "$remove_home" == "y" ]]; then
        sudo userdel -r "$username"
        log_message "User '$username' and home directory removed successfully."
    else
        sudo userdel "$username"
        log_message "User '$username' removed successfully."
    fi
}

# Modify user details
modify_user() {
    read -p "Enter username to modify: " username
    if ! id "$username" &>/dev/null; then
        log_message "Error: User '$username' does not exist."
        return
    fi
    echo "1. Change password"
    echo "2. Add to a group"
    echo "3. Remove from a group"
    read -p "Choose an option: " option
    case $option in
    1)
        read -s -p "Enter new password: " password
        echo
        echo "$username:$password" | sudo chpasswd
        log_message "Password for '$username' updated successfully."
        ;;
    2)
        read -p "Enter group to add: " group
        sudo usermod -aG "$group" "$username"
        log_message "User '$username' added to group '$group'."
        ;;
    3)
        read -p "Enter group to remove: " group
        sudo gpasswd -d "$username" "$group"
        log_message "User '$username' removed from group '$group'."
        ;;
    *)
        log_message "Invalid option."
        ;;
    esac
}

# Generate user report
generate_report() {
    log_message "Generating user account report..."
    echo "=== User Account Report ===" > "$REPORT_FILE"
    echo "Generated on: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    awk -F':' '{print $1, $3, $7}' /etc/passwd | while read -r user uid shell; do
        if [[ "$uid" -ge 1000 && "$uid" -lt 60000 ]]; then
            last_login=$(lastlog -u "$user" | awk 'NR==2 {print $4, $5, $6}')
            if [[ -z "$last_login" ]]; then
                last_login="Never logged in"
            fi
            echo "User: $user | UID: $uid | Shell: $shell | Last Login: $last_login" >> "$REPORT_FILE"
        fi
    done
    log_message "Report saved to $REPORT_FILE."
}

# MAIN SCRIPT

echo "=== User Management System ==="
echo "1. Add a new user"
echo "2. Remove a user"
echo "3. Modify a user"
echo "4. Generate user report"
echo "5. Exit"
read -p "Choose an option: " choice

case $choice in
1)
    add_user
    ;;
2)
    remove_user
    ;;
3)
    modify_user
    ;;
4)
    generate_report
    ;;
5)
    log_message "Exiting User Management System."
    exit 0
    ;;
*)
    log_message "Invalid option. Exiting."
    exit 1
    ;;
esac
