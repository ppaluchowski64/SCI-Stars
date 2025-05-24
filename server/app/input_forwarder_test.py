import asyncio

from message_handler import MessageHandler


class UDPClientProtocol(asyncio.DatagramProtocol):
    def __init__(self, handler):
        self.handler = handler

    def connection_made(self, transport):
        self.transport = transport
        addr = transport.get_extra_info('sockname')
        print("[Client] Bound to", addr)

    def datagram_received(self, data, addr):
        text = data.decode('utf-8', 'ignore').strip()

        try:
            message = self.handler.parse_message(text)

            if (
                message["type"] == "request"
                and message["command"] == "input"
            ):
                payload = message["payload"]
                source_id = payload["player_id"]
                content = payload["input"]

                print(f"\n[Broadcast] Player {source_id}: {content}")
                print("> ", end="", flush=True)

        except Exception:
            pass


async def user_input_loop(transport, server_addr, instance_id, player_id, handler):
    while True:
        user_input = await asyncio.to_thread(input, "> ")
        user_input = user_input.strip()

        if user_input.lower() == "exit":
            break

        message = handler.create_message(
            "request",
            "input",
            {
                "instance_id": instance_id,
                "player_id": player_id,
                "input": user_input,
            },
        )
        transport.sendto(message.encode("utf-8"), server_addr)


async def main():
    instance_id = int(await asyncio.to_thread(input, "Instance ID: "))
    player_id = int(await asyncio.to_thread(input, "Player ID: "))

    handler = MessageHandler()
    server_addr = ("127.0.0.1", 7001)

    loop = asyncio.get_running_loop()
    transport, _ = await loop.create_datagram_endpoint(
        lambda: UDPClientProtocol(handler),
        local_addr=("0.0.0.0", 0),
    )

    print("Enter inputs (type 'exit' to quit):")

    await user_input_loop(transport, server_addr, instance_id, player_id, handler)

    transport.close()
    print("Client exiting.")


if __name__ == "__main__":
    asyncio.run(main())
