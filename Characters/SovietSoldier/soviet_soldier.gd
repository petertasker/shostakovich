extends AnimatableBody2D


@export var MOVEMENT_SPEED = 50.0
@export var WAIT_TIME := 1.0

# Places the guard will stop
var path = [
	Vector2(4, 1) * 16, # Spawn
	Vector2(9, 1) * 16, # Move right, look down
	Vector2(14, 1) * 16, # Move left
	Vector2(9, 1) * 16 # Move left, look down
]

var current_target_index = 1
var is_waiting = false
var wait_timer = 0.0

func _ready():
	set_deferred("global_position", path[0])
	current_target_index = 1
	$AnimatedSprite2D.play("idle")


func _physics_process(delta):
	# Check if the character is idling
	if is_waiting:
		wait_timer -= delta
		# If wait time is up, stop waiting
		if wait_timer <= 0.0:
			is_waiting = false
		else:
			$AnimatedSprite2D.play("idle")
		return
	
	# Loop back to the start when reached all points
	if current_target_index >= path.size():
		current_target_index = 0  
	
	# Calculate path intention
	var target = path[current_target_index]
	var direction = (target - global_position).normalized()
	var distance_to_move = MOVEMENT_SPEED * delta
	var distance_to_target = global_position.distance_to(target)

	if distance_to_target <= distance_to_move:
		# If the character has reached a point
		global_position = target
		# Set movement intention to next point
		current_target_index += 1
		# Start idling
		is_waiting = true
		wait_timer = WAIT_TIME
	else:
		# Character has not reached a point - Move character
		global_position += direction * distance_to_move
		
		# Refresh animation
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				$AnimatedSprite2D.play("right")
			else:
				$AnimatedSprite2D.play("left")
		else:
			if direction.y > 0:
				$AnimatedSprite2D.play("down")
			else:
				$AnimatedSprite2D.play("up")
