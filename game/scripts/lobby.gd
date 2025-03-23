extends Node2D

@onready var upgrade_interface: CanvasLayer = $UpgradeInterface

func _on_button_play_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")

func _on_button_upgrade_button_down() -> void:
	upgrade_interface.visible = true

func _on_button_exit_upgrade_button_down() -> void:
	upgrade_interface.visible = false
