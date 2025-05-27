extends Node2D

@onready var udp := PacketPeerUDP.new()
@onready var handler = MessageHandler.new()

var server_ip := "127.0.0.1"
var server_port := 7001

var instance_id := 0
var player_id := 0

var connected := false

var main_player: CharacterBody2D

func start_connection():
	udp.connect_to_host(server_ip, server_port)
	connected = true
	print("UDP client ready, sending and listening to %s:%d" % [server_ip, server_port])
	
	var msg = handler.create_message("debug_input", "input")
	udp.put_packet(msg.to_utf8_buffer())

func _process(_delta):
	if not connected:
		return
	
	if not main_player:
		recieve_udp()
		return
	
	var move_vec := Input.get_vector("left", "right", "up", "down")
	
	if move_vec.length() > 0 or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("super_attack"):
		var input_data := {}
		
		if move_vec.length() > 0:
			input_data["move_x"] = move_vec.x
			input_data["move_y"] = move_vec.y
		
		if main_player.shoot_cooldown.time_left == 0:
			if Input.is_action_just_pressed("attack") and main_player.ammo >= 1 and not main_player.block_controls:
				main_player.set_shoot_angle()
				input_data["attack_angle"] = main_player.shoot_angle
			
			if Input.is_action_just_pressed("super_attack") and main_player.super_charge >= 1 and not main_player.block_controls:
				main_player.set_shoot_angle()
				input_data["super_angle"] = main_player.shoot_angle
		
		var msg = handler.create_message(
			"request",
			"input",
			{
				"instance_id": instance_id,
				"player_id": player_id,
				"input": input_data
			}
		)
		
		if msg != null:
			udp.put_packet(msg.to_utf8_buffer())
	
	recieve_udp()

func recieve_udp() -> void:
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var text = packet.get_string_from_utf8()
		
		var message = handler.parse_message(text)
		if message:
			_handle_input_message(message)

func _handle_input_message(message: Dictionary) -> void:
	if message.command == "input":
		var sender_id = message.payload.get("player_id", -1)
		var sender_input = message.payload.get("input", {})
		
		#print("Received input from player %d: %s" % [sender_id, str(sender_input)])
		
		for player in get_tree().get_first_node_in_group("players").get_children():
			if player.id == sender_id:
				if sender_input.has("move_x") and sender_input.has("move_y"):
					player.dir_vec.x = sender_input["move_x"]
					player.dir_vec.y = sender_input["move_y"]
				
				if sender_input.has("attack_angle"):
					player.shoot_angle = sender_input["attack_angle"]
					player.regular_attack(true)
				
				elif sender_input.has("super_angle"):
					player.shoot_angle = sender_input["super_angle"]
					player.super_attack(true)
