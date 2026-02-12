#!/bin/bash

# Debug script to check airodump-ng CSV output
INTERFACE="${1:-wlan0mon}"

echo "Testing airodump-ng on interface: $INTERFACE"

# Check if interface exists
if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist!"
    exit 1
fi

# Check if interface is in monitor mode
if ! iwconfig "$INTERFACE" 2>/dev/null | grep -q "Mode:Monitor"; then
    echo "Warning: Interface $INTERFACE is not in monitor mode!"
    echo "Current mode: $(iwconfig "$INTERFACE" 2>/dev/null | grep Mode | awk '{print $1,$2,$3,$4}')"
fi

# Run a short scan
echo "Running 5 second scan..."
scan_file=$(mktemp -t test_scan.XXXXXX)
timeout 5 airodump-ng --output-format csv -w "$scan_file" "$INTERFACE" 2>&1 &
scan_pid=$!

sleep 5
kill $scan_pid 2>/dev/null
wait $scan_pid 2>/dev/null

if [[ -f "${scan_file}-01.csv" ]]; then
    echo "Scan completed. CSV file contents:"
    echo "==================================="
    cat "${scan_file}-01.csv"
    echo ""
    echo "==================================="
    echo "File size: $(wc -l < "${scan_file}-01.csv") lines"
    
    # Count APs
    grep -c "^[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]" "${scan_file}-01.csv" 2>/dev/null || echo "No valid MAC addresses found"
    
    rm -f "${scan_file}"*.csv "${scan_file}"*.kismet* 2>/dev/null
else
    echo "Error: No CSV file generated!"
    echo "airodump-ng output:"
    timeout 5 airodump-ng "$INTERFACE" 2>&1 | head -20
fi