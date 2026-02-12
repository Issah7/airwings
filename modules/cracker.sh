#!/bin/bash

# Cracker module - Unified password cracking interface
# Supports: aircrack-ng, hashcat, john the ripper

# Main cracker menu
cracker_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                 PASSWORD CRACKING                        ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} Aircrack-ng              ${GRAY}CPU-based dictionary attacks${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Hashcat                  ${GRAY}GPU-accelerated cracking{{BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} John the Ripper          ${GRAY}Multi-mode cracking{{BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} Format Converter          ${GRAY}Convert between formats{{BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} Wordlist Manager         {{GRAY}Download/manage wordlists{{BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} Cracking Benchmark       {{GRAY}Test performance{{BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]{{WHITE} Back to Main Menu         {{GRAY}Return{{BLUE}│{{NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘{{NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) cracker_aircrack_menu ;;
            2) cracker_hashcat_menu ;;
            3) cracker_john_menu ;;
            4) cracker_format_converter ;;
            5) cracker_wordlist_manager ;;
            6) cracker_benchmark ;;
            0) break ;;
            *)
                echo -e "${RED}[!] Invalid option{{NC}"
                sleep 2
                ;;
        esac
    done
}

# ══════════════════════════════════════════════════════════════════════════════
# Aircrack-ng Interface
# ══════════════════════════════════════════════════════════════════════════════

cracker_aircrack_menu() {
    while true; do
        clear
        echo -e "${BLUE}Aircrack-ng Cracker{{NC}"
        echo -e "${GRAY}===================={{NC}"
        echo ""
        echo -e "${CYAN}[1]{{NC} Dictionary attack"
        echo -e "${CYAN}[2]{{NC} Brute force"
        echo -e "${CYAN}[3]{{NC} Use rules"
        echo -e "${CYAN}[4]{{NC} Resume session"
        echo -e "${CYAN}[5]{{NC} Show results"
        echo -e "${CYAN}[0]{{NC} Back"
        echo ""
        
        read -p "Select option: " choice
        
        case $choice in
            1) cracker_aircrack_dict ;;
            2) cracker_aircrack_bruteforce ;;
            3) cracker_aircrack_rules ;;
            4) cracker_aircrack_resume ;;
            5) cracker_aircrack_results ;;
            0) break ;;
        esac
    done
}

