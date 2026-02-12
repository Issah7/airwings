#!/bin/bash

# Test CSV parsing from airodump-ng
echo "Testing CSV parsing..."

# Create test scan
scan_file=$(mktemp -t test_csv.XXXXXX)
timeout 3 airodump-ng --output-format csv -w "$scan_file" wlan1 2>/dev/null &
scan_pid=$!
sleep 3
kill $scan_pid 2>/dev/null
wait $scan_pid 2>/dev/null

if [[ -f "${scan_file}-01.csv" ]]; then
    echo "CSV file contents:"
    echo "=================="
    cat "${scan_file}-01.csv" | head -20
    echo ""
    echo "Field analysis for first AP:"
    head -n 10 "${scan_file}-01.csv" | tail -n 1 | awk -F',' '{for(i=1;i<=NF;i++) print i": "$i}'
    
    rm -f "${scan_file}"*.csv
else
    echo "No CSV file generated"
fi