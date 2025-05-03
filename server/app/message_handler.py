import json


class MessageHandler:
    @staticmethod
    def create_message(message_type, command, payload=None):
        if payload is not None and not isinstance(payload, dict):
            raise TypeError("payload must be a dict or None")

        message = {
            "type": message_type,
            "command": command,
            "payload": payload if payload else {}
        }

        return json.dumps(message, separators=(',', ':')) + '\n'

    @staticmethod
    def parse_message(data):
        message = json.loads(data)
        if not isinstance(message, dict):
            raise ValueError("Parsed message must be a JSON object (dict)")

        if "type" not in message or "command" not in message or "payload" not in message:
            raise ValueError("Message must contain 'type', 'command', and 'payload' keys")

        if not isinstance(message["payload"], dict):
            raise TypeError("Payload must be a dict")

        return message


if __name__ == "__main__":
    mh = MessageHandler()

    msg1 = mh.create_message("type", "command")
    msg2 = mh.create_message("type", "command", {"payload": "payload"})

    print(msg1)
    print(msg2)

    parsed1 = mh.parse_message(msg1)
    parsed2 = mh.parse_message(msg2)

    print(parsed1)
    print(parsed2)
