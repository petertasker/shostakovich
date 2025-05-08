extends Node

# Music tracks
var title_music = preload("res://Audio/symphony5moderato.mp3")
var level_music = preload("res://Audio/symphony5moderato.mp3")

# Scene constants
const TITLE_SCENE = "res://Scenes/TitleScreen/title_screen.tscn"
const LEVEL_1_SCENE = "res://Scenes/Level1/level_1.tscn"
var textbox_scenes = [
	"res://Scenes/IntroScenes/TextScene1/text_scene_1.tscn"
	#"res://scenes/textbox_2.tscn",
	#"res://scenes/textbox_3.tscn"
]

# Music player nodes
@onready var music_player_1 = $MusicPlayer1
@onready var music_player_2 = $MusicPlayer2
var active_player = 1
var fade_tween: Tween
var current_music_type = "none"
var current_textbox_index = 0

func _ready():
	MusicManager.play_title_music()


func start_game():
	current_textbox_index = 0
	set_integer_scaling(true)
	get_tree().change_scene_to_file(TITLE_SCENE)


func start_story():
	current_textbox_index = 0
	set_integer_scaling(true)
	get_tree().change_scene_to_file(textbox_scenes[current_textbox_index])


func next_textbox():
	current_textbox_index += 1
	if current_textbox_index < textbox_scenes.size():
		set_integer_scaling(true)
		get_tree().change_scene_to_file(textbox_scenes[current_textbox_index])
	else:
		set_integer_scaling(false)
		get_tree().change_scene_to_file(LEVEL_1_SCENE)



func set_integer_scaling(enabled: bool):
	ProjectSettings.set_setting("display/window/stretch/use_integer_scaling", enabled)
	get_tree().set_screen_stretch(
		ProjectSettings.get_setting("display/window/stretch/mode"),
		ProjectSettings.get_setting("display/window/stretch/aspect"),
		Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	)
