extends CharacterBody2D

const SPEED = 100
@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D

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
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction_y != 0:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
