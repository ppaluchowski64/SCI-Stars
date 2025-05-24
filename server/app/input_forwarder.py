import asyncio

from message_handler import MessageHandler


class InputForwarderProtocol(asyncio.DatagramProtocol):
    def __init__(self, instances, handler):
        self.instances = instances
        self.handler = handler

    def connection_made(self, transport):
        self.transport = transport
        address = transport.get_extra_info('sockname')

        print("[InputForwarder] Listening on", address)

    def datagram_received(self, data, sender_address):
        raw_text = data.decode('utf-8', 'ignore').strip()

        print("[InputForwarder] Received from", sender_address, "->", raw_text)

        try:
            message = self.handler.parse_message(raw_text)

            if (
                message["type"] != "request"
                or message["command"] != "input"
            ):
                return

            payload = message["payload"]

            instance_id = payload["instance_id"]
            player_id = payload["player_id"]
            user_input = payload["input"]

        except Exception as error:
            error_response = self.handler.create_message(
                "response",
                "error",
                {"message": str(error)},
            )

            self.transport.sendto(
                error_response.encode("utf-8"),
                sender_address,
            )
            return

        instance = next(
            (i for i in self.instances if i.instance_id == instance_id),
            None,
        )

        if not instance:
            error_response = self.handler.create_message(
                "response",
                "error",
                {"message": f"instance_{instance_id}_not_found"},
            )

            self.transport.sendto(
                error_response.encode("utf-8"),
                sender_address,
            )
            return

        if not hasattr(instance, "udp_peers"):
            instance.udp_peers = {}

        instance.udp_peers[player_id] = sender_address

        print(
            f"[InputForwarder] Registered player {player_id}"
            f" in instance {instance_id}"
        )

        forward_message = self.handler.create_message(
            "request",
            "input",
            {"player_id": player_id, "input": user_input},
        ).encode("utf-8")

        for other_id, other_address in instance.udp_peers.items():
            if other_id == player_id:
                continue

            self.transport.sendto(forward_message, other_address)

            print(
                f"[InputForwarder] Forwarded from {player_id}"
                f" to {other_id}"
            )


class InputForwarder:
    def __init__(self, instances, host="0.0.0.0", port=7001):
        self.instances = instances
        self.host = host
        self.port = port
        self.handler = MessageHandler()

    async def start(self):
        loop = asyncio.get_running_loop()

        await loop.create_datagram_endpoint(
            lambda: InputForwarderProtocol(self.instances, self.handler),
            local_addr=(self.host, self.port),
        )
