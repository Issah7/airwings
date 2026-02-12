# Airwings - Comprehensive Wireless Security Testing Suite

## ⚠️ LEGAL WARNING

**FOR AUTHORIZED TESTING ONLY!**

All tools and techniques in this suite are strictly for:
- ✅ Testing your own networks
- ✅ Authorized penetration testing
- ✅ Educational purposes (with isolated networks)
- ✅ Security awareness training

**UNAUTHORIZED USE IS ILLEGAL:**
- ❌ Testing networks without permission
- ❌ Public WiFi attacks
- ❌ Credential harvesting without authorization
- ❌ Any malicious activity

**Penalties vary by jurisdiction:**
- 🇺🇸 US: Fines up to $250,000, 20 years prison
- 🇬🇧 UK: Unlimited fines, 10 years prison
- 🇪🇺 EU: €20 million or 4% global revenue

## 🎯 What is Airwings?

**Airwings** is an integrated wireless security testing suite that combines the power of multiple tools into a unified, user-friendly interface. It provides comprehensive capabilities for authorized WiFi security testing.

### 🚀 Key Features

- **Integrated Interface** - Unified menu system for all tools
- **Multi-Tool Support** - airgeddon, ESP8266, aircrack-ng, hashcat
- **Captive Portal Creation** - Professional phishing pages with templates
- **Hardware Integration** - ESP8266 Deauther support with Huhnitor
- **Attack Automation** - One-click workflows for common attacks
- **Plugin System** - Extensible architecture
- **Real-time Analytics** - Monitor attack progress and results

### 🛠️ Tools Integrated

| Tool | Purpose | Integration |
|-------|---------|--------------|
| **airgeddon** | Comprehensive WiFi attacks | Full integration with all modules |
| **ESP8266 Deauther** | Hardware-based attacks | Serial control, web interface |
| **aircrack-ng** | Capture & cracking | Automated workflows |
| **hashcat** | GPU password cracking | Optimized integration |
| **Huhnitor** | ESP8266 monitoring | Built-in serial terminal |
| **Bettercap** | MITM attacks | Advanced capabilities |
| **reaver/bully** | WPS attacks | Automated WPS workflows |

## 📦 Installation

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install core dependencies
sudo apt install -y git python3 python3-pip

# Install wireless tools
sudo apt install -y aircrack-ng bettercap mdk4 reaver bully

# Install Python tools
pip3 install scapy requests

# Install ESP8266 tools
pip3 install esptool huhnitor

# Install hashcat (for GPU cracking)
sudo apt install -y hashcat
```

### Install Airwings

```bash
# Clone repository
cd /opt/
sudo git clone https://github.com/your-repo/airwings.git
cd airwings

# Make executable
chmod +x bin/airwings.sh

# Create symlink for easy access
sudo ln -s /opt/airwings/bin/airwings.sh /usr/local/bin/airwings

# Run
sudo airwings
```

## 🎮 Usage

### Basic Navigation

```bash
# Launch airwings
sudo airwings

# Navigate menus using number keys
# Follow on-screen instructions
# Return to main menu with option 0
```

### Main Menu Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                      MAIN MENU                          │
├─────────────────────────────────────────────────────────────────┤
│ [1] Interface Management       Setup and manage interfaces    │
│ [2] Network Scanning          Discover and analyze networks  │
│ [3] Airgeddon Integration      Launch airgeddon attacks     │
│ [4] ESP8266 Deauther         Hardware-based attacks      │
│ [5] Captive Portal Attacks    Evil Twin with custom pages │
│ [6] Handshake & Password      Capture and crack passwords │
│ [7] Advanced Attacks          WPS, DoS, MITM           │
│ [8] Plugin Manager           Manage airgeddon plugins    │
│ [9] Tools & Utilities        Additional utilities        │
│ [10] Configuration            Settings and preferences    │
│ [0] Exit                     Exit airwings              │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Core Workflows

### 1. Evil Twin Attack with Captive Portal

```
1. Interface Management → Select Interface → Enable Monitor Mode
2. Network Scanning → Quick Scan → Note target BSSID/Channel/ESSID
3. Captive Portal Attacks → Select Template (Facebook, Hotel, etc.)
4. Enter target details → Launch attack
5. Monitor captive portal → View captured credentials
```

### 2. ESP8266 Hardware Attack

```
1. ESP8266 Deauther → Flash Firmware
2. Select ESP8266 device → Choose firmware
3. Web Interface → Connect to "pwned" network
4. Select attack type → Configure parameters
5. Monitor results via web interface or Huhnitor
```

### 3. WPA Handshake Capture & Cracking

```
1. Network Scanning → Detailed Scan → Find targets
2. Handshake & Password → Capture Handshake
3. Deauth target → Force authentication
4. Verify handshake → Check .cap file
5. Password Cracking → Use hashcat or aircrack-ng
```

## 🎨 Captive Portal Templates

### Available Templates

| Template | Target Environment | Features |
|-----------|-------------------|----------|
| **Facebook WiFi** | Coffee shops, urban areas | Modern UI, high trust |
| **Google WiFi** | Professional environments | Material design, clean |
| **Hotel Portal** | Hospitality industry | Room + name fields |
| **Airport WiFi** | Transportation hubs | Travel-themed UI |
| **Starbucks** | Coffee chains | Brand-mimicking |
| **University** | Educational campuses | Academic styling |
| **Corporate** | Business environments | Professional design |
| **Router Config** | Technical environments | System admin theme |

### Custom Portal Creation

```bash
# Access custom portal creation
Captive Portal Attacks → Custom Captive Portal → Create from scratch