cracker_aircrack_dict() {
    clear
    echo -e "${BLUE}Aircrack-ng Dictionary Attack{{NC}"
    echo -e "${GRAY}================================{{NC}"
    
    read -p "Enter capture file (.cap): " cap_file
    [[ ! -f "$cap_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    read -p "Enter wordlist: " wordlist
    [[ ! -f "$wordlist" ]] && { echo -e "${RED}[!] Wordlist not found{{NC}"; sleep 2; return; }
    
    echo -e "${YELLOW}[*] Starting aircrack-ng...{{NC}"
    aircrack-ng -w "$wordlist" "$cap_file"
    pause
}

cracker_aircrack_bruteforce() {
    clear
    echo -e "${BLUE}Aircrack-ng Brute Force{{NC}"
    echo -e "${GRAY}=======================.{{NC}"
    
    read -p "Enter capture file: " cap_file
    [[ ! -f "$cap_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    read -p "Min password length [6]: " min_len
    min_len="${min_len:-6}"
    read -p "Max password length [8]: " max_len
    max_len="${max_len:-8}"
    
    echo -e "${YELLOW}[*] This will take a very long time...{{NC}"
    read -p "Continue? (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] && {
        echo -e "${YELLOW}[*] Starting brute force...{{NC}"
        # aircrack-ng -a 3 -b $target_bssid "$cap_file"
        echo -e "${YELLOW}[!] Brute force mode requires ESSID and target selection{{NC}"
    }
    pause
}

cracker_aircrack_rules() {
    clear
    echo -e "${BLUE}Aircrack-ng with Rules{{NC}"
    echo -e "${GRAY}=======================.{{NC}"
    
    echo -e "${YELLOW}[!] Aircrack-ng doesn't support rules natively{{NC}"
    echo -e "${YELLOW}[!] Use: Hashcat (better GPU support) or John (better rules){{NC}"
    pause
}

cracker_aircrack_resume() {
    clear
    echo -e "${BLUE}Resume Aircrack Session{{NC}"
    echo -e "${GRAY}========================{{NC}"
    
    echo -e "${YELLOW}[!] Check .ivs files and resume with same wordlist{{NC}"
    pause
}

cracker_aircrack_results() {
    clear
    echo -e "${BLUE}Aircrack-ng Results{{NC}"
    echo -e "${GRAY}====================.{{NC}"
    
    read -p "Enter capture file: " cap_file
    [[ -f "$cap_file" ]] && {
        echo -e "${YELLOW}[*] Checking for passwords...{{NC}"
        aircrack-ng "$cap_file" 2>&1 | grep -i "key found\|password"
    } || echo -e "${RED}[!] File not found{{NC}}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Hashcat Interface
# ══════════════════════════════════════════════════════════════════════════════

cracker_hashcat_menu() {
    while true; do
        clear
        echo -e "${BLUE}Hashcat Cracker{{NC}"
        echo -e "${GRAY}================.{{NC}"
        echo ""
        echo -e "${CYAN}[1]{{NC} Dictionary attack (mode 22000)"
        echo -e "${CYAN}[2]{{NC} Dictionary + Rules"
        echo -e "${CYAN}[3]{{NC} Brute force (mask)"
        echo -e "${CYAN}[4]{{NC} Combination attack"
        echo -e "${CYAN}[5]{{NC} Hybrid attack"
        echo -e "${CYAN}[6]{{NC} Show GPU status"
        echo -e "${CYAN}[0]{{NC} Back"
        echo ""
        
        read -p "Select option: " choice
        
        case $choice in
            1) cracker_hashcat_dict ;;
            2) cracker_hashcat_rules ;;
            3) cracker_hashcat_mask ;;
            4) cracker_hashcat_combo ;;
            5) cracker_hashcat_hybrid ;;
            6) cracker_hashcat_gpu_status ;;
            0) break ;;
        esac
    done
}

