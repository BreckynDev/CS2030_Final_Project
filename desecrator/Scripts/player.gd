extends CharacterBody2D

const SPEED = 100
@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $flashlight
@export var flashlightEnabled = true

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	
	# Flip sprite
	if direction_x > 0:
		playerSprite.flip_h = false
	elif direction_x < 0:
		playerSprite.flip_h = true
	
	if direction_x == 0 and direction_y == 0:
		playerSprite.play("idle")
	else:
		playerSprite.play("walk")
		
	# Apply Movement
	if direction_x != 0:
		velocity.x = direction_x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction_y != 0:
		velocity.y = direction_y
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	var newVelocity = velocity.normalized() * SPEED # Diagonal movement makes you faster, this stops it.
	velocity = newVelocity
	move_and_slide()
	
	if flashlightEnabled:
		flashlight.enabled = true
		flashlight.look_at(get_global_mouse_position())
	else:
		flashlight.enabled = false
	
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ActionOne"):
		flashlightEnabled = !flashlightEnabled # Probably better to just disable it here but nahhhhhhhhhhhhh
