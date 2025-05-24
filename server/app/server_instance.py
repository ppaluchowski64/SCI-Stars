import asyncio

class ServerInstance:
    def __init__(self, instance_id):
        self.instance_id = instance_id
        self.required_players = 8
        self.mode = "loading"
        self.players = {}
        self.ready = asyncio.Event()

        print(f"Started instance {self.instance_id}")
        self.ready.set()

    async def start_gameplay(self):
        print(f"Gameplay started for instance {self.instance_id}")
        # Gameplay

    def add_player(self, player_id, writer):
        if self.mode == "loading":
            self.players[player_id] = writer
            print(
                f"Player {player_id} added to instance {self.instance_id}, "
                f"total players: {len(self.players)}"
            )

            if len(self.players) == self.required_players:
                self.mode = "gameplay"
                print(f"Instance {self.instance_id} switching to gameplay mode")
                asyncio.create_task(self.start_gameplay())
    
    def remove_player(self, player_id):
        if player_id in self.players:
            del self.players[player_id]
            print(
                f"Player {player_id} removed from instance {self.instance_id}, "
                f"total players: {len(self.players)}"
            )
        
            if len(self.players) == 1 and self.mode == "gameplay":
                print(f"Gameplay ended for instance {self.instance_id}")
                self.mode = "ended"
                
                last_writer = next(iter(self.players.values()))
                last_writer.close()
                asyncio.create_task(last_writer.wait_closed())
    
    def __del__(self):
        print(f"Server instance {self.instance_id} destroyed")
