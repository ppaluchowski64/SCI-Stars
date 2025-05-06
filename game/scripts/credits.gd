extends Node2D

@onready var label: Label = $Label

# Had to set up all of this in code because control nodes are just nasty
func _process(delta: float) -> void:
	if visible:
		label.size.x = get_viewport_rect().size.x / 4 - 60
		
		label.global_position.x = get_viewport_rect().size.x / 2 - label.size.x * 2
		label.position.y = 0
		
		var condition = Input.is_action_pressed("ui_click") or Input.is_action_pressed("ui_accept")
		global_position.y -= delta * Const.CREDITS_SCROLL_SPEED * (4 if condition else 1)

func _on_button_credits_button_down() -> void:
	global_position.y = get_viewport_rect().size.y - 230
