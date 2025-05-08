extends Node

@onready var music_player_1 = $MusicPlayer1
@onready var music_player_2 = $MusicPlayer2
var active_player = 1
var fade_tween: Tween
var current_music_type = "none"

# Preload music tracks
var title_music = preload("res://Audio/symphony5moderato.mp3")
# TODO: Find Symphony 7 with CC Liscense
var level_music = preload("res://Audio/symphony5moderato.mp3") 

func _ready():
	music_player_1.volume_db = 0
	music_player_2.volume_db = -80
	play_title_music()

func play_title_music():
	if current_music_type != "title":
		play_music(title_music)
		current_music_type = "title"

func play_level_music():
	if current_music_type != "level":
		play_music(level_music)
		current_music_type = "level"

func play_music(stream: AudioStream):
	var next_player = music_player_2 if active_player == 1 else music_player_1
	var current_player = music_player_1 if active_player == 1 else music_player_2
	
	next_player.stream = stream
	next_player.volume_db = -80
	next_player.play()
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(current_player, "volume_db", -80.0, 1.0)
	fade_tween.parallel().tween_property(next_player, "volume_db", 0.0, 1.0)
	
	active_player = 2 if active_player == 1 else 1
	
	await fade_tween.finished
	current_player.stop()

func change_to_textbox_scene(scene_path: String):
	# Just change scene without changing music
	get_tree().change_scene_to_file(scene_path)

# Call when changing to level 1
func change_to_level_scene(scene_path: String):
	# Switch to level music and change scene
	play_level_music()
	get_tree().change_scene_to_file(scene_path)
