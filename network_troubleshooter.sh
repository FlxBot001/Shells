#!/bin/bash

# CONFIGURATION
HOSTS=("8.8.8.8" "1.1.1.1" "www.google.com")  # List of hosts to ping
DOMAINS=("google.com" "openai.com" "example.com")  # List of domains for DNS resolution
PORTS=("google.com:80" "github.com:443" "openai.com:22")  # List of domain:port pairs to check

REPORT_FILE="network_troubleshooting_report.txt"  # Report file name

# FUNCTIONS

# Function to check connectivity using ping
check_ping() {
    echo "== Pinging Hosts ==" | tee -a "$REPORT_FILE"
    for host in "${HOSTS[@]}"; do
        if ping -c 2 "$host" &>/dev/null; then
            echo "[SUCCESS] Ping to $host: Reachable" | tee -a "$REPORT_FILE"
        else
            echo "[FAILURE] Ping to $host: Unreachable" | tee -a "$REPORT_FILE"
        fi
    done
    echo "" | tee -a "$REPORT_FILE"
}

# Function to check DNS resolution
check_dns_resolution() {
    echo "== Checking DNS Resolution ==" | tee -a "$REPORT_FILE"
    for domain in "${DOMAINS[@]}"; do
        if nslookup "$domain" &>/dev/null; then
            echo "[SUCCESS] DNS resolution for $domain: Successful" | tee -a "$REPORT_FILE"
        else
            echo "[FAILURE] DNS resolution for $domain: Failed" | tee -a "$REPORT_FILE"
        fi
    done
    echo "" | tee -a "$REPORT_FILE"
}

# Function to check port availability
check_ports() {
    echo "== Checking Port Availability ==" | tee -a "$REPORT_FILE"
    for entry in "${PORTS[@]}"; do
        domain="${entry%:*}"
        port="${entry#*:}"
        if timeout 3 bash -c "echo > /dev/tcp/$domain/$port" &>/dev/null; then
            echo "[SUCCESS] Port $port on $domain: Open" | tee -a "$REPORT_FILE"
        else
            echo "[FAILURE] Port $port on $domain: Closed or Unreachable" | tee -a "$REPORT_FILE"
        fi
    done
    echo "" | tee -a "$REPORT_FILE"
}

# MAIN SCRIPT

# Prepare report file
echo "Network Troubleshooting Report" > "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run troubleshooting functions
check_ping
check_dns_resolution
check_ports

# Final message
echo "Network troubleshooting complete. See the report at $REPORT_FILE."
