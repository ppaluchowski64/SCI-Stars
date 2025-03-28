import asyncio

class ServerInstance:
    def __init__(self, instance_id):
        self.instance_id = instance_id
        self.required_players = 8
        self.mode = 'loading'
        self.players = []

    async def run(self):
        print(f'Started instance {self.instance_id}')
        while self.mode == 'loading':
            await asyncio.sleep(1)
            if len(self.players) == self.required_players:
                self.mode = 'gameplay'
                print(f'Instance {self.instance_id} switching to gameplay mode')
                break

        await self.start_gameplay()

    async def start_gameplay(self):
        print(f'Gameplay started for instance {self.instance_id}')
        await asyncio.sleep(10)  # Simulate gameplay
        print(f'Gameplay ended for instance {self.instance_id}')
        self.mode = 'ended'

    def add_player(self, player_id):
        if self.mode == 'loading':
            self.players.append(player_id)
            print(f'Player {player_id} added to instance {self.instance_id}, total players: {len(self.players)}')

    def __del__(self):
        print(f'Server instance {self.instance_id} destroyed')
