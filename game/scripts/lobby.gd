extends Node2D

func _on_button_play_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")
