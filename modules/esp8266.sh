#!/bin/bash

# ESP8266 Deauther module

# ESP8266 menu
esp8266_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                 ESP8266 DEAUTHER                       ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} Flash Firmware            ${GRAY}Program ESP8266 device${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Serial Monitor            ${GRAY}Huhnitor terminal${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} Web Interface            ${GRAY}Access via browser${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} Deauth Attack            ${GRAY}Disconnect devices${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} Beacon Flood             ${GRAY}Create fake APs${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} Probe Request Attack    ${GRAY}Device discovery${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[7]${WHITE} Packet Monitor            ${GRAY}Analyze traffic${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[8]${WHITE} SSID Manager             ${GRAY}Manage SSID lists${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[9]${WHITE} Device Configuration      ${GRAY}Settings and options${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[10]${WHITE} Scripts & Automation     ${GRAY}Run attack scripts${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE} Back to Main Menu         ${GRAY}Return${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) esp_flash_firmware ;;
            2) esp_serial_monitor ;;
            3) esp_web_interface ;;
            4) esp_deauth_attack ;;
            5) esp_beacon_flood ;;
            6) esp_probe_attack ;;
            7) esp_packet_monitor ;;
            8) esp_ssid_manager ;;
            9) esp_device_config ;;
            10) esp_scripts_automation ;;
            0) break ;;
            *) 
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# Default serial settings
ESP8266_PORT="${ESP8266_PORT:-/dev/ttyUSB0}"
ESP8266_BAUD="${ESP8266_BAUD:-115200}"

