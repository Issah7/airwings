#!/bin/bash

# Network scanning module

# Scanning menu
scanner_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                    NETWORK SCANNING                      ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} Quick Scan                ${GRAY}Basic network discovery${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Detailed Scan             ${GRAY}Comprehensive scanning${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} Channel Scan              ${GRAY}Scan specific channels${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} WPS Networks              ${GRAY}Find WPS-enabled networks${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} 5GHz Networks             ${GRAY}Scan 5GHz band only${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} Client Monitoring         ${GRAY}Monitor connected clients${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[7]${WHITE} Save Scan Results         ${GRAY}Export scan data${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[8]${WHITE} Scan History              ${GRAY}View previous scans${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[9]${WHITE} Live Airodump (new term)  ${GRAY}Open a live airodump in a new terminal${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE} Back to Main Menu         ${GRAY}Return${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""

        read -p "Select an option: " choice

        case $choice in
            1) quick_scan ;;
            2) detailed_scan ;;
            3) channel_scan ;;
            4) wps_scan ;;
            5) five_ghz_scan ;;
            6) client_monitoring ;;
            7) save_scan_results ;;
            8) scan_history ;;
            9) live_airodump ;;
            0) break ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# Quick scan
quick_scan() {
    clear
    echo -e "${BLUE}Quick Network Scan${NC}"
    echo -e "${GRAY}=================${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if [[ ! -e "/sys/class/net/$interface" ]]; then
        echo -e "${RED}[!] Interface $interface not found${NC}"
        echo -e "${YELLOW}[!] Use Interface Management menu to select or enable monitor mode${NC}"
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        echo -e "${YELLOW}[!] Use Interface Management menu to enable monitor mode${NC}"
        pause
        return
    fi

    echo -e "${YELLOW}[*] Starting quick scan (15 seconds)...${NC}"
    echo ""

    # Kill any existing airodump-ng processes to prevent hanging
    pkill -f airodump-ng 2>/dev/null
    sleep 2

    rm -f /tmp/airodump.* 2>/dev/null

    local temp_file
    temp_file=$(mktemp /tmp/airodump.XXXXXX)

    timeout 17 airodump-ng -w "$temp_file" --output-format csv "$interface" &>/dev/null &
    local scan_pid=$!

    for i in $(seq 1 15); do
        echo -ne "\r${YELLOW}[*] Scanning... ${i}/15s${NC}"
        sleep 1
    done
    echo ""

    kill $scan_pid 2>/dev/null
    wait $scan_pid 2>/dev/null
    sleep 1

    if [[ -f "${temp_file}-01.csv" ]]; then
        parse_and_display_scan "${temp_file}-01.csv"
        rm -f "${temp_file}"*
    else
        echo -e "${RED}[!] Scan failed - no data collected${NC}"
    fi

    pause
}

# Detailed scan
detailed_scan() {
    clear
    echo -e "${BLUE}Detailed Network Scan${NC}"
    echo -e "${GRAY}=====================${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        pause
        return
    fi

    read -p "Enter scan duration in seconds [default: 60]: " duration
    duration=${duration:-60}

    echo -e "${YELLOW}[*] Starting detailed scan for $duration seconds...${NC}"
    echo ""

    # Kill any existing airodump-ng processes to prevent hanging
    pkill -f airodump-ng 2>/dev/null
    sleep 2

    local temp_file
    temp_file=$(mktemp /tmp/airodump.XXXXXX)

    timeout $((duration + 2)) airodump-ng -w "$temp_file" --output-format csv --manufacturer "$interface" &>/dev/null &
    local scan_pid=$!

    for i in $(seq 1 "$duration"); do
        echo -ne "\r${YELLOW}[*] Scanning... ${i}/${duration}s${NC}"
        sleep 1
    done
    echo ""

    kill $scan_pid 2>/dev/null
    wait $scan_pid 2>/dev/null
    sleep 1

    if [[ -f "${temp_file}-01.csv" ]]; then
        parse_and_display_scan "${temp_file}-01.csv" "detailed"
        rm -f "${temp_file}"*
    else
        echo -e "${RED}[!] Scan failed - no data collected${NC}"
    fi

    pause
}

