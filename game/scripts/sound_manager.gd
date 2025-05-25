extends Node

var attack_sfx_count: int = 1
var attack_sfx: Array

func _ready() -> void:
	for i in range(attack_sfx_count + 1):
		attack_sfx.append(load("res://audio/SFX/characters/attack" + str(i) + ".wav"))
	
	var buttons: Array = get_tree().get_nodes_in_group("button")
	
	for button in buttons:
		button.connect("button_down", _on_button_down)
	
	var character_button: TextureButton = get_tree().get_first_node_in_group("character_button")
	
	if character_button:
		character_button.connect("button_down", _on_character_button_down)

func _on_button_down() -> void:
	GlobalAudio.stream = preload("res://audio/SFX/UI/button.wav")
	GlobalAudio.play()

func _on_character_button_down() -> void:
	GlobalAudio.stream = preload("res://audio/SFX/UI/select_character.wav")
	GlobalAudio.play()
