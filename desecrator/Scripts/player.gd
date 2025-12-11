extends CharacterBody2D

const SPEED = 100
@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $flashlight
@export var flashlightEnabled = true

@onready var current_camera : Camera2D = get_viewport().get_camera_2d()

@onready var treasure_bar = get_node("/root/Game/UI/TreasureBar")
@export var treasureGoal = 100
@export var treasure = 0

@onready var battery_bar = get_node("/root/Game/UI/BatteryBar")
@export var batteryPower = 125
@export var batteryDrain := 5.0

@onready var health_bar = get_node("/root/Game/UI/Health")
@export var health = 100

# Footstep sounds
@onready var footstepPlayer: AudioStreamPlayer2D = $FootstepPlayer
@export var footstep_sounds: Array[AudioStream] = []

# Footstep timer for sound effect
var footstep_cooldown := 0.5
var footstep_timer := 0.0

#digging
var current_interactable = null
var camShakePower = 0
var camShakeDecay = 10

func game_over():
	get_tree().paused = true
	if $"AnimatedSprite2D":
		var player_sprite = $"AnimatedSprite2D"
		player_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
		player_sprite.play("death")
		
	if $"DeathSound":
		var death_sound = $"DeathSound"
		death_sound.play()

	await get_tree().create_timer(2.0, true, false, true).timeout # 2 seconds - adjust as needed
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func screenShake(delta): # holy moly this actually works really well lol
	current_camera.offset = Vector2(randf_range(-camShakePower, camShakePower),randf_range(-camShakePower, camShakePower))
	camShakePower = max(camShakePower - camShakeDecay * delta, 0)

func takeDamage(dmg):
	health -= dmg
	camShakePower = 10
	if (health <= 0):
		game_over()

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")	
	
	#detecting if digging
	if Input.is_action_pressed("dig") and current_interactable:
		current_interactable.dig(get_physics_process_delta_time())
	
	footstep_timer -= delta
	if treasure_bar:
		treasure_bar.value = treasure
	if health_bar:
		health_bar.value = health
	
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
	if battery_bar:
		battery_bar.value = batteryPower
	screenShake(delta)
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ActionOne"):
		flashlightEnabled = !flashlightEnabled # Probably better to just disable it here but nahhhhhhhhhhhhh

func play_footstep() -> void:
	if footstepPlayer == null:
		return
	if footstep_sounds.size() == 0:
		return
	footstepPlayer.stream = footstep_sounds[randi() % footstep_sounds.size()]
	
	var randomPitch := RandomNumberGenerator.new()
	footstepPlayer.pitch_scale = randomPitch.randf_range(0.9, 1.1)
	
	footstepPlayer.play()


func _on_exit_body_entered(body):
	pass # Replace with function body.
