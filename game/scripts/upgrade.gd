extends Control

@onready var sprite: Sprite2D = $TextureButton/Sprite2D
@onready var name_label: Label = $NameLabel
@onready var level_label: Label = $LevelLabel
@onready var button: TextureButton = $TextureButton

@onready var panel: Node2D = $Panel

@onready var rect: ColorRect = $Panel/ColorRect

@onready var corner_sprites: Node2D = $Panel/CornerSprites
@onready var sprite_corners: Array = corner_sprites.get_children()
var corner_origin_pos: Array

@export var type: TYPE

@onready var scale_tween: Tween
var scale_factor: float = 1.0

enum TYPE {DAMAGE, HEALTH}

func _ready() -> void:
	match type:
		TYPE.DAMAGE:
			sprite.texture = preload("res://graphics/UI/icons/damage.png")
			name_label.text = "DAMAGE"
		TYPE.HEALTH:
			sprite.texture = preload("res://graphics/UI/icons/heart.png")
			name_label.text = "HEALTH"
	
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
