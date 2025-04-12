extends Node2D

@onready var LootBoxDrop = preload("res://scenes/loot_box_drop.tscn")

@onready var animation: AnimationPlayer = $ContentLayer/AnimationPlayer
@onready var content: CanvasLayer = $ContentLayer
@onready var coins_label: Label = $ReasourcesInterface/HBoxContainer/CoinsContainer/MarginContainer/Label

@onready var coins_tween: Tween
var coins_tween_dummy: bool = true

@onready var tokens_label: Label = $ReasourcesInterface/HBoxContainer/TokensContainer/MarginContainer/Label

@export var block_click: bool = true

var display_coins: float = PlayerData.money
var drop_n: int = 0

func _ready() -> void:
	coins_label.text = "COINS: " + str(int(PlayerData.money))
	tokens_label.text = "RJ-45: " + str(int(PlayerData.tokens))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_click") and not block_click:
		if drop_n == 0:
			animation.play("open")
			drop_resource(randi_range(80, 120))
			
			drop_n += 1
		else:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/lobby.tscn")
	
	if coins_tween:
		coins_label.text = "COINS: " + str(int(display_coins))

func drop_resource(amount: float) -> void:
	PlayerData.money += amount
	
	var drop = LootBoxDrop.instantiate()
	
	drop.amount = amount
	drop.position.y -= 88
	
	content.add_child(drop)
	
	coins_tween = create_tween()
	
	coins_tween.tween_property(self, "coins_tween_dummy", false, 1.8)
	
	coins_tween.set_trans(Tween.TRANS_CUBIC)
	coins_tween.set_ease(Tween.EASE_OUT)
	coins_tween.tween_property(self, "display_coins", PlayerData.money, 1)
