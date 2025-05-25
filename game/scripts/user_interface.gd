extends CanvasLayer

@onready var player_count: Label = $PlayerCount/Label
@export var players: Node2D

@onready var superbar_fill: ColorRect = $MarginContainer/SuperBar/Mask/ColorRect
@onready var superbar_particles_mask: ColorRect = $MarginContainer/SuperBar/ParticleMask
@onready var superbar_particles: CPUParticles2D = $MarginContainer/SuperBar/ParticleMask/CPUParticles2D
@onready var superbar_icon: Sprite2D = $MarginContainer/SuperBar/Icon

@onready var superbar_container: MarginContainer = $MarginContainer

@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var move_joystick: VirtualJoystick = $MoveJoystick
@onready var attack_joystick: VirtualJoystick = $AttackJoystick

var main_player: Node
var superbar_icon_modulate: float = 0.3
var last_player_super_charge: float = 0.0

func update_player_count(count: int) -> void:
	player_count.text = "Players left: %s" % count

func _ready() -> void:
	if PlayerData.is_joystick_enabled:
		superbar_container.add_theme_constant_override("margin_bottom", 332)
	else:
		move_joystick.visible = false
		attack_joystick.visible = false

func _process(_delta: float) -> void:
	if main_player:
		if main_player.super_charge >= 1.0:
			animation.play("super_charged")
		elif main_player.super_charge != last_player_super_charge:
			animation.play("super_gain")
			last_player_super_charge = main_player.super_charge
		
		var size = clamp(main_player.super_charge * 224.0, 0.0, 224.0)
		superbar_icon_modulate = lerp(superbar_icon_modulate, 0.3 + 0.7 * main_player.super_charge, Const.STATUS_BAR_SMOOTHNESS)
		
		superbar_fill.size.x = lerp(superbar_fill.size.x, size, Const.STATUS_BAR_SMOOTHNESS)
		superbar_particles_mask.size.x = lerp(superbar_fill.size.x, size, Const.STATUS_BAR_SMOOTHNESS) + 64
		
		superbar_particles.emitting = main_player.super_charge > 0
		
		superbar_icon.self_modulate = Color(superbar_icon_modulate, superbar_icon_modulate, superbar_icon_modulate)
