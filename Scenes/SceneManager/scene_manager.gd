extends Node
# Add this as another Autoload named "SceneManager"

# Define scene paths
const TITLE_SCENE = "res://Scenes/TitleScreen/title_screen.tscn"
const LEVEL_1_SCENE = "res://scenes/Level1/level_1.tscn"
#const TEXTBOX_1_SCENE = "res://scenes/textbox_1.tscn"
#const TEXTBOX_2_SCENE = "res://scenes/textbox_2.tscn"
#const TEXTBOX_3_SCENE = "res://scenes/textbox_3.tscn"

# Track the current scene type
enum SceneType { TITLE, TEXTBOX, LEVEL }
var current_scene_type = SceneType.TITLE

func go_to_title():
	current_scene_type = SceneType.TITLE
	$MusicManager.play_title_music()
	get_tree().change_scene_to_file(TITLE_SCENE)

func go_to_level_1():
	current_scene_type = SceneType.LEVEL
	$MusicManager.play_level_music()
	get_tree().change_scene_to_file(LEVEL_1_SCENE)

func go_to_textbox_1():
	current_scene_type = SceneType.TEXTBOX
	# Keep current music playing
	get_tree().change_scene_to_file(TEXTBOX_1_SCENE)

func go_to_textbox_2():
	current_scene_type = SceneType.TEXTBOX
	# Keep current music playing
	get_tree().change_scene_to_file(TEXTBOX_2_SCENE)

func go_to_textbox_3():
	current_scene_type = SceneType.TEXTBOX
	# Keep current music playing
	get_tree().change_scene_to_file(TEXTBOX_3_SCENE)

func next_textbox():
	# This handles progressing through textboxes sequentially
	var current_scene = get_tree().current_scene.scene_file_path
	
	match current_scene:
		TEXTBOX_1_SCENE:
			go_to_textbox_2()
		TEXTBOX_2_SCENE:
			go_to_textbox_3()
		TEXTBOX_3_SCENE:
			go_to_level_1()
		_:
			# Fallback - go to level 1
			go_to_level_1()