cracker_hashcat_dict() {
    clear
    echo -e "${BLUE}Hashcat Dictionary Attack{{NC}"
    echo -e "${GRAY}============================.{{NC}"
    
    read -p "Enter hash file (.hc22000 or .hccapx): " hash_file
    [[ ! -f "$hash_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    read -p "Enter wordlist: " wordlist
    [[ ! -f "$wordlist" ]] && { echo -e "${RED}[!] Wordlist not found{{NC}"; sleep 2; return; }
    
    local hash_mode="22000"
    [[ "$hash_file" == *.hccapx ]] && hash_mode="2500"
    
    echo -e "${YELLOW}[*] Hash mode: $hash_mode{{NC}"
    echo -e "${YELLOW}[*] Starting hashcat...{{NC}"
    
    hashcat -m "$hash_mode" -a 0 "$hash_file" "$wordlist" --status --status-timer=10
    pause
}

cracker_hashcat_rules() {
    clear
    echo -e "${BLUE}Hashcat with Rules{{NC}"
    echo -e "${GRAY}===================={{NC}"
    
    read -p "Enter hash file: " hash_file
    read -p "Enter wordlist: " wordlist
    read -p "Enter rules file [best64.rule]: " rules_file
    rules_file="${rules_file:-/usr/share/hashcat/rules/best64.rule}"
    
    [[ ! -f "$hash_file" ]] && { echo -e "${RED}[!] Hash file not found{{NC}"; sleep 2; return; }
    [[ ! -f "$wordlist" ]] && { echo -e "${RED}[!] Wordlist not found{{NC}"; sleep 2; return; }
    [[ ! -f "$rules_file" ]] && { echo -e "${RED}[!] Rules file not found{{NC}"; sleep 2; return; }
    
    local hash_mode="22000"
    [[ "$hash_file" == *.hccapx ]] && hash_mode="2500"
    
    echo -e "${YELLOW}[*] Starting hashcat with rules...{{NC}"
    hashcat -m "$hash_mode" -a 0 "$hash_file" "$wordlist" -r "$rules_file" --status
    pause
}

cracker_hashcat_mask() {
    clear
    echo -e "${BLUE}Hashcat Mask Attack{{NC}"
    echo -e "${GRAY}===================={{NC}"
    
    read -p "Enter hash file: " hash_file
    [[ ! -f "$hash_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    echo -e "${WHITE}Common masks:{{NC}"
    echo "  ?d = digit, ?l = lowercase, ?u = uppercase, ?s = special"
    echo "  Examples:"
    echo "    ?d?d?d?d?d?d?d?d = 8 digits"
    echo "    ?l?l?l?l?l?l?l?l = 8 lowercase"
    echo ""
    
    read -p "Enter mask: " mask
    
    local hash_mode="22000"
    echo -e "${YELLOW}[*] Starting mask attack...{{NC}"
    hashcat -m "$hash_mode" -a 3 "$hash_file" "$mask" --status
    pause
}

cracker_hashcat_combo() {
    clear
    echo -e "${BLUE}Hashcat Combination Attack{{NC}"
    echo -e "${GRAY}============================={{NC}"
    
    read -p "Enter hash file: " hash_file
    read -p "Enter first wordlist: " wordlist1
    read -p "Enter second wordlist: " wordlist2
    
    [[ ! -f "$hash_file" || ! -f "$wordlist1" || ! -f "$wordlist2" ]] && {
        echo -e "${RED}[!] File not found{{NC}}"
        sleep 2
        return
    }
    
    local hash_mode="22000"
    echo -e "${YELLOW}[*] Starting combination attack...{{NC}"
    hashcat -m "$hash_mode" -a 1 "$hash_file" "$wordlist1" "$wordlist2" --status
    pause
}

cracker_hashcat_hybrid() {
    clear
    echo -e "${BLUE}Hashcat Hybrid Attack{{NC}"
    echo -e "${GRAY}=======================.{{NC}"
    
    read -p "Enter hash file: " hash_file
    read -p "Enter wordlist: " wordlist
    read -p "Enter mask: " mask
    
    local hash_mode="22000"
    echo -e "${YELLOW}[*] Starting hybrid attack (wordlist + mask)...{{NC}"
    hashcat -m "$hash_mode" -a 6 "$hash_file" "$wordlist" "$mask" --status
    pause
}

cracker_hashcat_gpu_status() {
    clear
    echo -e "${BLUE}GPU Status{{NC}"
    echo -e "${GRAY}===========.{{NC}"
    
    if command -v hashcat &>/dev/null; then
        hashcat --version
        hashcat -I 2>/dev/null | head -20
    else
        echo -e "${RED}[!] Hashcat not found{{NC}}"
    fi
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# John the Ripper Interface
# ══════════════════════════════════════════════════════════════════════════════

cracker_john_menu() {
    while true; do
        clear
        echo -e "${BLUE}John the Ripper{{NC}"
        echo -e "${GRAY}================{{NC}"
        echo ""
        echo -e "${CYAN}[1]{{NC} Single crack mode"
        echo -e "${CYAN}[2]{{NC} Wordlist mode"
        echo -e "${CYAN}[3]{{NC} Incremental mode"
        echo -e "${CYAN}[4]{{NC} Show results"
        echo -e "${CYAN}[5]{{NC} Remove session"
        echo -e "${CYAN}[0]{{NC} Back"
        echo ""
        
        read -p "Select option: " choice
        
        case $choice in
            1) cracker_john_single ;;
            2) cracker_john_wordlist ;;
            3) cracker_john_incremental ;;
            4) cracker_john_show ;;
            5) cracker_john_remove ;;
            0) break ;;
        esac
    done
}

