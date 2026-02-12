#!/bin/bash

# Interface management module

# Interface menu
interface_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                  INTERFACE MANAGEMENT                   ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} List Wireless Interfaces     ${GRAY}Show available cards${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Select Interface            ${GRAY}Choose primary interface${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} Enable Monitor Mode        ${GRAY}Put interface in monitor${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} Disable Monitor Mode       ${GRAY}Return to managed${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} Interface Information       ${GRAY}Detailed interface info${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} Change MAC Address         ${GRAY}Spoof MAC address${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[7]${WHITE} Test Interface             ${GRAY}Check capabilities${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[8]${WHITE} USB Device Information    ${GRAY}Connected USB devices${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE} Back to Main Menu         ${GRAY}Return${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) list_interfaces ;;
            2) select_interface ;;
            3) enable_monitor_mode ;;
            4) disable_monitor_mode ;;
            5) interface_info ;;
            6) change_mac_address ;;
            7) test_interface ;;
            8) usb_device_info ;;
            0) break ;;
            *) 
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# List wireless interfaces
list_interfaces() {
    clear
    echo -e "${BLUE}Available Wireless Interfaces:${NC}"
    echo -e "${GRAY}================================${NC}"
    
    local interfaces=$(get_wireless_interfaces)
    
    if [[ -z "$interfaces" ]]; then
        echo -e "${RED}No wireless interfaces found!${NC}"
        echo ""
        echo -e "${YELLOW}Possible solutions:${NC}"
        echo "- Install wireless drivers"
        echo "- Check USB devices"
        echo "- Try different USB port"
        pause
        return
    fi
    
    echo ""
    printf "${WHITE}%-10s %-15s %-10s %-10s %-15s${NC}\n" "INTERFACE" "TYPE" "MODE" "DRIVER" "CHIPSET"
    echo -e "${GRAY}-----------------------------------------------------------${NC}"
    
    while IFS= read -r interface; do
        local mode="Managed"
        local driver=""
        local chipset="Unknown"
        
        if is_monitor_mode "$interface"; then
            mode="Monitor"
        fi
        
        # Try to get driver info
        driver=$(ethtool -i "$interface" 2>/dev/null | grep driver | awk '{print $2}')
        
        # Try to identify chipset
        if [[ "$driver" =~ "ath" ]]; then
            chipset="Atheros"
        elif [[ "$driver" =~ "rt" ]] || [[ "$driver" =~ "r8" ]]; then
            chipset="Ralink/Realtek"
        elif [[ "$driver" =~ "rtl" ]]; then
            chipset="Realtek"
        elif [[ "$driver" =~ "brc" ]]; then
            chipset="Broadcom"
        fi
        
        printf "%-10s %-15s %-10s %-10s %-15s\n" "$interface" "Wireless" "$mode" "$driver" "$chipset"
    done <<< "$interfaces"
    
    echo ""
    pause
}

