#!/bin/bash

# Utils module - Common utility functions and helpers

# ══════════════════════════════════════════════════════════════════════════════
# System Information
# ══════════════════════════════════════════════════════════════════════════════

utils_system_info() {
    clear
    echo -e "${BLUE}System Information${NC}"
    echo -e "${GRAY}===================${NC}"
    echo ""
    
    echo -e "${WHITE}OS Information:${NC}"
    uname -a
    echo ""
    
    echo -e "${WHITE}Linux Version:${NC}"
    cat /etc/os-release 2>/dev/null | grep "PRETTY_NAME" | cut -d'=' -f2
    echo ""
    
    echo -e "${WHITE}Kernel:${NC}"
    uname -r
    echo ""
    
    echo -e "${WHITE}Memory:${NC}"
    free -h | grep Mem
    echo ""
    
    echo -e "${WHITE}CPU Cores:${NC}"
    nproc
    echo ""
    
    echo -e "${WHITE}Disk Space:${NC}"
    df -h / | tail -1
    echo ""
}

utils_network_status() {
    clear
    echo -e "${BLUE}Network Status${NC}"
    echo -e "${GRAY}===============${NC}"
    echo ""
    
    echo -e "${WHITE}Network Interfaces:${NC}"
    ip addr show | grep -E "^\d+:|inet " | paste - -
    echo ""
    
    echo -e "${WHITE}Routing Table:${NC}"
    ip route show | head -5
    echo ""
    
    echo -e "${WHITE}DNS Servers:${NC}"
    cat /etc/resolv.conf 2>/dev/null | grep -i "nameserver" || echo "[!] No DNS configured"
    echo ""
    
    echo -e "${WHITE}Connected Hosts:${NC}"
    arp-scan -l 2>/dev/null | wc -l
}

utils_airmon_info() {
    clear
    echo -e "${BLUE}Wireless Interface Info${NC}"
    echo -e "${GRAY}=======================.${NC}"
    echo ""
    
    if command -v airmon-ng &>/dev/null; then
        airmon-ng
    else
        echo -e "${RED}[!] airmon-ng not found${NC}}"
    fi
    
    echo ""
    echo -e "${WHITE}Wireless Interfaces (iw):${NC}}"
    iw dev 2>/dev/null || echo "[!] iw not available"
}

# ══════════════════════════════════════════════════════════════════════════════
# Dependency Checker
# ══════════════════════════════════════════════════════════════════════════════

utils_check_dependencies() {
    clear
    echo -e "${BLUE}Dependency Check${NC}"
    echo -e "${GRAY}=================${NC}"
    echo ""
    
    local deps=(
        "aircrack-ng"
        "airmon-ng"
        "airodump-ng"
        "aireplay-ng"
        "hashcat"
        "john"
        "reaver"
        "bettercap"
        "hostapd"
        "dnsmasq"
        "lighttpd"
        "wget"
        "curl"
        "git"
    )
    
    local missing=()
    for tool in "${deps[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}[✓]${NC} $tool"
        else
            echo -e "  ${RED}[✗]${NC} $tool"
            missing+=("$tool")
        fi
    done
    
    echo ""
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Missing tools:${NC}"
        for tool in "${missing[@]}"; do
            echo "  sudo apt install $tool"
        done
    else
        echo -e "${GREEN}All dependencies installed!${NC}}"
    fi
    
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Logging & Report Generation
# ══════════════════════════════════════════════════════════════════════════════

utils_generate_report() {
    clear
    echo -e "${BLUE}Generate Report${NC}"
    echo -e "${GRAY}=================${NC}"
    
    local report_file="$LOGS_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
    mkdir -p "$LOGS_DIR"
    
    {
        echo "==============================================="
        echo "Wireless Security Toolkit Report"
        echo "Generated: $(date)"
        echo "==============================================="
        echo ""
        
        echo "System Information:"
        uname -a
        echo ""
        
        echo "Captures:"
        ls -lh "$LOGS_DIR/captures/" 2>/dev/null | tail -10
        echo ""
        
        echo "Credentials:"
        ls -lh "$LOGS_DIR/credentials/" 2>/dev/null | tail -10
        echo ""
    } > "$report_file"
    
    echo -e "${GREEN}[✓] Report saved: $report_file${NC}}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Utilities Menu
# ══════════════════════════════════════════════════════════════════════════════

utils_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                      UTILITIES                           ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} System Information       ${GRAY}OS and hardware info${BLUE}      │${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Network Status           ${GRAY}Network configuration${BLUE}     │${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} Wireless Info            ${GRAY}Adapter information${BLUE}       │${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} Check Dependencies       ${GRAY}Verify tool installation${BLUE} │${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} Generate Report          ${GRAY}Create session report${BLUE}     │${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} View Logs                ${GRAY}Browse activity logs${BLUE}      │${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE} Back to Main Menu        ${GRAY}Return${BLUE}                    │${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) utils_system_info; pause ;;
            2) utils_network_status; pause ;;
            3) utils_airmon_info; pause ;;
            4) utils_check_dependencies ;;
            5) utils_generate_report ;;
            6) 
                clear
                echo -e "${BLUE}Log Files${NC}"
                echo -e "${GRAY}===========${NC}"
                ls -lh "$LOGS_DIR" 2>/dev/null || echo "[!] No logs found"
                pause
                ;;
            0) break ;;
            *)
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════════════════
# Helper Functions
# ══════════════════════════════════════════════════════════════════════════════

# Color definitions
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

# Helper function: pause
if ! type pause &>/dev/null 2>&1; then
    pause() {
        read -rp "Press Enter to continue..." _tmp
    }
fi

# Open a command in a separate terminal or session.
# Preference order: gnome-terminal, xfce4-terminal, konsole, xterm, tmux, screen, fallback background
open_in_terminal() {
    local cmd="$*"
    if [[ -z "$cmd" ]]; then
        return 1
    fi

    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -c "$cmd; exec bash" &
        return 0
    fi

    if command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal --hold -e "bash -c '$cmd; exec bash'" &
        return 0
    fi

    if command -v konsole >/dev/null 2>&1; then
        konsole -e bash -c "$cmd; exec bash" &
        return 0
    fi

    if command -v xterm >/dev/null 2>&1; then
        xterm -hold -e "$cmd" &
        return 0
    fi

    if command -v tmux >/dev/null 2>&1; then
        # create a detached session with a unique name
        local sess="airwings_airodump_$(date +%s)"
        tmux new-session -d -s "$sess" "$cmd"
        echo "Started tmux session: tmux attach -t $sess"
        return 0
    fi

    if command -v screen >/dev/null 2>&1; then
        local sess="airwings_airodump_$(date +%s)"
        screen -dmS "$sess" bash -c "$cmd"
        echo "Started screen session: screen -r $sess"
        return 0
    fi

    # Fallback: run in background
    bash -c "$cmd" &
    return 0
}

# LOGS_DIR default
LOGS_DIR="${LOGS_DIR:-$PWD/logs}"
mkdir -p "$LOGS_DIR" 2>/dev/null || true
