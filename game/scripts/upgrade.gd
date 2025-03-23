extends Control

@onready var sprite: Sprite2D = $TextureButton/Sprite2D
@onready var name_label: Label = $NameLabel

@export var type: TYPE

enum TYPE {DAMAGE, HEALTH}

func _ready() -> void:
	match type:
		TYPE.DAMAGE:
			sprite.texture = preload("res://graphics/UI/icons/damage.png")
			name_label.text = "DAMAGE"
		TYPE.HEALTH:
			sprite.texture = preload("res://graphics/UI/icons/heart.png")
			name_label.text = "HEALTH"
