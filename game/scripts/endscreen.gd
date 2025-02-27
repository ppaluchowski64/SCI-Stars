extends Node2D

func _on_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/lobby.tscn")
