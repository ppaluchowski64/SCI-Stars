extends Label

@onready var container: Control = get_parent()

# EDIT: they aren't, turns out I was just a dumbass
# EDIT EDIT: honestly, I don't know why did I even touch that
#            it worked just fine and I just had to break it
#            and spend an ungodly amount of time reimplementing it
#            I am not even sure if it's better now...

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	
	var condition = Input.is_action_pressed("ui_click") or Input.is_action_pressed("ui_accept")
	offset_transform_position.y -= delta * Const.CREDITS_SCROLL_SPEED * (4 if condition else 1)
	
	container.custom_minimum_size = DisplayManager.get_actual_display_size() - Vector2.ONE * 224

func _on_button_credits_pressed() -> void:
	offset_transform_position.y = DisplayManager.get_actual_display_size().y / 2 - 80