# Channel scan
channel_scan() {
    clear
    echo -e "${BLUE}Channel Scan${NC}"
    echo -e "${GRAY}=============${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        pause
        return
    fi

    echo -e "${WHITE}Select Channel Range:${NC}"
    echo -e "${CYAN}[1]${NC} 2.4GHz only (1-14)"
    echo -e "${CYAN}[2]${NC} 5GHz only (36-165)"
    echo -e "${CYAN}[3]${NC} Custom range"
    echo -e "${CYAN}[4]${NC} Single channel"
    echo ""

    read -p "Select option: " channel_choice

    case $channel_choice in
        1) start_chan=1; end_chan=14 ;;
        2) start_chan=36; end_chan=165 ;;
        3) read -p "Start channel: " start_chan; read -p "End channel: " end_chan ;;
        4) read -p "Channel: " single_chan; start_chan=$single_chan; end_chan=$single_chan ;;
        *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1; return ;;
    esac

    echo -e "${YELLOW}[*] Scanning channels $start_chan to $end_chan...${NC}"
    echo ""

    # Kill any existing airodump-ng processes to prevent hanging
    pkill -f airodump-ng 2>/dev/null
    sleep 2

    local temp_file
    temp_file=$(mktemp /tmp/airodump.XXXXXX)

    for ((channel=start_chan; channel<=end_chan; channel++)); do
        if is_valid_channel "$channel"; then
            echo -ne "\r${YELLOW}[*] Scanning channel $channel...${NC}   "
            timeout 7 airodump-ng -c "$channel" -w "${temp_file}_${channel}" --output-format csv "$interface" &>/dev/null &
            local ch_pid=$!
            sleep 5
            kill $ch_pid 2>/dev/null
            wait $ch_pid 2>/dev/null
        fi
    done
    echo ""

    echo -e "${YELLOW}[*] Scan completed. Compiling results...${NC}"

    local compiled_file
    compiled_file="${temp_file}_compiled.csv"
    echo "BSSID,First time seen,Last time seen,Channel,Speed,Privacy,Cipher,Authentication,Power,# beacons,# IV,LAN IP,ID-length,ESSID,Key" > "$compiled_file"

    for ((channel=start_chan; channel<=end_chan; channel++)); do
        if [[ -f "${temp_file}_${channel}-01.csv" ]]; then
            tail -n +2 "${temp_file}_${channel}-01.csv" >> "$compiled_file"
        fi
    done

    if [[ -s "$compiled_file" ]]; then
        parse_and_display_scan "$compiled_file"
    else
        echo -e "${RED}[!] No networks found${NC}"
    fi

    rm -f "${temp_file}"*

    pause
}

# WPS scan
wps_scan() {
    clear
    echo -e "${BLUE}WPS Network Scan${NC}"
    echo -e "${GRAY}=================${NC}"

    if ! command -v wash &> /dev/null; then
        echo -e "${RED}[!] wash not found. Install reaver package.${NC}"
        pause
        return
    fi

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        pause
        return
    fi

    echo -e "${YELLOW}[*] Scanning for WPS-enabled networks...${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop scanning${NC}"
    echo ""

    # Clean up any existing wash processes
    pkill -f wash 2>/dev/null
    sleep 1

    # Run wash with visible output and timeout
    timeout 60 wash -i "$interface" -C || {
        echo ""
        echo -e "${YELLOW}[!] Scan completed or interrupted${NC}"
    }

    echo ""
    pause
}

# 5GHz scan
five_ghz_scan() {
    clear
    echo -e "${BLUE}5GHz Network Scan${NC}"
    echo -e "${GRAY}==================${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        pause
        return
    fi

    echo -e "${YELLOW}[*] Scanning 5GHz bands (36-165)...${NC}"
    echo ""

    # Kill any existing airodump-ng processes to prevent hanging
    pkill -f airodump-ng 2>/dev/null
    sleep 2

    local temp_file
    temp_file=$(mktemp /tmp/airodump.XXXXXX)

    timeout 32 airodump-ng --band a -w "$temp_file" --output-format csv "$interface" &>/dev/null &
    local scan_pid=$!

    for i in $(seq 1 30); do
        echo -ne "\r${YELLOW}[*] Scanning... ${i}/30s${NC}"
        sleep 1
    done
    echo ""

    kill $scan_pid 2>/dev/null
    wait $scan_pid 2>/dev/null
    sleep 1

    if [[ -f "${temp_file}-01.csv" ]]; then
        parse_and_display_scan "${temp_file}-01.csv"
    else
        echo -e "${RED}[!] No 5GHz networks found${NC}"
    fi

    rm -f "${temp_file}"*

    pause
}