# Flash ESP8266 firmware
esp_flash_firmware() {
    clear
    echo -e "${BLUE}Flash ESP8266 Firmware${NC}"
    echo -e "${GRAY}=========================${NC}"
    
    if ! command -v esptool &> /dev/null; then
        echo -e "${RED}[!] esptool not found${NC}"
        echo -e "${YELLOW}[!] Install with: pip3 install esptool${NC}"
        pause
        return
    fi
    
    # Find ESP8266 devices
    echo -e "${YELLOW}[*] Detecting ESP8266 devices...${NC}"
    
    local devices=()
    local device_ports=()
    
    # Common serial ports
    for port in /dev/ttyUSB* /dev/ttyACM*; do
        if [[ -e "$port" ]]; then
            devices+=("$port")
            device_ports+=("$(basename "$port")")
        fi
    done
    
    if [[ ${#devices[@]} -eq 0 ]]; then
        echo -e "${RED}[!] No ESP8266 devices found${NC}"
        echo ""
        echo -e "${WHITE}Troubleshooting:${NC}"
        echo "- Check USB connections"
        echo "- Install drivers (CH340, CP2102, etc.)"
        echo "- Try different USB port"
        echo "- Check device permissions"
        pause
        return
    fi
    
    echo ""
    echo -e "${WHITE}Found devices:${NC}"
    for i in "${!devices[@]}"; do
        echo -e "${CYAN}[$((i+1))]${NC} ${devices[$i]}"
    done
    echo ""
    
    read -p "Select device (1-${#devices[@]}): " device_choice
    
    if [[ $device_choice -ge 1 && $device_choice -le ${#devices[@]} ]]; then
        local selected_port="${devices[$((device_choice-1))]}"
        echo -e "${YELLOW}[*] Selected: $selected_port${NC}"
    else
        echo -e "${RED}[!] Invalid selection${NC}"
        sleep 2
        return
    fi
    
    # Firmware selection
    echo ""
    echo -e "${WHITE}Firmware Options:${NC}"
    echo -e "${CYAN}[1]${NC} Download latest release (recommended)"
    echo -e "${CYAN}[2]${NC} Use local firmware file"
    echo -e "${CYAN}[3]${NC} Development version"
    echo ""
    
    read -p "Select option: " firmware_choice
    
    local firmware_file=""
    
    case $firmware_choice in
        1)
            echo -e "${YELLOW}[*] Downloading latest firmware...${NC}"
            local latest_url="https://github.com/SpacehuhnTech/esp8266_deauther/releases/latest/download/esp8266_deauther_2.6.1_NODEMCU.bin"
            firmware_file="/tmp/esp8266_latest.bin"
            
            if wget -O "$firmware_file" "$latest_url" 2>/dev/null; then
                success "Firmware downloaded"
            else
                error "Failed to download firmware"
            fi
            ;;
        2)
            read -p "Enter path to firmware file: " custom_firmware
            if [[ -f "$custom_firmware" ]]; then
                firmware_file="$custom_firmware"
            else
                error "Firmware file not found"
            fi
            ;;
        3)
            echo -e "${YELLOW}[*] Cloning development repository...${NC}"
            local dev_dir="/tmp/esp8266_dev"
            if git clone https://github.com/SpacehuhnTech/esp8266_deauther.git "$dev_dir" 2>/dev/null; then
                echo -e "${YELLOW}[*] Building firmware...${NC}"
                cd "$dev_dir"
                # This would require Arduino CLI or similar
                echo -e "${RED}[!] Development build requires Arduino IDE${NC}"
                cd - > /dev/null
                error "Development build not implemented yet"
            else
                error "Failed to clone repository"
            fi
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            return
            ;;
    esac
    
    if [[ -z "$firmware_file" || ! -f "$firmware_file" ]]; then
        error "Firmware file not available"
    fi
    
    # Flash firmware
    echo ""
    echo -e "${YELLOW}[*] Preparing to flash firmware...${NC}"
    echo -e "${YELLOW}[*] Ensure ESP8266 is in flash mode${NC}"
    echo -e "${YELLOW}[*] Hold FLASH button, press RESET, release FLASH${NC}"
    echo ""
    
    read -p "Ready to flash? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Erasing flash...${NC}"
        esptool.py --port "$selected_port" erase_flash
        
        echo -e "${YELLOW}[*] Flashing firmware...${NC}"
        esptool.py --port "$selected_port" write_flash 0x0 "$firmware_file"
        
        if [[ $? -eq 0 ]]; then
            success "Firmware flashed successfully!"
            echo -e "${YELLOW}[*] Resetting device...${NC}"
            
            # Wait for device to reset
            sleep 3
            
            # Check if device is responding
            if check_esp8266_response "$selected_port"; then
                success "ESP8266 is responding!"
            else
                warning "ESP8266 may need manual reset"
            fi
        else
            error "Firmware flash failed"
        fi
    fi
    
    # Cleanup
    [[ -f "$firmware_file" ]] && rm -f "$firmware_file"
}

# Serial monitor (Huhnitor)
esp_serial_monitor() {
    clear
    echo -e "${BLUE}Serial Monitor (Huhnitor)${NC}"
    echo -e "${GRAY}==========================${NC}"
    
    if ! command -v huhnitor &> /dev/null; then
        echo -e "${RED}[!] huhnitor not found${NC}"
        echo -e "${YELLOW}[!] Install with: pip3 install huhnitor${NC}"
        pause
        return
    fi
    
    # Find ESP8266 device
    local esp_port=""
    
    # Try to find connected ESP8266
    for port in /dev/ttyUSB* /dev/ttyACM*; do
        if [[ -e "$port" ]]; then
            if check_esp8266_response "$port"; then
                esp_port="$port"
                break
            fi
        fi
    done
    
    if [[ -z "$esp_port" ]]; then
        # Use default or user-specified
        esp_port="$ESP8266_PORT"
        if [[ -z "$esp_port" ]]; then
            esp_port="/dev/ttyUSB0"
        fi
    fi
    
    echo -e "${YELLOW}[*] Connecting to ESP8266 on $esp_port${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to exit${NC}"
    echo ""
    
    # Start huhnitor
    huhnitor -p "$esp_port" -b "$ESP8266_BAUD"
    
    pause
}

# Web interface access
esp_web_interface() {
    clear
    echo -e "${BLUE}Access ESP8266 Web Interface${NC}"
    echo -e "${GRAY}================================${NC}"
    
    echo -e "${WHITE}To access the ESP8266 web interface:${NC}"
    echo ""
    echo -e "${CYAN}1. Connect to WiFi network:${NC}"
    echo -e "   SSID: pwned"
    echo -e "   Password: deauther"
    echo ""
    echo -e "${CYAN}2. Open web browser:${NC}"
    echo -e "   Navigate to: http://192.168.4.1"
    echo ""
    echo -e "${CYAN}3. Default login:${NC}"
    echo -e "   Password: deauther"
    echo ""
    echo -e "${YELLOW}[*] If you can't connect:${NC}"
    echo -e "- Check if ESP8266 is powered on"
    echo -e "- Try resetting the device"
    echo -e "- Check WiFi signal strength"
    echo -e "- Clear browser cache"
    
    # Test connectivity
    echo ""
    read -p "Test connection to ESP8266? (y/N): " test_connection
    
    if [[ "$test_connection" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Testing connection to ESP8266...${NC}"
        
        # Check if connected to pwned network
        if ip route | grep -q "192.168.4.0"; then
            if ping -c 1 192.168.4.1 &>/dev/null; then
                success "ESP8266 is accessible at http://192.168.4.1"
                
                # Try to open in browser
                if command -v xdg-open &> /dev/null; then
                    echo -e "${YELLOW}[*] Opening browser...${NC}"
                    xdg-open http://192.168.4.1
                elif command -v firefox &> /dev/null; then
                    firefox http://192.168.4.1 &>/dev/null &
                else
                    echo -e "${YELLOW}[*] Manually navigate to: http://192.168.4.1${NC}"
                fi
            else
                warning "ESP8266 not responding to ping"
                echo -e "${YELLOW}[!] Check device power and connection${NC}"
            fi
        else
            warning "Not connected to ESP8266 WiFi network"
            echo -e "${YELLOW}[!] Connect to 'pwned' network first${NC}"
        fi
    fi
    
    pause
}

# Deauth attack
esp_deauth_attack() {
    clear
    echo -e "${BLUE}Deauth Attack${NC}"
    echo -e "${GRAY}=============${NC}"
    
    echo -e "${WHITE}Deauth Attack Options:${NC}"
    echo -e "${CYAN}[1]${NC} Select target APs"
    echo -e "${CYAN}[2]${NC} Deauth all networks"
    echo -e "${CYAN}[3]${NC} Target specific clients"
    echo -e "${CYAN}[4]${NC} Continuous deauth mode"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) esp_select_targets_deauth ;;
        2) esp_deauth_all ;;
        3) esp_target_clients_deauth ;;
        4) esp_continuous_deauth ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Beacon flood attack
esp_beacon_flood() {
    clear
    echo -e "${BLUE}Beacon Flood Attack${NC}"
    echo -e "${GRAY}====================${NC}"
    
    echo -e "${WHITE}Beacon Flood Options:${NC}"
    echo -e "${CYAN}[1]${NC} Random SSIDs"
    echo -e "${CYAN}[2]${NC} Clone nearby SSIDs"
    echo -e "${CYAN}[3]${NC} Custom SSID list"
    echo -e "${CYAN}[4]${NC} Targeted beacon flood"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) esp_random_beacons ;;
        2) esp_clone_ssids ;;
        3) esp_custom_beacons ;;
        4) esp_targeted_beacons ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Probe request attack
