extends Node2D

var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
var rng = RandomNumberGenerator.new()

var current_target_letter = ""
var current_key_instance = null

func _ready():
	rng.randomize()
	# Подключаем таймер (предполагается, что у вас есть узел Timer с именем "Timer")
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()  # Запускаем таймер
	spawn_new_button()

func get_random_letter():
	var random_index = rng.randi_range(0, letters.size() - 1)
	return letters[random_index]

func spawn_new_button():
	# Удаляем предыдущую кнопку, если она существует
	if current_key_instance != null and is_instance_valid(current_key_instance):
		current_key_instance.queue_free()
	
	# Генерируем новую целевую букву (ОДИН раз!)
	current_target_letter = get_random_letter()
	
	# Загружаем сохраненную сцену с клавишей
	var button_green_scene = preload("res://scenes/button_green.tscn")
	
	# Создаем экземпляр (копию) этой сцены
	current_key_instance = button_green_scene.instantiate()
	
	# Добавляем этот экземпляр на сцену, чтобы он стал видимым
	add_child(current_key_instance)
	
	# Находим узел Label внутри экземпляра и задаем ему текст
	var label_node = current_key_instance.get_node("Texture/Text")
	label_node.text = current_target_letter  # Используем ЦЕЛЕВУЮ букву!
	
	# Случайная позиция клавиши
	current_key_instance.position = Vector2(
		rng.randf_range(-640/2 + 64, 640/2 - 64),
		rng.randf_range(-480/2 + 64, 480/2 - 64)
	)
	
	print("Новая цель: ", current_target_letter)

func kill_button_by_name():
	if current_key_instance != null and is_instance_valid(current_key_instance):
		# Можно добавить анимацию исчезновения
		var tween = create_tween()
		tween.tween_property(current_key_instance, "modulate:a", 0.0, 0.3)
		tween.tween_callback(_actually_remove_button)
	else:
		current_target_letter = ""

func _actually_remove_button():
	if current_key_instance != null:
		current_key_instance.queue_free()
		current_key_instance = null
	current_target_letter = ""

func _input(event):
	# Обрабатываем только если есть целевая буква
	if current_target_letter != "":
		if event is InputEventKey and event.pressed and not event.echo:
			# Преобразуем код клавиши в символ
			var pressed_letter = char(event.keycode).to_lower()
			
			# Проверяем совпадение с целевой буквой
			if pressed_letter == current_target_letter:
				print("Верно! Нажата клавиша '", pressed_letter, "'")
				$Timer.start()
				kill_button_by_name()
				# Сразу создаем новую цель
				spawn_new_button()
			else:
				print("Неверно! Вы нажали '", pressed_letter, "', а нужно '", current_target_letter, "'")

func _on_timer_timeout():
	print("Время вышло для буквы: ", current_target_letter)
	kill_button_by_name()
	spawn_new_button()
