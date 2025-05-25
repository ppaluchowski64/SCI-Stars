extends Node2D

@onready var Upgrade = preload("res://scenes/upgrade.tscn")

@onready var upgrade_interface: CanvasLayer = $UpgradeInterface
@onready var character_select_interface: CanvasLayer = $CharacterSelectInterface
@onready var settings_interface: CanvasLayer = $SettingsInterface
@onready var upgrade_parent: HBoxContainer = $UpgradeInterface/Buttons
@onready var money_label: Label = $ReasourcesInterface/HBoxContainer/CoinsContainer/MarginContainer/Label

@onready var character_sprite: Sprite2D = $UserInterface/CharacterContainer/SpriteParent/Sprite2D
@onready var character_label: Label = $UserInterface/CharacterContainer/CharacterLabel/LabelParent/Label

@onready var tokens_label: Label = $ReasourcesInterface/HBoxContainer/TokensContainer/MarginContainer/Label
@onready var loot_box_label: Label = $UserInterface/MarginContainer/LootBox/Label

@onready var settings_buttons: VFlowContainer = $SettingsInterface/ButtonsContainer
@onready var volume: Control = $SettingsInterface/VolumeContainer
@onready var language: Control = $SettingsInterface/LanguageContainer
@onready var credits: MarginContainer = $SettingsInterface/CreditsContainer
@onready var resolution_container: VBoxContainer = $SettingsInterface/ResolutionContainer
@onready var controls_container: Control = $SettingsInterface/ControlsContainer

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
	
	# Sincerely, thanks for this, Duda
	if PlayerData.selected_character == Characters.ID.KATE:
		character_sprite.region_rect.position.x = 82
		character_sprite.region_rect.size.x = 15
	else:
		character_sprite.region_rect.position.x = 65
		character_sprite.region_rect.size.x = 14
		
func _ready() -> void:
	update_upgrades()
	update_selected_character()
	
	money_label.text = "COINS: " + str(int(PlayerData.money))
	tokens_label.text = "PLUGS: " + str(int(PlayerData.tokens))
	
	if PlayerData.tokens >= 100:
		loot_box_label.theme.set_color("font_color", "Label", Color("#75EB75"))
	else:
		loot_box_label.theme.set_color("font_color", "Label", Color("#EB7775"))

func _on_button_play_button_down() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")

func _on_button_upgrade_button_down() -> void:
	upgrade_interface.visible = true

func _on_button_exit_upgrade_button_down() -> void:
	upgrade_interface.visible = false

func _on_button_character_select_button_down() -> void:
	character_select_interface.visible = true
	character_select_interface.selected_character = PlayerData.selected_character
	character_select_interface.change_value = PlayerData.selected_character
	
	character_select_interface.update_labels()

func _on_button_exit_character_select_button_down() -> void:
	character_select_interface.visible = false

func _on_button_loot_box_button_down() -> void:
	if PlayerData.tokens >= 100:
		PlayerData.tokens -= 100
		get_tree().call_deferred("change_scene_to_file", "res://scenes/loot_box.tscn")

func _on_button_settings_button_down() -> void:
	settings_interface.visible = true

func _on_button_exit_settings_button_down() -> void:
	settings_interface.visible = false
	volume.visible = false
	language.visible = false
	credits.visible = false
	resolution_container.visible = false
	controls_container.visible = false
	settings_buttons.visible = true

func _on_button_volume_button_down() -> void:
	settings_buttons.visible = false
	volume.visible = true

func _on_button_language_button_down() -> void:
	settings_buttons.visible = false
	language.visible = true

func _on_button_credits_button_down() -> void:
	settings_buttons.visible = false
	credits.visible = true

func _on_button_resolution_button_down() -> void:
	settings_buttons.visible = false
	resolution_container.visible = true

func _on_button_select_button_down() -> void:
	character_select_interface.visible = false

func _on_button_controls_button_down() -> void:
	settings_buttons.visible = false
	controls_container.visible = true

func _on_check_box_toggled(toggled_on: bool) -> void:
	PlayerData.is_joystick_enabled = toggled_on
