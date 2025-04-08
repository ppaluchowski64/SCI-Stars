extends CharacterBody2D

@onready var healthbar_fill: ColorRect = $Healthbar/ColorRect
@onready var healthbar_label: Label = $Healthbar/LabelParent/Label

var max_health: float = 3000.0
var health: float = max_health

func update_ui() -> void:
	healthbar_fill.size.x = lerp(healthbar_fill.size.x, health / max_health * 56, Const.STATUS_BAR_SMOOTHNESS)

func take_damage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		queue_free()
	
	healthbar_label.text = str(int(health))

func _process(_delta: float) -> void:
	update_ui()
