#!/usr/bin/env python3

import socket
import sys
import json

from message_handler import MessageHandler


SERVER_HOST = "127.0.0.1"
SERVER_PORT = 7000


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    buffer = ""

    try:
        sock.connect((SERVER_HOST, SERVER_PORT))
        print(f"Connected to {SERVER_HOST}:{SERVER_PORT}, waiting for server messages. Press Ctrl+C to exit.")

        handler = MessageHandler()
        instance_id = None
        player_id = None

        while True:
            data = sock.recv(1024)
            if not data:
                print("Server closed connection.")
                break

            buffer += data.decode('utf-8', 'ignore')
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                try:
                    msg = handler.parse_message(line)
                except Exception as e:
                    print(f"[Client] Error parsing message: {e}")
                    continue

                if msg["type"] == "response" and msg["command"] == "start_gameplay":
                    payload = msg["payload"]
                    instance_id = payload.get("instance_id")
                    player_id = payload.get("player_id")
                    print(f"[Client] Game started: instance_id={instance_id}, player_id={player_id}")

                elif msg["type"] == "response" and msg["command"] == "instance_id_update":
                    payload = msg["payload"]
                    instance_id = payload.get("instance_id")
                    print(f"[Client] Updated instance_id -> {instance_id} (you are player {player_id})")

                else:
                    pass

    except KeyboardInterrupt:
        print("\nInterrupted by user, closing connection.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()
        sys.exit(0)


if __name__ == "__main__":
    main()
