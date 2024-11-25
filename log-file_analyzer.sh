#!/bin/bash

# CONFIGURATION
LOG_FILE="/path/to/logfile"  # Path to the log file (e.g., /var/log/syslog or /var/log/apache2/access.log)
REPORT_FILE="/path/to/report.txt"  # Path to save the report
EMAIL="admin@example.com"  # Email address to send the report
TOP_ENTRIES=10  # Number of top entries to include in the report
LOG_TYPE="apache"  # Type of log file: apache or syslog

# FUNCTIONS

# Log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") : $1"
}

# Analyze Apache logs
analyze_apache_logs() {
    log_message "Analyzing Apache log file..."

    echo "=== Apache Log Analysis Report ===" > "$REPORT_FILE"
    echo "Generated on: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Top 10 most accessed URLs
    echo "Top $TOP_ENTRIES Most Accessed URLs:" >> "$REPORT_FILE"
    awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n "$TOP_ENTRIES" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Top 10 IP addresses
    echo "Top $TOP_ENTRIES IP Addresses:" >> "$REPORT_FILE"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n "$TOP_ENTRIES" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Top 10 error codes
    echo "Top $TOP_ENTRIES Error Codes:" >> "$REPORT_FILE"
    awk '{print $9}' "$LOG_FILE" | grep -E '4[0-9]{2}|5[0-9]{2}' | sort | uniq -c | sort -rn | head -n "$TOP_ENTRIES" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    log_message "Apache log analysis complete."
}

# Analyze system logs
analyze_syslog() {
    log_message "Analyzing system log file..."

    echo "=== System Log Analysis Report ===" > "$REPORT_FILE"
    echo "Generated on: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Top 10 error messages
    echo "Top $TOP_ENTRIES Error Messages:" >> "$REPORT_FILE"
    grep -i "error" "$LOG_FILE" | awk '{for (i=5; i<=NF; i++) printf $i" "; print ""}' | sort | uniq -c | sort -rn | head -n "$TOP_ENTRIES" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Failed login attempts
    echo "Failed Login Attempts:" >> "$REPORT_FILE"
    grep -i "failed password" "$LOG_FILE" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Top 10 sources of failed logins
    echo "Top $TOP_ENTRIES Sources of Failed Logins:" >> "$REPORT_FILE"
    grep -i "failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -n "$TOP_ENTRIES" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    log_message "System log analysis complete."
}

# Send report via email
send_report() {
    log_message "Sending report to $EMAIL..."
    mail -s "Log Analysis Report" "$EMAIL" < "$REPORT_FILE"
    log_message "Report sent."
}

# MAIN SCRIPT

# Check if log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    log_message "Error: Log file $LOG_FILE not found!"
    exit 1
fi

# Analyze logs based on type
if [[ "$LOG_TYPE" == "apache" ]]; then
    analyze_apache_logs
elif [[ "$LOG_TYPE" == "syslog" ]]; then
    analyze_syslog
else
    log_message "Error: Unknown log type $LOG_TYPE. Use 'apache' or 'syslog'."
    exit 1
fi

# Optionally send report via email
read -p "Do you want to email the report? (y/n): " send_email
if [[ "$send_email" == "y" ]]; then
    send_report
fi

log_message "Log analysis completed. Report saved to $REPORT_FILE."
