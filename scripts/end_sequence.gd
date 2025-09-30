extends Control

var dialogue_lines_Red = [
	"Professor: Oh, Morgan, this is the best work I've ever seen! You have done great!",
	"Morgan (on the next day): So, I seem to have achieved what I wanted, but I've given up my identity — is that really what I wanted all those years of school???",
	"Maybe I can start over?"
]

var dialogue_lines_Fail = [
	"Professor: Hmm... You seem a bit confused on what you want this paper to be. Maybe try again?",
	"Morgan (on the next day): Okay, I tried to please both him and myself, but honestly, I still feel like I did something wrong... ",
	"Maybe I can make a better choice by going back to the beginning?"
]

var dialogue_lines_Green = [
	"Professor (Morgan's first attempt): Morgan, how many times can you bring me this nonsense? Maybe it's time to do it «right»?",
	"Professor (Morgan's second attempt): Morgan, I already told you I won't accept your work until you do it right.", 
	"Do you think you're special? Do you know how many people like you came before me?",
	"Professor (Morgan's third attempt): Ok, I accept your thesis...",
	"Morgan: What!? I don't believe it?! But what's changed in you since last time?",
	"Professor: Nothing, you just haven't changed, but maybe that's for the best...", 
	"Water breaks through stone not with force, but with consistency. Move on with your life and be yourself."
]


var current_line_index = 0

@onready var credits_label: Label = $CreditsLabel
@onready var dialogue_label: Label = $Textbox/DialogueLabel
@onready var continue_button: Button = $Textbox/ContinueButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialogue_lines = dialogue_lines_Fail
func _ready():
	
	if Global.result == "Red":
		dialogue_lines = dialogue_lines_Red
	elif Global.result == "Green":
		dialogue_lines = dialogue_lines_Green
	else:
		dialogue_lines = dialogue_lines_Fail
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
	else:
		end()

func end():
	var temp = null
	if Global.result == "Red":
		temp = "This is ending 2/3"
	elif Global.result == "Green":
		temp = "This is ending 3/3"
	else:
		temp = "This is ending 1/3"
	credits_label.visible = true
	continue_button.visible = false
	dialogue_label.visible = false
	credits_label.text = temp + "\n" + credits_label.text
	
