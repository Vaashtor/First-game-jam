extends Node2D

var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
var rng = RandomNumberGenerator.new()

@onready var label_score: Label = $Label

var score = 0

var current_target_letter = ""
var current_key_instance = null
var is_transition_in_progress = false # Флаг для предотвращения конфликтов

func _ready():
	score_update()
	rng.randomize()
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()
	spawn_new_button("green")

func score_update():
	label_score.text = "Score = " + str(score)

func get_random_letter():
	var random_index = rng.randi_range(0, letters.size() - 1)
	return letters[random_index]

func spawn_new_button(type):
	if is_transition_in_progress:
		return
	
	is_transition_in_progress = true
	
	# Удаляем предыдущую кнопку, если она существует
	if current_key_instance != null and is_instance_valid(current_key_instance):
		current_key_instance.queue_free()
		current_key_instance = null
	
	# Генерируем новую целевую букву
	current_target_letter = get_random_letter()
	
	# Загружаем сцену с клавишей
	var button_green_scene = preload("res://scenes/button.tscn")
	current_key_instance = button_green_scene.instantiate()
	
	# Добавляем на сцену
	add_child(current_key_instance)
	
	# add appropriate texture
	var texture_node = current_key_instance.get_node("Texture")
	var new_texture = null
	if type == "red":
		new_texture = load("res://assets/redButton.png")
	else: 
		new_texture = load("res://assets/greenButton.png")
	texture_node.texture = new_texture
	
	# Устанавливаем текст
	var label_node = current_key_instance.get_node("Texture/Text")
	label_node.text = current_target_letter.to_upper() #make letter capital
	
	# Случайная позиция
	current_key_instance.position = Vector2(
		rng.randf_range(-640 / 2 + 64, 640 / 2 - 64),
		rng.randf_range(-480 / 2 + 64, 480 / 2 - 64)
	)
	
	print("Новая цель: ", current_target_letter)
	is_transition_in_progress = false
	$Timer.start() # Перезапускаем таймер только после полного создания

func kill_button():
	if is_transition_in_progress:
		return
	
	is_transition_in_progress = true
	
	if current_key_instance != null and is_instance_valid(current_key_instance):
		var tween = create_tween()
		tween.tween_property(current_key_instance, "modulate:a", 0.0, 0.2)
		tween.tween_callback(_actually_remove_button)
	else:
		_actually_remove_button()

func _actually_remove_button():
	if current_key_instance != null:
		current_key_instance.queue_free()
		current_key_instance = null
	current_target_letter = ""
	is_transition_in_progress = false

func end_sequence():
	score_update()
	kill_button()
	await get_tree().create_timer(0.25).timeout # Ждем завершения анимации
	spawn_new_button("green")

func _input(event):
	if is_transition_in_progress or current_target_letter == "":
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var pressed_letter = char(event.keycode).to_lower()
		
		if pressed_letter == current_target_letter:
			print("Верно! Нажата клавиша '", pressed_letter, "'")
			score += 1
			end_sequence()

func _on_timer_timeout():
	if not is_transition_in_progress:
		print("Время вышло для буквы: ", current_target_letter)
		score -= 1
		end_sequence()
