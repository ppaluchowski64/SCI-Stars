extends Control

@onready var question_label = $Panel/Label
@onready var button_a = $Panel/VBoxContainer/ButtonA
@onready var button_b = $Panel/VBoxContainer/ButtonB
@onready var button_c = $Panel/VBoxContainer/ButtonC
@onready var button_d = $Panel/VBoxContainer/ButtonD

var questions = []
var answers = []
var correct_answers = []

var current_question_id = -1
var current_answers = []

func _ready() -> void:
	load_json_data("res://data/questions.json")

	var question_text = get_random_question()
	current_question_id = get_question_id(question_text)
	current_answers = get_answers(current_question_id)

	display_question(question_text, current_answers)

func load_json_data(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())

		if parse_result == OK:
			var data = json.get_data()

			questions = data["questions"]
			answers = data["answers"]
			correct_answers = data["correct_answers"]

func get_question(question_id: int) -> String:
	for question in questions:
		if question["id"] == question_id:
			return question["content"]

	return ""

func get_question_id(question_content: String) -> int:
	for question in questions:
		if question["content"] == question_content:
			return question["id"]

	return -1

func get_answers(question_id: int) -> Array:
	var result = []

	for answer in answers:
		if answer["question_id"] == question_id:
			result.append(answer["content"])

	return result

func get_correct_answer(question_id: int) -> String:
	for entry in correct_answers:
		if entry["question_id"] == question_id:
			return entry["answer_id"]

	return ""

func get_random_question() -> String:
	if questions.size() == 0:
		return ""

	var random_index = randi() % questions.size()
	var question_id = questions[random_index]["id"]

	return get_question(question_id)

func check_answer(question_id: int, answer_id: String) -> bool:
	var correct = get_correct_answer(question_id)
	return correct.to_lower() == answer_id.to_lower()

func display_question(question_text: String, answer_options: Array) -> void:
	question_label.text = question_text

	if answer_options.size() >= 4:
		button_a.text = answer_options[0]
		button_b.text = answer_options[1]
		button_c.text = answer_options[2]
		button_d.text = answer_options[3]

func _on_button_a_pressed() -> void:
	handle_answer("a")

func _on_button_b_pressed() -> void:
	handle_answer("b")

func _on_button_c_pressed() -> void:
	handle_answer("c")

func _on_button_d_pressed() -> void:
	handle_answer("d")

func handle_answer(selected_id: String) -> void:
	if check_answer(current_question_id, selected_id):
		print("Correct answer!")
	else:
		var correct = get_correct_answer(current_question_id)
		print("Wrong answer! The correct answer is %s" % correct.to_upper())
