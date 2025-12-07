extends CharacterBody2D

const SPEED = 100
@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $flashlight
@onready var battery_bar = get_node("/root/Game/UI/BatteryBar")
@onready var treasure_bar = get_node("/root/Game/UI/TreasureBar")

@export var flashlightEnabled = true
@export var flashlightToggled = true

var treasureGoal = 100
var treasure = 0

var batteryPower = 100
@export var batteryDrain := 5.0

# Footstep sounds
@onready var footstepPlayer: AudioStreamPlayer2D = $FootstepPlayer
@export var footstep_sounds: Array[AudioStream] = []

# Footstep timer for sound effect
var footstep_cooldown := 0.5
var footstep_timer := 0.0

#digging
var current_interactable = null

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	
	treasure_bar.value = treasure
	
	#detecting if digging
	if Input.is_action_pressed("dig") and current_interactable:
		current_interactable.dig(get_physics_process_delta_time())
	
	footstep_timer -= delta
	
	# Flip sprite
	if direction_x > 0:
		playerSprite.flip_h = false
	elif direction_x < 0:
		playerSprite.flip_h = true
	
	if direction_x == 0 and direction_y == 0:
		playerSprite.play("idle")
	else:
		playerSprite.play("walk")
		if footstep_timer <= 0:
			play_footstep()
			footstep_timer = footstep_cooldown
		
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
	
	if flashlightToggled:
		if flashlightEnabled:
			flashlight.enabled = true
			if batteryPower > 0:
				batteryPower -= batteryDrain  * delta
			if batteryPower <= 0:
				batteryPower = 0
				flashlightEnabled = false
				flashlight.enabled = false
			if flashlightEnabled:
				flashlight.look_at(get_global_mouse_position())
		else:
			flashlight.enabled = false
	else:
		flashlightEnabled = false # Put this here, so that it will have to be turned back in sory
		flashlight.enabled = false
	
	battery_bar.value = batteryPower
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ActionOne"):
		flashlightEnabled = !flashlightEnabled # Probably better to just disable it here but nahhhhhhhhhhhhh

func play_footstep() -> void:
	if footstepPlayer == null:
		return
	if footstep_sounds.size() == 0:
		return
	footstepPlayer.stream = footstep_sounds[randi() % footstep_sounds.size()]
	footstepPlayer.play()
