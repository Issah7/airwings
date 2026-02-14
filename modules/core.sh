#!/bin/bash

# Core functions for airwings

# Logging function
log_event() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Error handling
error() {
    echo -e "${RED}[ERROR] $1${NC}"
    log_event "ERROR" "$1"
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}[✓] $1${NC}"
    log_event "SUCCESS" "$1"
}

# Warning message
warning() {
    echo -e "${YELLOW}[!] $1${NC}"
    log_event "WARNING" "$1"
}

# Info message
info() {
    echo -e "${BLUE}[*] $1${NC}"
    log_event "INFO" "$1"
}

# Question function
question() {
    echo -e "${PURPLE}[?] $1${NC}"
}

# Clean up processes
cleanup_processes() {
    info "Cleaning up processes..."
    
    # Kill aircrack processes
    pkill -f airodump-ng 2>/dev/null
    pkill -f aireplay-ng 2>/dev/null
    pkill -f aircrack-ng 2>/dev/null
    
    # Kill airgeddon
    pkill -f airgeddon 2>/dev/null
    
    # Kill ESP8266 processes
    pkill -f huhnitor 2>/dev/null
    
    # Kill captive portal processes
    pkill -f lighttpd 2>/dev/null
    pkill -f dnsmasq 2>/dev/null
    pkill -f hostapd 2>/dev/null
    
    # Kill mdk4/mdk3
    pkill -f mdk4 2>/dev/null
    pkill -f mdk3 2>/dev/null
    
    success "Processes cleaned up"
}

# Restore interfaces
restore_interfaces() {
    info "Restoring network interfaces..."

    # Stop all monitor mode interfaces
    local mon_interfaces=$(get_monitor_interfaces)
    if [[ -n "$mon_interfaces" ]]; then
        for mon_iface in $mon_interfaces; do
            info "Stopping monitor mode on $mon_iface..."
            airmon-ng stop "$mon_iface" 2>/dev/null
        done
    fi

    # Restart network manager
    systemctl start NetworkManager 2>/dev/null
    systemctl start wpa_supplicant 2>/dev/null

    success "Interfaces restored"
}

# Check if interface exists
check_interface() {
    local iface="$1"
    ifconfig "$iface" &>/dev/null || return 1
    return 0
}

# Check if interface is in monitor mode
is_monitor_mode() {
    local iface="$1"
    if iwconfig "$iface" 2>/dev/null | grep -q "Mode:Monitor"; then
        return 0
    else
        return 1
    fi
}

# Get current interfaces
get_wireless_interfaces() {
    iwconfig 2>/dev/null | grep -E "^[a-zA-Z0-9]+" | awk '{print $1}'
}

# Get first available wireless interface (helper for dynamic selection)
get_first_wireless_interface() {
    local first=$(get_wireless_interfaces | head -1)
    echo "${first:-}"
}

# Get selected or first available interface
get_selected_or_first_interface() {
    if [[ -n "$SELECTED_INTERFACE" ]] && check_interface "$SELECTED_INTERFACE"; then
        echo "$SELECTED_INTERFACE"
    elif [[ -n "$DEFAULT_INTERFACE" ]] && check_interface "$DEFAULT_INTERFACE"; then
        echo "$DEFAULT_INTERFACE"
    else
        get_first_wireless_interface
    fi
}

# Get active monitor interface (for scanning and attacks)
get_monitor_interface() {
    # First check if MONITOR_INTERFACE is set and valid
    if [[ -n "$MONITOR_INTERFACE" ]] && is_monitor_mode "$MONITOR_INTERFACE"; then
        echo "$MONITOR_INTERFACE"
        return 0
    fi

    # Try to find any active monitor interface
    local mon_iface=$(get_monitor_interfaces | head -1)
    if [[ -n "$mon_iface" ]]; then
        echo "$mon_iface"
        return 0
    fi

    # Check for common naming patterns (wlan0mon, wlan1mon, etc.)
    local base=$(get_selected_or_first_interface)
    if [[ -n "$base" ]]; then
        if is_monitor_mode "${base}mon"; then
            echo "${base}mon"
            return 0
        elif is_monitor_mode "$base"; then
            echo "$base"
            return 0
        fi
    fi

    # No monitor interface found
    return 1
}

# Get all ethernet/wired interfaces (for internet connectivity)
get_ethernet_interfaces() {
    ip link show | grep -E "^[0-9]+: (eth|enp|ens|eno|br)" | awk '{print $2}' | tr -d ':' | grep -v "^lo$"
}

