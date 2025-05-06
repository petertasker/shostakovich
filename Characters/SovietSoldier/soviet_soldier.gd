extends AnimatableBody2D
# NPC properties
@export var movement_speed = 50.0
@export var side_length = 100.0  # Length of each side of the square
# Path variables
var current_side = 0  # 0: right, 1: down, 2: left, 3: up
var side_progress = 0.0
var start_position = Vector2.ZERO
var target_position = Vector2.ZERO

func _ready():
	# Save initial position
	start_position = global_position
	target_position = global_position
	# Start with right animation
	$AnimatedSprite2D.play("right")

func _physics_process(delta):
	# Calculate target position based on current side
	match current_side:
		0: target_position = start_position + Vector2(side_length, 0)  # Right
		1: target_position = start_position + Vector2(side_length, side_length)  # Down
		2: target_position = start_position + Vector2(0, side_length)  # Left
		3: target_position = start_position  # Up
	
	# Move towards target position
	var direction = (target_position - global_position).normalized()
	var distance_to_move = movement_speed * delta
	var distance_to_target = global_position.distance_to(target_position)
	
	if distance_to_target <= distance_to_move:
		# We've reached the target, move to next corner
		global_position = target_position
		current_side = (current_side + 1) % 4
		
		# Update animation
		match current_side:
			0: $AnimatedSprite2D.play("right")
			1: $AnimatedSprite2D.play("down")
			2: $AnimatedSprite2D.play("left")
			3: $AnimatedSprite2D.play("up")
	else:
		# Move toward target
		global_position += direction * distance_to_move

# Optional debugging: visualize the square path
func _draw():
	# Draw square path (visible in editor)
	var points = [
		Vector2(0, 0),
		Vector2(side_length, 0),
		Vector2(side_length, side_length),
		Vector2(0, side_length),
		Vector2(0, 0)
	]

# Call queue_redraw() if you modify side_length at runtime
func _on_side_length_changed():
	queue_redraw()