# Options:
- HTML/CSS editor
- Template cloning
- Website cloning
- Mobile responsive design
- Multi-language support
```

## 📡 ESP8266 Integration

### Setup

```bash
1. Flash ESP8266 with Deauther firmware
2. Connect via USB or WiFi
3. Use built-in Huhnitor serial monitor
4. Access web interface at http://192.168.4.1
```

### ESP8266 Features

- **Hardware attacks** - Standalone deauth/beacon
- **Web interface** - Browser-based control
- **Serial control** - Huhnitor integration
- **Script support** - Automated attack sequences
- **OLED display** - Standalone operation (optional)

## 🔐 Password Cracking

### Methods

1. **Dictionary Attack**
   ```bash
   hashcat -m 22000 handshake.hc22000 rockyou.txt
   ```

2. **Rule-based Attack**
   ```bash
   hashcat -m 22000 handshake.hc22000 wordlist.txt -r rules/best64.rule
   ```

3. **Brute Force**
   ```bash
   hashcat -m 22000 handshake.hc22000 -a 3 ?l?l?l?l?d?d?d?d
   ```

4. **Mask Attack**
   ```bash
   hashcat -m 22000 handshake.hc22000 -a 3 password?d?d?d
   ```

### Optimized Wordlists

```bash
# Download rockyou (14M passwords)
wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

# SecLists (comprehensive)
git clone https://github.com/danielmiessler/SecLists.git
```

## 🎚️ Advanced Features

### DoS Pursuit Mode
- Multi-interface setup
- Channel hopping detection
- Automatic target tracking
- Unattended operation

### Enterprise Attacks
- EAP-TTLS/PEAP support
- RADIUS credential harvesting
- Certificate-based attacks
- Network discovery

### Plugin System
- airgeddon plugin integration
- Custom attack modules
- Template sharing
- Community contributions

## 📊 Analytics & Monitoring

### Real-time Monitoring

- **Attack Progress** - Live status updates
- **Capture Statistics** - Success rates, packet counts
- **Victim Analytics** - Device fingerprinting, behavior
- **Performance Metrics** - Signal strength, channel usage

### Data Export

```bash
# Export captured credentials
Export captured data → CSV/JSON/HTML formats

# Attack log analysis
Parse attack logs → Generate reports

# Network mapping
Visualize discovered networks → Export to KML/CSV
```

## 🛡️ Safety & Ethics

### Pre-Attack Checklist

- [ ] Written authorization from network owner
- [ ] Defined scope and limitations
- [ ] Backed up original configurations
- [ ] Emergency contact procedures
- [ ] Legal compliance verified
- [ ] Test environment isolated

### During Attack

- [ ] Monitor for unintended effects
- [ ] Stop if non-target systems affected
- [ ] Document all activities
- [ ] Respect time windows
- [ ] Maintain privacy protections

### Post-Attack

- [ ] Restore original configurations
- [ ] Secure captured data
- [ ] Generate detailed report
- [ ] Disclose findings responsibly
- [ ] Clean up temporary files

## 🔧 Configuration

### Main Config File

Location: `config/airwings.conf`

```ini
# Interface Settings
DEFAULT_INTERFACE=""
MONITOR_INTERFACE=""
INTERNET_INTERFACE="eth0"

# ESP8266 Settings
ESP8266_PORT="/dev/ttyUSB0"
ESP8266_BAUD="115200"

# Attack Settings
DEAUTH_COUNT="20"
HANDSHAKE_TIMEOUT="30"
CAPTIVE_PORT="80"

