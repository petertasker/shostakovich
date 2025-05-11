extends Control

var click_count := 0
@onready var rect_cover := $Cover1
@onready var polygon_cover_1 := $Cover2
@onready var polygon_cover_2 := $Cover3

func _ready():
	# Ensure all covers are visible at start
	rect_cover.visible = true
	polygon_cover_1.visible = true
	polygon_cover_2.visible = true

func _input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (
		event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
			
		click_count += 1
		match click_count:
			1:
				rect_cover.visible = false
			2:
				polygon_cover_1.visible = false
			3:
				polygon_cover_2.visible = false
			4:
				SceneManager.next_textbox()
