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
@export var catch_distance: float = 30.0

@onready var footstepPlayer: AudioStreamPlayer2D = $FootstepPlayer
@export var footstep_sounds: Array[AudioStream] = []
var footstep_cooldown := 0.8
var footstep_timer := 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export_node_path var teleport_points_parent_path: NodePath

@onready var flashlight: PointLight2D = $"../Player/flashlight"
@export var flashlight_range: float = 400.0
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
		return false
	
	# Check distance
	var distance = global_position.distance_to(flashlight.global_position)
	if distance > flashlight_range:
		return false
	
	# Check angle - is monster within the flashlight cone?
	var flashlight_direction = Vector2.RIGHT.rotated(flashlight.global_rotation)
	var to_monster = (global_position - flashlight.global_position).normalized()
	var angle = flashlight_direction.angle_to(to_monster)
	
	# Convert cone angle to radians and check if within cone
	var in_cone = abs(angle) <= deg_to_rad(flashlight_cone_angle)
	return in_cone
	
func _physics_process(delta: float) -> void:
	if global_position.distance_to(player.global_position) < catch_distance:
		game_over()
		return
		
	if is_in_flashlight():
		velocity = Vector2.ZERO
		monster.animation = "Idle" 
		monster.stop()        
		return
		
	monster.play()
	var next_point = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_point)
	velocity = direction * SPEED
	move_and_slide()
	
	footstep_timer -= delta
	if footstep_timer <= 0:
			play_footstep()
			footstep_timer = footstep_cooldown
	
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
	monster.animation = "Idle"
	monster.play()

func game_over():
	get_tree().paused = true
	if player.has_node("AnimatedSprite2D"):
		var player_sprite = player.get_node("AnimatedSprite2D")
		player_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
		player_sprite.play("death")
		
	if player.has_node("DeathSound"):
		var death_sound = player.get_node("DeathSound")
		death_sound.play()

	await get_tree().create_timer(2.0, true, false, true).timeout # 2 seconds - adjust as needed
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