esp_probe_attack() {
    clear
    echo -e "${BLUE}Probe Request Attack${NC}"
    echo -e "${GRAY}======================${NC}"
    
    echo -e "${YELLOW}[*] Starting probe request attack...${NC}"
    echo -e "${YELLOW}[*] This will broadcast probe requests for device discovery${NC}"
    echo ""
    
    # This would send commands to ESP8266
    echo -e "${YELLOW}[!] Requires connection to ESP8266${NC}"
    echo -e "${YELLOW}[!] Use web interface or serial monitor to configure${NC}"
    
    pause
}

# Packet monitor
esp_packet_monitor() {
    clear
    echo -e "${BLUE}Packet Monitor${NC}"
    echo -e "${GRAY}==============${NC}"
    
    echo -e "${YELLOW}[*] Starting packet monitor mode...${NC}"
    echo -e "${YELLOW}[*] Monitor real-time 802.11 traffic${NC}"
    echo ""
    
    # This would start packet monitoring on ESP8266
    echo -e "${YELLOW}[!] Use ESP8266 web interface Monitor tab${NC}"
    echo -e "${YELLOW}[!] Or connect via serial: monitor command${NC}"
    
    pause
}

# SSID Manager
esp_ssid_manager() {
    clear
    echo -e "${BLUE}SSID Manager${NC}"
    echo -e "${GRAY}=============${NC}"
    
    echo -e "${WHITE}SSID Management Options:${NC}"
    echo -e "${CYAN}[1]${NC} Add SSID"
    echo -e "${CYAN}[2]${NC} View SSID list"
    echo -e "${CYAN}[3]${NC} Clear SSID list"
    echo -e "${CYAN}[4]${NC} Import SSID list"
    echo -e "${CYAN}[5]${NC} Export SSID list"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) esp_add_ssid ;;
        2) esp_view_ssids ;;
        3) esp_clear_ssids ;;
        4) esp_import_ssids ;;
        5) esp_export_ssids ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Device configuration