# Get first available ethernet interface
get_first_ethernet_interface() {
    local first=$(get_ethernet_interfaces | head -1)
    echo "${first:-}"
}

# Get internet interface (for NAT/forwarding in attacks)
get_internet_interface() {
    # First check if INTERNET_INTERFACE is set and valid
    if [[ -n "$INTERNET_INTERFACE" ]] && ip link show "$INTERNET_INTERFACE" &>/dev/null; then
        echo "$INTERNET_INTERFACE"
        return 0
    fi

    # Try to find the default route interface (most likely has internet)
    local default_iface=$(ip route | grep "^default" | head -1 | awk '{print $5}')
    if [[ -n "$default_iface" ]] && [[ "$default_iface" != "lo" ]]; then
        echo "$default_iface"
        return 0
    fi

    # Fallback to first ethernet interface
    local eth_iface=$(get_first_ethernet_interface)
    if [[ -n "$eth_iface" ]]; then
        echo "$eth_iface"
        return 0
    fi

    # No internet interface found
    return 1
}

# Interactively select internet interface
select_internet_interface() {
    local available=$(get_ethernet_interfaces)

    if [[ -z "$available" ]]; then
        echo -e "${YELLOW}[!] No ethernet interfaces found${NC}"
        echo -e "${YELLOW}[!] Attacks requiring internet may not work${NC}"
        return 1
    fi

    echo -e "${WHITE}Available internet interfaces:${NC}"
    local count=0
    local iface_array=()

    for iface in $available; do
        count=$((count + 1))
        iface_array+=("$iface")

        # Check if interface has an IP
        local ip=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -1)
        local status="down"
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            status="up"
        fi

        if [[ -n "$ip" ]]; then
            echo -e "  ${CYAN}[$count]${NC} $iface ${GREEN}($status, IP: $ip)${NC}"
        else
            echo -e "  ${CYAN}[$count]${NC} $iface ${GRAY}($status, no IP)${NC}"
        fi
    done

    echo ""
    if [[ $count -eq 1 ]]; then
        echo "${iface_array[0]}"
        return 0
    fi

    read -p "Select internet interface (1-$count) [1]: " selection
    selection="${selection:-1}"

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt $count ]]; then
        echo -e "${RED}[!] Invalid selection${NC}"
        return 1
    fi

    echo "${iface_array[$((selection - 1))]}"
    return 0
}

# Get monitor interfaces
get_monitor_interfaces() {
    iwconfig 2>/dev/null | grep "Mode:Monitor" | awk '{print $1}'
}

# Check VIF support
check_vif_support() {
    local iface="$1"
    if sudo iw list 2>/dev/null | grep -A 8 "Supported interface modes" | grep -q "AP/VLAN"; then
        return 0
    else
        return 1
    fi
}

# Check packet injection
check_packet_injection() {
    local iface="$1"
    # Add timeout to prevent hanging - 10 seconds should be enough
    if timeout 10 aireplay-ng --test "$iface" 2>&1 | grep -q "Injection is working"; then
        return 0
    else
        return 1
    fi
}

# Press any key to continue
pause() {
    echo ""
    read -p "Press any key to continue..."
}

