#!/bin/bash

# CONFIGURATION
# --------------------------------------------------------------
# Thresholds (you can modify these values as per your requirement)
CPU_THRESHOLD=80      # CPU usage threshold in percentage
MEMORY_THRESHOLD=80   # Memory usage threshold in percentage
DISK_THRESHOLD=80     # Disk space threshold in percentage
NET_THRESHOLD=80      # Network traffic threshold (in MB)
ALERT_EMAIL="flxnjgn.greylock@gmail.com"  # Email to send alerts to
LOG_FILE="/var/log/system_monitor.log"  # Log file location

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Usage: $CPU_USAGE%"

    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        alert "High CPU usage detected: $CPU_USAGE%"
    fi
}

# Function to check memory usage
check_memory() {
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo "Memory Usage: $MEMORY_USAGE%"

    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        alert "High memory usage detected: $MEMORY_USAGE%"
    fi
}

# Function to check disk usage
check_disk() {
    DISK_USAGE=$(df -h | grep '/$' | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: $DISK_USAGE%"

    if (( DISK_USAGE > DISK_THRESHOLD )); then
        alert "High disk usage detected: $DISK_USAGE%"
    fi
}

# Function to check network traffic (example checks bytes received)
check_network() {
    NET_USAGE=$(ifstat -i eth0 1 1 | tail -n 1 | awk '{print $1}')
    NET_USAGE_MB=$(echo "$NET_USAGE / 1024 / 1024" | bc -l)  # Convert to MB
    echo "Network Traffic: $NET_USAGE_MB MB/s"

    if (( $(echo "$NET_USAGE_MB > $NET_THRESHOLD" | bc -l) )); then
        alert "High network traffic detected: $NET_USAGE_MB MB/s"
    fi
}

# Function to send alerts via email or log to file
alert() {
    MESSAGE="$1"
    echo "$(date): $MESSAGE" | tee -a $LOG_FILE

    # Send email alert (requires mail utility configured)
    echo "$MESSAGE" | mail -s "System Alert: $MESSAGE" $ALERT_EMAIL
}

# Main monitoring function
monitor_system() {
    echo "Starting system monitoring..."

    while true; do
        check_cpu
        check_memory
        check_disk
        check_network
        sleep 60  # Check every minute
    done
}

# Function to monitor multiple servers
monitor_multiple_servers() {
    SERVERS=("server1.example.com" "server2.example.com")  # Add your servers here

    for SERVER in "${SERVERS[@]}"; do
        echo "Monitoring server: $SERVER"
        ssh user@$SERVER "bash -s" < "$0"  # Execute the script remotely
    done
}

# Check if we need to monitor multiple servers
if [ "$1" == "multi" ]; then
    monitor_multiple_servers
else
    monitor_system
fi