esp_device_config() {
    clear
    echo -e "${BLUE}Device Configuration${NC}"
    echo -e "${GRAY}====================${NC}"
    
    echo -e "${WHITE}Configuration Options:${NC}"
    echo -e "${CYAN}[1]${NC} Change device name/SSID"
    echo -e "${CYAN}[2]${NC} Change password"
    echo -e "${CYAN}[3]${NC} Set channel"
    echo -e "${CYAN}[4]${NC} Configure LED settings"
    echo -e "${CYAN}[5]${NC} Reset to defaults"
    echo -e "${CYAN}[6]${NC} Save configuration"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) esp_change_device_name ;;
        2) esp_change_device_password ;;
        3) esp_set_device_channel ;;
        4) esp_configure_led ;;
        5) esp_reset_defaults ;;
        6) esp_save_config ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Scripts & automation
esp_scripts_automation() {
    clear
    echo -e "${BLUE}Scripts & Automation${NC}"
    echo -e "${GRAY}======================${NC}"
    
    echo -e "${WHITE}Automation Options:${NC}"
    echo -e "${CYAN}[1]${NC} Create attack script"
    echo -e "${CYAN}[2]${NC} Run saved script"
    echo -e "${CYAN}[3]${NC} View script list"
    echo -e "${CYAN}[4]${NC} Delete script"
    echo -e "${CYAN}[5]${NC} Scheduled attacks"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) esp_create_script ;;
        2) esp_run_script ;;
        3) esp_view_scripts ;;
        4) esp_delete_script ;;
        5) esp_scheduled_attacks ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Helper functions for ESP8266

# Check if ESP8266 is responding
check_esp8266_response() {
    local port="$1"

    # Try to get a response from ESP8266 (non-destructive)
    if [[ -e "$port" ]]; then
        # send a newline and read any immediate output
        printf "\r\n" > "$port" 2>/dev/null || true
        timeout 2 head -n 5 "$port" 2>/dev/null | grep -q "help\|scan\|deauth" && return 0 || return 1
    fi
    return 1
}

# Select targets for deauth
esp_select_targets_deauth() {
    echo -e "${YELLOW}[*] This feature requires ESP8266 web interface${NC}"
    echo -e "${YELLOW}[*] Steps:${NC}"
    echo -e "1. Connect to ESP8266 web interface"
    echo -e "2. Go to Scan tab"
    echo -e "3. Click Scan APs"
    echo -e "4. Select target networks"
    echo -e "5. Go to Attack tab"
    echo -e "6. Choose Deauth attack"
    
    pause
}

# Deauth all networks
esp_deauth_all() {
    echo -e "${YELLOW}[*] Starting deauth attack on all networks...${NC}"
    echo -e "${YELLOW}[!] This affects all WiFi networks in range${NC}"
    echo -e "${YELLOW}[!] Use responsibly and only on authorized networks${NC}"
    echo ""
    
    read -p "Continue? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Use ESP8266 web interface to start${NC}"
        echo -e "${YELLOW}[*] Attack -> Deauth -> Select All -> Start${NC}"
    fi
    
    pause
}

# Target specific clients
esp_target_clients_deauth() {
    echo -e "${YELLOW}[*] Targeted client deauth${NC}"
    echo -e "${YELLOW}[!] Requires scanning first to identify clients${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scan -> Scan Stations -> Select -> Attack${NC}"
    
    pause
}

# Continuous deauth mode
esp_continuous_deauth() {
    echo -e "${YELLOW}[*] Continuous deauth mode${NC}"
    echo -e "${YELLOW}[!] ESP8266 will continuously deauth targets${NC}"
    echo -e "${YELLOW}[!] Use web interface to configure interval${NC}"
    
    pause
}

# Random beacons
esp_random_beacons() {
    read -p "Number of fake APs [default: 100]: " ap_count
    ap_count=${ap_count:-100}
    
    echo -e "${YELLOW}[*] Creating $ap_count random beacon frames...${NC}"
    echo -e "${YELLOW}[!] Configure in ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] SSIDs -> Random -> Set count -> Start${NC}"
    
    pause
}

