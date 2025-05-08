extends AnimatableBody2D

const MOVEMENT_SPEED = 50.0
const WAIT_TIME := 1.5
const MAX_VIEW_DISTANCE = 200
const FOV_ANGLE = 30 # degrees

# Places the guard will stop
var path = [
	Vector2(9, 4) * 16,
	Vector2(9, 9) * 16,
	Vector2(9, 14) * 16,
	Vector2(9, 9) * 16,
]

var current_target_index = 1 # The index of which path the soldier wants to go to
var is_waiting = false
var wait_timer = 0.0
var footstep_timer = 0.0
var idle_animation_phase = 0
var idle_animation_timer = 0.0

var facing_direction = Vector2.DOWN

var player_detected = false # If player is in Soldiers LOS

func _ready():
	current_target_index = 1
	$AnimatedSprite2D.play("idle")
	$ExclamationMark.visible = false
	facing_direction = Vector2.DOWN
	
	$AnimatedSprite2D.frame_changed.connect(play_step_sound)

	
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

func handle_waiting(delta):
	footstep_timer = 0.0 # Reset footstep timer while idle
	
	if path[current_target_index - 1] == Vector2(9, 9) * 16:
		# Handle idle look sequence at (9,9)
		idle_animation_timer -= delta
		if idle_animation_phase == 0:
			$AnimatedSprite2D.play("idle_left")
			facing_direction = Vector2.LEFT
			idle_animation_timer = 1
			idle_animation_phase = 1
		elif idle_animation_phase == 1 and idle_animation_timer <= 0.0:
			$AnimatedSprite2D.play("idle_right")
			facing_direction = Vector2.RIGHT
			idle_animation_timer = 1
			idle_animation_phase = 2
		elif idle_animation_phase == 2 and idle_animation_timer <= 0.0:
			is_waiting = false
			idle_animation_phase = 0
	else:
		wait_timer -= delta
		if wait_timer <= 0.0:
			is_waiting = false
		else:
			# Use the correct animation based on waypoint
			if current_target_index == 1:  # First point (9,4)
				$AnimatedSprite2D.play("idle_down")
				facing_direction = Vector2.DOWN
			elif current_target_index == 2:  # Second point (9,9)
				$AnimatedSprite2D.play("idle_down")
				facing_direction = Vector2.DOWN
			elif current_target_index == 3:  # Third point (9,14)
				$AnimatedSprite2D.play("idle_up")
				facing_direction = Vector2.UP
			elif current_target_index == 0:  # Last point, looped back to start
				$AnimatedSprite2D.play("idle_up")
				facing_direction = Vector2.UP

func move_along_path(delta):
	# Loop back to the start when reached all points
	if current_target_index >= path.size():
		current_target_index = 0
		facing_direction = (path[0] - global_position).normalized()
	
	# Calculate path intention
	var target = path[current_target_index]
	var direction = (target - global_position).normalized()
	var distance_to_move = MOVEMENT_SPEED * delta
	var distance_to_target = global_position.distance_to(target)
	
	if distance_to_target <= distance_to_move:
		# If the character has reached a point
		global_position = target
		current_target_index += 1
		is_waiting = true
		wait_timer = WAIT_TIME
	else:
		# Move character
		global_position += direction * distance_to_move
		update_animation(direction)
				

func can_see_player(player: Node2D) -> bool:
	var to_player = player.global_position - global_position
	if to_player.length() > MAX_VIEW_DISTANCE:
		return false

	# Use current facing direction to calculate polygon angle
	var angle = facing_direction.angle_to(to_player.normalized())
	if abs(rad_to_deg(angle)) > FOV_ANGLE:
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
	var half_fov = deg_to_rad(FOV_ANGLE)
	var start_angle = facing_direction.angle() - half_fov
	var end_angle = facing_direction.angle() + half_fov
	
	points.append(Vector2.ZERO) # Origin at guard
	
	# Create rays for FOV segments
	var space = get_world_2d().direct_space_state
	var segments = 20
	
	for i in range(segments + 1):
		var angle = lerp(start_angle, end_angle, float(i) / segments)
		var ray_end = global_position + Vector2.RIGHT.rotated(angle) * MAX_VIEW_DISTANCE
		
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
