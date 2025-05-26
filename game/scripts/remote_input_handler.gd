extends Node2D

@onready var udp := PacketPeerUDP.new()
@onready var handler = MessageHandler.new()

var server_ip := "127.0.0.1"
var server_port := 7001

var instance_id := 0
var player_id := 0

var connected := false

func _ready():
	udp.connect_to_host(server_ip, server_port)
	connected = true
	print("UDP client ready, sending and listening to %s:%d" % [server_ip, server_port])

func _process(_delta):
	if not connected:
		return
	
	var move_vec := Input.get_vector("left", "right", "up", "down")
	var mouse_clicked := Input.is_action_just_pressed("ui_click")
	
	if move_vec.length() > 0 or mouse_clicked:
		var input_data := {}
		
		if move_vec.length() > 0:
			input_data["move_x"] = move_vec.x
			input_data["move_y"] = move_vec.y
		
		if mouse_clicked:
			var mouse_pos = get_viewport().get_mouse_position()
			var player_pos = global_position if self is Node2D else Vector2.ZERO
			var angle = Vector2.RIGHT.angle_to(mouse_pos - player_pos)
			input_data["click_angle"] = rad_to_deg(angle)
		
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
		print("Received input from player %d: %s" % [sender_id, str(sender_input)])
