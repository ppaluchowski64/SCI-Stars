#!/usr/bin/env python3

import socket
import sys

SERVER_HOST = "127.0.0.1"
SERVER_PORT = 7000

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    try:
        sock.connect((SERVER_HOST, SERVER_PORT))
        print(f"Connected to {SERVER_HOST}:{SERVER_PORT}, waiting indefinitely. Press Ctrl+C to exit.")
        
        while True:
            data = sock.recv(1024)
            if not data:
                print("Server closed connection.")
                break
    except KeyboardInterrupt:
        print("\nInterrupted by user, closing connection.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()
        sys.exit(0)

if __name__ == "__main__":
    main()
