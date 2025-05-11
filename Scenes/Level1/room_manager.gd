extends Node2D

const ROOM_SIZE = Vector2(640, 360)
var current_room = Vector2(0, 0)
@onready var camera = $Camera2D
@onready var player = $Player

signal room_changed(old_room, new_room)
var initialized = false

func _ready():
	# Position the player at the center of the starting room
	player.global_position = current_room * ROOM_SIZE + ROOM_SIZE/2
	
	# Force the camera to match exactly
	camera.global_position = player.global_position
	
	# Disable smoothing temporarily
	var original_smoothing = camera.position_smoothing_enabled
	camera.position_smoothing_enabled = false
	
	# Set camera limits for the starting room
	update_camera_limits()
	
	# Delay activation to avoid initial movement detection
	set_process(false)
	await get_tree().process_frame
	initialized = true
	camera.position_smoothing_enabled = original_smoothing
	set_process(true)

func _process(delta):
	if !initialized:
		return
		
	# Check if player has moved to a new room
	var player_grid_pos = Vector2(
		floor(player.global_position.x / ROOM_SIZE.x),
		floor(player.global_position.y / ROOM_SIZE.y)
	)
	
	if player_grid_pos != current_room:
		var old_room = current_room
		current_room = player_grid_pos
		change_room(old_room, current_room)

func change_room(old_room, new_room):
	# Calculate camera position for new room
	var target_position = new_room * ROOM_SIZE + ROOM_SIZE/2
	
	# Use tween for smooth transition
	var tween = create_tween()
	tween.tween_property(camera, "global_position", target_position, 0.5)
	
	# Update camera limits
	update_camera_limits()
	
	# Signal that the room has changed
	emit_signal("room_changed", old_room, new_room)

func update_camera_limits():
	# Set camera limits for the current room
	camera.limit_left = int(current_room.x * ROOM_SIZE.x)
	camera.limit_top = int(current_room.y * ROOM_SIZE.y)
	camera.limit_right = int(current_room.x * ROOM_SIZE.x + ROOM_SIZE.x)
	camera.limit_bottom = int(current_room.y * ROOM_SIZE.y + ROOM_SIZE.y)
