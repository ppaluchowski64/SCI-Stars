extends Control

@onready var label: Label = $TextLabel/LabelParent/Label
@onready var particles: CPUParticles2D = $SpriteParent/CPUParticles2D

var amount: float

func setup_particles() -> void:
	var velocity = (Vector2(110, 54) - particles.global_position) / particles.lifetime
	
	particles.direction = velocity.normalized()
	particles.initial_velocity_min = velocity.length()
	particles.emitting = true

func _ready() -> void:
	size.x = label.size.x * 4 + 168
	pivot_offset.x = size.x / 2
	
	label.text = "COINS:\n" + str(int(amount))
