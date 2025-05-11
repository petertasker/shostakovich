extends BaseGuard

const MOVEMENT_SPEED = 50.0
const WAIT_TIME := 1.5
const MAX_VIEW_DISTANCE = 200
const FOV_ANGLE = 30 # degrees

func configure():
	path = [
		Vector2(9, 4) * 16,
		Vector2(9, 9) * 16,
		Vector2(9, 14) * 16,
		Vector2(9, 9) * 16,
	]
	current_target_index = 1
	facing_direction = Vector2.DOWN

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