# Select interface
select_interface() {
    clear
    echo -e "${BLUE}***************************** Interface selection *****************************${NC}"
    echo -e "${WHITE}Select an interface to work with:${NC}"
    echo -e "${GRAY}---------${NC}"
    
    local interfaces
    interfaces=$(ls /sys/class/net 2>/dev/null)
    
    if [[ -z "$interfaces" ]]; then
        echo -e "${RED}No network interfaces found!${NC}"
        pause
        return
    fi
    
    local count=0
    local iface_array=()
    
    for interface in $interfaces; do
        count=$((count + 1))
        iface_array+=("$interface")
        # Get driver/chipset info
        local driver="$(ethtool -i "$interface" 2>/dev/null | awk '/driver:/ {print $2}' || true)"
        local chipset="Unknown"
        local bands="Unknown"
        
        if [[ -n "$driver" ]]; then
            if [[ "$driver" =~ ath|ath9k ]]; then
                chipset="Atheros"
            elif [[ "$driver" =~ rt|rtl|r8 ]]; then
                chipset="Realtek/Ralink"
            elif [[ "$driver" =~ brcm|brc ]]; then
                chipset="Broadcom"
            fi
        fi
        
        # Frequency support quick guess
        if iw list 2>/dev/null | grep -A2 "Frequencies" | grep -q "5180"; then
            bands="2.4Ghz, 5Ghz"
        else
            bands="2.4Ghz"
        fi
        
        printf "${CYAN}%-2d${NC} %-8s // %-20s // Chipset: %s\n" "$count" "$interface" "$bands" "$chipset"
    done
    
    echo -e "${GRAY}---------${NC}"
    echo -e "Hint If you want to learn how to perform professional wireless network assessments,"
    echo -e "      visit: https://github.com/v1s1t0r1sh3r3/airgeddon"
    echo -e "${GRAY}---------${NC}"
    echo ""
    
    read -p "> " choice
    
    if [[ $choice -ge 1 && $choice -le $count ]]; then
        SELECTED_INTERFACE="${iface_array[$((choice-1))]}"
        
        # Update config
        sed -i "s/DEFAULT_INTERFACE=.*/DEFAULT_INTERFACE=\"$SELECTED_INTERFACE\"/" "$CONFIG_FILE" 2>/dev/null
        
        success "Selected interface: $SELECTED_INTERFACE"
        
        # Check if VIF capable
        if check_vif_support "$SELECTED_INTERFACE"; then
            success "Interface supports VIF (Virtual Interface Functionality)"
        else
            warning "Interface does not support VIF - Evil Twin attacks limited"
        fi
        
        pause
    else
        echo -e "${RED}[!] Invalid selection${NC}"
        sleep 2
    fi
}