# Client monitoring
client_monitoring() {
    clear
    echo -e "${BLUE}Client Monitoring${NC}"
    echo -e "${GRAY}=================${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi

    if ! is_monitor_mode "$interface"; then
        echo -e "${RED}[!] Interface $interface is not in monitor mode${NC}"
        pause
        return
    fi

    read -p "Enter target BSSID (leave empty for all): " target_bssid
    read -p "Enter channel [1-165]: " channel

    if [[ -n "$target_bssid" ]]; then
        if ! is_valid_mac "$target_bssid"; then
            echo -e "${RED}[!] Invalid BSSID format${NC}"
            sleep 1
            return
        fi
    fi

    if [[ -n "$channel" ]] && ! is_valid_channel "$channel"; then
        echo -e "${RED}[!] Invalid channel${NC}"
        sleep 1
        return
    fi

    echo -e "${YELLOW}[*] Monitoring clients...${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop${NC}"
    echo ""

    local timestamp
    timestamp=$(date +%s)
    local out_file
    out_file="/tmp/airodump.${timestamp}"
    local cmd
    cmd="airodump-ng -w ${out_file} --output-format csv $interface"

    if [[ -n "$channel" ]]; then
        cmd="$cmd -c $channel"
    fi

    if [[ -n "$target_bssid" ]]; then
        cmd="$cmd --bssid $target_bssid"
    fi

    # Launch airodump in a separate terminal/session
    if type open_in_terminal &>/dev/null; then
        open_in_terminal "$cmd"
    else
        eval "$cmd" &
    fi

    pause
}

# Open a live airodump in a new terminal (non-blocking)
live_airodump() {
    clear
    echo -e "${BLUE}Live Airodump (new terminal)${NC}"
    echo -e "${GRAY}==============================${NC}"

    local interface=$(get_monitor_interface)

    if [[ -z "$interface" ]]; then
        error "No monitor mode interface found. Please enable monitor mode first."
        pause
        return
    fi
    read -p "Interface [${interface}]: " iface_in
    interface=${iface_in:-$interface}

    read -p "Channel (optional): " channel
    read -p "BSSID (optional): " bssid

    local timestamp
    timestamp=$(date +%s)
    local out_file="/tmp/airodump.${timestamp}"

    local cmd="airodump-ng -w ${out_file} --output-format csv ${interface}"
    if [[ -n "$channel" ]]; then
        cmd="$cmd -c $channel"
    fi
    if [[ -n "$bssid" ]]; then
        cmd="$cmd --bssid $bssid"
    fi

    if type open_in_terminal &>/dev/null; then
        open_in_terminal "$cmd"
    else
        echo "Starting: $cmd"
        eval "$cmd" &
    fi

    echo -e "${YELLOW}[*] Launched airodump in separate terminal. Files: ${out_file}-01.csv${NC}"
    pause
}

# Save scan results
save_scan_results() {
    clear
    echo -e "${BLUE}Save Scan Results${NC}"
    echo -e "${GRAY}==================${NC}"

    read -p "Enter filename (without extension): " filename

    if [[ -z "$filename" ]]; then
        filename="scan_$(get_timestamp)"
    fi

    local output_dir
    output_dir="$LOGS_DIR/scans"
    mkdir -p "$output_dir"

    local latest_scan
    latest_scan=$(ls -t /tmp/airodump*.csv 2>/dev/null | head -1)

    if [[ -f "$latest_scan" ]]; then
        cp "$latest_scan" "$output_dir/${filename}.csv"
        parse_and_display_scan "$latest_scan" > "$output_dir/${filename}.txt"
        success "Scan results saved to:"
        echo -e "  $output_dir/${filename}.csv"
        echo -e "  $output_dir/${filename}.txt"
    else
        echo -e "${RED}[!] No scan results found to save${NC}"
        echo -e "${YELLOW}[!] Run a scan first${NC}"
    fi

    pause
}

