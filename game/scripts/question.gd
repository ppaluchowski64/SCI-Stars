extends Control

@onready var question_label = $Panel/Label
@onready var button_a = $Panel/VBoxContainer/ButtonA
@onready var button_b = $Panel/VBoxContainer/ButtonB
@onready var button_c = $Panel/VBoxContainer/ButtonC
@onready var button_d = $Panel/VBoxContainer/ButtonD

var questions = []
var answers = []
var correct_answers = []
var current_question = {}
var current_answers = {}

func _ready() -> void:
	load_json_data("res://data/questions.json")
	get_random_question()
	set_question()

	button_a.pressed.connect(_on_button_a_pressed)
	button_b.pressed.connect(_on_button_b_pressed)
	button_c.pressed.connect(_on_button_c_pressed)
	button_d.pressed.connect(_on_button_d_pressed)

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
		else:
			print("Error while loading JSON file")
	else:
		print("Error while loading JSON file")

func load_question(question_id: int) -> void:
	current_question = {}
	
	for question in questions:
		if question["id"] == question_id:
			current_question = question
			break
	
	current_answers = []
	
	for answer in answers:
		if answer["question_id"] == question_id:
			current_answers.append(answer)

func set_question() -> void:
	question_label.text = current_question["content"]
	button_a.text = current_answers[0]["content"]
	button_b.text = current_answers[1]["content"]
	button_c.text = current_answers[2]["content"]
	button_d.text = current_answers[3]["content"]

func get_random_question() -> void:
	var random_index = randi() % questions.size()
	var random_question = questions[random_index]
	load_question(random_question["id"])

func _on_button_a_pressed() -> void:
	check_answer("a")

func _on_button_b_pressed() -> void:
	check_answer("b")

func _on_button_c_pressed() -> void:
	check_answer("c")

func _on_button_d_pressed() -> void:
	check_answer("d")

func check_answer(answer_id: String) -> void:
	var correct_answer_id = ""
	
	for correct in correct_answers:
		if correct["question_id"] == current_question["id"]:
			correct_answer_id = correct["answer_id"]
			break
	
	if answer_id == correct_answer_id:
		print("Correct answer!")
	else:
		print("Wrong answer!")