# Enable monitor mode
enable_monitor_mode() {
    clear
    echo -e "${BLUE}Enable Monitor Mode${NC}"
    echo -e "${GRAY}===================${NC}"
    
    local interface="${SELECTED_INTERFACE:-wlan0}"
    
    if [[ ! -e "/sys/class/net/$interface" ]]; then
        error "Interface $interface not found"
    fi
    
    if is_monitor_mode "${interface}mon"; then
        echo -e "${YELLOW}Interface $interface is already in monitor mode${NC}"
        pause
        return
    fi
    
    echo -e "${WHITE}Available adapters:${NC}"
    local adapters=($(ip link show | grep "wlan" | awk '{print $2}' | sed 's/:$//'))
    
    if [[ ${#adapters[@]} -gt 1 ]]; then
        echo -e "${CYAN}[*] Multiple adapters detected - selective mode${NC}"
        echo -e "${CYAN}[*] Only $interface will be affected (others stay connected)${NC}"
        echo ""
    fi
    
    echo -e "${YELLOW}[*] Carefully stopping interfering processes on $interface only...${NC}"
    
    # Instead of 'airmon-ng check kill', selectively kill only on this interface
    # Step 1: Disconnect the specific interface from any network
    nmcli device disconnect "$interface" 2>/dev/null || true
    sleep 1
    
    # Step 2: Stop wpa_supplicant ONLY for this interface if running
    local wpa_pid=$(pgrep -f "wpa_supplicant.*$interface" 2>/dev/null)
    if [[ -n "$wpa_pid" ]]; then
        echo -e "${YELLOW}[*] Stopping wpa_supplicant for $interface...${NC}"
        kill "$wpa_pid" 2>/dev/null
        sleep 1
    fi
    
    # Step 3: Bring interface down
    echo -e "${YELLOW}[*] Bringing interface down...${NC}"
    ip link set "$interface" down 2>/dev/null || true
    sleep 1
    
    echo -e "${YELLOW}[*] Enabling monitor mode on $interface...${NC}"
    if airmon-ng start "$interface" > /dev/null 2>&1; then
        local monitor_interface="${interface}mon"
        
        # Find the actual monitor interface name
        monitor_interface=$(iwconfig 2>/dev/null | grep "Mode:Monitor" | awk '{print $1}' | head -1)
        
        if [[ -n "$monitor_interface" ]]; then
            success "Monitor mode enabled: $monitor_interface"
            echo -e "${CYAN}[✓] Other adapters remain connected${NC}"
            
            # Update config
            sed -i "s/MONITOR_INTERFACE=.*/MONITOR_INTERFACE=\"$monitor_interface\"/" "$CONFIG_FILE"
            
            # Show interface info
            echo ""
            iwconfig "$monitor_interface" | head -5
        else
            error "Failed to find monitor interface"
        fi
    else
        error "Failed to enable monitor mode"
    fi
    
    pause
}

# Disable monitor mode
disable_monitor_mode() {
    clear
    echo -e "${BLUE}Disable Monitor Mode${NC}"
    echo -e "${GRAY}====================${NC}"
    
    local monitor_interface="${MONITOR_INTERFACE:-wlan0mon}"
    
    if ! is_monitor_mode "$monitor_interface"; then
        echo -e "${YELLOW}Interface $monitor_interface is not in monitor mode${NC}"
        pause
        return
    fi
    
    echo -e "${YELLOW}[*] Disabling monitor mode...${NC}"
    if airmon-ng stop "$monitor_interface" > /dev/null 2>&1; then
        success "Monitor mode disabled"
        
        # Restart network manager
        echo -e "${YELLOW}[*] Restarting NetworkManager...${NC}"
        systemctl start NetworkManager > /dev/null 2>&1
        systemctl start wpa_supplicant > /dev/null 2>&1
        
        pause
    else
        error "Failed to disable monitor mode"
    fi
}

# Interface information
interface_info() {
    clear
    echo -e "${BLUE}Interface Information${NC}"
    echo -e "${GRAY}===================${NC}"
    
    local interface="${SELECTED_INTERFACE:-wlan0}"
    
    if [[ ! -e "/sys/class/net/$interface" ]]; then
        echo -e "${RED}Interface $interface not found${NC}"
        pause
        return
    fi
    
    echo -e "${WHITE}Basic Information:${NC}"
    echo -e "Interface: $interface"
    echo -e "Status: $(cat /sys/class/net/$interface/operstate 2>/dev/null || echo "Unknown")"
    echo -e "MAC: $(cat /sys/class/net/$interface/address 2>/dev/null || echo "Unknown")"
    echo -e "Mode: $(iwconfig "$interface" 2>/dev/null | grep "Mode:" | awk '{print $2}')"
    echo ""
    
    echo -e "${WHITE}Wireless Information:${NC}"
    iwconfig "$interface" 2>/dev/null || echo "Failed to get wireless info"
    echo ""
    
    echo -e "${WHITE}Driver Information:${NC}"
    ethtool -i "$interface" 2>/dev/null || echo "Failed to get driver info"
    echo ""
    
    # Check capabilities
    echo -e "${WHITE}Capabilities:${NC}"
    
    if is_monitor_mode "$interface"; then
        echo -e "✓ Monitor Mode: Active"
    else
        echo -e "✗ Monitor Mode: Inactive"
    fi
    
    if check_vif_support "$interface"; then
        echo -e "✓ VIF Support: Available"
    else
        echo -e "✗ VIF Support: Not Available"
    fi
    
    if check_packet_injection "$interface"; then
        echo -e "✓ Packet Injection: Working"
    else
        echo -e "✗ Packet Injection: Not Working"
    fi
    
    pause
}

# Change MAC address
change_mac_address() {
    clear
    echo -e "${BLUE}Change MAC Address${NC}"
    echo -e "${GRAY}=================${NC}"
    
    local interface="${SELECTED_INTERFACE:-wlan0}"
    
    if [[ ! -e "/sys/class/net/$interface" ]]; then
        error "Interface $interface not found"
    fi
    
    echo -e "${YELLOW}Current MAC: $(cat /sys/class/net/$interface/address 2>/dev/null || echo "Unknown")${NC}"
    echo ""
    
    echo -e "${WHITE}Options:${NC}"
    echo -e "${CYAN}[1]${NC} Random MAC address"
    echo -e "${CYAN}[2]${NC} Custom MAC address"
    echo -e "${CYAN}[3]${NC} Restore original MAC"
    echo -e "${CYAN}[0]${NC} Cancel"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1)
            local new_mac=$(generate_random_mac)
            echo -e "${YELLOW}[*] Setting MAC to $new_mac${NC}"
            ;;
        2)
            read -p "Enter new MAC address: " new_mac
            if ! is_valid_mac "$new_mac"; then
                error "Invalid MAC address format"
            fi
            ;;
        3)
            # Store original MAC (should be done at startup)
            new_mac=""
            echo -e "${YELLOW}[*] Restoring original MAC${NC}"
            ;;
        0|*)
            return
            ;;
    esac
    
    # Bring interface down
    ip link set "$interface" down
    
    if [[ -n "$new_mac" ]]; then
        ip link set "$interface" address "$new_mac"
    fi
    
    # Bring interface up
    ip link set "$interface" up
    
    # Verify
    local current_mac=$(cat /sys/class/net/$interface/address 2>/dev/null)
    if [[ -n "$new_mac" && "$current_mac" == "$new_mac" ]]; then
        success "MAC address changed to $current_mac"
    elif [[ -z "$new_mac" ]]; then
        success "MAC address restored"
    else
        warning "MAC address change may not have worked correctly"
    fi
    
    pause
}

