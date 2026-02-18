#!/bin/bash

# ESP8266 Deauther module - Serial Command Integration
# Supports Spacehuhn ESP8266 Deauther firmware (v2.x)
# Serial commands: scan, show, select, deauth, beacon, probe, stop, sysinfo, etc.

# Default serial settings
ESP8266_PORT="${ESP8266_PORT:-/dev/ttyUSB0}"
ESP8266_BAUD="${ESP8266_BAUD:-115200}"
ESP_SSID_FILE="${AIRWINGS_DIR:-$(dirname "$0")/..}/data/esp_ssids.txt"

# ══════════════════════════════════════════════════════════════════════════════
# Serial Communication Engine (using Python pyserial)
# ══════════════════════════════════════════════════════════════════════════════

ESP_COM="${AIRWINGS_DIR:-$(dirname "$0")/..}/utils/esp_com.py"

esp_list_ports() {
    python3 "$ESP_COM" list 2>/dev/null | tr -d '\0'
}

# Auto-detect ESP8266 serial port
esp_detect_port() {
    local detected=""

    while IFS= read -r port; do
        [[ -z "$port" ]] && continue
        [[ ! -e "$port" ]] && continue

        if python3 "$ESP_COM" check "$port" "$ESP8266_BAUD" 2>/dev/null | grep -q "heap\|free\|ram"; then
            detected="$port"
            break
        fi
    done < <(python3 "$ESP_COM" list 2>/dev/null | tr -d '\0')

    printf "%s" "$detected"
}

