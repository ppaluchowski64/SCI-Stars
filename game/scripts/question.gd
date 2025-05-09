extends Control

@onready var question_label = $Panel/Content
@onready var button_a = $Panel/Answers/ButtonA
@onready var button_b = $Panel/Answers/ButtonB
@onready var button_c = $Panel/Answers/ButtonC
@onready var button_d = $Panel/Answers/ButtonD

@onready var tcp = StreamPeerTCP.new()
@onready var handler = MessageHandler.new()

var is_connected = false
var current_question_id = -1
var current_answers = []
var buffer_text = ""

var player: Node2D
var  answer: String

@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var correctness: Label = $Panel/Correctness
@onready var progress_tween: Tween

func exit_question(is_answer_correct: bool = false) -> void:
	if player:
		player.block_controls = false
		player.immunity_timer.start()
		
		if is_answer_correct:
			player.max_health += 600
			player.regen_cooldown.start(1)
			player.damage_multiplier += 0.3
		else:
			for other in player.get_parent().get_children():
				if other.is_in_group("player") and other != player:
					other.max_health += 600
					other.regen_cooldown.start(1)
					other.damage_multiplier += 0.3
	
	queue_free()

func _ready() -> void:
	call_deferred("_start_connection")
	set_process(true)
	
	progress_tween = create_tween()
	progress_tween.tween_property(progress_bar, "value", 0, Const.QUESTION_ANSWER_TIME)
	progress_tween.tween_callback(exit_question)
	
	correctness.visible = false
	progress_bar.show_percentage = true

func _start_connection() -> void:
	var error = tcp.connect_to_host("127.0.0.1", 12345)

	if error != OK:
		push_error("Connection error: %d" % error)
	else:
		print("Connection attempt sent")

func _process(_delta: float) -> void:
	tcp.poll()
	
	if not is_connected and tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		is_connected = true
		print("Connected to the server!")
		request_random_question()
	
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
				var newline_index = buffer_text.find("\n")
				var line = buffer_text.substr(0, newline_index)
				buffer_text = buffer_text.substr(newline_index + 1)
				
				handle_server_response(line)

func request_random_question() -> void:
	var request = handler.create_message("request", "get_random_question")

	if request != null:
		tcp.put_data(request.to_utf8_buffer())
		print("Requesting a random question from the server")

func submit_answer(selected_id: String) -> void:
	progress_tween.kill()
	progress_bar.value = progress_bar.max_value
	answer = selected_id
	
	if not is_connected:
		push_error("Not connected to the server")
		return
	
	var submit = handler.create_message("request", "submit_answer", {
		"question_id": current_question_id,
		"answer": selected_id
	})
	
	if submit != null:
		tcp.put_data(submit.to_utf8_buffer())
		print("Submitted answer %s" % selected_id.to_upper())
	
	disable_all_buttons()

func handle_server_response(response_text: String) -> void:
	var response = handler.parse_message(response_text)

	if response == null:
		push_error("JSON parsing error: %s" % response_text)
		return

	if response.type == "response" and response.command == "get_random_question":
		current_question_id = response.payload.question_id
		current_answers = response.payload.answers
		display_question(response.payload.question, current_answers)

	elif response.type == "response" and response.command == "submit_answer":
		if response.payload.has("correct"):
			display_check_result(answer, response.payload.correct_answer)
			await get_tree().create_timer(3.0).timeout
			exit_question(answer == response.payload.correct_answer)
	
	else:
		push_error("Unexpected response: %s" % response_text)
		is_connected = false
		tcp.disconnect_from_host()

func disable_all_buttons() -> void:
	var buttons = [
		button_a,
		button_b,
		button_c,
		button_d
	]
	
	for button in buttons:
		button.disabled = true

func display_check_result(selected: String, correct: String) -> void:
	var buttons = {
		"a": button_a,
		"b": button_b,
		"c": button_c,
		"d": button_d
	}
	
	for key in buttons.keys():
		var style = buttons[key].get_theme_stylebox("disabled")
		style.set_border_width_all(0)
		
		if key == selected or key == correct:
			style.set_border_width_all(4)
			
			if key == selected and key == correct:
				style.border_color = Color(0, 1, 0)
			elif key == selected and key != correct:
				style.border_color = Color(1, 0, 0)
			elif key == correct:
				style.border_color = Color(0, 1, 0)
			
			buttons[key].add_theme_stylebox_override("disabled", style)
	
	if selected == correct:
		correctness.text = "Correct Answer!"
	else:
		correctness.text = "Wrong Answer!"
	
	progress_bar.show_percentage = false
	correctness.visible = true

func display_question(question_text: String, answer_options: Array) -> void:
	question_label.text = question_text

	if answer_options.size() >= 4:
		button_a.text = answer_options[0]
		button_b.text = answer_options[1]
		button_c.text = answer_options[2]
		button_d.text = answer_options[3]

func _on_button_a_pressed() -> void:
	submit_answer("a")

func _on_button_b_pressed() -> void:
	submit_answer("b")

func _on_button_c_pressed() -> void:
	submit_answer("c")

func _on_button_d_pressed() -> void:
	submit_answer("d")
