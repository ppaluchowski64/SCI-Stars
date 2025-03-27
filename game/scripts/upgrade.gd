extends Control

@onready var sprite: Sprite2D = $TextureButton/Sprite2D
@onready var name_label: Label = $NameLabel
@onready var level_label: Label = $LevelLabel
@onready var button: TextureButton = $TextureButton

@onready var description_label: Label = $Panel/DescriptionLabel
@onready var accept_button: TextureButton = $Panel/ButtonAccept

@onready var panel: Node2D = $Panel

@onready var rect: ColorRect = $Panel/ColorRect

@onready var corner_sprites: Node2D = $Panel/CornerSprites
@onready var sprite_corners: Array = corner_sprites.get_children()
var corner_origin_pos: Array

@onready var lobby: Node2D

@export var type: TYPE
@export var stat_id: int
@export var description: String
var stat_name: String

var stat: PlayerData.Stat

@onready var scale_tween: Tween
var scale_factor: float = 1.0

enum TYPE {DAMAGE, HEALTH}

func update_values() -> void:
	var cost: float = stat.base_cost * (1.15 ** (stat.level - 1))
	accept_button.get_node("Label").text = str(int(cost))
	
	level_label.text = "LVL " + str(stat.level)
	
	description_label.text = "%s %s\n%s\n%s -> %s" % [stat_name, stat.level, description, int(stat.value), int(stat.value + stat.delta_value)]

func _ready() -> void:
	stat = PlayerData.character_stats[0][stat_id]
	
	match type:
		TYPE.DAMAGE:
			sprite.texture = preload("res://graphics/UI/icons/damage.png")
			stat_name = "DAMAGE"
		TYPE.HEALTH:
			sprite.texture = preload("res://graphics/UI/icons/heart.png")
			stat_name = "HEALTH"
			
	name_label.text = stat_name
	
	update_values()
	
	for corner in sprite_corners:
		corner_origin_pos.append(corner.position)

func _process(_delta: float) -> void:
	var i: int = 0
	
	for corner in sprite_corners:
		corner.position = corner_origin_pos[i] * scale_factor
		
		if i == 4 or i == 6:
			corner.scale.x = (44 * scale_factor - 12) / 7.0
		elif i == 5 or i == 7:
			corner.scale.y = (44 * scale_factor - 12) / 7.0
		
		i += 1
	
	rect.scale.x = (44 * scale_factor - 12) / 28.0
	rect.scale.y = (44 * scale_factor - 12) / 28.0
	
	custom_minimum_size.x = 176 / 2.0 * (1 + scale_factor)
	panel.position.x = (custom_minimum_size.x - 176) / 2.0

func _on_texture_button_button_down() -> void:
	corner_sprites.visible = true
	rect.visible = true
	
	button.visible = false
	name_label.visible = false
	level_label.visible = false
	
	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale_factor", 4.0, 0.5)
	scale_tween.tween_property(description_label, "visible", true, 0.0) # Slick but probably a bad way to do this
	scale_tween.tween_property(accept_button, "visible", true, 0.0)
	
	update_values()

func _on_button_accept_button_down() -> void:
	var cost: float = int(stat.base_cost * (1.15 ** (stat.level - 1)))
	
	if PlayerData.money >= cost:
		PlayerData.money -= cost
		stat.value += stat.delta_value
		stat.level += 1
		
		update_values()
		lobby.money_label.text = "COINS: " + str(int(PlayerData.money))
		
		print("stat upgraded")
	else:
		print("not enough resources")