# Clone SSIDs
esp_clone_ssids() {
    echo -e "${YELLOW}[*] Cloning nearby SSIDs for beacon flood${NC}"
    echo -e "${YELLOW}[!] Requires scan first${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scan -> Clone APs -> Start${NC}"
    
    pause
}

# Custom beacons
esp_custom_beacons() {
    read -p "Enter SSID for beacon flood: " custom_ssid
    read -p "Number of APs [default: 50]: " ap_count
    ap_count=${ap_count:-50}
    
    echo -e "${YELLOW}[*] Creating beacon flood with SSID: $custom_ssid${NC}"
    echo -e "${YELLOW}[!] Configure in ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] SSIDs -> Add SSID -> Set count -> Start${NC}"
    
    pause
}

# Targeted beacons
esp_targeted_beacons() {
    echo -e "${YELLOW}[*] Targeted beacon flood${NC}"
    echo -e "${YELLOW}[!] Creates beacons for specific networks${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface to configure targets${NC}"
    
    pause
}

# Add SSID
esp_add_ssid() {
    read -p "Enter SSID to add: " new_ssid
    
    if [[ -n "$new_ssid" ]]; then
        echo -e "${YELLOW}[*] Adding SSID: $new_ssid${NC}"
        echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
        echo -e "${YELLOW}[!] SSIDs -> Add -> $new_ssid -> Save${NC}"
    fi
    
    pause
}

# View SSIDs
esp_view_ssids() {
    echo -e "${YELLOW}[*] View SSID list${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] SSIDs tab to view current list${NC}"
    
    pause
}

# Clear SSIDs
esp_clear_ssids() {
    echo -e "${YELLOW}[*] Clear SSID list${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] SSIDs -> Clear -> Confirm${NC}"
    
    pause
}

# Import SSIDs
esp_import_ssids() {
    read -p "Enter path to SSID list file: " ssid_file
    
    if [[ -f "$ssid_file" ]]; then
        echo -e "${YELLOW}[*] Importing SSIDs from: $ssid_file${NC}"
        echo -e "${YELLOW}[!] Copy SSIDs to ESP8266 web interface${NC}"
    else
        echo -e "${RED}[!] File not found${NC}"
    fi
    
    pause
}

# Export SSIDs
esp_export_ssids() {
    echo -e "${YELLOW}[*] Export SSID list${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] SSIDs -> Export -> Save to file${NC}"
    
    pause
}

# Change device name
esp_change_device_name() {
    read -p "Enter new device name (SSID): " new_name
    
    if [[ -n "$new_name" ]]; then
        echo -e "${YELLOW}[*] Changing device name to: $new_name${NC}"
        echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
        echo -e "${YELLOW}[!] Settings -> SSID -> $new_name -> Save${NC}"
    fi
    
    pause
}

# Change device password
esp_change_device_password() {
    read -p "Enter new password: " new_password
    
    if [[ -n "$new_password" ]]; then
        echo -e "${YELLOW}[*] Changing device password${NC}"
        echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
        echo -e "${YELLOW}[!] Settings -> Password -> $new_password -> Save${NC}"
    fi
    
    pause
}

# Set device channel
esp_set_device_channel() {
    read -p "Enter channel (1-14): " new_channel
    
    if [[ $new_channel -ge 1 && $new_channel -le 14 ]]; then
        echo -e "${YELLOW}[*] Setting channel to: $new_channel${NC}"
        echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
        echo -e "${YELLOW}[!] Settings -> Channel -> $new_channel -> Save${NC}"
    else
        echo -e "${RED}[!] Invalid channel${NC}"
    fi
    
    pause
}

# Configure LED
esp_configure_led() {
    echo -e "${WHITE}LED Configuration Options:${NC}"
    echo -e "${CYAN}[1]${NC} Enable activity LED"
    echo -e "${CYAN}[2]${NC} Disable LED"
    echo -e "${CYAN}[3]${NC} Custom LED behavior"
    echo ""
    
    read -p "Select option: " led_choice
    
    case $led_choice in
        1|2|3)
            echo -e "${YELLOW}[*] Configuring LED...${NC}"
            echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
            echo -e "${YELLOW}[!] Settings -> LED -> Configure -> Save${NC}"
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac
    
    pause
}

