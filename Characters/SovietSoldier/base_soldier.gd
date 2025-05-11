extends AnimatableBody2D
class_name BaseGuard

# Exported Properties (editable per instance in the editor)
@export var patrol_points: Array[Vector2] = []
@export var movement_speed: float = 50.0
@export var wait_time: float = 1.5
@export var max_view_distance: float = 200.0
@export var fov_angle: float = 30.0 # degrees

# Internal State
var path = []
var current_target_index = 1
var is_waiting = false
var wait_timer = 0.0
var footstep_timer = 0.0
var idle_animation_phase = 0
var idle_animation_timer = 0.0
var facing_direction = Vector2.DOWN
var player_detected = false

func _ready():
	configure()
	$AnimatedSprite2D.play("idle")
	$ExclamationMark.visible = false
	$AnimatedSprite2D.frame_changed.connect(play_step_sound)

# Override this in child classes to customize guard behavior
func configure():
	path = []
	current_target_index = 0
	facing_direction = Vector2.DOWN
	
func _physics_process(delta):
	# Get player reference and check detection
	var player = get_tree().get_first_node_in_group("player")
	check_player_detection(player)
	
	# Update facing direction and handle movement
	if !is_waiting:
		# When moving, face the movement direction
		var next_index = current_target_index % path.size()
		facing_direction = (path[next_index] - global_position).normalized()
	
	# Update the FOV based on current facing direction
	update_fov_cone()
	
	# Handle waiting at waypoints
	if is_waiting:
		handle_waiting(delta)
		return
	
	move_along_path(delta)

func check_player_detection(player):
	if player and can_see_player(player):
		if !player_detected:
			# Player just detected - show exclamation
			$ExclamationMark.visible = true
			player_detected = true
			if has_node("AlertPlayer"):
				$AlertPlayer.play()
	else:
		# Player not detected - hide exclamation
		$ExclamationMark.visible = false
		player_detected = false

# Override this in child classes for custom idle behavior
func handle_waiting(delta):
	footstep_timer = 0.0
	wait_timer -= delta
	if wait_timer <= 0.0:
		is_waiting = false
	else:
		# Default idle behavior
		$AnimatedSprite2D.play("idle")

func move_along_path(delta):
	# Skip if path is empty
	if path.size() == 0:
		return
		
	# Loop back to the start when reached all points
	if current_target_index >= path.size():
		current_target_index = 0
		facing_direction = (path[0] - global_position).normalized()
	
	# Calculate path intention
	var target = path[current_target_index]
	var direction = (target - global_position).normalized()
	var distance_to_move = movement_speed * delta
	var distance_to_target = global_position.distance_to(target)
	
	if distance_to_target <= distance_to_move:
		# If the character has reached a point
		global_position = target
		current_target_index += 1
		is_waiting = true
		wait_timer = wait_time
	else:
		# Move character
		global_position += direction * distance_to_move
		update_animation(direction)

func can_see_player(player: Node2D) -> bool:
	var to_player = player.global_position - global_position
	if to_player.length() > max_view_distance:
		return false

	# Use current facing direction to calculate polygon angle
	var angle = facing_direction.angle_to(to_player.normalized())
	if abs(rad_to_deg(angle)) > fov_angle:
		return false

	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.exclude = [self]
	query.collision_mask = 1
	var result = space.intersect_ray(query)
	if result and result.collider != player:
		return false
	return true

func update_fov_cone():
	var points = []
	var half_fov = deg_to_rad(fov_angle)
	var start_angle = facing_direction.angle() - half_fov
	var end_angle = facing_direction.angle() + half_fov
	
	points.append(Vector2.ZERO) # Origin at guard
	
	# Create rays for FOV segments
	var space = get_world_2d().direct_space_state
	var segments = 20
	
	for i in range(segments + 1):
		var angle = lerp(start_angle, end_angle, float(i) / segments)
		var ray_end = global_position + Vector2.RIGHT.rotated(angle) * max_view_distance
		
		# Cast ray to check for walls
		var query = PhysicsRayQueryParameters2D.create(global_position, ray_end)
		query.exclude = [self]
		query.collision_mask = 1
		var result = space.intersect_ray(query)
		
		if result:
			# Ray hit a wall, use the collision point
			points.append(result.position - global_position)
		else:
			# No wall, use maximum distance
			points.append(ray_end - global_position)
	
	$ConeOfVision.polygon = points

func update_animation(direction):
	# Set animation based on movement direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			$AnimatedSprite2D.play("right")
			facing_direction = Vector2.RIGHT
		else:
			$AnimatedSprite2D.play("left")
			facing_direction = Vector2.LEFT
	else:
		if direction.y > 0:
			$AnimatedSprite2D.play("down")
			facing_direction = Vector2.DOWN
		else:
			$AnimatedSprite2D.play("up")
			facing_direction = Vector2.UP

func play_step_sound():
	var animation = $AnimatedSprite2D.animation
	var current_frame = $AnimatedSprite2D.frame
	
	if animation in ["up", "down", "left", "right"] and current_frame in [1, 3]:
		if has_node("FootstepPlayer"):
			$FootstepPlayer.pitch_scale = randf_range(0.9, 1.1)
			$FootstepPlayer.play()