# Password Cracking
WORDLIST_PATH="/usr/share/wordlists/rockyou.txt"
HASHCAT_GPU="true"
HASHCAT_THREADS="4"
```

### Customization Options

- **Interface selection** - Choose primary/default interfaces
- **Attack parameters** - Default packet counts, timeouts
- **Logging configuration** - Verbosity, rotation, retention
- **Visual settings** - ASCII art, colors, themes
- **Auto-update** - Automatic tool updates

## 📁 File Structure

```
airwings/
├── bin/
│   └── airwings.sh              # Main executable
├── modules/
│   ├── core.sh                  # Core functions
│   ├── interface.sh             # Interface management
│   ├── scanner.sh              # Network scanning
│   ├── attacks.sh              # Attack modules
│   ├── esp8266.sh             # ESP8266 integration
│   ├── captive-portal.sh       # Captive portal creation
│   ├── cracker.sh             # Password cracking
│   ├── plugins.sh              # Plugin system
│   └── utils.sh               # Utility functions
├── config/
│   └── airwings.conf           # Main configuration
├── logs/
│   ├── scans/                  # Scan results
│   ├── captures/               # Handshake files
│   ├── credentials/            # Captured data
│   └── airwings.log           # Application log
├── templates/
│   ├── facebook-wifi/          # Portal templates
│   ├── hotel-portal/
│   ├── airport-wifi/
│   └── ...
├── plugins/
│   ├── custom-portals.sh        # airgeddon plugins
│   └── multi-int.sh
├── utils/
│   ├── wordlist-manager.sh      # Wordlist utilities
│   └── report-generator.sh     # Reporting tools
└── README.md                  # This file
```

## 🚀 Advanced Usage

### Scripting & Automation

```bash
# Create custom attack script
custom_attack.sh
├── scan_target.sh
├── launch_evil_twin.sh
└── monitor_results.sh

# Execute from airwings
Tools & Utilities → Run Custom Script
```

### Multi-Interface Attacks

```bash
# Setup for dual-interface Evil Twin
Interface Management → Select two interfaces
- Interface 1: Monitor mode for DoS
- Interface 2: AP mode for Evil Twin

# Configure DoS pursuit mode
Advanced Attacks → DoS Pursuit Mode
```

### Plugin Development

```bash
# Create custom plugin
plugins/my_custom_plugin.sh
├── Plugin metadata
├── Hook functions
└── Attack logic

# Install in airgeddon
cp plugins/my_custom_plugin.sh /path/to/airgeddon/plugins/
```

## 🐛 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Interface not detected | Check USB drivers, try different port |
| Monitor mode failed | Kill NetworkManager: `airmon-ng check kill` |
| Evil Twin not starting | Check VIF support, verify regulatory domain |
| Handshake not captured | Increase deauth packets, move closer |
| ESP8266 not responding | Check USB connection, verify port |
| Hashcat GPU not working | Install proper drivers, check `hashcat -I` |

### Debug Mode

```bash
# Enable debug logging
airwings --debug

# Verbose output
airwings --verbose

# Check configuration
airwings --check-config
```

### Getting Help

```bash
# Command line help
airwings --help

# Module-specific help
airwings --help-module esp8266

# Version info
airwings --version
```

## 📚 Learning Resources

### Official Documentation
- [airgeddon Wiki](https://github.com/v1s1t0r1sh3r3/airgeddon/wiki)
- [ESP8266 Deauther Docs](https://deauther.com)
- [Aircrack-ng Docs](https://aircrack-ng.org)
- [Hashcat Wiki](https://hashcat.net/wiki)

### Security Training
- [Hack The Box](https://hackthebox.eu)
- [TryHackMe](https://tryhackme.com)
- [OSWP Certification](https://www.offensive-security.com/information-security-certifications/oswp/)

### Communities
- [r/HowToHack](https://reddit.com/r/HowToHack)
- [airgeddon Discord](https://discord.gg/sQ9dgt9)
- [ESP8266 Forum](https://www.esp8266.com)

## 🤝 Contributing

### Development Setup

```bash
# Clone development version
git clone -b develop https://github.com/your-repo/airwings.git

# Install development dependencies
pip3 install -r requirements-dev.txt

# Run tests
./tests/run_tests.sh
```

### Submitting Changes

1. Fork repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚡ Quick Start

```bash
# 1. Install
cd /opt && sudo git clone https://github.com/your-repo/airwings.git && cd airwings && sudo ln -s $(pwd)/bin/airwings.sh /usr/local/bin/airwings

# 2. Run
sudo airwings

# 3. Start with Interface Management
# 4. Enable monitor mode
# 5. Scan networks
# 6. Choose your attack

**Remember: Only test networks you own or have explicit permission to test!**
```

---

**🔴 CRITICAL REMINDER:** This tool is for authorized security testing only. Unauthorized use is illegal and unethical. Always obtain proper authorization and follow applicable laws and regulations.

---

*Made with ❤️ for security professionals and ethical hackers*# airwings