# Scan history
scan_history() {
    clear
    echo -e "${BLUE}Scan History${NC}"
    echo -e "${GRAY}=============${NC}"

    local scan_dir
    scan_dir="$LOGS_DIR/scans"

    if [[ ! -d "$scan_dir" ]]; then
        echo -e "${YELLOW}[!] No scan history found${NC}"
        pause
        return
    fi

    ls -lt "$scan_dir"/*.txt 2>/dev/null | while read -r line; do
        filename=$(echo "$line" | awk '{print $9}')
        basename=$(basename "$filename" .txt)
        size=$(get_file_size "$filename")
        echo -e "${CYAN}$basename${NC} (${size}) - $(echo "$line" | awk '{print $6, $7, $8}')"
    done

    echo ""
    read -p "Enter scan name to view (or 0 to go back): " scan_choice

    if [[ "$scan_choice" != "0" && -n "$scan_choice" ]]; then
        if [[ -f "$scan_dir/${scan_choice}.txt" ]]; then
            clear
            echo -e "${BLUE}Viewing Scan: $scan_choice${NC}"
            echo -e "${GRAY}================================${NC}"
            cat "$scan_dir/${scan_choice}.txt"
            pause
        else
            echo -e "${RED}[!] Scan not found${NC}"
            sleep 1
        fi
    fi
}

# Parse and display scan results
parse_and_display_scan() {
    local csv_file="$1"
    local display_mode="${2:-basic}"

    if [[ ! -f "$csv_file" ]]; then
        echo -e "${RED}[!] CSV file not found${NC}"
        return 1
    fi

    echo -e "${BLUE}Scan Results:${NC}"
    echo -e "${GRAY}=============${NC}"

    if [[ "$display_mode" == "detailed" ]]; then
        printf "%s%-20s %-10s %-10s %-10s %-15s %-10s %-10s %-20s%s\n" "$WHITE" "BSSID" "Channel" "Speed" "Power" "Encryption" "Cipher" "Auth" "ESSID" "$NC"
        echo -e "${GRAY}--------------------------------------------------------------------------------${NC}"
        tail -n +2 "$csv_file" | while IFS=',' read -r bssid ft lt ch speed priv cipher auth power beacons ivs lan ipid essid key; do
            if [[ -n "$bssid" && "$bssid" != "Station MAC" ]]; then
                printf "%-20s %-10s %-10s %-10s %-15s %-10s %-10s %-20s\n" "$bssid" "$ch" "$speed" "$power" "$priv" "$cipher" "$auth" "${essid:-}"
            fi
        done
    else
        printf "%s%-20s %-8s %-8s %-15s %-20s%s\n" "$WHITE" "BSSID" "Channel" "Power" "Encryption" "ESSID" "$NC"
        echo -e "${GRAY}-----------------------------------------------------${NC}"
        tail -n +2 "$csv_file" | while IFS=',' read -r bssid ft lt ch speed priv cipher auth power beacons ivs lan ipid essid key; do
            if [[ -n "$bssid" && "$bssid" != "Station MAC" ]]; then
                printf "%-20s %-8s %-8s %-15s %-20s\n" "$bssid" "$ch" "$power" "$priv" "${essid:-}"
            fi
        done
    fi

    echo ""

    local total_networks
    total_networks=$(tail -n +2 "$csv_file" | grep -v "Station MAC" | wc -l)
    local wpa_networks
    wpa_networks=$(tail -n +2 "$csv_file" | grep -E "WPA( |$)" | wc -l)
    local wpa2_networks
    wpa2_networks=$(tail -n +2 "$csv_file" | grep "WPA2" | wc -l)
    local open_networks
    open_networks=$(tail -n +2 "$csv_file" | grep -E "OPN|Open" | wc -l)

    echo -e "${WHITE}Scan Statistics:${NC}"
    echo -e "• Total networks found: $total_networks"
    echo -e "• WPA networks: $wpa_networks"
    echo -e "• WPA2 networks: $wpa2_networks"
    echo -e "• Open networks: $open_networks"

    return 0
}