# Select or detect ESP8266 port interactively
esp_select_port() {
    local devices=()
    while IFS= read -r port; do
        [[ -n "$port" ]] && devices+=("$port")
    done < <(esp_list_ports)

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

        if [[ "$choice" -ge 1 && "$choice" -le ${#devices[@]} ]]; then
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

    python3 "$ESP_COM" send "$port" "$ESP8266_BAUD" "$cmd" "$wait_time" 2>/dev/null
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

    python3 "$ESP_COM" send "$port" "$ESP8266_BAUD" "$cmd" "$wait_time" 2>/dev/null | while IFS= read -r line; do
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

    python3 "$ESP_COM" check "$port" "$ESP8266_BAUD" 2>/dev/null
}

# Verify connection before running attacks (used by all attack functions)
esp_require_connection() {
    local port="${ESP8266_PORT:-/dev/ttyUSB0}"
    
    if [[ -z "$port" || "$port" == "/dev/" ]]; then
        echo -e "${YELLOW}[*] No port set, attempting auto-detection...${NC}"
        local detected=$(esp_detect_port)
        if [[ -n "$detected" ]]; then
            ESP8266_PORT="$detected"
            port="$detected"
            echo -e "${GREEN}[✓] Found ESP8266 on $ESP8266_PORT${NC}"
        else
            echo -e "${RED}[!] No ESP8266 device found${NC}"
            echo "  - Check USB connection"
            echo "  - Device is powered on"
            echo "  - Deauther firmware is flashed"
            return 1
        fi
    elif ! esp_check_connection "$port"; then
        echo -e "${RED}[!] ESP8266 not responding on $port${NC}"
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
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE}  Huhnitor                 ${GRAY}Advanced CLI interface          ${BLUE}│${NC}"
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
            3) esp_huhnitor ;;
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
    echo -e "${BLUE}Flash ESP8266 Deauther Firmware${NC}"
    echo -e "${GRAY}===================================${NC}"

    if ! command -v esptool.py &>/dev/null && ! command -v esptool &>/dev/null; then
        echo -e "${RED}[!] esptool not found${NC}"
        echo ""
        read -p "Install esptool now? (Y/n): " install_esptool
        if [[ ! "$install_esptool" =~ ^[Nn]$ ]]; then
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y esptool
            else
                pip3 install --break-system-packages esptool 2>/dev/null || pip3 install esptool
            fi
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}[!] Failed to install esptool${NC}"
                pause
                return
            fi
        else
            pause
            return
        fi
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
            echo -e "${YELLOW}[*] Downloading latest Deauther nightly firmware...${NC}"
            echo ""
            echo -e "${WHITE}Downloading ESP8266 Deauther V3 (1M flash)${NC}"

            local dl_url="https://github.com/SpacehuhnTech/nightly-deauther/releases/download/nightly/esp8266_deauther_V3_1M_Nightly.bin"
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
        $esptool_cmd -p "$ESP8266_PORT" -b 115200 write_flash 0 "$firmware_file"

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
# 2. Serial Terminal - Web-based
# ══════════════════════════════════════════════════════════════════════════════

esp_serial_terminal() {
    clear
    echo -e "${BLUE}ESP8266 Serial Terminal${NC}"
    echo -e "${GRAY}========================${NC}"
    echo ""

    echo -e "${WHITE}Using web-based serial terminal from spacehuhn.com${NC}"
    echo ""
    echo -e "${CYAN}Instructions:${NC}"
    echo "  1. Connect your ESP8266 via USB"
    echo "  2. Select the correct serial port in the web terminal"
    echo "  3. Use 115200 baud rate"
    echo ""
    echo -e "${YELLOW}Opening web terminal in browser...${NC}"
    echo ""

    if command -v xdg-open &>/dev/null; then
        xdg-open "https://terminal.spacehuhn.com/"
    elif command -v firefox &>/dev/null; then
        firefox "https://terminal.spacehuhn.com/"
    elif command -v google-chrome &>/dev/null; then
        google-chrome "https://terminal.spacehuhn.com/"
    else
        echo -e "${YELLOW}Please open this URL in your browser:${NC}"
        echo -e "${GREEN}https://terminal.spacehuhn.com/${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Press Enter when done with terminal...${NC}"
    read

    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. Huhnitor - Advanced CLI (via Snap)
# ══════════════════════════════════════════════════════════════════════════════

esp_huhnitor() {
    clear
    echo -e "${BLUE}Huhnitor - Advanced ESP8266 CLI${NC}"
    echo -e "${GRAY}================================${NC}"
    echo ""

    # Add snap to PATH if not already
    if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
        export PATH="$PATH:/snap/bin"
    fi

    if ! command -v huhnitor &>/dev/null; then
        echo -e "${RED}[!] huhnitor not found${NC}"
        echo ""
        echo -e "${YELLOW}Installing huhnitor via snap...${NC}"
        echo ""

        if ! command -v snap &>/dev/null; then
            echo -e "${YELLOW}Installing snapd...${NC}"
            if command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y snapd
            else
                echo -e "${RED}[!] Cannot install snap. Please install snapd manually.${NC}"
                pause
                return
            fi
        fi

        echo -e "${YELLOW}[*] Installing huhnitor...${NC}"
        sudo snap install huhnitor --edge --devmode

        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[!] Failed to install huhnitor${NC}"
            echo "Try running: sudo snap install huhnitor --edge --devmode"
            pause
            return
        fi
    fi

    # Find available terminal emulator
    launch_terminal() {
        local cmd="$1"
        
        if command -v gnome-terminal &>/dev/null; then
            gnome-terminal -- "$cmd"
        elif command -v konsole &>/dev/null; then
            konsole -e "$cmd"
        elif command -v xfce4-terminal &>/dev/null; then
            xfce4-terminal -x "$cmd"
        elif command -v tilix &>/dev/null; then
            tilix -x "$cmd"
        elif command -v mate-terminal &>/dev/null; then
            mate-terminal -x "$cmd"
        elif command -v xterm &>/dev/null; then
            xterm -e "$cmd"
        else
            echo -e "${YELLOW}[!] No terminal emulator found${NC}"
            echo "Install gnome-terminal, konsole, xfce4-terminal, or xterm"
            return 1
        fi
        return 0
    }

    echo -e "${GREEN}[✓] Huhnitor ready${NC}"
    echo ""
    echo -e "${YELLOW}[*] Launching huhnitor in new terminal...${NC}"
    echo ""

    # Show commands help
    echo -e "${CYAN}Huhnitor Commands:${NC}"
    echo "  scan / scan -m ap+st   - Scan for APs and stations"
    echo "  results / results -type ap   - Show scan results"
    echo "  select <index>         - Select target"
    echo "  deauth                 - Start deauth attack"
    echo "  beacon -ssid <name>   - Send beacon frames"
    echo "  probe -ssid <name>    - Send probe requests"
    echo "  ap -s <ssid> -p <pwd> - Start access point"
    echo "  stop                   - Stop all attacks"
    echo "  sysinfo / ram         - Show system info"
    echo "  help                   - Show all commands"
    echo ""
    echo -e "${CYAN}Note:${NC} Enter your sudo password in the new terminal window"
    echo ""

    # Launch huhnitor in new terminal with sudo
    if [[ -x "/snap/bin/huhnitor" ]]; then
        launch_terminal "sudo /snap/bin/huhnitor" || sudo /snap/bin/huhnitor
    elif command -v huhnitor &>/dev/null; then
        launch_terminal "sudo huhnitor" || sudo huhnitor
    else
        echo -e "${RED}[!] huhnitor not found${NC}"
    fi

    echo ""
    echo -e "${GREEN}[*] Huhnitor launched in new window${NC}"
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
