extends Node

# Define scene paths
const TITLE_SCENE = "res://Scenes/TitleScreen/title_screen.tscn"
const TEXT_SCENE_1 = "res://Scenes/IntroScenes/TextScene1/text_scene_1.tscn"
const LEVEL_1_SCENE = "res://Scenes/Level1/level_1.tscn"

# Track the current scene type
enum SceneType { TITLE, TEXTBOX, LEVEL }
var current_scene_type = SceneType.TITLE

func _ready():
	# Initialize anything needed when the autoload starts
	pass

func go_to_title():
	current_scene_type = SceneType.TITLE
	# Check if MusicManager exists before trying to access it
	if has_node("MusicManager"):
		$MusicManager.play_title_music()
	get_tree().change_scene_to_file(TITLE_SCENE)

func go_to_level_1():
	current_scene_type = SceneType.LEVEL
	if has_node("MusicManager"):
		$MusicManager.play_level_music()
	get_tree().change_scene_to_file(LEVEL_1_SCENE)

func go_to_text_scene_1():
	current_scene_type = SceneType.TEXTBOX
	# Keep current music playing
	get_tree().change_scene_to_file(TEXT_SCENE_1)

func next_textbox():
	# Since there's only one text scene, always go to level 1
	var current_scene = get_tree().current_scene.scene_file_path
	
	if current_scene == TEXT_SCENE_1:
		go_to_level_1()
	else:
		# Fallback - go to level 1
		go_to_level_1()
