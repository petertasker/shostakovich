extends Control

func _ready():
	# Connect button signals to their respective functions
	$MarginContainer/VBoxContainer2/MenuOptions/NewGame.pressed.connect(_on_PlayButton_pressed)
	$MarginContainer/VBoxContainer2/MenuOptions/ExitGame.pressed.connect(_on_ExitButton_pressed)

func _on_PlayButton_pressed():
	var game_flow_scene = load("res://Scenes/GameFlow/game_flow.tscn")
	var game_flow_instance = game_flow_scene.instantiate()
	get_tree().root.add_child(game_flow_instance)

	await game_flow_instance.ready
	game_flow_instance.start_story()




# Quit the game
func _on_ExitButton_pressed():
	get_tree().quit()
