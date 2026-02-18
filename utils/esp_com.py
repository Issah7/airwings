#!/usr/bin/env python3
import sys
import time
import os
import threading
import serial
import serial.tools.list_ports

def list_ports():
    ports = list(serial.tools.list_ports.comports())
    return [p.device for p in ports]

def send_command(port, baud, cmd, wait=3):
    try:
        ser = serial.Serial(port, baud, timeout=1)
        time.sleep(0.3)
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        
        ser.write(b'\r\n')
        time.sleep(0.3)
        ser.reset_input_buffer()
        
        ser.write(f"{cmd}\r\n".encode())
        
        time.sleep(wait)
        
        lines = []
        while ser.in_waiting:
            line = ser.readline().decode('utf-8', errors='replace').strip()
            if line:
                lines.append(line)
        
        ser.close()
        return '\n'.join(lines)
    except Exception as e:
        return f"ERROR: {e}"

def interactive_terminal(port, baud):
    print(f"Connected to {port} at {baud} bps")
    print("Type commands and press Enter. Type 'exit' to quit.")
    print("-" * 50)
    
    try:
        ser = serial.Serial(port, baud, timeout=0.1)
        
        def reader():
            while True:
                try:
                    if ser.in_waiting:
                        data = ser.read(ser.in_waiting)
                        print(data.decode('utf-8', errors='replace'), end='')
                    time.sleep(0.05)
                except:
                    break
        
        reader_thread = threading.Thread(target=reader, daemon=True)
        reader_thread.start()
        
        while True:
            cmd = input()
            if cmd.lower() == 'exit':
                break
            ser.write(f"{cmd}\r\n".encode())
            time.sleep(0.1)
        
        ser.close()
    except Exception as e:
        print(f"Error: {e}")

def check_connection(port, baud):
    if not port or not os.path.exists(port):
        return False, "Port does not exist"
    
    response = send_command(port, baud, "ram", wait=3)
    
    keywords = ['deauther', 'spacehuhn', 'esp8266', 'sdk', 'channel', 'mac', 'chip', 'free', 'version', 'uptime', 'heap', 'kb']
    response_lower = response.lower()
    
    for kw in keywords:
        if kw in response_lower:
            return True, response
    
    return False, response

def main():
    if len(sys.argv) < 2:
        print("Usage: esp_com.py <command> [args...]")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == "list":
        for p in list_ports():
            print(p)
    elif cmd == "check":
        port = sys.argv[2] if len(sys.argv) > 2 else "/dev/ttyUSB0"
        baud = int(sys.argv[3]) if len(sys.argv) > 3 else 115200
        success, response = check_connection(port, baud)
        print(response)
        sys.exit(0 if success else 1)
    elif cmd == "send":
        port = sys.argv[2] if len(sys.argv) > 2 else "/dev/ttyUSB0"
        baud = int(sys.argv[3]) if len(sys.argv) > 3 else 115200
        command = sys.argv[4] if len(sys.argv) > 4 else "sysinfo"
        wait = int(sys.argv[5]) if len(sys.argv) > 5 else 3
        print(send_command(port, baud, command, wait))
    elif cmd == "terminal":
        port = sys.argv[2] if len(sys.argv) > 2 else "/dev/ttyUSB0"
        baud = int(sys.argv[3]) if len(sys.argv) > 3 else 115200
        interactive_terminal(port, baud)
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)

if __name__ == "__main__":
    main()
