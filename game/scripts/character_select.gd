extends CanvasLayer

@onready var lobby: Node2D = $".."
@onready var characters: ReferenceRect = $LeftContainer/Characters/ReferenceRect
@onready var character_name_label: Label = $LeftContainer/CharacterName/LabelParent/Label
@onready var character_description_label: Label = $RightContainer/Description/LabelParent/Label

var selected_character: Characters.ID = Characters.ID.PABLO

var change_tween: Tween
var change_value: float

func change_character() -> void:
	change_tween = create_tween()
	
	change_tween.set_trans(Tween.TRANS_QUART)
	change_tween.set_ease(Tween.EASE_OUT)
	
	change_tween.tween_property(self, "change_value", selected_character, 1)
	
	update_labels()

func update_labels() -> void:
	character_name_label.text = Characters.display_names[selected_character]
	character_description_label.text = Characters.character_descriptions[selected_character]

func _process(_delta: float) -> void:
	var i: int = 0
	
	for child in characters.get_children():
		child.global_position.x = 324 + 204 * (i - change_value)
		
		var scale_value = 8 + (1 - max(abs(i - change_value), 0)) * 2
		
		child.scale.x = scale_value
		child.scale.y = scale_value
		
		child.global_position.y = get_window().content_scale_size.y / 2
		
		i += 1
	
	characters.size.y = get_window().content_scale_size.y - 240

func _on_button_left_button_down() -> void:
	if selected_character > 0:
		selected_character -= 1
		change_character()

func _on_button_right_button_down() -> void:
	if selected_character < Characters.CHARACTER_COUNT - 1:
		selected_character += 1
		change_character()

func _on_button_select_button_down() -> void:
	PlayerData.selected_character = selected_character
	
	lobby.update_selected_character()
	lobby.update_upgrades()
