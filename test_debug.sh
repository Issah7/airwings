#!/bin/bash

echo "=== DEBUGGING SCAN ISSUE ==="
echo "Checking if script is running as root: $(id -u)"
echo "EUID: $EUID"

# Check for monitor interface
echo ""
echo "Available wireless interfaces:"
iwconfig 2>/dev/null | grep "wlan" || echo "No wireless interfaces found"

# Check if MONITOR_INTERFACE is set
echo ""
echo "MONITOR_INTERFACE variable: ${MONITOR_INTERFACE:-not set}"
echo "SELECTED_INTERFACE variable: ${SELECTED_INTERFACE:-not set}"

# Test airodump-ng directly
echo ""
echo "Testing airodump-ng command:"
if command -v airodump-ng >/dev/null 2>&1; then
    echo "airodump-ng found at: $(which airodump-ng)"
    
    # Check if we can run it (without root for this test)
    echo "Testing airodump-ng execution (will fail without root but shows if it exists):"
    timeout 1 airodump-ng --help 2>&1 | head -3
else
    echo "airodump-ng NOT found!"
fi

echo ""
echo "=== END DEBUG ==="