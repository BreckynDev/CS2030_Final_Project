extends CharacterBody2D

var SPEED: float = 100
var stuck_timer: float = 0.0
var last_position: Vector2
var STUCK_TIME := 3.0
var last_distance_to_player: float = 0.0
var TELEPORT_POINTS: Array[Vector2] = []
var is_teleporting := false

@export var player: Node2D
@onready var monster: AnimatedSprite2D = $AnimatedSprite2D

@onready var footstepPlayer: AudioStreamPlayer2D = $FootstepPlayer
@export var footstep_sounds: Array[AudioStream] = []
var footstep_cooldown := 0.8
var footstep_timer := 0.0

var hitCooldown = 3
var hitTimer = 0
var canHit = true

var flashStunTimer = 0
var flashStunLength = 2

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export_node_path var teleport_points_parent_path: NodePath

@onready var flashlight: PointLight2D = $"../Player/flashlight"
@export var flashlight_range: float = 125.0
@export var flashlight_cone_angle: float = 45.0 

func _ready():
	last_position = global_position
	last_distance_to_player = global_position.distance_to(player.global_position)
	
	var parent = get_node(teleport_points_parent_path)
	for child in parent.get_children():
		if child is Area2D:
			TELEPORT_POINTS.append(child.global_position)
			
func is_in_flashlight() -> bool:
	if not player.flashlightEnabled or flashlight == null:
		#print("Flashlight disabled or null")
		return false
	
	# Check distance
	var distance = global_position.distance_to(flashlight.global_position)
	#print("Distance to flashlight: ", distance, " | Max range: ", flashlight_range)
	if distance > flashlight_range:
		#print("Too far!")
		return false
	
	# Check angle - is monster within the flashlight cone?
	var flashlight_direction = Vector2.RIGHT.rotated(flashlight.global_rotation)
	var to_monster = (global_position - flashlight.global_position).normalized()
	var angle = flashlight_direction.angle_to(to_monster)
	var angle_degrees = rad_to_deg(abs(angle))
	
	#print("Flashlight rotation: ", rad_to_deg(flashlight.global_rotation))
	#print("Angle to monster: ", angle_degrees, " | Max cone angle: ", flashlight_cone_angle)
	
	# Convert cone angle to radians and check if within cone
	var in_cone = abs(angle) <= deg_to_rad(flashlight_cone_angle)
	#print("In cone: ", in_cone)
	return in_cone
	
func _physics_process(delta: float) -> void:
	#if is_in_flashlight():
		#velocity = Vector2.ZERO
		#monster.animation = "Idle" 
		#monster.stop()        
		#return
		
	monster.play()
	var next_point = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_point)
	velocity = direction * SPEED
	if is_in_flashlight():
		velocity = velocity * ((flashStunLength - flashStunTimer) / flashStunLength)
		flashStunTimer += delta
		print(flashStunTimer)
		if flashStunTimer >= flashStunLength:
			teleport_monster()

	else:
		flashStunTimer = max(flashStunTimer - delta, 0)
	move_and_slide()
	
	footstep_timer -= delta
	if footstep_timer <= 0:
			play_footstep()
			footstep_timer = footstep_cooldown
	
	hitTimer -= delta
	var playerDist = global_position.distance_to(player.global_position)
	if playerDist < 25 and hitTimer <= 0: # Do damage and stuff.
		teleport_monster()
		player.takeDamage(25)
		hitTimer = hitCooldown
		
	
	if not is_teleporting:
		var current_distance = global_position.distance_to(player.global_position)
		var progress_stuck = abs(current_distance - last_distance_to_player) < 5.0
		
		if progress_stuck:
			stuck_timer += delta
		else:
			stuck_timer = 0.0
			last_distance_to_player = current_distance
		
		if stuck_timer >= STUCK_TIME:
			teleport_monster()

func path() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	path()

func play_footstep() -> void:
	if footstepPlayer == null:
		return
	if footstep_sounds.size() == 0:
		return
	footstepPlayer.stream = footstep_sounds[randi() % footstep_sounds.size()]
	footstepPlayer.play()

func teleport_monster():
	if TELEPORT_POINTS.is_empty():
		return
	is_teleporting = true
	stuck_timer = 0.0 
	
	monster.animation = "teleport"
	monster.play()
	
	await get_tree().create_timer(0.3).timeout
	
	var nearest_point := TELEPORT_POINTS[0]
	var min_distance := player.global_position.distance_to(TELEPORT_POINTS[0])
	
	for point in TELEPORT_POINTS:
		var dist = player.global_position.distance_to(point)
		if dist < min_distance:
			min_distance = dist
			nearest_point = point
	
	global_position = nearest_point
	last_position = global_position
	last_distance_to_player = global_position.distance_to(player.global_position)
	
	nav_agent.target_position = player.global_position
	velocity = Vector2.ZERO
	
	is_teleporting = false
	flashStunTimer = 0
	monster.animation = "Idle"
	monster.play()
