extends Node2D

var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
var rng = RandomNumberGenerator.new()

@onready var label_score: Label = $Label

var score = 0

var button_count = 2
var current_target_letters = []
var current_key_instances = null
var is_transition_in_progress = false # Флаг для предотвращения конфликтов
var button_scene = null

func _ready():
	score_update()
	rng.randomize()
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()
	spawn_new_buttons()

func score_update():
	label_score.text = "Score = " + str(score)

func get_random_letter():
	var random_index = rng.randi_range(0, letters.size() - 1)
	return letters[random_index]

func spawn_new_buttons():
	if is_transition_in_progress:
		return
	
	is_transition_in_progress = true
	print(1)
	
	# Delete previous buttons if they exist
	if current_key_instances != null:
		for i in range(len(current_key_instances)):
			if is_instance_valid(current_key_instances[i]):
				current_key_instances[i].queue_free()
	print(2)
	# Create new buttons
	
	current_key_instances = []
	var current_target_letter = ""
	current_target_letters = []
	var positions = []
	var break_trigger = false
	print(3)
	for i in range(button_count):
		print("i=",i)
		# generate a letter
		while true:
			# generate a letter that's different from previous
			current_target_letter = get_random_letter()
			if i == 0:
				break
			var c = 0
			# check all existing letters
			for j in range(len(current_target_letters)):
				if current_target_letters[j]!=current_target_letter:
					c += 1
				if c == len(current_target_letters):
					break_trigger = true
			if break_trigger:
				break
		print("first while loop")
		current_target_letters.append(current_target_letter)

		# Load a button scene
		button_scene = preload("res://scenes/button.tscn")
		current_key_instances.append(button_scene.instantiate())
		
		# add a button scene to game scene
		add_child(current_key_instances[i])
		
		# add appropriate texture
		var texture_node = current_key_instances[i].get_node("Texture")
		var new_texture = null
		if i == 0:
			new_texture = load("res://assets/redButton.png")
		else:
			new_texture = load("res://assets/greenButton.png")
		texture_node.texture = new_texture
		
		# Устанавливаем текст
		var label_node = current_key_instances[i].get_node("Texture/Text")
		label_node.text = current_target_letter.to_upper() #make letter capital
		
		# get different random position
		var button_size = [64, 64]
		var x = 0
		var y = 0
		while true:
			# generate random coordinates
			x = rng.randf_range(-640 / 2 + button_size[0], 640 / 2 - button_size[0])
			y = rng.randf_range(-480 / 2 + button_size[1], 480 / 2 - button_size[1])
			var c = 0
			if i ==0:
				break
			# check all existing positions
			for j in range(len(positions)):
				# if new position is not in the range of other buttons
				if not ((positions[j][0] - button_size[0] < x and x < positions[j][0] + button_size[0]) and (positions[j][1] - button_size[1] < y and y < positions[j][1] + button_size[1])) :
					#increase counter
					c += 1
				# if the generated position is different from all the others, use it
				if c == len(positions):
					break_trigger = true
			if break_trigger:
				break
		current_key_instances[i].position = Vector2(x,y)
		print("second while loop")
		positions.append([x,y])
	
	#when all buttons are generated
	print("Новая цель: ", current_target_letters[0], ", ", current_target_letters[1])
	is_transition_in_progress = false
	$Timer.start() # Перезапускаем таймер только после полного создания

func kill_button():
	if is_transition_in_progress:
		return
	
	is_transition_in_progress = true
	if current_key_instances != null:
		for i in range(len(current_key_instances)):
			if is_instance_valid(current_key_instances[i]):
				var tween = create_tween()
				tween.tween_property(current_key_instances[i], "modulate:a", 0.0, 0.2)
				tween.tween_callback(_actually_remove_button)
	else:
		_actually_remove_button()

func _actually_remove_button():
	if current_key_instances != null:
		for i in range(len(current_key_instances)):
			if is_instance_valid(current_key_instances[i]):
				current_key_instances[i].queue_free()
		current_key_instances = null
	current_target_letters = []
	is_transition_in_progress = false

func end_sequence():
	score_update()
	kill_button()
	await get_tree().create_timer(0.25).timeout # Ждем завершения анимации
	spawn_new_buttons()

func _input(event):
	if is_transition_in_progress or current_target_letters == []:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var pressed_letter = char(event.keycode).to_lower()
		
		for i in range(len(current_target_letters)):
			if pressed_letter == current_target_letters[i]:
				print("Верно! Нажата клавиша '", pressed_letter, "'")
				if(i == 1):
					score += 1
				else:
					score -= 1
				end_sequence()

func _on_timer_timeout():
	if not is_transition_in_progress:
		print("Время вышло")
		end_sequence()
