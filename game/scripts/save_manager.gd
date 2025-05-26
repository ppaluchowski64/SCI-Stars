extends Node

var save_on_exit: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_5"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://savedata.save"))
		save_on_exit = false
		
		print("Ereased saved data")
	
	if event.is_action_pressed("exit"):
		confirm_exit()

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	load_data()

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and save_on_exit:
		save_data()
		confirm_exit()

func _on_dialogue_confirm() -> void:
	get_tree().quit()

func confirm_exit() -> void:
	var dialog = ConfirmationDialog.new() 
	
	dialog.title = "Exit" 
	dialog.dialog_text = "Are you sure you want to exit the game?"
	dialog.confirmed.connect(_on_dialogue_confirm)
	
	add_child(dialog)
	
	dialog.popup_centered()
	dialog.show()

func save_stats() -> void:
	var save_file = FileAccess.open("user://statsdata.save", FileAccess.WRITE)
	
	var dict_array: Array
	
	for stat_list in PlayerData.character_stats:
		var inner: Array
		
		for stat in stat_list:
			inner.append(stat.to_dict())
			
		dict_array.append(inner)
	
	var json_string = JSON.stringify(dict_array)
	
	save_file.store_string(json_string)
	save_file.close()

func save_data() -> void:
	var save_file = FileAccess.open("user://savedata.save", FileAccess.WRITE)
	
	var node_data: Dictionary = {
		"money" : PlayerData.money,
		"tokens" : PlayerData.tokens,
		"nickname" : PlayerData.nickname,
		
		"selected_character" : PlayerData.selected_character,
		
		"window_is_fullscreen" : PlayerData.window_is_fullscreen,
		"window_ratio_mode" : PlayerData.window_ratio_mode,
		"window_scale" : PlayerData.window_scale
	}
	
	var json_string = JSON.stringify(node_data)
	
	save_file.store_line(json_string)
	save_file.close()
	
	save_stats()

func load_stats():
	if not FileAccess.file_exists("user://statsdata.save"):
		return
	
	var file = FileAccess.open("user://statsdata.save", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if not parse_result == OK:
		print("Failed to parse stats:", json.error_string)
		return
	
	var dict_array = json.get_data()
	
	PlayerData.character_stats.clear()
	
	for stat_list_dict in dict_array:
		var stat_list = []
		
		for stat_dict in stat_list_dict:
			stat_list.append(PlayerData.Stat.from_dict(stat_dict))
			
		PlayerData.character_stats.append(stat_list)

func load_data() -> void:
	if not FileAccess.file_exists("user://savedata.save"):
		return
	
	var save_file = FileAccess.open("user://savedata.save", FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		for key in json.data.keys():
			PlayerData.set(key, json.data[key])
	
	load_stats()