# Test interface
test_interface() {
    clear
    echo -e "${BLUE}Interface Testing${NC}"
    echo -e "${GRAY}=================${NC}"
    
    local interface="${SELECTED_INTERFACE:-wlan0}"
    
    if [[ ! -e "/sys/class/net/$interface" ]]; then
        error "Interface $interface not found"
    fi
    
    echo -e "${YELLOW}[*] Testing interface $interface...${NC}"
    echo ""
    
    # Test basic functionality
    echo -e "${WHITE}Testing...${NC}"
    
    if is_monitor_mode "${interface}mon"; then
        local mon_iface="${interface}mon"
    else
        local mon_iface="$interface"
    fi
    
    echo -n "• Monitor mode support: "
    if check_vif_support "$interface"; then
        echo -e "${GREEN}✓ Available${NC}"
    else
        echo -e "${RED}✗ Not Available${NC}"
    fi
    
    echo -n "• VIF support: "
    if check_vif_support "$interface"; then
        echo -e "${GREEN}✓ Available${NC}"
    else
        echo -e "${RED}✗ Not Available${NC}"
    fi
    
    echo -n "• Packet injection: "
    if check_packet_injection "$mon_iface"; then
        echo -e "${GREEN}✓ Working${NC}"
    else
        echo -e "${RED}✗ Not Working${NC}"
    fi
    
    echo -n "• Driver compatibility: "
    local driver=$(ethtool -i "$interface" 2>/dev/null | grep driver | awk '{print $2}')
    case "$driver" in
        "ath9k_htc"|"ath9k"|"carl9170")
            echo -e "${GREEN}✓ Excellent (Atheros)${NC}"
            ;;
        "rt2800usb"|"rt73usb"|"rt8187")
            echo -e "${GREEN}✓ Good (Ralink)${NC}"
            ;;
        "rtl8187eu"|"rtl8812au")
            echo -e "${YELLOW}⚠ Limited (Realtek)${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠ Unknown driver: $driver${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${WHITE}Recommendations:${NC}"
    
    if ! check_vif_support "$interface"; then
        echo -e "• Upgrade to Atheros or Ralink chipset for Evil Twin attacks"
    fi
    
    if ! check_packet_injection "$mon_iface"; then
        echo -e "• Try different USB port or adapter"
        echo -e "• Check if interface is fully supported"
    fi
    
    pause
}

# USB device information
usb_device_info() {
    clear
    echo -e "${BLUE}USB Device Information${NC}"
    echo -e "${GRAY}======================${NC}"
    
    local usb_devices=$(get_usb_devices)
    
    if [[ -z "$usb_devices" ]]; then
        echo -e "${YELLOW}No USB wireless devices found${NC}"
        echo ""
        echo -e "${WHITE}Troubleshooting:${NC}"
        echo "- Check USB connections"
        echo "- Try different USB port"
        echo "- Install required drivers"
        pause
        return
    fi
    
    echo ""
    echo -e "${WHITE}USB Wireless Devices:${NC}"
    echo -e "${GRAY}----------------------------------------${NC}"
    
    lsusb | grep -i "wireless\->theros\|ralink\|realtek\|mediatek" | while read line; do
        echo -e "$line"
    done
    
    echo ""
    echo -e "${WHITE}All USB Devices:${NC}"
    echo -e "${GRAY}----------------------------------------${NC}"
    lsusb
    
    pause
}