cracker_john_single() {
    clear
    echo -e "${BLUE}John Single Crack{{NC}"
    echo -e "${GRAY}==================.{{NC}"
    
    read -p "Enter hash file: " hash_file
    [[ ! -f "$hash_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    echo -e "${YELLOW}[*] Starting single crack mode...{{NC}"
    john --single "$hash_file"
    pause
}

cracker_john_wordlist() {
    clear
    echo -e "${BLUE}John Wordlist Mode{{NC}"
    echo -e "${GRAY}===================={{NC}"
    
    read -p "Enter hash file: " hash_file
    read -p "Enter wordlist: " wordlist
    
    [[ ! -f "$hash_file" || ! -f "$wordlist" ]] && {
        echo -e "${RED}[!] File not found{{NC}}"
        sleep 2
        return
    }
    
    echo -e "${YELLOW}[*] Starting wordlist mode...{{NC}"
    john --wordlist="$wordlist" "$hash_file"
    pause
}

cracker_john_incremental() {
    clear
    echo -e "${BLUE}John Incremental Mode{{NC}"
    echo -e "${GRAY}=======================.{{NC}"
    
    read -p "Enter hash file: " hash_file
    [[ ! -f "$hash_file" ]] && { echo -e "${RED}[!] File not found{{NC}"; sleep 2; return; }
    
    echo -e "${YELLOW}[*] This can take a very long time...{{NC}"
    read -p "Max password length [8]: " max_len
    max_len="${max_len:-8}"
    
    echo -e "${YELLOW}[*] Starting incremental mode...{{NC}"
    john --incremental --max-length=$max_len "$hash_file"
    pause
}

cracker_john_show() {
    clear
    echo -e "${BLUE}Show John Results{{NC}"
    echo -e "${GRAY}=================={{NC}"
    
    read -p "Enter hash file: " hash_file
    [[ -f "$hash_file" ]] && {
        echo -e "${YELLOW}[*] Cracked passwords:{{NC}"
        john --show "$hash_file"
    } || echo -e "${RED}[!] File not found{{NC}}"
    pause
}

cracker_john_remove() {
    clear
    echo -e "${BLUE}Remove John Session{{NC}"
    echo -e "${GRAY}====================.{{NC}"
    
    read -p "Enter hash file: " hash_file
    [[ -f "$hash_file" ]] && {
        john --remove "$hash_file"
        echo -e "${GREEN}[✓] Session removed{{NC}}"
    } || echo -e "${RED}[!] File not found{{NC}}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Format Converter
# ══════════════════════════════════════════════════════════════════════════════

cracker_format_converter() {
    clear
    echo -e "${BLUE}Format Converter{{NC}"
    echo -e "${GRAY}================={{NC}"
    
    echo -e "${CYAN}[1]{{NC} .cap → .hc22000 (WPA)"
    echo -e "${CYAN}[2]{{NC} .cap → .hccapx (legacy)"
    echo -e "${CYAN}[3]{{NC} .cap → .john"
    echo -e "${CYAN}[4]{{NC} .pcapng → .hc22000"
    echo ""
    
    read -p "Select conversion: " choice
    
    case $choice in
        1)
            read -p "Enter .cap file: " cap_file
            read -p "Output file [output.hc22000]: " output
            output="${output:-output.hc22000}"
            command -v hcxpcapngtool &>/dev/null && {
                hcxpcapngtool "$cap_file" -o "$output"
                echo -e "${GREEN}[✓] Converted to: $output{{NC}}"
            } || echo -e "${RED}[!] hcxpcapngtool not found{{NC}}"
            ;;
        2)
            read -p "Enter .cap file: " cap_file
            read -p "Output file [output.hccapx]: " output
            output="${output:-output.hccapx}"
            command -v cap2hccapx &>/dev/null && {
                cap2hccapx "$cap_file" "$output"
                echo -e "${GREEN}[✓] Converted to: $output{{NC}}"
            } || echo -e "${RED}[!] cap2hccapx not found{{NC}}"
            ;;
        3)
            read -p "Enter .cap file: " cap_file
            read -p "Output file [output.john]: " output
            output="${output:-output.john}"
            command -v wpapcap2john &>/dev/null && {
                wpapcap2john "$cap_file" > "$output"
                echo -e "${GREEN}[✓] Converted to: $output{{NC}}"
            } || echo -e "${RED}[!] wpapcap2john not found{{NC}}"
            ;;
        4)
            read -p "Enter .pcapng file: " pcap_file
            read -p "Output file [output.hc22000]: " output
            output="${output:-output.hc22000}"
            command -v hcxpcapngtool &>/dev/null && {
                hcxpcapngtool "$pcap_file" -o "$output"
                echo -e "${GREEN}[✓] Converted to: $output{{NC}}"
            } || echo -e "${RED}[!] hcxpcapngtool not found{{NC}}"
            ;;
    esac
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Wordlist Manager
# ══════════════════════════════════════════════════════════════════════════════

cracker_wordlist_manager() {
    while true; do
        clear
        echo -e "${BLUE}Wordlist Manager{{NC}"
        echo -e "${GRAY}================={{NC}"
        echo ""
        echo -e "${CYAN}[1]{{NC} List wordlists"
        echo -e "${CYAN}[2]{{NC} Download rockyou.txt"
        echo -e "${CYAN}[3]{{NC} Download Seclists"
        echo -e "${CYAN}[4]{{NC} Decompress wordlist"
        echo -e "${CYAN}[5]{{NC} Merge wordlists"
        echo -e "${CYAN}[6]{{NC} Deduplicate wordlist"
        echo -e "${CYAN}[0]{{NC} Back"
        echo ""
        
        read -p "Select option: " choice
        
        case $choice in
            1) cracker_list_wordlists ;;
            2) cracker_download_rockyou ;;
            3) cracker_download_seclists ;;
            4) cracker_decompress_wordlist ;;
            5) cracker_merge_wordlists ;;
            6) cracker_deduplicate_wordlist ;;
            0) break ;;
        esac
    done
}

