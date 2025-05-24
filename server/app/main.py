#!/usr/bin/env python3

import asyncio

from server_instance import ServerInstance
from input_forwarder import InputForwarder
from question_server import QuestionServer


def initialize_servers():
    return []


async def create_server(servers):
    server = ServerInstance(len(servers))
    servers.append(server)

    await server.ready.wait()

    print(f"Server instance {server.instance_id} is ready")
    return server


async def listen_for_players(servers):
    async def handle_client(reader, writer):
        loading_server = None

        for server in servers:
            if server.mode == "loading":
                loading_server = server
                break
        
        if loading_server is None:
            loading_server = await create_server(servers)

        player_id = len(loading_server.players)
        loading_server.add_player(player_id, writer)

        try:
            while True:
                if loading_server.mode == "ended":
                    break
                
                data = await reader.read(100)
                if not data:
                    break
        finally:
            loading_server.remove_player(player_id)
            writer.close()
            await writer.wait_closed()
            print(
                f"Player {player_id} disconnected "
                f"from instance {loading_server.instance_id}"
            )

    server = await asyncio.start_server(handle_client, "0.0.0.0", 7000)
    print("Listening for player connections on port 7000")
    async with server:
        await server.serve_forever()


async def manage_server_instances(servers):
    while True:
        await asyncio.sleep(1)

        if any(server.mode == "ended" for server in servers):
            clean_servers(servers)
            update_server_ids(servers)


def clean_servers(servers):
    servers[:] = [server for server in servers if server.mode != "ended"]


def update_server_ids(servers):
    for i, server in enumerate(servers):
        server.instance_id = i

    print("Updated instance IDs")


async def run_input_forwarder(servers):
    input_forwarder = InputForwarder(servers)
    await input_forwarder.start()


async def run_question_server():
    question_server = QuestionServer()
    await question_server.start()


async def main():
    servers = initialize_servers()

    await asyncio.gather(
        listen_for_players(servers),
        manage_server_instances(servers),
        run_input_forwarder(servers),
        run_question_server(),
    )


if __name__ == "__main__":
    asyncio.run(main())