# Reset to defaults
esp_reset_defaults() {
    echo -e "${RED}[!] This will reset all ESP8266 settings${NC}"
    echo -e "${RED}[!] Including SSID, password, and configuration${NC}"
    echo ""
    read -p "Continue? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Resetting to defaults...${NC}"
        echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
        echo -e "${YELLOW}[!] Settings -> Reset -> Confirm${NC}"
        echo -e "${YELLOW}[!] Or press hardware reset button${NC}"
    fi
    
    pause
}

# Save configuration
esp_save_config() {
    echo -e "${YELLOW}[*] Saving ESP8266 configuration${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Settings -> Save${NC}"
    
    pause
}

# Create script
esp_create_script() {
    echo -e "${YELLOW}[*] Create attack script${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scripts tab -> Add Script -> Configure actions${NC}"
    
    pause
}

# Run script
esp_run_script() {
    echo -e "${YELLOW}[*] Run saved script${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scripts tab -> Select -> Run${NC}"
    
    pause
}

# View scripts
esp_view_scripts() {
    echo -e "${YELLOW}[*] View saved scripts${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scripts tab to view available scripts${NC}"
    
    pause
}

# Delete script
esp_delete_script() {
    echo -e "${YELLOW}[*] Delete script${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scripts tab -> Select -> Delete -> Confirm${NC}"
    
    pause
}

# Scheduled attacks
esp_scheduled_attacks() {
    echo -e "${YELLOW}[*] Scheduled attacks${NC}"
    echo -e "${YELLOW}[!] Configure automatic attack timing${NC}"
    echo -e "${YELLOW}[!] Use ESP8266 web interface:${NC}"
    echo -e "${YELLOW}[!] Scripts tab -> Add Script -> Set schedule${NC}"
    
    pause
}
# ══════════════════════════════════════════════════════════════════════════════
# Serial Command Integration
# ══════════════════════════════════════════════════════════════════════════════

# Send raw command to ESP8266 via serial
esp_send_serial_command() {
    local cmd="$1"
    local port="${2:-$ESP8266_PORT}"
    local baud="${3:-$ESP8266_BAUD}"
    
    if [[ ! -e "$port" ]]; then
        echo -e "${RED}[!] Serial port not found: $port${NC}"
        return 1
    fi
    
    if ! command -v stty &>/dev/null; then
        echo -e "${RED}[!] stty not found${NC}"
        return 1
    fi
    
    # Configure serial port
    stty -F "$port" "$baud" cs8 -cstopb -parenb 2>/dev/null || true
    
    # Send command
    echo -e "${cmd}\r\n" > "$port" 2>/dev/null
    
    # Read response (non-blocking)
    timeout 2 cat "$port" 2>/dev/null | head -n 5
    
    return 0
}

# Open interactive serial terminal
esp_open_terminal() {
    local port="${1:-$ESP8266_PORT}"
    local baud="${2:-$ESP8266_BAUD}"
    
    if [[ ! -e "$port" ]]; then
        echo -e "${RED}[!] Serial port not found: $port${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}[*] Opening serial terminal on $port (${baud}bps)${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+A then X to exit (if using screen)${NC}"
    echo -e "${YELLOW}[*] Or Ctrl+C to abort${NC}"
    echo ""
    
    if command -v screen &>/dev/null; then
        screen "$port" "$baud"
    elif command -v minicom &>/dev/null; then
        minicom -D "$port" -b "$baud"
    elif command -v picocom &>/dev/null; then
        picocom -b "$baud" "$port"
    else
        echo -e "${RED}[!] No serial terminal found (screen/minicom/picocom)${NC}"
        echo -e "${YELLOW}[!] Install with: sudo apt install screen${NC}"
        return 1
    fi
}

# List available serial ports
esp_list_ports() {
    echo -e "${WHITE}Available serial ports:${NC}"
    if [[ -d "/dev" ]]; then
        ls -1 /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | while read port; do
            if [[ -e "$port" ]]; then
                echo -e "  ${CYAN}$port${NC}"
            fi
        done
    fi
}

# Helper constants for colors (if not already defined)
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

# Helper function: pause (if not already defined)
if ! type pause &>/dev/null 2>&1; then
    pause() {
        read -rp "Press Enter to continue..." _tmp
    }
fi
