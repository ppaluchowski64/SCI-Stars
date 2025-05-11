#!/usr/bin/env python3

import asyncio

from server_instance import ServerInstance
from question_server import QuestionServer


def initialize_servers():
    return []


async def create_server(servers):
    server = ServerInstance(len(servers))
    servers.append(server)

    asyncio.create_task(server.run())
    await server.ready.wait()

    print(f"Server instance {server.instance_id} is ready")
    return server


async def add_players_to_servers(servers, num_players):
    players_added = 0
    loading_server = None

    while players_added < num_players:
        await asyncio.sleep(1)

        if loading_server is None or loading_server.mode != "loading":
            loading_server = await create_server(servers)

        if len(loading_server.players) < loading_server.required_players:
            player_id = len(loading_server.players)
            loading_server.add_player(player_id)

            players_added += 1


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


async def run_question_server():
    question_server = QuestionServer()
    await question_server.start()


async def main():
    servers = initialize_servers()

    await asyncio.gather(
        add_players_to_servers(servers, 30),
        manage_server_instances(servers),
        run_question_server(),
    )


if __name__ == "__main__":
    asyncio.run(main())
