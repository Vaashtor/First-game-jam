extends Control

var dialogue_lines = [
	"Morgan returned to the dorm in the evening, as usual. He was tired. Studying had been especially draining and consuming him lately.",
	"And it was all because of that damned thesis he'd been writing with that professor he hated. That old coot hadn't accepted his work for months...",
	"This could be because Morgan had been doing his work the way he wanted, not the professor's way. Maybe you could be the one to help Morgan submit his work to the professor?",
	"If you want Morgan's thesis to turn out the way his professor wants it to, press the red buttons. \nIf you want for Morgan to write with his vibe, press only greens."
]

var current_line_index = 0

@onready var dialogue_label: Label = $Textbox/DialogueLabel
@onready var continue_button: Button = $Textbox/ContinueButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	display_current_line()
	continue_button.pressed.connect(_on_continue_pressed)

func display_current_line():
	if current_line_index < dialogue_lines.size():
		dialogue_label.text = dialogue_lines[current_line_index]
		# Optional: Add typewriter effect here
		# animation_player.play("text_appear")

func _on_continue_pressed():
	current_line_index += 1
	if current_line_index < dialogue_lines.size():
		display_current_line()
	elif current_line_index == dialogue_lines.size() + 1:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	else:
		end()

func end():
	# Hide the continue button and show choice buttons
	dialogue_label.visible = false
	continue_button.text = "Begin thesis!"