cracker_list_wordlists() {
    clear
    echo -e "${YELLOW}Available wordlists:{{NC}}"
    ls -lh /usr/share/wordlists/ 2>/dev/null || echo -e "${YELLOW}[!] /usr/share/wordlists not found{{NC}}"
    pause
}

cracker_download_rockyou() {
    clear
    echo -e "${YELLOW}Downloading rockyou.txt...{{NC}}"
    if [[ -f "/usr/share/wordlists/rockyou.txt.gz" ]]; then
        gunzip -k /usr/share/wordlists/rockyou.txt.gz
        echo -e "${GREEN}[✓] rockyou.txt decompressed{{NC}}"
    else
        echo -e "${YELLOW}[!] rockyou.txt.gz not found{{NC}}"
    fi
    pause
}

cracker_download_seclists() {
    clear
    echo -e "${YELLOW}Seclists installation:{{NC}}"
    echo "sudo apt install seclists"
    pause
}

cracker_decompress_wordlist() {
    clear
    read -p "Enter wordlist file (.gz): " wordlist
    if [[ -f "$wordlist" ]]; then
        gunzip -k "$wordlist"
        echo -e "${GREEN}[✓] Decompressed{{NC}}"
    else
        echo -e "${RED}[!] File not found{{NC}}"
    fi
    pause
}

cracker_merge_wordlists() {
    clear
    read -p "Enter wordlist paths (space-separated): " -a lists
    read -p "Output file: " output
    cat "${lists[@]}" 2>/dev/null | sort -u > "$output"
    local count=$(wc -l < "$output")
    echo -e "${GREEN}[✓] Merged $count unique entries{{NC}}"
    pause
}

cracker_deduplicate_wordlist() {
    clear
    read -p "Enter wordlist file: " wordlist
    if [[ -f "$wordlist" ]]; then
        local before=$(wc -l < "$wordlist")
        sort -u "$wordlist" -o "$wordlist"
        local after=$(wc -l < "$wordlist")
        echo -e "${GREEN}[✓] Removed $((before - after)) duplicates{{NC}}"
    fi
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Cracking Benchmark
# ══════════════════════════════════════════════════════════════════════════════

cracker_benchmark() {
    clear
    echo -e "${BLUE}Cracking Benchmark{{NC}"
    echo -e "${GRAY}===================={{NC}"
    
    echo -e "${CYAN}[1]{{NC} Hashcat benchmark"
    echo -e "${CYAN}[2]{{NC} John benchmark"
    echo -e "${CYAN}[3]{{NC} Compare all tools"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}[*] Running hashcat benchmark...{{NC}}"
            hashcat -b 2>&1 | tail -20
            ;;
        2)
            echo -e "${YELLOW}[*] Running john benchmark...{{NC}}"
            john --test
            ;;
        3)
            echo -e "${YELLOW}[*] Comparing cracking speeds...{{NC}}"
            ;;
    esac
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Helper functions
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
