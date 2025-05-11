extends Control

func _ready():
	# Connect button signals to their respective functions
	$MarginContainer/VBoxContainer2/MenuOptions/NewGame.pressed.connect(_on_PlayButton_pressed)
	$MarginContainer/VBoxContainer2/MenuOptions/ExitGame.pressed.connect(_on_ExitButton_pressed)

func _on_PlayButton_pressed():
	# Use the SceneManager to go to the first text scene
	SceneManager.go_to_text_scene_1()

# Quit the game
func _on_ExitButton_pressed():
	get_tree().quit()
