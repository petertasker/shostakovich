extends Camera2D

const ROOM_SIZE = Vector2(640, 360)
const TRANSITION_SPEED = 10.0

# Current room position in grid
var current_room = Vector2(0, 0)
var target_position = Vector2.ZERO
var transitioning = false

func _ready():
	# Initialise camera position
	limit_smoothed = true
	position_smoothing_enabled = true
	position_smoothing_speed = TRANSITION_SPEED
	global_position = current_room * ROOM_SIZE
	target_position = global_position

func _process(delta):
	if transitioning:
		# Check if we've reached the target position (with a small margin of error)
		if global_position.distance_to(target_position) < 5:
			transitioning = false

func change_room(direction: Vector2):
	current_room += direction
	target_position = current_room * ROOM_SIZE
	transitioning = true
	
	# Update camera limits for the new room
	limit_left = int(target_position.x - ROOM_SIZE.x/2)
	limit_right = int(target_position.x + ROOM_SIZE.x/2)
	limit_top = int(target_position.y - ROOM_SIZE.y/2)
	limit_bottom = int(target_position.y + ROOM_SIZE.y/2)
	
	# Force the camera to the new position (smoother transition)
	global_position = target_position
