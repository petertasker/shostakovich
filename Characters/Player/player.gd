extends CharacterBody2D  

var speed = 100
var animation_player
var current_room = Vector2(0, 0)

func _ready():
	# Get reference to the AnimationPlayer node
	animation_player = $AnimatedSprite2D 
	add_to_group("player")

func _physics_process(delta):
	# Get input direction
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		animation_player.play("right")
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
		animation_player.play("left")
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		animation_player.play("down")
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		animation_player.play("up")
	
	# Handle diagonal movement (prioritise the last pressed direction for animation)
	if direction.length() > 0:
		direction = direction.normalized()
	else:
		# Play idle animation or stop current animation when not moving
		animation_player.stop()
	
	# Set velocity and move
	velocity = direction * speed
	move_and_slide()
