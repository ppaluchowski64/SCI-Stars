extends Node2D

@onready var Upgrade = preload("res://scenes/upgrade.tscn")

@onready var upgrade_interface: CanvasLayer = $UpgradeInterface
@onready var character_select_interface: CanvasLayer = $CharacterSelectInterface
@onready var upgrade_parent: HBoxContainer = $UpgradeInterface/Buttons
@onready var money_label: Label = $ReasourcesInterface/HBoxContainer/CoinsContainer/MarginContainer/Label

@onready var character_sprite: Sprite2D = $UserInterface/CharacterContainer/SpriteParent/Sprite2D
@onready var character_label: Label = $UserInterface/CharacterContainer/CharacterLabel/LabelParent/Label

@onready var tokens_label: Label = $ReasourcesInterface/HBoxContainer/TokensContainer/MarginContainer/Label
@onready var loot_box_label: Label = $UserInterface/MarginContainer/LootBox/Label

func update_upgrades() -> void:
	for upgrade in upgrade_parent.get_children():
		upgrade.queue_free()
	
	var data: Array = UpgradeData.upgrade_data[PlayerData.selected_character]
	var i: int = 0
	
	for stat in data:
		var upgrade = Upgrade.instantiate()
		
		upgrade.stat_id = i
		upgrade.stat_name = stat[0]
		upgrade.description = stat[1]
		upgrade.texture = stat[2]
		upgrade.lobby = self
		
		upgrade_parent.add_child(upgrade)
		
		i += 1

func update_selected_character() -> void:
	character_sprite.texture = Characters.textures[PlayerData.selected_character]
	character_label.text = "CHARACTER: " + Characters.display_names[PlayerData.selected_character]

func _ready() -> void:
	update_upgrades()
	update_selected_character()
	
	money_label.text = "COINS: " + str(int(PlayerData.money))
	tokens_label.text = "PLUGS: " + str(int(PlayerData.tokens))
	
	if PlayerData.tokens >= 100:
		loot_box_label.theme.set_color("font_color", "Label", Color("#8DEB8D"))
	else:
		loot_box_label.theme.set_color("font_color", "Label", Color("#EB8D8B"))

func _on_button_play_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")

func _on_button_upgrade_button_down() -> void:
	upgrade_interface.visible = true

func _on_button_exit_upgrade_button_down() -> void:
	upgrade_interface.visible = false

func _on_button_character_select_button_down() -> void:
	character_select_interface.visible = true

func _on_button_exit_character_select_button_down() -> void:
	character_select_interface.visible = false

# You are about to witness what you won't unsee
func _on_button_select_button_down_pablo() -> void:
	PlayerData.selected_character = Characters.ID.PABLO
	character_select_interface.visible = false
	update_selected_character()
	update_upgrades()

func _on_button_select_button_down_jack() -> void:
	PlayerData.selected_character = Characters.ID.JACK
	character_select_interface.visible = false
	update_selected_character()
	update_upgrades()

func _on_button_loot_box_button_down() -> void:
	if PlayerData.tokens >= 100:
		PlayerData.tokens -= 100
		get_tree().call_deferred("change_scene_to_file", "res://scenes/loot_box.tscn")
