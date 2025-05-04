extends CharacterBody2D

@onready var Question = preload("res://scenes/question.tscn")
@onready var ShieldFX = preload("res://scenes/FX/shield_fx.tscn")

@onready var question_interface: CanvasLayer = get_tree().get_first_node_in_group("question_interface")
@onready var healthbar_fill: ColorRect = $Healthbar/ColorRect
@onready var healthbar_label: Label = $Healthbar/LabelParent/Label

var max_health: float = 3000.0
var health: float = max_health

func update_ui() -> void:
	healthbar_fill.size.x = lerp(healthbar_fill.size.x, health / max_health * 56, Const.STATUS_BAR_SMOOTHNESS)

func take_damage(damage: int, hitter: Node = null) -> void:
	health -= damage
	
	if health <= 0:
		if hitter:
			if hitter.is_main_player:
				hitter.block_controls = true
				hitter.is_immune = true
				
				var fx = ShieldFX.instantiate()
				hitter.add_child(fx)
				
				var question = Question.instantiate()
				question.player = hitter
				question_interface.add_child(question)
		
		queue_free()
	
	healthbar_label.text = str(int(health))

func _process(_delta: float) -> void:
	update_ui()