# Validate MAC address
is_valid_mac() {
    local mac="$1"
    if [[ $mac =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Generate random MAC
generate_random_mac() {
    printf "02:%02x:%02x:%02x:%02x:%02x\n" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
}

# Convert channel to frequency
channel_to_freq() {
    local channel="$1"
    
    if [[ $channel -ge 1 && $channel -le 14 ]]; then
        # 2.4 GHz band
        echo $((2407 + channel))
    elif [[ $channel -ge 36 && $channel -le 165 ]]; then
        # 5 GHz band
        if [[ $channel -eq 36 ]]; then echo "5180"
        elif [[ $channel -eq 40 ]]; then echo "5200"
        elif [[ $channel -eq 44 ]]; then echo "5220"
        elif [[ $channel -eq 48 ]]; then echo "5240"
        elif [[ $channel -eq 52 ]]; then echo "5260"
        elif [[ $channel -eq 56 ]]; then echo "5280"
        elif [[ $channel -eq 60 ]]; then echo "5300"
        elif [[ $channel -eq 64 ]]; then echo "5320"
        elif [[ $channel -eq 100 ]]; then echo "5500"
        elif [[ $channel -eq 104 ]]; then echo "5520"
        elif [[ $channel -eq 108 ]]; then echo "5540"
        elif [[ $channel -eq 112 ]]; then echo "5560"
        elif [[ $channel -eq 116 ]]; then echo "5580"
        elif [[ $channel -eq 120 ]]; then echo "5600"
        elif [[ $channel -eq 124 ]]; then echo "5620"
        elif [[ $channel -eq 128 ]]; then echo "5640"
        elif [[ $channel -eq 132 ]]; then echo "5660"
        elif [[ $channel -eq 136 ]]; then echo "5680"
        elif [[ $channel -eq 140 ]]; then echo "5700"
        elif [[ $channel -eq 144 ]]; then echo "5720"
        elif [[ $channel -eq 149 ]]; then echo "5745"
        elif [[ $channel -eq 153 ]]; then echo "5765"
        elif [[ $channel -eq 157 ]]; then echo "5785"
        elif [[ $channel -eq 161 ]]; then echo "5805"
        elif [[ $channel -eq 165 ]]; then echo "5825"
        fi
    else
        echo "0"
    fi
}

# Check if channel is valid
is_valid_channel() {
    local channel="$1"
    if [[ $channel -ge 1 && $channel -le 14 ]] || [[ $channel -ge 36 && $channel -le 165 ]]; then
        return 0
    else
        return 1
    fi
}

# Get signal strength in dBm
get_signal_strength() {
    local bssid="$1"
    local interface="$2"
    
    local signal=$(airodump-ng -c 1 --bssid "$bssid" "$interface" 2>/dev/null | grep "$bssid" | awk '{print $4}')
    echo "${signal:-0}"
}

# Convert dBm to percentage
dbm_to_percentage() {
    local dbm="$1"
    
    if [[ $dbm -le -100 ]]; then
        echo "0"
    elif [[ $dbm -ge -50 ]]; then
        echo "100"
    else
        local percentage=$(( (dbm + 100) * 2 ))
        if [[ $percentage -gt 100 ]]; then
            echo "100"
        elif [[ $percentage -lt 0 ]]; then
            echo "0"
        else
            echo "$percentage"
        fi
    fi
}

# Check if process is running
is_process_running() {
    local process="$1"
    pgrep -f "$process" >/dev/null
}

# Wait for process to finish
wait_for_process() {
    local process="$1"
    local timeout="${2:-30}"
    
    local count=0
    while is_process_running "$process" && [[ $count -lt $timeout ]]; do
        sleep 1
        count=$((count + 1))
    done
    
    if [[ $count -ge $timeout ]]; then
        warning "Process $process timeout after $timeout seconds"
        pkill -f "$process"
    fi
}

# Create temporary directory
create_temp_dir() {
    mktemp -d -t airwings.XXXXXX
}

# Clean temporary directory
clean_temp_dir() {
    local temp_dir="$1"
    if [[ -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
    fi
}

# Check for root privileges
require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This function requires root privileges"
    fi
}

# Get current timestamp
get_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# Format duration (seconds to readable format)
format_duration() {
    local seconds="$1"
    
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%02d:%02d:%02d" $hours $minutes $secs
    elif [[ $minutes -gt 0 ]]; then
        printf "%02d:%02d" $minutes $secs
    else
        printf "%02d" $secs
    fi
}

# Get file size in human readable format
get_file_size() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        
        if [[ $size -lt 1024 ]]; then
            echo "${size}B"
        elif [[ $size -lt 1048576 ]]; then
            echo "$((size / 1024))KB"
        elif [[ $size -lt 1073741824 ]]; then
            echo "$((size / 1048576))MB"
        else
            echo "$((size / 1073741824))GB"
        fi
    else
        echo "0B"
    fi
}

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get public IP
get_public_ip() {
    curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "Unknown"
}

# Get system information
get_system_info() {
    echo "System Information:"
    echo "----------------"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p 2>/dev/null || echo "Unknown")"
    echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")}')"
    echo ""
}

# Check if script is running in VM
is_vm() {
    if command -v systemd-detect-virt &>/dev/null; then
        local vm_type=$(systemd-detect-virt 2>/dev/null)
        if [[ "$vm_type" != "none" ]]; then
            return 0
        fi
    fi
    
    # Alternative checks
    if [[ -d "/proc/vz" ]] || [[ -f "/.dockerenv" ]] || lspci 2>/dev/null | grep -i "VirtualBox\|VMware\|QEMU"; then
        return 0
    fi
    
    return 1
}

# Get available USB devices
get_usb_devices() {
    lsusb 2>/dev/null | grep -i "wireless\|realtek\->theros\|ralink\|mediatek" | while read line; do
        echo "$line" | awk '{print $6" "$7" " $8}'
    done
}