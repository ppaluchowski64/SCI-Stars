extends Node

@onready var tcp := StreamPeerTCP.new()
@onready var handler = MessageHandler.new()

var is_connected: bool = false
var buffer_text: String = ""

var connected_players: int = 1
var is_instance_starting: bool = false

func start_connection():
	connected_players = 1
	
	var err = tcp.connect_to_host("127.0.0.1", 7000)
	
	if err != OK:
		push_error("Connection error: %d" % err)
	else:
		print("Connection attempt sent...")

func _process(_delta):
	tcp.poll()

	if not is_connected and tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		is_connected = true
		print("Connected to the server!")
		_send_player_stats()

	if is_connected:
		var available = tcp.get_available_bytes()
		if available > 0:
			var result = tcp.get_data(available)
			var err = result[0]
			var data_buffer = result[1]

			if err != OK:
				push_error("Error receiving data")
				is_connected = false
				tcp.disconnect_from_host()
				return

			var chunk = data_buffer.get_string_from_utf8()
			buffer_text += chunk

			while buffer_text.find("\n") != -1:
				var newline_pos = buffer_text.find("\n")
				var line = buffer_text.substr(0, newline_pos)
				buffer_text = buffer_text.substr(newline_pos + 1, buffer_text.length() - newline_pos - 1)

				var message = handler.parse_message(line)
				if message:
					_handle_message(message)

func _send_player_stats():
	var upgrades: Array = []
	var raw_upgrades: Array = PlayerData.character_stats[PlayerData.selected_character]

	for stat in raw_upgrades:
		if stat is PlayerData.Stat:
			upgrades.append(stat.to_dict())
		else:
			push_error("Invalid stat object in upgrades")
			return
	
	var player_stats: Dictionary = {
		"nickname": PlayerData.nickname,
		"character": PlayerData.selected_character,
		"upgrades": upgrades
	}
	
	var msg = handler.create_message(
		"request",
		"player_stats",
		player_stats
	)
	if msg != null:
		tcp.put_data(msg.to_utf8_buffer())
		print("Sent player stats to server")

func _handle_message(message: Dictionary) -> void:
	match message.command:
		"start_gameplay":
			print("Gameplay has started! Instance ID: ", int(message.payload.instance_id), ", Player ID: ", int(message.payload.player_id))
			
			PlayerData.instance_id = int(message.payload.instance_id)
			PlayerData.player_id = int(message.payload.player_id)
			
			RemoteInputHandler.instance_id = int(message.payload.instance_id)
			RemoteInputHandler.player_id = int(message.payload.player_id)
			
			is_instance_starting = true
		
		"instance_id_update":
			print("Update! Instance ID: ", int(message.payload.instance_id), ", Player ID: ", int(message.payload.player_id))
			
		"players_stats":
			print("Received players stats broadcast:")
			
			PlayerData.online_player_stats = message.payload.duplicate(true)
			
			for pid in message.payload.keys():
				#print("Player ID: ", pid, ", Stats: ", message.payload[pid])
				pass
		_:
			# other commands can be added here if needed
			pass
